//
//  CameraModule.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/9/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import ImageIO
import MobileCoreServices

class CameraModule: NSObject, ModuleProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session: AVCaptureSession?
    let connector: RabbitConnector
    var device: AVCaptureDevice?
    var cameraStatistics = CameraDeviceStatistics()
    var inputDevice: AVCaptureDeviceInput?
    var dataOutput: AVCaptureVideoDataOutput?
    
    var statistics: [StatisticsItem] {
        get {
            return [cameraStatistics]
        }
    }
    
    var settings: [ModuleSettingProtocol] { get { return [cameraSettings as ModuleSettingProtocol] } }
    var cameraSettings: CameraModuleSettings!
    
    init(connector: RabbitConnector, cameraPosition: AVCaptureDevicePosition) {
        self.connector = connector
        super.init()
        
        cameraSettings = CameraModuleSettings(defaultExchangeName: "camera") {
            self.changeHandler(parameter: $0)
        }
        
        if let session = prepareCaptureSession() {
            self.session = session
        }
    }
    
    func start() {
        guard let session = self.session else {
            return
        }
        session.startRunning()
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    func stop() {
        guard let session = self.session else { return }
        session.stopRunning()
        
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    func orientationChanged() {
        let shouldAdjust = cameraSettings.adjustDeviceOrientationSettingItem.switchStatus
        let isRunning = session?.isRunning ?? false
        
        if (isRunning && shouldAdjust) || !isRunning {
            let connection: AVCaptureConnection! = dataOutput?.connection(withMediaType: AVMediaTypeVideo)
            if connection.isVideoOrientationSupported {
                let orientation = UIDevice.current.orientation
                connection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue)!
            } else {
                print("Orientation not supported")
            }
        }
    }
    
    private func prepareCaptureSession() -> AVCaptureSession? {
        let session = AVCaptureSession()
        
        let preset = AVCaptureSessionPreset640x480
        if session.canSetSessionPreset(preset) {
            session.sessionPreset = preset
            print("Setting session preset")
        } else {
            print("Cannot set session preset")
        }
        
        let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
        let frontCameras = videoDevices.filter { $0.position == .back }
        guard frontCameras.count >= 1 else { return nil }
        let frontCamera = frontCameras[0];
        
        inputDevice = try! AVCaptureDeviceInput.init(device: frontCamera)
        guard session.canAddInput(inputDevice) else {
            cameraStatistics.setFailMessage(message: "Can not add input device")
            return nil
        }
        device = inputDevice!.device
        session.addInput(inputDevice)
        
        dataOutput = AVCaptureVideoDataOutput()
        let outputQueue = DispatchQueue(label: "VideoOutputDataQeueue")
        dataOutput!.setSampleBufferDelegate(self, queue: outputQueue)
        guard session.canAddOutput(dataOutput) else {
            cameraStatistics.setFailMessage(message: "Can not add output device")
            return nil
        }
        dataOutput!.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)]
        dataOutput!.alwaysDiscardsLateVideoFrames = true
        session.addOutput(dataOutput)
        
        orientationChanged()
        
        return session
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        cameraStatistics.increaseFramesDropped()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let compression: Float = 1.0 - Float(cameraSettings.jpegCompressionSettingItem.value)
        guard
            let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer),
            let jpegData = jpegCompress(image: image, compression: compression)
        else {
            cameraStatistics.increaseFramesDropped()
            return
        }
        let exchange = cameraSettings.exchangeSettingItem.getValueOrPlaceholder()
        connector.sendMessage(exchangeName: exchange, message: jpegData)
        cameraStatistics.increaseFramesRecorded()
    }
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        guard let quartzImage = context.makeImage() else { return nil }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
        
        return quartzImage
    }
    
    func jpegCompress(image: CGImage, compression: Float) -> Data? {
        // http://picopikopon.blogspot.cz/2011/09/get-jpeg-data-from-cgimage.html
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else { return nil }
        guard let idst = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil) else { return nil }
        
        let options: CFDictionary = [
            kCGImageDestinationLossyCompressionQuality as String : NSNumber(value: compression),
            kCGImagePropertyOrientation as String : "3"] as CFDictionary
        CGImageDestinationAddImage(idst, image, options);
        
        if (CGImageDestinationFinalize(idst)) {
            return data as Data
        }
        
        return Data()
    }
    
    func changeHandler(parameter: String) {
        switch parameter {
        case "sendData":
            break // reading on-the-fly
        case "exchange":
            break // reading on-the-fly
        case "refreshRate":
            let frameRate = cameraSettings.refreshRateSettingItem.value
            setupFrameRate(frameRate: frameRate)
        case "shouldAdjust":
            break // reading on-the-fly
        case "jpegCompression":
            break // reading on-the-fly
        default:
            print("Camera: Unknown setting")
        }
    }
    
    func setupFrameRate(frameRate: Double) {
        print("A \(frameRate)")
        guard let inputDevice = self.inputDevice else { return }
        print("A \(frameRate)")
        try? inputDevice.device.lockForConfiguration()
        defer {
            inputDevice.device.unlockForConfiguration()
        }
        
        let minFrameDuration: CMTime = CMTime(seconds: 1.0 / frameRate, preferredTimescale: CMTimeScale(100))
        print(minFrameDuration)
        inputDevice.device.activeVideoMinFrameDuration = minFrameDuration
    }
}

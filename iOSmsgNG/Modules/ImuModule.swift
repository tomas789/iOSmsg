//
//  ImuModule.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/9/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation
import CoreMotion

class ImuModule: ModuleProtocol {
    // MARK : Properties
    private var connector: RabbitConnector
    private var motionManager = CMMotionManager()
    private var updateRate = 1e-2;
    private var queue = OperationQueue()
    private var imuTimestampOffset: Double
    
    // MARK : Statistics
    
    private var accelerometerStatistics = ImuDeviceStatistics(deviceName: "accelerometer")
    private var gyroscopeStatistics = ImuDeviceStatistics(deviceName: "gyroscope")
    private var magnetometerStatistics = ImuDeviceStatistics(deviceName: "magnetometer")
    
    internal var statistics: [StatisticsItem] {
        get {
            return [accelerometerStatistics, gyroscopeStatistics, magnetometerStatistics]
        }
    }
    
    // MARK : Settings
    
    var accelerometerSettings: ImuModuleSettings!
    var gyroscopeSettings: ImuModuleSettings!
    var magnetometerSettings: ImuModuleSettings!
    
    var settings: [ModuleSettingProtocol] {
        get {
            return [accelerometerSettings, gyroscopeSettings, magnetometerSettings]
        }
    }
    
    // MARK : Initializers

    init(connector: RabbitConnector) {
        self.connector = connector
        
        let uptime = ProcessInfo.processInfo.systemUptime
        let nowFromEpochBeginning = Date().timeIntervalSince1970
        imuTimestampOffset = nowFromEpochBeginning - uptime
        
        configureSettings()
    }
    
    internal func start() {
        configureSensor(sensor: .accelerometer)
        configureSensor(sensor: .gyroscope)
        configureSensor(sensor: .magnetometer)
        
        startSensor(sensor: .accelerometer)
        startSensor(sensor: .gyroscope)
        startSensor(sensor: .magnetometer)
    }
    
    internal func stop() {
        stopSensor(sensor: .accelerometer)
        stopSensor(sensor: .gyroscope)
        stopSensor(sensor: .magnetometer)
    }
    
    private func configureSensor(sensor: ImuSensor) {
        switch sensor {
        case .accelerometer:
            let rate = 1 / accelerometerSettings.updateRateSettingItem.value
            motionManager.accelerometerUpdateInterval = rate
        case .gyroscope:
            let rate = 1 / gyroscopeSettings.updateRateSettingItem.value
            motionManager.gyroUpdateInterval = rate
        case .magnetometer:
            let rate = 1 / magnetometerSettings.updateRateSettingItem.value
            motionManager.magnetometerUpdateInterval = rate
        }
    }
    
    private func startSensor(sensor: ImuSensor) {
        switch sensor {
        case .accelerometer:
            if accelerometerSettings.sendDataSettingItem.switchStatus {
                motionManager.startAccelerometerUpdates(to: queue, withHandler: accelerometerHandler)
            }
        case .gyroscope:
            if gyroscopeSettings.sendDataSettingItem.switchStatus {
                motionManager.startGyroUpdates(to: queue, withHandler: gyroscopeHandler)
            }
        case .magnetometer:
            if magnetometerSettings.sendDataSettingItem.switchStatus {
                motionManager.startMagnetometerUpdates(to: queue, withHandler: magnetometerHandler)
            }
        }
    }
    
    private func stopSensor(sensor: ImuSensor) {
        switch sensor {
        case .accelerometer:
            motionManager.stopAccelerometerUpdates()
        case .gyroscope:
            motionManager.stopGyroUpdates()
        case .magnetometer:
            motionManager.stopMagnetometerUpdates()
        }
    }
    
    private func restartSensor(sensor: ImuSensor) {
        stopSensor(sensor: sensor)
        configureSensor(sensor: sensor)
        startSensor(sensor: sensor)
    }
    
    private func accelerometerHandler(data: CMAccelerometerData?, error: Error?) {
        guard
            let accel = data?.acceleration,
            let timestamp = data?.timestamp,
            let message = makeAccelerometerMessage(timestamp: timestamp, accel: accel)
        else {
            accelerometerStatistics.increaseFailedCounter()
            return
        }
        let exchange = accelerometerSettings.exchangeSettingItem.getValueOrPlaceholder()
        connector.sendMessage(exchangeName: exchange, message: message)
        accelerometerStatistics.increaseSuccessCounter()
    }
    
    private func gyroscopeHandler(data: CMGyroData?, error: Error?) {
        guard
            let gyro = data?.rotationRate,
            let timestamp = data?.timestamp,
            let message = makeGyroscopeMessage(timestamp: timestamp, gyro: gyro)
        else {
            gyroscopeStatistics.increaseFailedCounter()
            return
        }
        let exchange = gyroscopeSettings.exchangeSettingItem.getValueOrPlaceholder()
        connector.sendMessage(exchangeName: exchange, message: message)
        gyroscopeStatistics.increaseSuccessCounter()
    }
    
    private func magnetometerHandler(data: CMMagnetometerData?, error: Error?) {
        guard
            let mag = data?.magneticField,
            let timestamp = data?.timestamp,
            let message = makeMagnetometerMessage(timestamp: timestamp, mag: mag)
        else {
            magnetometerStatistics.increaseFailedCounter()
            return
        }
        let exchange = magnetometerSettings.exchangeSettingItem.getValueOrPlaceholder()
        connector.sendMessage(exchangeName: exchange, message: message)
        magnetometerStatistics.increaseSuccessCounter()
    }
    
    private func makeAccelerometerMessage(timestamp: TimeInterval, accel: CMAcceleration) -> Data? {
        let content = [
            "timestamp": convertImuTimeToUnixTimestamp(timestamp: timestamp),
            "x": accel.x, "y": accel.y, "z": accel.z
        ]
        return serializeMessage(content: content)
    }
    
    private func makeGyroscopeMessage(timestamp: TimeInterval, gyro: CMRotationRate) -> Data? {
        let content = [
            "timestamp": convertImuTimeToUnixTimestamp(timestamp: timestamp),
            "x": gyro.x, "y": gyro.y, "z": gyro.z
        ]
        return serializeMessage(content: content)
    }

    
    private func makeMagnetometerMessage(timestamp: TimeInterval, mag: CMMagneticField) -> Data? {
        let content = [
            "timestamp": convertImuTimeToUnixTimestamp(timestamp: timestamp),
            "x": mag.x, "y": mag.y, "z": mag.z
        ]
        return serializeMessage(content: content)
    }
    
    private func serializeMessage(content: [String: Double]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: content, options: .prettyPrinted)
    }
    
    private func convertImuTimeToUnixTimestamp(timestamp: TimeInterval) -> Double {
        return imuTimestampOffset + timestamp
    }
    
    private func configureSettings() {
        accelerometerSettings = ImuModuleSettings(moduleName: "Accelerometer", defaultExchangeName: "accelerometer") {
            self.changeHandler(sensor: .accelerometer, parameter: $0)
        }
        
        gyroscopeSettings = ImuModuleSettings(moduleName: "Gyroscope", defaultExchangeName: "gyroscope") {
            self.changeHandler(sensor: .gyroscope, parameter: $0)
        }
        
        magnetometerSettings = ImuModuleSettings(moduleName: "Magnetometer", defaultExchangeName: "magnetometer") {
            self.changeHandler(sensor: .gyroscope, parameter: $0)
        }
    }
    
    private func changeHandler(sensor: ImuSensor, parameter: String) {
        print(accelerometerSettings.sendDataSettingItem.switchStatus)
        restartSensor(sensor: sensor)
    }
}

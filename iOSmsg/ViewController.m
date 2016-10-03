//
//  ViewController.m
//  iOSmsg
//
//  Created by Tomas Krejci on 10/3/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

@import CoreMotion;
#import "ViewController.h"
#import <RMQClient/RMQClient.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.offset = [self computeImuTimeOffsetFromEpoch];
    [self initializeInternalState];
    [self startTimer];
}

- (void)initializeInternalState {
    self.accelerometerSent = 0;
    self.gyroscopeSent = 0;
    self.isRunning = 0;
    
    self.queue = [[NSOperationQueue alloc] init];
    self.motionManager = [[CMMotionManager alloc] init];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    [self updateUiWithUserDefaults];
    
    NSString *broker = [self.brokerEdit text];
    if (broker == nil || [broker length] == 0) {
        [self.connectButton setEnabled:FALSE];
    }
}

- (NSTimeInterval)computeImuTimeOffsetFromEpoch {
    NSTimeInterval uptime = [NSProcessInfo processInfo].systemUptime;
    NSTimeInterval nowTimeIntervalSince1970 = [[NSDate date] timeIntervalSince1970];
    return nowTimeIntervalSince1970 - uptime;
}

- (void)startTimer {
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerTick) userInfo:nil repeats:TRUE];
}

- (void)timerTick {
    [self.accelerometerSentLabel setText:[NSString stringWithFormat:@"%d", self.accelerometerSent]];
    [self.gyroscopeSentLabel setText:[NSString stringWithFormat:@"%d", self.gyroscopeSent]];
}

- (void)updateUiWithUserDefaults {
    NSString *defaultBroker = [self.defaults stringForKey:@"broker-hostname"];
    if (defaultBroker != nil) {
        [self.brokerEdit setText:defaultBroker];
    }
    NSString *defaultExchange = [self.defaults stringForKey:@"broker-exchange"];
    if (defaultExchange != nil) {
        [self.exchangeEdit setText:defaultExchange];
    }
    
    NSNumber *defaultRate = [self.defaults valueForKey:@"rate"];
    if (defaultRate != nil) {
        [self.rateSlider setValue:[defaultRate floatValue]];
        [self rateChanged:nil];
    }
}

- (void)handleAccelerometer:(CMAccelerometerData *)data error:(NSError *)error {
    NSString *format = @"{\"sensor\": \"accelerometer\", \"time\": %f, \"x\": %f, \"y\": %f, \"z\": %f}";
    NSString *msg = [NSString stringWithFormat:format, self.offset + data.timestamp, data.acceleration.x, data.acceleration.y, data.acceleration.z];
    [self.exchange publish:[msg dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)handleGyroscope:(CMGyroData *)data error:(NSError *) error {
    NSString *format = @"{\"sensor\": \"gyroscope\", \"time\": %f, \"x\": %f, \"y\": %f, \"z\": %f}";
    NSString *msg = [NSString stringWithFormat:format, self.offset + data.timestamp, data.rotationRate.x, data.rotationRate.y, data.rotationRate.z];
    [self.exchange publish:[msg dataUsingEncoding:NSUTF8StringEncoding]];
}

- (IBAction)updateDefaultsOnItemChanged:(UITextField *)sender {
    NSLog(@"Called");
    if ([sender isEqual:self.brokerEdit]) {
        NSString *brokerHostname = [self.brokerEdit text];
        [self.defaults setValue:brokerHostname forKey:@"broker-hostname"];
    } else if ([sender isEqual:self.exchangeEdit]) {
        NSString *brokerExchange = [self.exchangeEdit text];
        [self.defaults setValue:brokerExchange forKey:@"broker-exchange"];
    } else {
        NSLog(@"Different");
        return;
    }
    
    if ([[self.brokerEdit text] length] == 0) {
        [self.connectButton setEnabled:FALSE];
    } else {
        [self.connectButton setEnabled:TRUE];
    }
}

- (IBAction)rateChanged:(UISlider *)sender {
    float rate = [self.rateSlider value];
    NSString *labelText = [[NSString alloc] initWithFormat:@"%.0f Hz", rate];
    [self.rateLabel setText:labelText];
    [self.defaults setValue:[NSNumber numberWithFloat:rate] forKey:@"rate"];
}

- (IBAction)connectButtonPressed:(UIButton *)sender {
    if (self.connection == nil) {
        // Not connected -> Connecting
        NSLog(@"Starting ...");
        NSString *brokerUri = [self.brokerEdit text];
        [self connectToBrokerWithUri:brokerUri];
        NSString *exchangeName = [self.exchangeEdit text];
        if (exchangeName == nil || [exchangeName length] == 0) {
            exchangeName = [self.exchangeEdit placeholder];
        }
        self.exchange = [self getExchange:exchangeName];
        
        float updateRate = [self.rateSlider value];
        NSTimeInterval interval = 1.0 / updateRate;
        
        [self.motionManager setAccelerometerUpdateInterval:interval];
        [self.motionManager startAccelerometerUpdatesToQueue:self.queue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            [self handleAccelerometer:accelerometerData error:error];
            self.accelerometerSent += 1;
        }];
        
        [self.motionManager setGyroUpdateInterval:interval];
        [self.motionManager startGyroUpdatesToQueue:self.queue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            [self handleGyroscope:gyroData error:error];
            self.gyroscopeSent += 1;
        }];
        
        [self setUiStateEnabled:FALSE];
    } else {
        // Connected -> Disconnecting
        [self.connection close];
        self.connection = nil;
        
        [self.motionManager stopAccelerometerUpdates];
        [self.motionManager stopGyroUpdates];
        
        [self setUiStateEnabled:TRUE];
    }
}

- (void)setUiStateEnabled: (BOOL)enabled {
    [self.rateSlider setEnabled:enabled];
    [self.brokerEdit setEnabled:enabled];
    [self.exchangeEdit setEnabled:enabled];
    
    if (enabled) {
        [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    } else {
        [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    }
}

- (void)connectToBrokerWithUri:(NSString *)uri {
    self.connection = [[RMQConnection alloc] initWithUri:uri delegate:[RMQConnectionDelegateLogger new]];
    [self.connection start];
    self.channel = [self.connection createChannel];
}

- (RMQExchange *)getExchange:(NSString *)exchange {
    return [self.channel fanout:exchange];
}

@end

//
//  ViewController.h
//  iOSmsg
//
//  Created by Tomas Krejci on 10/3/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RMQClient/RMQClient.h>

@interface ViewController : UIViewController <RMQConnectionDelegate>

@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) RMQConnection *connection;
@property (strong, nonatomic) id<RMQChannel> channel;
@property (strong, nonatomic) RMQExchange *exchange;
@property NSTimeInterval offset;
@property int accelerometerSent;
@property int gyroscopeSent;
@property BOOL isRunning;
@property NSUserDefaults *defaults;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UITextField *brokerEdit;
@property (weak, nonatomic) IBOutlet UITextField *exchangeEdit;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerSentLabel;
@property (weak, nonatomic) IBOutlet UILabel *gyroscopeSentLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


- (IBAction)updateDefaultsOnItemChanged:(UITextField *)sender;
- (IBAction)rateChanged:(UISlider *)sender;
- (IBAction)connectButtonPressed:(UIButton *)sender;

- (void)initializeInternalState;
- (NSTimeInterval)computeImuTimeOffsetFromEpoch;
- (void)startTimer;
- (void)setUiStateEnabled: (BOOL)enabled;
- (void)notifyUserWith: (NSString *)message withTitle:(NSString *)title;

- (void)connectToBrokerWithUri: (NSString *)uri;
- (RMQExchange *)getExchange: (NSString *)exchange;

// RMQConnectionDelegate
- (void)connection:(RMQConnection *)connection failedToConnectWithError:(NSError *)error;
- (void)connection:(RMQConnection *)connection disconnectedWithError:(NSError *)error;
- (void)willStartRecoveryWithConnection:(RMQConnection *)connection;
- (void)startingRecoveryWithConnection:(RMQConnection *)connection;
- (void)recoveredConnection:(RMQConnection *)connection;
- (void)channel:(id<RMQChannel>)channel error:(NSError *)error;

@end


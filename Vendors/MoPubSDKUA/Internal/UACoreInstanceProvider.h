//
//  UACoreInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UAGlobal.h"


@class UAAdConfiguration;

// Fetching Ads
@class UAAdServerCommunicator;
@protocol UAAdServerCommunicatorDelegate;

// URL Handling
@class UAURLResolver;
@class UAAdDestinationDisplayAgent;
@protocol UAAdDestinationDisplayAgentDelegate;

// Utilities
@class UAAdAlertManager, UAAdAlertGestureRecognizer;
@class UAAnalyticsTracker;
@class UAReachability;
@class UATimer;

typedef id(^UASingletonProviderBlock)();

typedef enum {
    UATwitterAvailabilityNone = 0,
    UATwitterAvailabilityApp = 1 << 0,
    UATwitterAvailabilityNative = 1 << 1,
} UATwitterAvailability;

@interface UACoreInstanceProvider : NSObject

+ (instancetype)sharedProvider;
- (id)singletonForClass:(Class)klass provider:(UASingletonProviderBlock)provider;

- (void)keepObjectAliveForCurrentRunLoopIteration:(id)anObject;

#pragma mark - Fetching Ads
- (NSMutableURLRequest *)buildConfiguredURLRequestWithURL:(NSURL *)URL;
- (UAAdServerCommunicator *)buildUAAdServerCommunicatorWithDelegate:(id<UAAdServerCommunicatorDelegate>)delegate;

#pragma mark - URL Handling
- (UAURLResolver *)buildUAURLResolver;
- (UAAdDestinationDisplayAgent *)buildUAAdDestinationDisplayAgentWithDelegate:(id<UAAdDestinationDisplayAgentDelegate>)delegate;

#pragma mark - Utilities
- (id<UAAdAlertManagerProtocol>)buildUAAdAlertManagerWithDelegate:(id)delegate;
- (UAAdAlertGestureRecognizer *)buildUAAdAlertGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (NSOperationQueue *)sharedOperationQueue;
- (UAAnalyticsTracker *)sharedUAAnalyticsTracker;
- (UAReachability *)sharedUAReachability;

// This call may return nil and may not update if the user hot-swaps the device's sim card.
- (NSDictionary *)sharedCarrierInfo;

- (UATimer *)buildUATimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats;

- (UATwitterAvailability)twitterAvailabilityOnDevice;
- (void)resetTwitterAppInstallCheck;


@end

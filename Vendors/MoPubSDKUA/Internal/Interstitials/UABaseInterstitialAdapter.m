//
//  UABaseInterstitialAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 4/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "UABaseInterstitialAdapter.h"
#import "UAAdConfiguration.h"
#import "UAGlobal.h"
#import "UAAnalyticsTracker.h"
#import "UACoreInstanceProvider.h"
#import "UATimer.h"
#import "UAConstants.h"

@interface UABaseInterstitialAdapter ()

@property (nonatomic, strong) UAAdConfiguration *configuration;
@property (nonatomic, strong) UATimer *timeoutTimer;

- (void)startTimeoutTimer;

@end

@implementation UABaseInterstitialAdapter

@synthesize delegate = _delegate;
@synthesize configuration = _configuration;
@synthesize timeoutTimer = _timeoutTimer;

- (id)initWithDelegate:(id<UAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self unregisterDelegate];

    [self.timeoutTimer invalidate];

}

- (void)unregisterDelegate
{
    self.delegate = nil;
}

- (void)getAdWithConfiguration:(UAAdConfiguration *)configuration
{
    // To be implemented by subclasses.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithConfiguration:(UAAdConfiguration *)configuration
{
    self.configuration = configuration;

    [self startTimeoutTimer];

    UABaseInterstitialAdapter *strongSelf = self;
    [strongSelf getAdWithConfiguration:configuration];
}

- (void)startTimeoutTimer
{
    NSTimeInterval timeInterval = (self.configuration && self.configuration.adTimeoutInterval >= 0) ?
            self.configuration.adTimeoutInterval : INTERSTITIAL_TIMEOUT_INTERVAL;

    if (timeInterval > 0) {
        self.timeoutTimer = [[UACoreInstanceProvider sharedProvider] buildUATimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(timeout)
                                                                                      repeats:NO];

        [self.timeoutTimer scheduleNow];
    }
}

- (void)didStopLoading
{
    [self.timeoutTimer invalidate];
}

- (void)timeout
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

#pragma mark - Presentation

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Metrics

- (void)trackImpression
{
    [[[UACoreInstanceProvider sharedProvider] sharedUAAnalyticsTracker] trackImpressionForConfiguration:self.configuration];
}

- (void)trackClick
{
    [[[UACoreInstanceProvider sharedProvider] sharedUAAnalyticsTracker] trackClickForConfiguration:self.configuration];
}

@end


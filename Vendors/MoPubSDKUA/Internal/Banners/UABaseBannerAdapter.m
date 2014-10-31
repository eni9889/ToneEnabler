//
//  UABaseBannerAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "UABaseBannerAdapter.h"
#import "UAConstants.h"

#import "UAAdConfiguration.h"
#import "UALogging.h"
#import "UACoreInstanceProvider.h"
#import "UAAnalyticsTracker.h"
#import "UATimer.h"

@interface UABaseBannerAdapter ()

@property (nonatomic, strong) UAAdConfiguration *configuration;
@property (nonatomic, strong) UATimer *timeoutTimer;

- (void)startTimeoutTimer;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UABaseBannerAdapter

@synthesize delegate = _delegate;
@synthesize configuration = _configuration;
@synthesize timeoutTimer = _timeoutTimer;

- (id)initWithDelegate:(id<UABannerAdapterDelegate>)delegate
{
    if (self = [super init]) {
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

#pragma mark - Requesting Ads

- (void)getAdWithConfiguration:(UAAdConfiguration *)configuration containerSize:(CGSize)size
{
    // To be implemented by subclasses.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithConfiguration:(UAAdConfiguration *)configuration containerSize:(CGSize)size
{
    self.configuration = configuration;

    [self startTimeoutTimer];

    UABaseBannerAdapter *strongSelf = self;
    [strongSelf getAdWithConfiguration:configuration containerSize:size];
}

- (void)didStopLoading
{
    [self.timeoutTimer invalidate];
}

- (void)didDisplayAd
{
    [self trackImpression];
}

- (void)startTimeoutTimer
{
    NSTimeInterval timeInterval = (self.configuration && self.configuration.adTimeoutInterval >= 0) ?
    self.configuration.adTimeoutInterval : BANNER_TIMEOUT_INTERVAL;

    if (timeInterval > 0) {
        self.timeoutTimer = [[UACoreInstanceProvider sharedProvider] buildUATimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(timeout)
                                                                                      repeats:NO];

        [self.timeoutTimer scheduleNow];
    }
}

- (void)timeout
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

#pragma mark - Rotation

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    // Do nothing by default. Subclasses can override.
    UALogDebug(@"rotateToOrientation %d called for adapter %@ (%p)",
          newOrientation, NSStringFromClass([self class]), self);
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

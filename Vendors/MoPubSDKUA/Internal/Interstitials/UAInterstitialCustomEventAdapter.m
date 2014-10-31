//
//  UAInterstitialCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UAInterstitialCustomEventAdapter.h"

#import "UAAdConfiguration.h"
#import "UALogging.h"
#import "UAInstanceProvider.h"
#import "UAInterstitialCustomEvent.h"
#import "UAInterstitialAdController.h"

@interface UAInterstitialCustomEventAdapter ()

@property (nonatomic, strong) UAInterstitialCustomEvent *interstitialCustomEvent;
@property (nonatomic, strong) UAAdConfiguration *configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

@end

@implementation UAInterstitialCustomEventAdapter
@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

@synthesize interstitialCustomEvent = _interstitialCustomEvent;

- (void)dealloc
{
    if ([self.interstitialCustomEvent respondsToSelector:@selector(invalidate)]) {
        // Secret API to allow us to detach the custom event from (shared instance) routers synchronously
        // See the chartboost interstitial custom event for an example use case.
        [self.interstitialCustomEvent performSelector:@selector(invalidate)];
    }
    self.interstitialCustomEvent.delegate = nil;

    // make sure the custom event isn't released synchronously as objects owned by the custom event
    // may do additional work after a callback that results in dealloc being called
    [[UACoreInstanceProvider sharedProvider] keepObjectAliveForCurrentRunLoopIteration:_interstitialCustomEvent];
}

- (void)getAdWithConfiguration:(UAAdConfiguration *)configuration
{
    UALogInfo(@"Looking for custom event class named %@.", configuration.customEventClass);
    self.configuration = configuration;

    self.interstitialCustomEvent = [[UAInstanceProvider sharedProvider] buildInterstitialCustomEventFromCustomClass:configuration.customEventClass delegate:self];

    if (self.interstitialCustomEvent) {
        [self.interstitialCustomEvent requestInterstitialWithCustomEventInfo:configuration.customEventClassData];
    } else {
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
    }
}

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [self.interstitialCustomEvent showInterstitialFromRootViewController:controller];
}

#pragma mark - UAInterstitialCustomEventDelegate

- (NSString *)adUnitId
{
    return [self.delegate interstitialAdController].adUnitId;
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (id)interstitialDelegate
{
    return [self.delegate interstitialDelegate];
}

- (void)interstitialCustomEvent:(UAInterstitialCustomEvent *)customEvent
                      didLoadAd:(id)ad
{
    [self didStopLoading];
    [self.delegate adapterDidFinishLoadingAd:self];
}

- (void)interstitialCustomEvent:(UAInterstitialCustomEvent *)customEvent
       didFailToLoadAdWithError:(NSError *)error
{
    [self didStopLoading];
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialCustomEventWillAppear:(UAInterstitialCustomEvent *)customEvent
{
    [self.delegate interstitialWillAppearForAdapter:self];
}

- (void)interstitialCustomEventDidAppear:(UAInterstitialCustomEvent *)customEvent
{
    if ([self.interstitialCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedImpression) {
        self.hasTrackedImpression = YES;
        [self trackImpression];
    }
    [self.delegate interstitialDidAppearForAdapter:self];
}

- (void)interstitialCustomEventWillDisappear:(UAInterstitialCustomEvent *)customEvent
{
    [self.delegate interstitialWillDisappearForAdapter:self];
}

- (void)interstitialCustomEventDidDisappear:(UAInterstitialCustomEvent *)customEvent
{
    [self.delegate interstitialDidDisappearForAdapter:self];
}

- (void)interstitialCustomEventDidExpire:(UAInterstitialCustomEvent *)customEvent
{
    [self.delegate interstitialDidExpireForAdapter:self];
}

- (void)interstitialCustomEventDidReceiveTapEvent:(UAInterstitialCustomEvent *)customEvent
{
    if ([self.interstitialCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedClick) {
        self.hasTrackedClick = YES;
        [self trackClick];
    }

    [self.delegate interstitialDidReceiveTapEventForAdapter:self];
}

- (void)interstitialCustomEventWillLeaveApplication:(UAInterstitialCustomEvent *)customEvent
{
    [self.delegate interstitialWillLeaveApplicationForAdapter:self];
}

@end

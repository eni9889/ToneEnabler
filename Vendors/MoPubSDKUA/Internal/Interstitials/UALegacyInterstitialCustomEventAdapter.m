//
//  UALegacyInterstitialCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UALegacyInterstitialCustomEventAdapter.h"
#import "UAAdConfiguration.h"
#import "UALogging.h"
#import "UAInternalUtils.h"

@interface UALegacyInterstitialCustomEventAdapter ()

@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

@end

@implementation UALegacyInterstitialCustomEventAdapter

@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

- (void)getAdWithConfiguration:(UAAdConfiguration *)configuration
{
    UALogInfo(@"Looking for custom event selector named %@.", configuration.customSelectorName);

    SEL customEventSelector = NSSelectorFromString(configuration.customSelectorName);
    if ([self.delegate.interstitialDelegate respondsToSelector:customEventSelector]) {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
            [self.delegate.interstitialDelegate performSelector:customEventSelector withObject:nil]
        );
       return;
    }

    NSString *oneArgumentSelectorName = [configuration.customSelectorName
                                         stringByAppendingString:@":"];

    UALogInfo(@"Looking for custom event selector named %@.", oneArgumentSelectorName);

    SEL customEventOneArgumentSelector = NSSelectorFromString(oneArgumentSelectorName);
    if ([self.delegate.interstitialDelegate respondsToSelector:customEventOneArgumentSelector]) {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
            [self.delegate.interstitialDelegate performSelector:customEventOneArgumentSelector withObject:self.delegate.interstitialAdController]
        );
        return;
    }

    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)startTimeoutTimer
{
    // Override to do nothing as we don't want to time out these legacy custom events.
}

- (void)customEventDidLoadAd
{
    if (!self.hasTrackedImpression) {
        self.hasTrackedImpression = YES;
        [self trackImpression];
    }
}

- (void)customEventDidFailToLoadAd
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)customEventActionWillBegin
{
    if (!self.hasTrackedClick) {
        self.hasTrackedClick = YES;
        [self trackClick];
    }
}

@end

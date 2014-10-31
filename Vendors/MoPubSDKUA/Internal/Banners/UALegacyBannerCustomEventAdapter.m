//
//  UALegacyBannerCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UALegacyBannerCustomEventAdapter.h"
#import "UAAdConfiguration.h"
#import "UALogging.h"
#import "UAInternalUtils.h"

@implementation UALegacyBannerCustomEventAdapter

- (void)getAdWithConfiguration:(UAAdConfiguration *)configuration containerSize:(CGSize)size
{
    UALogInfo(@"Looking for custom event selector named %@.", configuration.customSelectorName);

    SEL customEventSelector = NSSelectorFromString(configuration.customSelectorName);
    if ([self.delegate.bannerDelegate respondsToSelector:customEventSelector]) {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
            [self.delegate.bannerDelegate performSelector:customEventSelector withObject:nil]
        );
        return;
    }

    NSString *oneArgumentSelectorName = [configuration.customSelectorName
                                         stringByAppendingString:@":"];

    UALogInfo(@"Looking for custom event selector named %@.", oneArgumentSelectorName);

    SEL customEventOneArgumentSelector = NSSelectorFromString(oneArgumentSelectorName);
    if ([self.delegate.bannerDelegate respondsToSelector:customEventOneArgumentSelector]) {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
            [self.delegate.bannerDelegate performSelector:customEventOneArgumentSelector withObject:self.delegate.banner]
        );
        return;
    }

    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)startTimeoutTimer
{
    // Override to do nothing as we don't want to time out these legacy custom events.
}

@end

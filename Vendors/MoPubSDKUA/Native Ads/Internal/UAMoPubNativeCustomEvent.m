//
//  UAMoPubNativeCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UAMoPubNativeCustomEvent.h"
#import "UAMoPubNativeAdAdapter.h"
#import "UANativeAd+Internal.h"
#import "UANativeAdError.h"
#import "UALogging.h"
#import "UANativeAdUtils.h"

@implementation UAMoPubNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    UAMoPubNativeAdAdapter *adAdapter = [[UAMoPubNativeAdAdapter alloc] initWithAdProperties:[info mutableCopy]];

    if (adAdapter.properties) {
        UANativeAd *interfaceAd = [[UANativeAd alloc] initWithAdAdapter:adAdapter];
        [interfaceAd.impressionTrackers addObjectsFromArray:adAdapter.impressionTrackers];

        // Get the image urls so we can download them prior to returning the ad.
        NSMutableArray *imageURLs = [NSMutableArray array];
        for (NSString *key in [info allKeys]) {
            if ([[key lowercaseString] hasSuffix:@"image"] && [[info objectForKey:key] isKindOfClass:[NSString class]]) {
                if (![UANativeAdUtils addURLString:[info objectForKey:key] toURLArray:imageURLs]) {
                    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:UANativeAdErrorInvalidServerResponse userInfo:nil]];
                }
            }
        }

        [super precacheImagesWithURLs:imageURLs completionBlock:^(NSArray *errors) {
            if (errors) {
                UALogDebug(@"%@", errors);
                UALogInfo(@"Error: data received was invalid.");
                [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:UANativeAdErrorInvalidServerResponse userInfo:nil]];
            } else {
                [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
            }
        }];
    } else {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:UANativeAdErrorInvalidServerResponse userInfo:nil]];
    }

}

@end

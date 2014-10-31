//
//  UANativeAdRequestTargeting.m
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UANativeAdRequestTargeting.h"
#import "UANativeAdConstants.h"

#import <CoreLocation/CoreLocation.h>

@implementation UANativeAdRequestTargeting

+ (UANativeAdRequestTargeting *)targeting
{
    return [[UANativeAdRequestTargeting alloc] init];
}

- (void)setDesiredAssets:(NSSet *)desiredAssets
{
    if (_desiredAssets != desiredAssets) {

        NSMutableSet *allowedAdAssets = [NSMutableSet setWithObjects:kAdTitleKey,
                                         kAdTextKey,
                                         kAdIconImageKey,
                                         kAdMainImageKey,
                                         kAdCTATextKey,
                                         kAdStarRatingKey,
                                         nil];
        [allowedAdAssets intersectSet:desiredAssets];
        _desiredAssets = allowedAdAssets;
    }
}


@end

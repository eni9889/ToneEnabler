//
//  UABannerCustomEventAdapter.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UABaseBannerAdapter.h"

#import "UAPrivateBannerCustomEventDelegate.h"

@class UABannerCustomEvent;

@interface UABannerCustomEventAdapter : UABaseBannerAdapter <UAPrivateBannerCustomEventDelegate>

@end

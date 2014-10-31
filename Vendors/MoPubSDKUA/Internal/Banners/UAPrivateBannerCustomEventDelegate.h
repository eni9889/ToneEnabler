//
//  UAPrivateBannerCustomEventDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UABannerCustomEventDelegate.h"

@class UAAdConfiguration;

@protocol UAPrivateBannerCustomEventDelegate <UABannerCustomEventDelegate>

- (NSString *)adUnitId;
- (UAAdConfiguration *)configuration;
- (id)bannerDelegate;

@end

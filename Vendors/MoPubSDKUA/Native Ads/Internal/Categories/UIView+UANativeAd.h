//
//  UIView+UANativeAd.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UANativeAd;

@interface UIView (UANativeAd)

- (void)mp_setNativeAd:(UANativeAd *)adObject;
- (void)mp_removeNativeAd;
- (UANativeAd *)mp_nativeAd;

@end

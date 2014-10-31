//
//  UIView+UANativeAd.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UIView+UANativeAd.h"

#import <objc/runtime.h>

static char UANativeAdKey;

@implementation UIView (UANativeAd)

- (void)mp_removeNativeAd
{
    [self mp_setNativeAd:nil];
}

- (void)mp_setNativeAd:(UANativeAd *)adObject
{
    objc_setAssociatedObject(self, &UANativeAdKey, adObject, OBJC_ASSOCIATION_ASSIGN);
}

- (UANativeAd *)mp_nativeAd
{
    return (UANativeAd *)objc_getAssociatedObject(self, &UANativeAdKey);
}

@end
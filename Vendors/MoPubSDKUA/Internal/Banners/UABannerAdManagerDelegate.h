//
//  UABannerAdManagerDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UAAdView;
@protocol UAAdViewDelegate;

@protocol UABannerAdManagerDelegate <NSObject>

- (NSString *)adUnitId;
- (UANativeAdOrientation)allowedNativeAdsOrientation;
- (UAAdView *)banner;
- (id<UAAdViewDelegate>)bannerDelegate;
- (CGSize)containerSize;
- (BOOL)ignoresAutorefresh;
- (NSString *)keywords;
- (CLLocation *)location;
- (BOOL)isTesting;
- (UIViewController *)viewControllerForPresentingModalView;

- (void)invalidateContentView;

- (void)managerDidLoadAd:(UIView *)ad;
- (void)managerDidFailToLoadAd;
- (void)userActionWillBegin;
- (void)userActionDidFinish;
- (void)userWillLeaveApplication;

@end

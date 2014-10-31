//
//  UAInterstitialViewController.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAGlobal.h"

@class CLLocation;

@protocol UAInterstitialViewControllerDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UAInterstitialViewController : UIViewController

@property (nonatomic, assign) UAInterstitialCloseButtonStyle closeButtonStyle;
@property (nonatomic, assign) UAInterstitialOrientationType orientationType;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, weak) id<UAInterstitialViewControllerDelegate> delegate;

- (void)presentInterstitialFromViewController:(UIViewController *)controller;
- (void)dismissInterstitialAnimated:(BOOL)animated;
- (BOOL)shouldDisplayCloseButton;
- (void)willPresentInterstitial;
- (void)didPresentInterstitial;
- (void)willDismissInterstitial;
- (void)didDismissInterstitial;
- (void)layoutCloseButton;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol UAInterstitialViewControllerDelegate <NSObject>

- (NSString *)adUnitId;
- (CLLocation *)location;
- (void)interstitialDidLoadAd:(UAInterstitialViewController *)interstitial;
- (void)interstitialDidFailToLoadAd:(UAInterstitialViewController *)interstitial;
- (void)interstitialWillAppear:(UAInterstitialViewController *)interstitial;
- (void)interstitialDidAppear:(UAInterstitialViewController *)interstitial;
- (void)interstitialWillDisappear:(UAInterstitialViewController *)interstitial;
- (void)interstitialDidDisappear:(UAInterstitialViewController *)interstitial;
- (void)interstitialDidReceiveTapEvent:(UAInterstitialViewController *)interstitial;
- (void)interstitialWillLeaveApplication:(UAInterstitialViewController *)interstitial;

@end

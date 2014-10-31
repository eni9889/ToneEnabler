//
//  UABaseInterstitialAdapter.h
//  MoPub
//
//  Created by Nafis Jamal on 4/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UAAdConfiguration, CLLocation;

@protocol UAInterstitialAdapterDelegate;

@interface UABaseInterstitialAdapter : NSObject

@property (nonatomic, weak) id<UAInterstitialAdapterDelegate> delegate;

/*
 * Creates an adapter with a reference to an UAInterstitialAdManager.
 */
- (id)initWithDelegate:(id<UAInterstitialAdapterDelegate>)delegate;

/*
 * Sets the adapter's delegate to nil.
 */
- (void)unregisterDelegate;

- (void)getAdWithConfiguration:(UAAdConfiguration *)configuration;
- (void)_getAdWithConfiguration:(UAAdConfiguration *)configuration;

- (void)didStopLoading;

/*
 * Presents the interstitial from the specified view controller.
 */
- (void)showInterstitialFromViewController:(UIViewController *)controller;

@end

@interface UABaseInterstitialAdapter (ProtectedMethods)

- (void)trackImpression;
- (void)trackClick;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@class UAInterstitialAdController;

@protocol UAInterstitialAdapterDelegate

- (UAInterstitialAdController *)interstitialAdController;
- (id)interstitialDelegate;
- (CLLocation *)location;

- (void)adapterDidFinishLoadingAd:(UABaseInterstitialAdapter *)adapter;
- (void)adapter:(UABaseInterstitialAdapter *)adapter didFailToLoadAdWithError:(NSError *)error;
- (void)interstitialWillAppearForAdapter:(UABaseInterstitialAdapter *)adapter;
- (void)interstitialDidAppearForAdapter:(UABaseInterstitialAdapter *)adapter;
- (void)interstitialWillDisappearForAdapter:(UABaseInterstitialAdapter *)adapter;
- (void)interstitialDidDisappearForAdapter:(UABaseInterstitialAdapter *)adapter;
- (void)interstitialDidExpireForAdapter:(UABaseInterstitialAdapter *)adapter;
- (void)interstitialDidReceiveTapEventForAdapter:(UABaseInterstitialAdapter *)adapter;
- (void)interstitialWillLeaveApplicationForAdapter:(UABaseInterstitialAdapter *)adapter;

@end

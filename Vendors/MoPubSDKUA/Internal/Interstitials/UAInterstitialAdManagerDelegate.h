//
//  UAInterstitialAdManagerDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UAInterstitialAdManager;
@class UAInterstitialAdController;
@class CLLocation;

@protocol UAInterstitialAdManagerDelegate <NSObject>

- (UAInterstitialAdController *)interstitialAdController;
- (CLLocation *)location;
- (id)interstitialDelegate;
- (void)managerDidLoadInterstitial:(UAInterstitialAdManager *)manager;
- (void)manager:(UAInterstitialAdManager *)manager
didFailToLoadInterstitialWithError:(NSError *)error;
- (void)managerWillPresentInterstitial:(UAInterstitialAdManager *)manager;
- (void)managerDidPresentInterstitial:(UAInterstitialAdManager *)manager;
- (void)managerWillDismissInterstitial:(UAInterstitialAdManager *)manager;
- (void)managerDidDismissInterstitial:(UAInterstitialAdManager *)manager;
- (void)managerDidExpireInterstitial:(UAInterstitialAdManager *)manager;
- (void)managerDidReceiveTapEventFromInterstitial:(UAInterstitialAdManager *)manager;

@end

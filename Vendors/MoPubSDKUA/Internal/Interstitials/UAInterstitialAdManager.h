//
//  UAInterstitialAdManager.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UAAdServerCommunicator.h"
#import "UABaseInterstitialAdapter.h"

@class CLLocation;
@protocol UAInterstitialAdManagerDelegate;

@interface UAInterstitialAdManager : NSObject <UAAdServerCommunicatorDelegate,
    UAInterstitialAdapterDelegate>

@property (nonatomic, weak) id<UAInterstitialAdManagerDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL ready;

- (id)initWithDelegate:(id<UAInterstitialAdManagerDelegate>)delegate;

- (void)loadInterstitialWithAdUnitID:(NSString *)ID
                            keywords:(NSString *)keywords
                            location:(CLLocation *)location
                             testing:(BOOL)testing;
- (void)presentInterstitialFromViewController:(UIViewController *)controller;

// Deprecated
- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;

@end

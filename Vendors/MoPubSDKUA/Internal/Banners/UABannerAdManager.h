//
//  UABannerAdManager.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAAdServerCommunicator.h"
#import "UABaseBannerAdapter.h"

@protocol UABannerAdManagerDelegate;

@interface UABannerAdManager : NSObject <UAAdServerCommunicatorDelegate, UABannerAdapterDelegate>

@property (nonatomic, weak) id<UABannerAdManagerDelegate> delegate;

- (id)initWithDelegate:(id<UABannerAdManagerDelegate>)delegate;

- (void)loadAd;
- (void)forceRefreshAd;
- (void)stopAutomaticallyRefreshingContents;
- (void)startAutomaticallyRefreshingContents;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

// Deprecated.
- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;
- (void)customEventActionDidEnd;

@end

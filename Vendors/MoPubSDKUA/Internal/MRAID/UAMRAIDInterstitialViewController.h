//
//  UAMRAIDInterstitialViewController.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UAInterstitialViewController.h"

#import "MRAdView.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol UAMRAIDInterstitialViewControllerDelegate;
@class UAAdConfiguration;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UAMRAIDInterstitialViewController : UAInterstitialViewController <MRAdViewDelegate>

- (id)initWithAdConfiguration:(UAAdConfiguration *)configuration;
- (void)startLoading;

@end


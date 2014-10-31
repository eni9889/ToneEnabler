//
//  UALegacyInterstitialCustomEventAdapter.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UABaseInterstitialAdapter.h"

@interface UALegacyInterstitialCustomEventAdapter : UABaseInterstitialAdapter

- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;

@end

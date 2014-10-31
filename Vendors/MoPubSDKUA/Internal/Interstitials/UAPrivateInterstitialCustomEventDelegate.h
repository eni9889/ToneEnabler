//
//  UAPrivateInterstitialcustomEventDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAInterstitialCustomEventDelegate.h"

@class UAAdConfiguration;
@class CLLocation;

@protocol UAPrivateInterstitialCustomEventDelegate <UAInterstitialCustomEventDelegate>

- (NSString *)adUnitId;
- (UAAdConfiguration *)configuration;
- (id)interstitialDelegate;

@end

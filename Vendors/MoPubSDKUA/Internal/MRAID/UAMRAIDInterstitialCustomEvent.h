//
//  UAMRAIDInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAInterstitialCustomEvent.h"
#import "UAMRAIDInterstitialViewController.h"
#import "UAPrivateInterstitialCustomEventDelegate.h"

@interface UAMRAIDInterstitialCustomEvent : UAInterstitialCustomEvent <UAInterstitialViewControllerDelegate>

@property (nonatomic, weak) id<UAPrivateInterstitialCustomEventDelegate> delegate;

@end

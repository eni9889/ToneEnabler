//
//  UAHTMLInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAInterstitialCustomEvent.h"
#import "UAHTMLInterstitialViewController.h"
#import "UAPrivateInterstitialCustomEventDelegate.h"

@interface UAHTMLInterstitialCustomEvent : UAInterstitialCustomEvent <UAInterstitialViewControllerDelegate>

@property (nonatomic, weak) id<UAPrivateInterstitialCustomEventDelegate> delegate;

@end

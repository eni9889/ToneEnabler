//
//  UAInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UAInterstitialCustomEvent.h"

@implementation UAInterstitialCustomEvent

@synthesize delegate;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to load an interstitial here.
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    // Subclasses may override this method to return NO to perform impression and click tracking
    // manually.
    return YES;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to display an interstitial here.
}

@end

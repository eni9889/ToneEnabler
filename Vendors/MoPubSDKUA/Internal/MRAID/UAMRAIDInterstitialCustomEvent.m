//
//  UAMRAIDInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAMRAIDInterstitialCustomEvent.h"
#import "UAInstanceProvider.h"
#import "UALogging.h"

@interface UAMRAIDInterstitialCustomEvent ()

@property (nonatomic, strong) UAMRAIDInterstitialViewController *interstitial;

@end

@implementation UAMRAIDInterstitialCustomEvent

@synthesize interstitial = _interstitial;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    UALogInfo(@"Loading MoPub MRAID interstitial");
    self.interstitial = [[UAInstanceProvider sharedProvider] buildUAMRAIDInterstitialViewControllerWithDelegate:self
                                                                                                  configuration:[self.delegate configuration]];
    [self.interstitial setCloseButtonStyle:UAInterstitialCloseButtonStyleAdControlled];
    [self.interstitial startLoading];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller
{
    [self.interstitial presentInterstitialFromViewController:controller];
}

#pragma mark - UAMRAIDInterstitialViewControllerDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (void)interstitialDidLoadAd:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub MRAID interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)interstitialDidFailToLoadAd:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub MRAID interstitial did fail");
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub MRAID interstitial will appear");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialDidAppear:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub MRAID interstitial did appear");
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDisappear:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub MRAID interstitial will disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDisappear:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub MRAID interstitial did disappear");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialDidReceiveTapEvent:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub MRAID interstitial did receive tap event");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)interstitialWillLeaveApplication:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub MRAID interstitial will leave application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end

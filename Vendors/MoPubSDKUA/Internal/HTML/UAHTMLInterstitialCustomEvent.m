//
//  UAHTMLInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAHTMLInterstitialCustomEvent.h"
#import "UALogging.h"
#import "UAAdConfiguration.h"
#import "UAInstanceProvider.h"

@interface UAHTMLInterstitialCustomEvent ()

@property (nonatomic, strong) UAHTMLInterstitialViewController *interstitial;

@end

@implementation UAHTMLInterstitialCustomEvent

@synthesize interstitial = _interstitial;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    UALogInfo(@"Loading MoPub HTML interstitial");
    UAAdConfiguration *configuration = [self.delegate configuration];
    UALogTrace(@"Loading HTML interstitial with source: %@", [configuration adResponseHTMLString]);

    self.interstitial = [[UAInstanceProvider sharedProvider] buildUAHTMLInterstitialViewControllerWithDelegate:self
                                                                                               orientationType:configuration.orientationType
                                                                                          customMethodDelegate:[self.delegate interstitialDelegate]];
    [self.interstitial loadConfiguration:configuration];
}

- (void)dealloc
{
    [self.interstitial setDelegate:nil];
    [self.interstitial setCustomMethodDelegate:nil];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial presentInterstitialFromViewController:rootViewController];
}

#pragma mark - UAInterstitialViewControllerDelegate

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
    UALogInfo(@"MoPub HTML interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)interstitialDidFailToLoadAd:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub HTML interstitial did fail");
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub HTML interstitial will appear");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialDidAppear:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub HTML interstitial did appear");
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDisappear:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub HTML interstitial will disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDisappear:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub HTML interstitial did disappear");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialDidReceiveTapEvent:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub HTML interstitial did receive tap event");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)interstitialWillLeaveApplication:(UAInterstitialViewController *)interstitial
{
    UALogInfo(@"MoPub HTML interstitial will leave application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end

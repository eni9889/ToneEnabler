//
//  UAGoogleAdMobInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UAGoogleAdMobInterstitialCustomEvent.h"
#import "UAInterstitialAdController.h"
#import "UALogging.h"
#import "UAAdConfiguration.h"
#import "UAInstanceProvider.h"
#import <CoreLocation/CoreLocation.h>

@interface UAInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd;
- (GADRequest *)buildGADInterstitialRequest;

@end

@implementation UAInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd
{
    return [[GADInterstitial alloc] init];
}

- (GADRequest *)buildGADInterstitialRequest
{
    return [GADRequest request];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UAGoogleAdMobInterstitialCustomEvent ()

@property (nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation UAGoogleAdMobInterstitialCustomEvent

@synthesize interstitial = _interstitial;

#pragma mark - UAInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    UALogInfo(@"Requesting Google AdMob interstitial");
    self.interstitial = [[UAInstanceProvider sharedProvider] buildGADInterstitialAd];

    self.interstitial.adUnitID = [info objectForKey:@"adUnitID"];
    self.interstitial.delegate = self;

    GADRequest *request = [[UAInstanceProvider sharedProvider] buildGADInterstitialRequest];

    CLLocation *location = self.delegate.location;
    if (location) {
        [request setLocationWithLatitude:location.coordinate.latitude
                               longitude:location.coordinate.longitude
                                accuracy:location.horizontalAccuracy];
    }

    // Here, you can specify a list of devices that will receive test ads.
    // See: http://code.google.com/mobile/ads/docs/ios/intermediate.html#testdevices
    request.testDevices = [NSArray arrayWithObjects:
                           GAD_SIMULATOR_ID,
                           // more UDIDs here,
                           nil];

    [self.interstitial loadRequest:request];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial presentFromRootViewController:rootViewController];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
}

#pragma mark - IMAdInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    UALogInfo(@"Google AdMob Interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    UALogInfo(@"Google AdMob Interstitial failed to load with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
    UALogInfo(@"Google AdMob Interstitial will present");
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    UALogInfo(@"Google AdMob Interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    UALogInfo(@"Google AdMob Interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    UALogInfo(@"Google AdMob Interstitial will leave application");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end

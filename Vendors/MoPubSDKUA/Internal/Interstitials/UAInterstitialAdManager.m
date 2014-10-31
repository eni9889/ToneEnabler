//
//  UAInterstitialAdManager.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "UAInterstitialAdManager.h"

#import "UAAdServerURLBuilder.h"
#import "UAInterstitialAdController.h"
#import "UAInterstitialCustomEventAdapter.h"
#import "UAInstanceProvider.h"
#import "UACoreInstanceProvider.h"
#import "UAInterstitialAdManagerDelegate.h"
#import "UALogging.h"

@interface UAInterstitialAdManager ()

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign, readwrite) BOOL ready;
@property (nonatomic, strong) UABaseInterstitialAdapter *adapter;
@property (nonatomic, strong) UAAdServerCommunicator *communicator;
@property (nonatomic, strong) UAAdConfiguration *configuration;

- (void)setUpAdapterWithConfiguration:(UAAdConfiguration *)configuration;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UAInterstitialAdManager

@synthesize loading = _loading;
@synthesize ready = _ready;
@synthesize delegate = _delegate;
@synthesize communicator = _communicator;
@synthesize adapter = _adapter;
@synthesize configuration = _configuration;

- (id)initWithDelegate:(id<UAInterstitialAdManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.communicator = [[UACoreInstanceProvider sharedProvider] buildUAAdServerCommunicatorWithDelegate:self];
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self.communicator cancel];
    [self.communicator setDelegate:nil];

    self.adapter = nil;


}

- (void)setAdapter:(UABaseInterstitialAdapter *)adapter
{
    if (self.adapter != adapter) {
        [self.adapter unregisterDelegate];
        _adapter = adapter;
    }
}

#pragma mark - Public

- (void)loadAdWithURL:(NSURL *)URL
{
    if (self.loading) {
        UALogWarn(@"Interstitial controller is already loading an ad. "
                  @"Wait for previous load to finish.");
        return;
    }

    UALogInfo(@"Interstitial controller is loading ad with MoPub server URL: %@", URL);

    self.loading = YES;
    [self.communicator loadURL:URL];
}


- (void)loadInterstitialWithAdUnitID:(NSString *)ID keywords:(NSString *)keywords location:(CLLocation *)location testing:(BOOL)testing
{
    if (self.ready) {
        [self.delegate managerDidLoadInterstitial:self];
    } else {
        [self loadAdWithURL:[UAAdServerURLBuilder URLWithAdUnitID:ID
                                                         keywords:keywords
                                                         location:location
                                                          testing:testing]];
    }
}

- (void)presentInterstitialFromViewController:(UIViewController *)controller
{
    if (self.ready) {
        [self.adapter showInterstitialFromViewController:controller];
    }
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (UAInterstitialAdController *)interstitialAdController
{
    return [self.delegate interstitialAdController];
}

- (id)interstitialDelegate
{
    return [self.delegate interstitialDelegate];
}

#pragma mark - UAAdServerCommunicatorDelegate

- (void)communicatorDidReceiveAdConfiguration:(UAAdConfiguration *)configuration
{
    self.configuration = configuration;

    UALogInfo(@"Interstitial ad view is fetching ad network type: %@", self.configuration.networkType);

    if ([self.configuration.networkType isEqualToString:kAdTypeClear]) {
        UALogInfo(kUAClearErrorLogFormatWithAdUnitID, self.delegate.interstitialAdController.adUnitId);
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:nil];
        return;
    }

    if (self.configuration.adType != UAAdTypeInterstitial) {
        UALogWarn(@"Could not load ad: interstitial object received a non-interstitial ad unit ID.");
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:nil];
        return;
    }

    [self setUpAdapterWithConfiguration:self.configuration];
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    self.ready = NO;
    self.loading = NO;

    [self.delegate manager:self didFailToLoadInterstitialWithError:error];
}

- (void)setUpAdapterWithConfiguration:(UAAdConfiguration *)configuration;
{
    UABaseInterstitialAdapter *adapter = [[UAInstanceProvider sharedProvider] buildInterstitialAdapterForConfiguration:configuration
                                                                                                              delegate:self];
    if (!adapter) {
        [self adapter:nil didFailToLoadAdWithError:nil];
        return;
    }

    self.adapter = adapter;
    [self.adapter _getAdWithConfiguration:configuration];
}

#pragma mark - UAInterstitialAdapterDelegate

- (void)adapterDidFinishLoadingAd:(UABaseInterstitialAdapter *)adapter
{
    self.ready = YES;
    self.loading = NO;
    [self.delegate managerDidLoadInterstitial:self];
}

- (void)adapter:(UABaseInterstitialAdapter *)adapter didFailToLoadAdWithError:(NSError *)error
{
    self.ready = NO;
    self.loading = NO;
    [self loadAdWithURL:self.configuration.failoverURL];
}

- (void)interstitialWillAppearForAdapter:(UABaseInterstitialAdapter *)adapter
{
    [self.delegate managerWillPresentInterstitial:self];
}

- (void)interstitialDidAppearForAdapter:(UABaseInterstitialAdapter *)adapter
{
    [self.delegate managerDidPresentInterstitial:self];
}

- (void)interstitialWillDisappearForAdapter:(UABaseInterstitialAdapter *)adapter
{
    [self.delegate managerWillDismissInterstitial:self];
}

- (void)interstitialDidDisappearForAdapter:(UABaseInterstitialAdapter *)adapter
{
    self.ready = NO;
    [self.delegate managerDidDismissInterstitial:self];
}

- (void)interstitialDidExpireForAdapter:(UABaseInterstitialAdapter *)adapter
{
    self.ready = NO;
    [self.delegate managerDidExpireInterstitial:self];
}

- (void)interstitialDidReceiveTapEventForAdapter:(UABaseInterstitialAdapter *)adapter
{
    [self.delegate managerDidReceiveTapEventFromInterstitial:self];
}

- (void)interstitialWillLeaveApplicationForAdapter:(UABaseInterstitialAdapter *)adapter
{
    //noop
}

#pragma mark - Legacy Custom Events

- (void)customEventDidLoadAd
{
    // XXX: The deprecated custom event behavior is to report an impression as soon as an ad loads,
    // rather than when the ad is actually displayed. Because of this, you may see impression-
    // reporting discrepancies between MoPub and your custom ad networks.
    if ([self.adapter respondsToSelector:@selector(customEventDidLoadAd)]) {
        self.loading = NO;
        [self.adapter performSelector:@selector(customEventDidLoadAd)];
    }
}

- (void)customEventDidFailToLoadAd
{
    if ([self.adapter respondsToSelector:@selector(customEventDidFailToLoadAd)]) {
        self.loading = NO;
        [self.adapter performSelector:@selector(customEventDidFailToLoadAd)];
    }
}

- (void)customEventActionWillBegin
{
    if ([self.adapter respondsToSelector:@selector(customEventActionWillBegin)]) {
        [self.adapter performSelector:@selector(customEventActionWillBegin)];
    }
}

@end

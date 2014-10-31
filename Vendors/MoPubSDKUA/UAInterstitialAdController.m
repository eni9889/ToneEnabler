//
//  UAInterstitialAdController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UAInterstitialAdController.h"

#import "UALogging.h"
#import "UAInstanceProvider.h"
#import "UAInterstitialAdManager.h"
#import "UAInterstitialAdManagerDelegate.h"

@interface UAInterstitialAdController () <UAInterstitialAdManagerDelegate>

@property (nonatomic, strong) UAInterstitialAdManager *manager;

+ (NSMutableArray *)sharedInterstitials;
- (id)initWithAdUnitId:(NSString *)adUnitId;

@end

@implementation UAInterstitialAdController

@synthesize manager = _manager;
@synthesize delegate = _delegate;
@synthesize adUnitId = _adUnitId;
@synthesize keywords = _keywords;
@synthesize location = _location;
@synthesize testing = _testing;

- (id)initWithAdUnitId:(NSString *)adUnitId
{
    if (self = [super init]) {
        self.manager = [[UAInstanceProvider sharedProvider] buildUAInterstitialAdManagerWithDelegate:self];
        self.adUnitId = adUnitId;
    }
    return self;
}

- (void)dealloc
{
    [self.manager setDelegate:nil];
}

#pragma mark - Public

+ (UAInterstitialAdController *)interstitialAdControllerForAdUnitId:(NSString *)adUnitId
{
    NSMutableArray *interstitials = [[self class] sharedInterstitials];

    @synchronized(self) {
        // Find the correct ad controller based on the ad unit ID.
        UAInterstitialAdController *interstitial = nil;
        for (UAInterstitialAdController *currentInterstitial in interstitials) {
            if ([currentInterstitial.adUnitId isEqualToString:adUnitId]) {
                interstitial = currentInterstitial;
                break;
            }
        }

        // Create a new ad controller for this ad unit ID if one doesn't already exist.
        if (!interstitial) {
            interstitial = [[[self class] alloc] initWithAdUnitId:adUnitId];
            [interstitials addObject:interstitial];
        }

        return interstitial;
    }
}

- (BOOL)ready
{
    return self.manager.ready;
}

- (void)loadAd
{
    [self.manager loadInterstitialWithAdUnitID:self.adUnitId
                                      keywords:self.keywords
                                      location:self.location
                                       testing:self.testing];
}

- (void)showFromViewController:(UIViewController *)controller
{
    if (!controller) {
        UALogWarn(@"The interstitial could not be shown: "
                  @"a nil view controller was passed to -showFromViewController:.");
        return;
    }

    if (![controller.view.window isKeyWindow]) {
        UALogWarn(@"Attempted to present an interstitial ad in non-key window. The ad may not render properly");
    }

    [self.manager presentInterstitialFromViewController:controller];
}

#pragma mark - Internal

+ (NSMutableArray *)sharedInterstitials
{
    static NSMutableArray *sharedInterstitials;

    @synchronized(self) {
        if (!sharedInterstitials) {
            sharedInterstitials = [NSMutableArray array];
        }
    }

    return sharedInterstitials;
}

#pragma mark - UAInterstitialAdManagerDelegate

- (UAInterstitialAdController *)interstitialAdController
{
    return self;
}

- (id)interstitialDelegate
{
    return self.delegate;
}

- (void)managerDidLoadInterstitial:(UAInterstitialAdManager *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
        [self.delegate interstitialDidLoadAd:self];
    }
}

- (void)manager:(UAInterstitialAdManager *)manager
        didFailToLoadInterstitialWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToLoadAd:)]) {
        [self.delegate interstitialDidFailToLoadAd:self];
    }
}

- (void)managerWillPresentInterstitial:(UAInterstitialAdManager *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialWillAppear:)]) {
        [self.delegate interstitialWillAppear:self];
    }
}

- (void)managerDidPresentInterstitial:(UAInterstitialAdManager *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidAppear:)]) {
        [self.delegate interstitialDidAppear:self];
    }
}

- (void)managerWillDismissInterstitial:(UAInterstitialAdManager *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialWillDisappear:)]) {
        [self.delegate interstitialWillDisappear:self];
    }
}

- (void)managerDidDismissInterstitial:(UAInterstitialAdManager *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidDisappear:)]) {
        [self.delegate interstitialDidDisappear:self];
    }
}

- (void)managerDidExpireInterstitial:(UAInterstitialAdManager *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidExpire:)]) {
        [self.delegate interstitialDidExpire:self];
    }
}

- (void)managerDidReceiveTapEventFromInterstitial:(UAInterstitialAdManager *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidReceiveTapEvent:)]) {
        [self.delegate interstitialDidReceiveTapEvent:self];
    }
}

#pragma mark - Deprecated

+ (NSMutableArray *)sharedInterstitialAdControllers
{
    return [[self class] sharedInterstitials];
}

+ (void)removeSharedInterstitialAdController:(UAInterstitialAdController *)controller
{
    [[[self class] sharedInterstitials] removeObject:controller];
}

- (void)customEventDidLoadAd
{
    [self.manager customEventDidLoadAd];
}

- (void)customEventDidFailToLoadAd
{
    [self.manager customEventDidFailToLoadAd];
}

- (void)customEventActionWillBegin
{
    [self.manager customEventActionWillBegin];
}

@end

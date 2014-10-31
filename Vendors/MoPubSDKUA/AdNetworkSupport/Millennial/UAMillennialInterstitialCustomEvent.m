//
//  UAMillennialInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAMillennialInterstitialCustomEvent.h"
#import "UAInstanceProvider.h"
#import "UALogging.h"

#import <MillennialMedia/MMInterstitial.h>

@interface UAMillennialInterstitialRouter : NSObject

@property (nonatomic, strong) NSMutableDictionary *events;
- (UAMillennialInterstitialCustomEvent *)eventForApid:(NSString *)apid;
- (void)registerEvent:(UAMillennialInterstitialCustomEvent *)event forApid:(NSString *)apid;
- (void)unregisterEvent:(UAMillennialInterstitialCustomEvent *)event forApid:(NSString *)apid;

@end

@interface UAInstanceProvider (MillennialInterstitials)

- (UAMillennialInterstitialRouter *)sharedMillennialInterstitialRouter;
- (id)MMInterstitial;

@end

@implementation UAInstanceProvider (MillennialInterstitials)

- (UAMillennialInterstitialRouter *)sharedMillennialInterstitialRouter
{
    return [self singletonForClass:[UAMillennialInterstitialRouter class]
                          provider:^id{
                              return [[UAMillennialInterstitialRouter alloc] init];
                          }];
}

- (id)MMInterstitial
{
    return [MMInterstitial class];
}

@end

@implementation UAMillennialInterstitialRouter

- (id)init
{
    self = [super init];
    if (self) {
        self.events = [NSMutableDictionary dictionary];
    }
    return self;
}


- (UAMillennialInterstitialCustomEvent *)eventForApid:(NSString *)apid
{
    return [self.events objectForKey:apid];
}

- (void)registerEvent:(UAMillennialInterstitialCustomEvent *)event forApid:(NSString *)apid
{
    [self.events setObject:event forKey:apid];
}

- (void)unregisterEvent:(UAMillennialInterstitialCustomEvent *)event forApid:(NSString *)apid
{
    if ([self.events objectForKey:apid] == event) {
        [self.events removeObjectForKey:apid];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UAMillennialInterstitialCustomEvent ()

@property (nonatomic, copy) NSString *apid;
@property (nonatomic, assign) BOOL didDisplay;
@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, assign) int modalCount;

@end

@implementation UAMillennialInterstitialCustomEvent

@synthesize apid = _apid;
@synthesize didDisplay = _didDisplay;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adWasTapped:) name:MillennialMediaAdWasTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adWillAppear:) name:MillennialMediaAdModalWillAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adDidAppear:) name:MillennialMediaAdModalDidAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adWillDismiss:) name:MillennialMediaAdModalWillDismiss object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adDidDismiss:) name:MillennialMediaAdModalDidDismiss object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self invalidate];
}

- (UAMillennialInterstitialRouter *)router
{
    return [[UAInstanceProvider sharedProvider] sharedMillennialInterstitialRouter];
}

- (void)invalidate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.router unregisterEvent:self forApid:self.apid];
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    UALogInfo(@"Requesting Millennial interstitial");
    self.apid = [info objectForKey:@"adUnitID"];

    if (!self.apid || [self.router eventForApid:self.apid]) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    MMRequest *request = [MMRequest requestWithLocation:self.delegate.location];
    [request setValue:@"mopubsdk" forKey:@"vendor"];

    [self.router registerEvent:self forApid:self.apid];

    [[[UAInstanceProvider sharedProvider] MMInterstitial] fetchWithRequest:request apid:self.apid onCompletion:^(BOOL success, NSError *error) {
        if ([self.router eventForApid:self.apid] != self) {
            return;
        }
        // Check for success isn't sufficient, because Millennial returns an error with domain "com.millennialmedia.error.alreadyCached" when there is already a pre-cached ad
        if (success || [[[UAInstanceProvider sharedProvider] MMInterstitial] isAdAvailableForApid:self.apid]) {
            UALogInfo(@"Millennial interstitial did load");
            [self.delegate interstitialCustomEvent:self didLoadAd:nil];
        } else {
            UALogInfo(@"Millennial interstitial did fail");
            [self invalidate];
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        }
    }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if (!self.didDisplay) {
        if (![[[UAInstanceProvider sharedProvider] MMInterstitial] isAdAvailableForApid:self.apid]) {
            [self invalidate];
            [self.delegate interstitialCustomEventDidExpire:self];
            return;
        }

        [[[UAInstanceProvider sharedProvider] MMInterstitial] displayForApid:self.apid fromViewController:rootViewController withOrientation:0 onCompletion:^(BOOL success, NSError *error) {
            if ([self.router eventForApid:self.apid] != self || self.didDisplay) {
                return;
            }

            if (success) {
                UALogInfo(@"Millennial interstitial did present succesfully");
                self.didDisplay = YES;
                [self.delegate trackImpression];
            } else {
                UALogInfo(@"Millennial interstitial failed to present");
                [self invalidate];
                [self.delegate interstitialCustomEventDidExpire:self];
            }
        }];
    }
}

- (BOOL)notificationIsRelevant:(NSNotification *)notification
{
    return [self.router eventForApid:self.apid] == self &&
    [[notification.userInfo objectForKey:MillennialMediaAdTypeKey] isEqual:MillennialMediaAdTypeInterstitial] &&
    [[notification.userInfo objectForKey:MillennialMediaAPIDKey] isEqual:self.apid];
}

- (void)adWasTapped:(NSNotification *)notification
{
    // XXX: Tap notifications do not include an APID object in the userInfo dictionary.
    if ([[notification.userInfo objectForKey:MillennialMediaAdTypeKey] isEqual:MillennialMediaAdTypeInterstitial] &&
        self.modalCount == 1) {
        UALogInfo(@"Millennial interstitial was tapped");
        if (!self.didTrackClick) {
            [self.delegate trackClick];
            self.didTrackClick = YES;
            [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
        }
    }
}

- (void)adWillAppear:(NSNotification *)notification
{
    if ([self notificationIsRelevant:notification] && self.modalCount == 0) {
        UALogInfo(@"Millennial interstitial will appear");
        [self.delegate interstitialCustomEventWillAppear:self];
    }
}

- (void)adDidAppear:(NSNotification *)notification
{
    if ([self notificationIsRelevant:notification]) {
        self.modalCount += 1;
        if (self.modalCount == 1) {
            UALogInfo(@"Millennial interstitial did appear");
            [self.delegate interstitialCustomEventDidAppear:self];
        }
    }
}

- (void)adWillDismiss:(NSNotification *)notification
{
    if ([self notificationIsRelevant:notification] && self.modalCount == 1) {
        UALogInfo(@"Millennial interstitial will dismiss");
        [self.delegate interstitialCustomEventWillDisappear:self];
    }
}

- (void)adDidDismiss:(NSNotification *)notification
{
    if ([self notificationIsRelevant:notification]) {
        self.modalCount -= 1;
        if (self.modalCount == 0) {
            UALogInfo(@"Millennial interstitial did dismiss");
            [self invalidate];
            [self.delegate interstitialCustomEventDidDisappear:self];
            [self.delegate interstitialCustomEventDidExpire:self];
        }
    }
}

@end

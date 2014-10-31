//
//  UAiAdBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAiAdBannerCustomEvent.h"
#import "UAInstanceProvider.h"
#import "UALogging.h"
#import <iAd/iAd.h>

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol UAADBannerViewManagerObserver <NSObject>

- (void)bannerDidLoad;
- (void)bannerDidFail;
- (void)bannerActionWillBeginAndWillLeaveApplication:(BOOL)willLeave;
- (void)bannerActionDidFinish;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UAADBannerViewManager : NSObject <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *bannerView;
@property (nonatomic, strong) NSMutableSet *observers;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

+ (UAADBannerViewManager *)sharedManager;

- (void)registerObserver:(id<UAADBannerViewManagerObserver>)observer;
- (void)unregisterObserver:(id<UAADBannerViewManagerObserver>)observer;
- (BOOL)shouldTrackImpression;
- (void)didTrackImpression;
- (BOOL)shouldTrackClick;
- (void)didTrackClick;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////


@interface UAInstanceProvider (iAdBanners)

- (ADBannerView *)buildADBannerView;
- (UAADBannerViewManager *)sharedUAAdBannerViewManager;

@end

@implementation UAInstanceProvider (iAdBanners)

- (ADBannerView *)buildADBannerView
{
    return [[ADBannerView alloc] init];
}

- (UAADBannerViewManager *)sharedUAAdBannerViewManager
{
    return [self singletonForClass:[UAADBannerViewManager class]
                          provider:^id{
                              return [[UAADBannerViewManager alloc] init];
                          }];
}

@end


/////////////////////////////////////////////////////////////////////////////////////

@interface UAiAdBannerCustomEvent () <UAADBannerViewManagerObserver>

@property (nonatomic, assign) BOOL onScreen;

@end

@implementation UAiAdBannerCustomEvent

@synthesize onScreen = _onScreen;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (ADBannerView *)bannerView
{
    return [UAADBannerViewManager sharedManager].bannerView;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    UALogInfo(@"Requesting iAd banner");

    [[UAADBannerViewManager sharedManager] registerObserver:self];

    if (self.bannerView.isBannerLoaded) {
        [self bannerDidLoad];
    }
}

- (void)invalidate
{
    self.onScreen = NO;
    [[UAADBannerViewManager sharedManager] unregisterObserver:self];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    self.bannerView.currentContentSizeIdentifier = UIInterfaceOrientationIsPortrait(orientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
}

- (void)didDisplayAd
{
    self.onScreen = YES;
    [self trackImpressionIfNecessary];
}

- (void)trackImpressionIfNecessary
{
    if (self.onScreen && [[UAADBannerViewManager sharedManager] shouldTrackImpression]) {
        [self.delegate trackImpression];
        [[UAADBannerViewManager sharedManager] didTrackImpression];
    }
}

- (void)trackClickIfNecessary
{
    if ([[UAADBannerViewManager sharedManager] shouldTrackClick]) {
        [self.delegate trackClick];
        [[UAADBannerViewManager sharedManager] didTrackClick];
    }
}

#pragma mark - <UAADBannerViewManagerObserver>

- (void)bannerDidLoad
{
    [self trackImpressionIfNecessary];
    [self.delegate bannerCustomEvent:self didLoadAd:self.bannerView];
}

- (void)bannerDidFail
{
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)bannerActionWillBeginAndWillLeaveApplication:(BOOL)willLeave
{
    [self trackClickIfNecessary];
    if (willLeave) {
        [self.delegate bannerCustomEventWillLeaveApplication:self];
    } else {
        [self.delegate bannerCustomEventWillBeginAction:self];
    }
}

- (void)bannerActionDidFinish
{
    [self.delegate bannerCustomEventDidFinishAction:self];
}

@end

/////////////////////////////////////////////////////////////////////////////////////

@implementation UAADBannerViewManager

@synthesize bannerView = _bannerView;
@synthesize observers = _observers;
@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

+ (UAADBannerViewManager *)sharedManager
{
    return [[UAInstanceProvider sharedProvider] sharedUAAdBannerViewManager];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.bannerView = [[UAInstanceProvider sharedProvider] buildADBannerView];
        self.bannerView.delegate = self;
        self.observers = [NSMutableSet set];
    }
    return self;
}

- (void)dealloc
{
    self.bannerView.delegate = nil;
}

- (void)registerObserver:(id<UAADBannerViewManagerObserver>)observer;
{
    [self.observers addObject:observer];
}

- (void)unregisterObserver:(id<UAADBannerViewManagerObserver>)observer;
{
    [self.observers removeObject:observer];
}

- (BOOL)shouldTrackImpression
{
    return !self.hasTrackedImpression;
}

- (void)didTrackImpression
{
    self.hasTrackedImpression = YES;
}

- (BOOL)shouldTrackClick
{
    return !self.hasTrackedClick;
}

- (void)didTrackClick
{
    self.hasTrackedClick = YES;
}

#pragma mark - <ADBannerViewDelegate>

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    UALogInfo(@"iAd banner did load");
    self.hasTrackedImpression = NO;
    self.hasTrackedClick = NO;

    for (id<UAADBannerViewManagerObserver> observer in [self.observers copy]) {
        [observer bannerDidLoad];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    UALogInfo(@"iAd banner did fail with error %@", error.localizedDescription);
    for (id<UAADBannerViewManagerObserver> observer in [self.observers copy]) {
        [observer bannerDidFail];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    UALogInfo(@"iAd banner action will begin");
    for (id<UAADBannerViewManagerObserver> observer in [self.observers copy]) {
        [observer bannerActionWillBeginAndWillLeaveApplication:willLeave];
    }
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    UALogInfo(@"iAd banner action did finish");
    for (id<UAADBannerViewManagerObserver> observer in [self.observers copy]) {
        [observer bannerActionDidFinish];
    }
}

@end


//
//  UAMillennialBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAMillennialBannerCustomEvent.h"
#import "UALogging.h"
#import "UAAdConfiguration.h"
#import "UAInstanceProvider.h"

#import <MillennialMedia/MMAdView.h>
#import <MillennialMedia/MMRequest.h>

#define MM_SIZE_320x50    CGSizeMake(320, 50)
#define MM_SIZE_300x250 CGSizeMake(300, 250)
#define MM_SIZE_728x90  CGSizeMake(728, 90)

@interface UAInstanceProvider (MillennialBanners)

- (MMAdView *)buildMMAdViewWithFrame:(CGRect)frame apid:(NSString *)apid rootViewController:(UIViewController *)controller;

@end

@implementation UAInstanceProvider (MillennialBanners)

- (MMAdView *)buildMMAdViewWithFrame:(CGRect)frame apid:(NSString *)apid rootViewController:(UIViewController *)controller
{
    return [[MMAdView alloc] initWithFrame:frame apid:apid rootViewController:controller];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UAMMCompletionBlockProxy : NSObject

@property (nonatomic, weak) UAMillennialBannerCustomEvent *event;

- (void)onRequestCompletion:(BOOL)success;

@end

@interface UAMillennialBannerCustomEvent ()

@property (nonatomic, strong) MMAdView *mmAdView;
@property (nonatomic, assign) BOOL didTrackImpression;
@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, assign) BOOL didShowModal;
@property (nonatomic, strong) UAMMCompletionBlockProxy *mmCompletionBlockProxy;

- (void)onRequestCompletion:(BOOL)success;
- (CGSize)sizeFromCustomEventInfo:(NSDictionary *)info;
- (CGRect)frameFromCustomEventInfo:(NSDictionary *)info;

@end

@implementation UAMMCompletionBlockProxy

- (void)onRequestCompletion:(BOOL)success
{
    [self.event onRequestCompletion:success];
}

@end

@implementation UAMillennialBannerCustomEvent

@synthesize mmAdView = _mmAdView;
@synthesize didTrackImpression = _didTrackImpression;
@synthesize didTrackClick = _didTrackClick;
@synthesize mmCompletionBlockProxy = _mmCompletionBlockProxy;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adWasTapped:) name:MillennialMediaAdWasTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modalWillAppear:) name:MillennialMediaAdModalWillAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modalDidDismiss:) name:MillennialMediaAdModalDidDismiss object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminateFromAd:) name:MillennialMediaAdWillTerminateApplication object:nil];
        self.mmCompletionBlockProxy = [[UAMMCompletionBlockProxy alloc] init];
        self.mmCompletionBlockProxy.event = self;
    }
    return self;
}

- (void)invalidate
{
    self.delegate = nil;
}

- (void)dealloc
{
    self.mmCompletionBlockProxy.event = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    UALogInfo(@"Requesting Millennial banner");

    CGRect frame = [self frameFromCustomEventInfo:info];
    NSString *apid = [info objectForKey:@"adUnitID"];
    self.mmAdView = [[UAInstanceProvider sharedProvider] buildMMAdViewWithFrame:frame
                                                                           apid:apid
                                                             rootViewController:self.delegate.viewControllerForPresentingModalView];

    MMRequest *request = [MMRequest requestWithLocation:self.delegate.location];
    [request setValue:@"mopubsdk" forKey:@"vendor"];

    // MMAdView hangs onto its block even after the block is called.  Therefore, we cannot pass
    // self in, as that will create a retain cycle (we hold self.mmAdView and mmAdView holds us through
    // the block).
    //
    // We can't just use __block UAMillennialBannerCustomEvent *event = self to tell the block *not*
    // to retain us.  As that might cause a crash when we are invalidated/dealloced *before* the block
    // is called.
    //
    // The UAMMCompletionBlockProxy has a weak reference to us so we avoid the retain cycle issue.
    // Of course, we must make sure to unregister from the proxy on dealloc to prevent a crash.

    UAMMCompletionBlockProxy *proxy = self.mmCompletionBlockProxy;
    [self.mmAdView getAdWithRequest:request onCompletion:^(BOOL success, NSError *error) {
        // In Millennial 5.2, request errors invoke the completion block on a background thread. This causes us
        // to initialize the failover NSURLConnection on the background thread, resulting in the inability to
        // receive callbacks from the connection.
        dispatch_async(dispatch_get_main_queue(), ^{
            [proxy onRequestCompletion:success];
        });
    }];
}

- (void)onRequestCompletion:(BOOL)success
{
    if (success) {
        UALogInfo(@"Millennial banner did load");
        [self.delegate bannerCustomEvent:self didLoadAd:self.mmAdView];
        if (!self.didTrackImpression) {
            [self.delegate trackImpression];
            self.didTrackImpression = YES;
        }
    } else {
        UALogInfo(@"Millennial banner did fail");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (CGSize)sizeFromCustomEventInfo:(NSDictionary *)info
{
    CGFloat width = [[info objectForKey:@"adWidth"] floatValue];
    CGFloat height = [[info objectForKey:@"adHeight"] floatValue];
    return CGSizeMake(width, height);
}

- (CGRect)frameFromCustomEventInfo:(NSDictionary *)info
{
    CGSize size = [self sizeFromCustomEventInfo:info];
    if (!CGSizeEqualToSize(size, MM_SIZE_300x250) && !CGSizeEqualToSize(size, MM_SIZE_728x90)) {
        size.width = MM_SIZE_320x50.width;
        size.height = MM_SIZE_320x50.height;
    }
    return CGRectMake(0, 0, size.width, size.height);
}

- (void)adWasTapped:(NSNotification *)notification
{
    if ([[notification.userInfo objectForKey:MillennialMediaAdObjectKey] isEqual:self.mmAdView]) {
        UALogInfo(@"Millennial banner was tapped");

        if (!self.didTrackClick) {
            [self.delegate trackClick];
            self.didTrackClick = YES;
        }

        // XXX: As of Millennial SDK version 5.1.0, a "tapped" notification for an MMAdView is
        // accompanied by the presentation of a modal loading indicator (spinner). Although this
        // spinner is modal, the Millennial SDK does not appropriately fire the
        // MillennialMediaAdModalWillAppear notification until much later. Specifically, the
        // notification is not fired until other modal content (e.g. browser or StoreKit) is about
        // to come on-screen and replace the spinner.
        //
        // In previous Millennial SDK versions, it was sufficient for MoPub to use the "will appear"
        // and "did dismiss" notifications to determine whether an MMAdView could be deallocated.
        // However, in 5.1.0, MMAdView causes crashes if deallocated while its spinner is on-screen.
        // Thus, we must call [self.delegate bannerCustomEventWillBeginAction:self] as soon as we
        // detect that the spinner has been presented.

        [self.delegate bannerCustomEventWillBeginAction:self];
    }
}

- (void)applicationWillTerminateFromAd:(NSNotification *)notification
{
    // no userinfo available for this notification, so we do our best to ensure that this notification
    // is from us
    if (self.didTrackClick) {
        UALogInfo(@"Millennial banner will leave application");
        [self.delegate bannerCustomEventWillLeaveApplication:self];

        // If this banner causes the user to leave the application without ever displaying a modal,
        // we consider the banner action to be finished. We need to inform the delegate of this, to
        // maintain the contract that every "begin action" is paired with an "end action".
        if (!self.didShowModal) {
            [self.delegate bannerCustomEventDidFinishAction:self];
        }
    }
}

- (void)modalWillAppear:(NSNotification *)notification
{
    if ([[notification.userInfo objectForKey:MillennialMediaAdObjectKey] isEqual:self.mmAdView]) {
        UALogInfo(@"Millennial banner will present modal");
        self.didShowModal = YES;
    }
}

- (void)modalDidDismiss:(NSNotification *)notification
{
    if ([[notification.userInfo objectForKey:MillennialMediaAdObjectKey] isEqual:self.mmAdView]) {
        UALogInfo(@"Millennial banner did dismiss modal");
        [self.delegate bannerCustomEventDidFinishAction:self];
    }
}

@end

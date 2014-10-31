//
//  UAInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAInstanceProvider.h"
#import "UAAdWebView.h"
#import "UAAdWebViewAgent.h"
#import "UAInterstitialAdManager.h"
#import "UAInterstitialCustomEventAdapter.h"
#import "UALegacyInterstitialCustomEventAdapter.h"
#import "UAHTMLInterstitialViewController.h"
#import "UAMRAIDInterstitialViewController.h"
#import "UAInterstitialCustomEvent.h"
#import "UABaseBannerAdapter.h"
#import "UABannerCustomEventAdapter.h"
#import "UALegacyBannerCustomEventAdapter.h"
#import "UABannerCustomEvent.h"
#import "UABannerAdManager.h"
#import "UALogging.h"
#import "MRJavaScriptEventEmitter.h"
#import "MRImageDownloader.h"
#import "MRBundleManager.h"
#import "MRCalendarManager.h"
#import "MRPictureManager.h"
#import "MRVideoPlayerManager.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UANativeCustomEvent.h"
#import "UANativeAdSource.h"
#import "UANativePositionSource.h"
#import "UAStreamAdPlacementData.h"
#import "UAStreamAdPlacer.h"

@interface UAInstanceProvider ()

@property (nonatomic, strong) NSMutableDictionary *singletons;

@end


@implementation UAInstanceProvider

static UAInstanceProvider *sharedAdProvider = nil;

+ (instancetype)sharedProvider
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedAdProvider = [[self alloc] init];
    });

    return sharedAdProvider;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.singletons = [NSMutableDictionary dictionary];
    }
    return self;
}


- (id)singletonForClass:(Class)klass provider:(UASingletonProviderBlock)provider
{
    id singleton = [self.singletons objectForKey:klass];
    if (!singleton) {
        singleton = provider();
        [self.singletons setObject:singleton forKey:(id<NSCopying>)klass];
    }
    return singleton;
}

#pragma mark - Banners

- (UABannerAdManager *)buildUABannerAdManagerWithDelegate:(id<UABannerAdManagerDelegate>)delegate
{
    return [(UABannerAdManager *)[UABannerAdManager alloc] initWithDelegate:delegate];
}

- (UABaseBannerAdapter *)buildBannerAdapterForConfiguration:(UAAdConfiguration *)configuration
                                                   delegate:(id<UABannerAdapterDelegate>)delegate
{
    if (configuration.customEventClass) {
        return [(UABannerCustomEventAdapter *)[UABannerCustomEventAdapter alloc] initWithDelegate:delegate];
    } else if (configuration.customSelectorName) {
        return [(UALegacyBannerCustomEventAdapter *)[UALegacyBannerCustomEventAdapter alloc] initWithDelegate:delegate];
    }

    return nil;
}

- (UABannerCustomEvent *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<UABannerCustomEventDelegate>)delegate
{
    UABannerCustomEvent *customEvent = [[customClass alloc] init];
    if (![customEvent isKindOfClass:[UABannerCustomEvent class]]) {
        UALogError(@"**** Custom Event Class: %@ does not extend UABannerCustomEvent ****", NSStringFromClass(customClass));
        return nil;
    }
    customEvent.delegate = delegate;
    return customEvent;
}

#pragma mark - Interstitials

- (UAInterstitialAdManager *)buildUAInterstitialAdManagerWithDelegate:(id<UAInterstitialAdManagerDelegate>)delegate
{
    return [(UAInterstitialAdManager *)[UAInterstitialAdManager alloc] initWithDelegate:delegate];
}


- (UABaseInterstitialAdapter *)buildInterstitialAdapterForConfiguration:(UAAdConfiguration *)configuration
                                                               delegate:(id<UAInterstitialAdapterDelegate>)delegate
{
    if (configuration.customEventClass) {
        return [(UAInterstitialCustomEventAdapter *)[UAInterstitialCustomEventAdapter alloc] initWithDelegate:delegate];
    } else if (configuration.customSelectorName) {
        return [(UALegacyInterstitialCustomEventAdapter *)[UALegacyInterstitialCustomEventAdapter alloc] initWithDelegate:delegate];
    }

    return nil;
}

- (UAInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<UAInterstitialCustomEventDelegate>)delegate
{
    UAInterstitialCustomEvent *customEvent = [[customClass alloc] init];
    if (![customEvent isKindOfClass:[UAInterstitialCustomEvent class]]) {
        UALogError(@"**** Custom Event Class: %@ does not extend UAInterstitialCustomEvent ****", NSStringFromClass(customClass));
        return nil;
    }
    if ([customEvent respondsToSelector:@selector(customEventDidUnload)]) {
        UALogWarn(@"**** Custom Event Class: %@ implements the deprecated -customEventDidUnload method.  This is no longer called.  Use -dealloc for cleanup instead ****", NSStringFromClass(customClass));
    }
    customEvent.delegate = delegate;
    return customEvent;
}

- (UAHTMLInterstitialViewController *)buildUAHTMLInterstitialViewControllerWithDelegate:(id<UAInterstitialViewControllerDelegate>)delegate
                                                                        orientationType:(UAInterstitialOrientationType)type
                                                                   customMethodDelegate:(id)customMethodDelegate
{
    UAHTMLInterstitialViewController *controller = [[UAHTMLInterstitialViewController alloc] init];
    controller.delegate = delegate;
    controller.orientationType = type;
    controller.customMethodDelegate = customMethodDelegate;
    return controller;
}

- (UAMRAIDInterstitialViewController *)buildUAMRAIDInterstitialViewControllerWithDelegate:(id<UAInterstitialViewControllerDelegate>)delegate
                                                                            configuration:(UAAdConfiguration *)configuration
{
    UAMRAIDInterstitialViewController *controller = [[UAMRAIDInterstitialViewController alloc] initWithAdConfiguration:configuration];
    controller.delegate = delegate;
    return controller;
}

#pragma mark - HTML Ads

- (UAAdWebView *)buildUAAdWebViewWithFrame:(CGRect)frame delegate:(id<UIWebViewDelegate>)delegate
{
    UAAdWebView *webView = [[UAAdWebView alloc] initWithFrame:frame];
    webView.delegate = delegate;
    return webView;
}

- (UAAdWebViewAgent *)buildUAAdWebViewAgentWithAdWebViewFrame:(CGRect)frame delegate:(id<UAAdWebViewAgentDelegate>)delegate customMethodDelegate:(id)customMethodDelegate
{
    return [[UAAdWebViewAgent alloc] initWithAdWebViewFrame:frame delegate:delegate customMethodDelegate:customMethodDelegate];
}

#pragma mark - MRAID

- (MRAdView *)buildMRAdViewWithFrame:(CGRect)frame
                     allowsExpansion:(BOOL)allowsExpansion
                    closeButtonStyle:(MRAdViewCloseButtonStyle)style
                       placementType:(MRAdViewPlacementType)type
                            delegate:(id<MRAdViewDelegate>)delegate
{
    MRAdView *mrAdView = [[MRAdView alloc] initWithFrame:frame allowsExpansion:allowsExpansion closeButtonStyle:style placementType:type];
    mrAdView.delegate = delegate;
    return mrAdView;
}

- (MRBundleManager *)buildMRBundleManager
{
    return [MRBundleManager sharedManager];
}

- (UIWebView *)buildUIWebViewWithFrame:(CGRect)frame
{
    return [[UIWebView alloc] initWithFrame:frame];
}

- (MRJavaScriptEventEmitter *)buildMRJavaScriptEventEmitterWithWebView:(UIWebView *)webView
{
    return [[MRJavaScriptEventEmitter alloc] initWithWebView:webView];
}

- (MRCalendarManager *)buildMRCalendarManagerWithDelegate:(id<MRCalendarManagerDelegate>)delegate
{
    return [[MRCalendarManager alloc] initWithDelegate:delegate];
}

- (EKEventEditViewController *)buildEKEventEditViewControllerWithEditViewDelegate:(id<EKEventEditViewDelegate>)editViewDelegate
{
    EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
    controller.editViewDelegate = editViewDelegate;
    controller.eventStore = [self buildEKEventStore];
    return controller;
}

- (EKEventStore *)buildEKEventStore
{
    return [[EKEventStore alloc] init];
}

- (MRPictureManager *)buildMRPictureManagerWithDelegate:(id<MRPictureManagerDelegate>)delegate
{
    return [[MRPictureManager alloc] initWithDelegate:delegate];
}

- (MRImageDownloader *)buildMRImageDownloaderWithDelegate:(id<MRImageDownloaderDelegate>)delegate
{
    return [[MRImageDownloader alloc] initWithDelegate:delegate];
}

- (MRVideoPlayerManager *)buildMRVideoPlayerManagerWithDelegate:(id<MRVideoPlayerManagerDelegate>)delegate
{
    return [[MRVideoPlayerManager alloc] initWithDelegate:delegate];
}

- (MPMoviePlayerViewController *)buildMPMoviePlayerViewControllerWithURL:(NSURL *)URL
{
    // ImageContext used to avoid CGErrors
    // http://stackoverflow.com/questions/13203336/iphone-mpmovieplayerviewcontroller-cgcontext-errors/14669166#14669166
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:URL];
    UIGraphicsEndImageContext();

    return playerViewController;
}

#pragma mark - Native

- (UANativeCustomEvent *)buildNativeCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<UANativeCustomEventDelegate>)delegate
{
    UANativeCustomEvent *customEvent = [[customClass alloc] init];
    if (![customEvent isKindOfClass:[UANativeCustomEvent class]]) {
        UALogError(@"**** Custom Event Class: %@ does not extend UANativeCustomEvent ****", NSStringFromClass(customClass));
        return nil;
    }
    customEvent.delegate = delegate;
    return customEvent;
}

- (UANativeAdSource *)buildNativeAdSourceWithDelegate:(id<UANativeAdSourceDelegate>)delegate
{
    UANativeAdSource *source = [UANativeAdSource source];
    source.delegate = delegate;
    return source;
}

- (UANativePositionSource *)buildNativePositioningSource
{
    return [[UANativePositionSource alloc] init];
}

- (UAStreamAdPlacementData *)buildStreamAdPlacementDataWithPositioning:(UAAdPositioning *)positioning
{
    UAStreamAdPlacementData *placementData = [[UAStreamAdPlacementData alloc] initWithPositioning:positioning];
    return placementData;
}

- (UAStreamAdPlacer *)buildStreamAdPlacerWithViewController:(UIViewController *)controller adPositioning:(UAAdPositioning *)positioning defaultAdRenderingClass:defaultAdRenderingClass
{
    return [UAStreamAdPlacer placerWithViewController:controller adPositioning:positioning defaultAdRenderingClass:defaultAdRenderingClass];
}

@end


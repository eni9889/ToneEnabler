//
//  UAInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAGlobal.h"
#import "UACoreInstanceProvider.h"

// Banners
@class UABannerAdManager;
@protocol UABannerAdManagerDelegate;
@class UABaseBannerAdapter;
@protocol UABannerAdapterDelegate;
@class UABannerCustomEvent;
@protocol UABannerCustomEventDelegate;

// Interstitials
@class UAInterstitialAdManager;
@protocol UAInterstitialAdManagerDelegate;
@class UABaseInterstitialAdapter;
@protocol UAInterstitialAdapterDelegate;
@class UAInterstitialCustomEvent;
@protocol UAInterstitialCustomEventDelegate;
@class UAHTMLInterstitialViewController;
@class UAMRAIDInterstitialViewController;
@protocol UAInterstitialViewControllerDelegate;

// HTML Ads
@class UAAdWebView;
@class UAAdWebViewAgent;
@protocol UAAdWebViewAgentDelegate;

// MRAID
@class MRAdView;
@protocol MRAdViewDelegate;
@class MRBundleManager;
@class MRJavaScriptEventEmitter;
@class MRCalendarManager;
@protocol MRCalendarManagerDelegate;
@class EKEventStore;
@class EKEventEditViewController;
@protocol EKEventEditViewDelegate;
@class MRPictureManager;
@protocol MRPictureManagerDelegate;
@class MRImageDownloader;
@protocol MRImageDownloaderDelegate;
@class MRVideoPlayerManager;
@protocol MRVideoPlayerManagerDelegate;
@class MPMoviePlayerViewController;

//Native
@protocol UANativeCustomEventDelegate;
@class UANativeCustomEvent;
@class UANativeAdSource;
@protocol UANativeAdSourceDelegate;
@class UANativePositionSource;
@class UAStreamAdPlacementData;
@class UAStreamAdPlacer;
@class UAAdPositioning;

@interface UAInstanceProvider : NSObject

+(instancetype)sharedProvider;
- (id)singletonForClass:(Class)klass provider:(UASingletonProviderBlock)provider;

#pragma mark - Banners
- (UABannerAdManager *)buildUABannerAdManagerWithDelegate:(id<UABannerAdManagerDelegate>)delegate;
- (UABaseBannerAdapter *)buildBannerAdapterForConfiguration:(UAAdConfiguration *)configuration
                                                   delegate:(id<UABannerAdapterDelegate>)delegate;
- (UABannerCustomEvent *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<UABannerCustomEventDelegate>)delegate;

#pragma mark - Interstitials
- (UAInterstitialAdManager *)buildUAInterstitialAdManagerWithDelegate:(id<UAInterstitialAdManagerDelegate>)delegate;
- (UABaseInterstitialAdapter *)buildInterstitialAdapterForConfiguration:(UAAdConfiguration *)configuration
                                                               delegate:(id<UAInterstitialAdapterDelegate>)delegate;
- (UAInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<UAInterstitialCustomEventDelegate>)delegate;
- (UAHTMLInterstitialViewController *)buildUAHTMLInterstitialViewControllerWithDelegate:(id<UAInterstitialViewControllerDelegate>)delegate
                                                                        orientationType:(UAInterstitialOrientationType)type
                                                                   customMethodDelegate:(id)customMethodDelegate;
- (UAMRAIDInterstitialViewController *)buildUAMRAIDInterstitialViewControllerWithDelegate:(id<UAInterstitialViewControllerDelegate>)delegate
                                                                            configuration:(UAAdConfiguration *)configuration;

#pragma mark - HTML Ads
- (UAAdWebView *)buildUAAdWebViewWithFrame:(CGRect)frame
                                  delegate:(id<UIWebViewDelegate>)delegate;
- (UAAdWebViewAgent *)buildUAAdWebViewAgentWithAdWebViewFrame:(CGRect)frame
                                                     delegate:(id<UAAdWebViewAgentDelegate>)delegate
                                         customMethodDelegate:(id)customMethodDelegate;

#pragma mark - MRAID
- (MRAdView *)buildMRAdViewWithFrame:(CGRect)frame
                     allowsExpansion:(BOOL)allowsExpansion
                    closeButtonStyle:(NSUInteger)style
                       placementType:(NSUInteger)type
                            delegate:(id<MRAdViewDelegate>)delegate;
- (MRBundleManager *)buildMRBundleManager;
- (UIWebView *)buildUIWebViewWithFrame:(CGRect)frame;
- (MRJavaScriptEventEmitter *)buildMRJavaScriptEventEmitterWithWebView:(UIWebView *)webView;
- (MRCalendarManager *)buildMRCalendarManagerWithDelegate:(id<MRCalendarManagerDelegate>)delegate;
- (EKEventEditViewController *)buildEKEventEditViewControllerWithEditViewDelegate:(id<EKEventEditViewDelegate>)editViewDelegate;
- (EKEventStore *)buildEKEventStore;
- (MRPictureManager *)buildMRPictureManagerWithDelegate:(id<MRPictureManagerDelegate>)delegate;
- (MRImageDownloader *)buildMRImageDownloaderWithDelegate:(id<MRImageDownloaderDelegate>)delegate;
- (MRVideoPlayerManager *)buildMRVideoPlayerManagerWithDelegate:(id<MRVideoPlayerManagerDelegate>)delegate;
- (MPMoviePlayerViewController *)buildMPMoviePlayerViewControllerWithURL:(NSURL *)URL;

#pragma mark - Native

- (UANativeCustomEvent *)buildNativeCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<UANativeCustomEventDelegate>)delegate;
- (UANativeAdSource *)buildNativeAdSourceWithDelegate:(id<UANativeAdSourceDelegate>)delegate;
- (UANativePositionSource *)buildNativePositioningSource;
- (UAStreamAdPlacementData *)buildStreamAdPlacementDataWithPositioning:(UAAdPositioning *)positioning;
- (UAStreamAdPlacer *)buildStreamAdPlacerWithViewController:(UIViewController *)controller adPositioning:(UAAdPositioning *)positioning defaultAdRenderingClass:defaultAdRenderingClass;

@end

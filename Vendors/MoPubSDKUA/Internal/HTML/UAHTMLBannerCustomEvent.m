//
//  UAHTMLBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAHTMLBannerCustomEvent.h"
#import "UAAdWebView.h"
#import "UALogging.h"
#import "UAAdConfiguration.h"
#import "UAInstanceProvider.h"

@interface UAHTMLBannerCustomEvent ()

@property (nonatomic, strong) UAAdWebViewAgent *bannerAgent;

@end

@implementation UAHTMLBannerCustomEvent

@synthesize bannerAgent = _bannerAgent;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    UALogInfo(@"Loading MoPub HTML banner");
    UALogTrace(@"Loading banner with HTML source: %@", [[self.delegate configuration] adResponseHTMLString]);

    CGRect adWebViewFrame = CGRectMake(0, 0, size.width, size.height);
    self.bannerAgent = [[UAInstanceProvider sharedProvider] buildUAAdWebViewAgentWithAdWebViewFrame:adWebViewFrame
                                                                                           delegate:self
                                                                               customMethodDelegate:[self.delegate bannerDelegate]];
    [self.bannerAgent loadConfiguration:[self.delegate configuration]];
}

- (void)dealloc
{
    self.bannerAgent.delegate = nil;
    self.bannerAgent.customMethodDelegate = nil;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.bannerAgent rotateToOrientation:newOrientation];
}

#pragma mark - UAAdWebViewAgentDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adDidFinishLoadingAd:(UAAdWebView *)ad
{
    UALogInfo(@"MoPub HTML banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:ad];
}

- (void)adDidFailToLoadAd:(UAAdWebView *)ad
{
    UALogInfo(@"MoPub HTML banner did fail");
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)adDidClose:(UAAdWebView *)ad
{
    //don't care
}

- (void)adActionWillBegin:(UAAdWebView *)ad
{
    UALogInfo(@"MoPub HTML banner will begin action");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adActionDidFinish:(UAAdWebView *)ad
{
    UALogInfo(@"MoPub HTML banner did finish action");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adActionWillLeaveApplication:(UAAdWebView *)ad
{
    UALogInfo(@"MoPub HTML banner will leave application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}


@end

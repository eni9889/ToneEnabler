//
//  UAMRAIDBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAMRAIDBannerCustomEvent.h"
#import "UALogging.h"
#import "UAAdConfiguration.h"
#import "UAInstanceProvider.h"

@interface UAMRAIDBannerCustomEvent ()

@property (nonatomic, strong) MRAdView *banner;

@end

@implementation UAMRAIDBannerCustomEvent

@synthesize banner = _banner;

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    UALogInfo(@"Loading MoPub MRAID banner");
    UAAdConfiguration *configuration = [self.delegate configuration];

    CGRect adViewFrame = CGRectZero;
    if ([configuration hasPreferredSize]) {
        adViewFrame = CGRectMake(0, 0, configuration.preferredSize.width,
                                 configuration.preferredSize.height);
    }

    self.banner = [[UAInstanceProvider sharedProvider] buildMRAdViewWithFrame:adViewFrame
                                                              allowsExpansion:YES
                                                             closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                                placementType:MRAdViewPlacementTypeInline
                                                                     delegate:self];

    self.banner.delegate = self;
    [self.banner loadCreativeWithHTMLString:[configuration adResponseHTMLString]
                                    baseURL:nil];
}

- (void)dealloc
{
    self.banner.delegate = nil;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.banner rotateToOrientation:newOrientation];
}

#pragma mark - MRAdViewDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (UAAdConfiguration *)adConfiguration
{
    return [self.delegate configuration];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adDidLoad:(MRAdView *)adView
{
    UALogInfo(@"MoPub MRAID banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adDidFailToLoad:(MRAdView *)adView
{
    UALogInfo(@"MoPub MRAID banner did fail");
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)closeButtonPressed
{
    //don't care
}

- (void)appShouldSuspendForAd:(MRAdView *)adView
{
    UALogInfo(@"MoPub MRAID banner will begin action");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)appShouldResumeFromAd:(MRAdView *)adView
{
    UALogInfo(@"MoPub MRAID banner did end action");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

@end

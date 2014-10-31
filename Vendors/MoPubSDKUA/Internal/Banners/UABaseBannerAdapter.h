//
//  UABaseBannerAdapter.h
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UAAdView.h"

@protocol UABannerAdapterDelegate;
@class UAAdConfiguration;

@interface UABaseBannerAdapter : NSObject
{
    id<UABannerAdapterDelegate> __weak _delegate;
}

@property (nonatomic, weak) id<UABannerAdapterDelegate> delegate;
@property (nonatomic, copy) NSURL *impressionTrackingURL;
@property (nonatomic, copy) NSURL *clickTrackingURL;

- (id)initWithDelegate:(id<UABannerAdapterDelegate>)delegate;

/*
 * Sets the adapter's delegate to nil.
 */
- (void)unregisterDelegate;

/*
 * -_getAdWithConfiguration creates a strong reference to self before calling
 * -getAdWithConfiguration to prevent the adapter from being prematurely deallocated.
 */
- (void)getAdWithConfiguration:(UAAdConfiguration *)configuration containerSize:(CGSize)size;
- (void)_getAdWithConfiguration:(UAAdConfiguration *)configuration containerSize:(CGSize)size;

- (void)didStopLoading;
- (void)didDisplayAd;

/*
 * Your subclass should implement this method if your native ads vary depending on orientation.
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;

- (void)trackImpression;

- (void)trackClick;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol UABannerAdapterDelegate

@required

- (UAAdView *)banner;
- (id<UAAdViewDelegate>)bannerDelegate;
- (UIViewController *)viewControllerForPresentingModalView;
- (UANativeAdOrientation)allowedNativeAdsOrientation;
- (CLLocation *)location;

/*
 * These callbacks notify you that the adapter (un)successfully loaded an ad.
 */
- (void)adapter:(UABaseBannerAdapter *)adapter didFailToLoadAdWithError:(NSError *)error;
- (void)adapter:(UABaseBannerAdapter *)adapter didFinishLoadingAd:(UIView *)ad;

/*
 * These callbacks notify you that the user interacted (or stopped interacting) with the native ad.
 */
- (void)userActionWillBeginForAdapter:(UABaseBannerAdapter *)adapter;
- (void)userActionDidFinishForAdapter:(UABaseBannerAdapter *)adapter;

/*
 * This callback notifies you that user has tapped on an ad which will cause them to leave the
 * current application (e.g. the ad action opens the iTunes store, Mobile Safari, etc).
 */
- (void)userWillLeaveApplicationFromAdapter:(UABaseBannerAdapter *)adapter;

@end

//
//  UANativeAdDelegate.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

/**
 * The delegate of an `UANativeAd` object must adopt the `UANativeAdDelegate` protocol. It must
 * implement `viewControllerForPresentingModalView` to provide a root view controller from which
 * the ad view should present modal content.
 */

@protocol UANativeAdDelegate <NSObject>

@required

/** @name Managing Modal Content Presentation */

/**
 * Asks the delegate for a view controller to use for presenting modal content, such as the in-app
 * browser that can appear when an ad is tapped.
 *
 * @return A view controller that should be used for presenting modal content.
 */
- (UIViewController *)viewControllerForPresentingModalView;

@end

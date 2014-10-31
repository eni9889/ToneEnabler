//
//  UANativeCustomEventDelegate.h
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UANativeAd;
@class UANativeCustomEvent;

/**
 * Instances of your custom subclass of `UANativeCustomEvent` will have an
 * `UANativeCustomEventDelegate` delegate object. You use this delegate to communicate progress
 * (such as whether an ad has loaded successfully) back to the MoPub SDK.
 */
@protocol UANativeCustomEventDelegate <NSObject>

/**
 * This method is called when the ad and all required ad assets are loaded.
 *
 * @param event You should pass `self` to allow the MoPub SDK to associate this event with the
 * correct instance of your custom event.
 * @param adObject An `UANativeAd` object, representing the ad that was retrieved.
 */
- (void)nativeCustomEvent:(UANativeCustomEvent *)event didLoadAd:(UANativeAd *)adObject;

/**
 * This method is called when the ad or any required ad assets fail to load.
 *
 * @param event You should pass `self` to allow the MoPub SDK to associate this event with the
 * correct instance of your custom event.
 * @param error (*optional*) You may pass an error describing the failure.
 */
- (void)nativeCustomEvent:(UANativeCustomEvent *)event didFailToLoadAdWithError:(NSError *)error;

@end

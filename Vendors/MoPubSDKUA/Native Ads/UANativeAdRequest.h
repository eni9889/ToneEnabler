//
//  UANativeAdRequest.h
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UANativeAd;
@class UANativeAdRequest;
@class UANativeAdRequestTargeting;

typedef void(^UANativeAdRequestHandler)(UANativeAdRequest *request,
                                      UANativeAd *response,
                                      NSError *error);

////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * The `UANativeAdRequest` class is used to manage individual requests to the MoPub ad server for
 * native ads.
 *
 * @warning **Note:** This class is meant for one-off requests for which you intend to manually
 * process the native ad response. If you are using `UATableViewAdPlacer` or
 * `UACollectionViewAdPlacer` to display ads, there should be no need for you to use this class.
 */

@interface UANativeAdRequest : NSObject

/** @name Targeting Information */

/**
 * An object representing targeting parameters that can be passed to the MoPub ad server to
 * serve more relevant advertising.
 */
@property (nonatomic, strong) UANativeAdRequestTargeting *targeting;

/** @name Initializing and Starting an Ad Request */

/**
 * Initializes a request object.
 *
 * @param identifier The ad unit identifier for this request. An ad unit is a defined placement in
 * your application set aside for advertising. Ad unit IDs are created on the MoPub website.
 *
 * @return An `UANativeAdRequest` object.
 */
+ (UANativeAdRequest *)requestWithAdUnitIdentifier:(NSString *)identifier;

/**
 * Executes a request to the MoPub ad server.
 *
 * @param handler A block to execute when the request finishes. The block includes as parameters the
 * request itself and either a valid UANativeAd or an NSError object indicating failure.
 */
- (void)startWithCompletionHandler:(UANativeAdRequestHandler)handler;

@end

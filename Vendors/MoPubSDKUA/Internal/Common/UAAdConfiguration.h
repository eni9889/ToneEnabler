//
//  UAAdConfiguration.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAGlobal.h"

enum {
    UAAdTypeUnknown = -1,
    UAAdTypeBanner = 0,
    UAAdTypeInterstitial = 1
};
typedef NSUInteger UAAdType;

extern NSString * const kAdTypeHeaderKey;
extern NSString * const kClickthroughHeaderKey;
extern NSString * const kCustomSelectorHeaderKey;
extern NSString * const kCustomEventClassNameHeaderKey;
extern NSString * const kCustomEventClassDataHeaderKey;
extern NSString * const kFailUrlHeaderKey;
extern NSString * const kHeightHeaderKey;
extern NSString * const kImpressionTrackerHeaderKey;
extern NSString * const kInterceptLinksHeaderKey;
extern NSString * const kLaunchpageHeaderKey;
extern NSString * const kNativeSDKParametersHeaderKey;
extern NSString * const kNetworkTypeHeaderKey;
extern NSString * const kRefreshTimeHeaderKey;
extern NSString * const kAdTimeoutHeaderKey;
extern NSString * const kScrollableHeaderKey;
extern NSString * const kWidthHeaderKey;
extern NSString * const kDspCreativeIdKey;
extern NSString * const kPrecacheRequiredKey;

extern NSString * const kInterstitialAdTypeHeaderKey;
extern NSString * const kOrientationTypeHeaderKey;

extern NSString * const kAdTypeHtml;
extern NSString * const kAdTypeInterstitial;
extern NSString * const kAdTypeMraid;
extern NSString * const kAdTypeClear;
extern NSString * const kAdTypeNative;

@interface UAAdConfiguration : NSObject

@property (nonatomic, assign) UAAdType adType;
@property (nonatomic, copy) NSString *networkType;
@property (nonatomic, assign) CGSize preferredSize;
@property (nonatomic, strong) NSURL *clickTrackingURL;
@property (nonatomic, strong) NSURL *impressionTrackingURL;
@property (nonatomic, strong) NSURL *failoverURL;
@property (nonatomic, strong) NSURL *interceptURLPrefix;
@property (nonatomic, assign) BOOL shouldInterceptLinks;
@property (nonatomic, assign) BOOL scrollable;
@property (nonatomic, assign) NSTimeInterval refreshInterval;
@property (nonatomic, assign) NSTimeInterval adTimeoutInterval;
@property (nonatomic, copy) NSData *adResponseData;
@property (nonatomic, strong) NSDictionary *nativeSDKParameters;
@property (nonatomic, copy) NSString *customSelectorName;
@property (nonatomic, assign) Class customEventClass;
@property (nonatomic, strong) NSDictionary *customEventClassData;
@property (nonatomic, assign) UAInterstitialOrientationType orientationType;
@property (nonatomic, copy) NSString *dspCreativeId;
@property (nonatomic, assign) BOOL precacheRequired;
@property (nonatomic, strong) NSDate *creationTimestamp;

- (id)initWithHeaders:(NSDictionary *)headers data:(NSData *)data;

- (BOOL)hasPreferredSize;
- (NSString *)adResponseHTMLString;
- (NSString *)clickDetectionURLPrefix;

@end

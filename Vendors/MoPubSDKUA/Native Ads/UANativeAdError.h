//
//  UANativeAdError.h
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const MoPubNativeAdsSDKDomain;

typedef enum UANativeAdErrorCode {
    UANativeAdErrorUnknown = -1,
    
    UANativeAdErrorHTTPError = -1000,
    UANativeAdErrorInvalidServerResponse = -1001,
    UANativeAdErrorNoInventory = -1002,
    UANativeAdErrorImageDownloadFailed = -1003,
    
    UANativeAdErrorContentDisplayError = -1100,
} UANativeAdErrorCode;

extern NSString *const UANativeAdErrorContentDisplayErrorReasonKey;

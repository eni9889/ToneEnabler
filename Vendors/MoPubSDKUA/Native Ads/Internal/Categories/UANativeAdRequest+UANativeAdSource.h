//
//  UANativeAdRequest+UANativeAdSource.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UANativeAdRequest.h"

@interface UANativeAdRequest (UANativeAdSource)

- (void)startForAdSequence:(NSInteger)adSequence withCompletionHandler:(UANativeAdRequestHandler)handler;

@end

//
//  UANativeAdSource.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UANativeAdSourceDelegate.h"
@class UANativeAdRequestTargeting;

@interface UANativeAdSource : NSObject

@property (nonatomic, weak) id <UANativeAdSourceDelegate> delegate;

+ (instancetype)source;
- (void)loadAdsWithAdUnitIdentifier:(NSString *)identifier andTargeting:(UANativeAdRequestTargeting *)targeting;
- (void)deleteCacheForAdUnitIdentifier:(NSString *)identifier;
- (id)dequeueAdForAdUnitIdentifier:(NSString *)identifier;


@end

//
//  UANativeAdSourceQueue.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UANativeAdRequestTargeting;
@class UANativeAd;

@protocol UANativeAdSourceQueueDelegate;

@interface UANativeAdSourceQueue : NSObject

@property (nonatomic, weak) id <UANativeAdSourceQueueDelegate> delegate;
@property (nonatomic, assign) NSUInteger currentSequence;


- (instancetype)initWithAdUnitIdentifier:(NSString *)identifier andTargeting:(UANativeAdRequestTargeting *)targeting;
- (UANativeAd *)dequeueAdWithMaxAge:(NSTimeInterval)age;
- (NSUInteger)count;
- (void)loadAds;
- (void)cancelRequests;

@end

@protocol UANativeAdSourceQueueDelegate <NSObject>

- (void)adSourceQueueAdIsAvailable:(UANativeAdSourceQueue *)source;

@end

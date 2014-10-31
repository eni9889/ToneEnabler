//
//  UANativeAdSource.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UANativeAdSource.h"
#import "UANativeAd.h"
#import "UANativeAdRequestTargeting.h"
#import "UANativeAdSourceQueue.h"

static NSTimeInterval const kCacheTimeoutInterval = 900; //15 minutes

@interface UANativeAdSource () <UANativeAdSourceQueueDelegate>

@property (nonatomic, strong) NSMutableDictionary *adQueueDictionary;

@end

@implementation UANativeAdSource

#pragma mark - Object Lifecycle

+ (instancetype)source
{
    return [[UANativeAdSource alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _adQueueDictionary = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void)dealloc
{
    for (NSString *queueKey in [_adQueueDictionary allKeys]) {
        [self deleteCacheForAdUnitIdentifier:queueKey];
    }
}

#pragma mark - Ad Source Interface

- (void)loadAdsWithAdUnitIdentifier:(NSString *)identifier andTargeting:(UANativeAdRequestTargeting *)targeting
{
    [self deleteCacheForAdUnitIdentifier:identifier];

    UANativeAdSourceQueue *adQueue = [[UANativeAdSourceQueue alloc] initWithAdUnitIdentifier:identifier andTargeting:targeting];
    adQueue.delegate = self;
    [self.adQueueDictionary setObject:adQueue forKey:identifier];

    [adQueue loadAds];
}

- (id)dequeueAdForAdUnitIdentifier:(NSString *)identifier
{
    UANativeAdSourceQueue *adQueue = [self.adQueueDictionary objectForKey:identifier];
    UANativeAd *nextAd = [adQueue dequeueAdWithMaxAge:kCacheTimeoutInterval];
    return nextAd;
}

- (void)deleteCacheForAdUnitIdentifier:(NSString *)identifier
{
    UANativeAdSourceQueue *sourceQueue = [self.adQueueDictionary objectForKey:identifier];
    sourceQueue.delegate = nil;
    [sourceQueue cancelRequests];

    [self.adQueueDictionary removeObjectForKey:identifier];
}

#pragma mark - UANativeAdSourceQueueDelegate

- (void)adSourceQueueAdIsAvailable:(UANativeAdSourceQueue *)source
{
    [self.delegate adSourceDidFinishRequest:self];
}

@end

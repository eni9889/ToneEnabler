//
//  UAMoPubNativeAdAdapter.h
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UANativeAdAdapter.h"

@interface UAMoPubNativeAdAdapter : NSObject <UANativeAdAdapter>

@property (nonatomic, strong) NSArray *impressionTrackers;
@property (nonatomic, strong) NSURL *engagementTrackingURL;

- (instancetype)initWithAdProperties:(NSMutableDictionary *)properties;

@end

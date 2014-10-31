//
//  UAAnalyticsTracker.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UAAdConfiguration;

@interface UAAnalyticsTracker : NSObject

+ (UAAnalyticsTracker *)tracker;

- (void)trackImpressionForConfiguration:(UAAdConfiguration *)configuration;
- (void)trackClickForConfiguration:(UAAdConfiguration *)configuration;

@end

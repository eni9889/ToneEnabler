//
//  UAAnalyticsTracker.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UAAnalyticsTracker.h"
#import "UAAdConfiguration.h"
#import "UACoreInstanceProvider.h"
#import "UALogging.h"

@interface UAAnalyticsTracker ()

- (NSURLRequest *)requestForURL:(NSURL *)URL;

@end

@implementation UAAnalyticsTracker

+ (UAAnalyticsTracker *)tracker
{
    return [[UAAnalyticsTracker alloc] init];
}

- (void)trackImpressionForConfiguration:(UAAdConfiguration *)configuration
{
    UALogDebug(@"Tracking impression: %@", configuration.impressionTrackingURL);
    [NSURLConnection connectionWithRequest:[self requestForURL:configuration.impressionTrackingURL]
                                  delegate:nil];
}

- (void)trackClickForConfiguration:(UAAdConfiguration *)configuration
{
    UALogDebug(@"Tracking click: %@", configuration.clickTrackingURL);
    [NSURLConnection connectionWithRequest:[self requestForURL:configuration.clickTrackingURL]
                                  delegate:nil];
}

- (NSURLRequest *)requestForURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [[UACoreInstanceProvider sharedProvider] buildConfiguredURLRequestWithURL:URL];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    return request;
}

@end

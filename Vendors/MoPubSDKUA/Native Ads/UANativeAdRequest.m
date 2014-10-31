//
//  UANativeAdRequest.m
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UANativeAdRequest.h"

#import "UAAdServerURLBuilder.h"
#import "UACoreInstanceProvider.h"
#import "UANativeAdError.h"
#import "UANativeAd+Internal.h"
#import "UANativeAdRequestTargeting.h"
#import "UALogging.h"
#import "UAImageDownloadQueue.h"
#import "UAConstants.h"
#import "UANativeCustomEventDelegate.h"
#import "UANativeCustomEvent.h"
#import "UAInstanceProvider.h"
#import "NSJSONSerialization+UAAdditions.h"
#import "UAAdServerCommunicator.h"

#import "UAMoPubNativeCustomEvent.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UANativeAdRequest () <UANativeCustomEventDelegate, UAAdServerCommunicatorDelegate>

@property (nonatomic, copy) NSString *adUnitIdentifier;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UAAdServerCommunicator *communicator;
@property (nonatomic, copy) UANativeAdRequestHandler completionHandler;
@property (nonatomic, strong) UANativeCustomEvent *nativeCustomEvent;
@property (nonatomic, strong) UAAdConfiguration *adConfiguration;
@property (nonatomic, assign) BOOL loading;

@end

@implementation UANativeAdRequest

- (id)initWithAdUnitIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _adUnitIdentifier = [identifier copy];
        _communicator = [[UACoreInstanceProvider sharedProvider] buildUAAdServerCommunicatorWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_communicator cancel];
    [_communicator setDelegate:nil];
    [_nativeCustomEvent setDelegate:nil];
}

#pragma mark - Public

+ (UANativeAdRequest *)requestWithAdUnitIdentifier:(NSString *)identifier
{
    return [[self alloc] initWithAdUnitIdentifier:identifier];
}

- (void)startWithCompletionHandler:(UANativeAdRequestHandler)handler
{
    if (handler)
    {
        self.URL = [UAAdServerURLBuilder URLWithAdUnitID:self.adUnitIdentifier
                                                keywords:self.targeting.keywords
                                                location:self.targeting.location
                                    versionParameterName:@"nsv"
                                                 version:UA_SDK_VERSION
                                                 testing:NO
                                           desiredAssets:[self.targeting.desiredAssets allObjects]];

        [self assignCompletionHandler:handler];

        [self loadAdWithURL:self.URL];
    }
    else
    {
        UALogWarn(@"Native Ad Request did not start - requires completion handler block.");
    }
}

- (void)startForAdSequence:(NSInteger)adSequence withCompletionHandler:(UANativeAdRequestHandler)handler
{
    if (handler)
    {
        self.URL = [UAAdServerURLBuilder URLWithAdUnitID:self.adUnitIdentifier
                                                keywords:self.targeting.keywords
                                                location:self.targeting.location
                                    versionParameterName:@"nsv"
                                                 version:UA_SDK_VERSION
                                                 testing:NO
                                           desiredAssets:[self.targeting.desiredAssets allObjects]
                                              adSequence:adSequence];

        [self assignCompletionHandler:handler];

        [self loadAdWithURL:self.URL];
    }
    else
    {
        UALogWarn(@"Native Ad Request did not start - requires completion handler block.");
    }
}

#pragma mark - Private

- (void)assignCompletionHandler:(UANativeAdRequestHandler)handler
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    // we explicitly create a block retain cycle here to prevent self from being deallocated if the developer
    // removes his strong reference to the request. This retain cycle is broken in
    // - (void)completeAdRequestWithAdObject:(UANativeAd *)adObject error:(NSError *)error
    // when self.completionHandler is set to nil.
    self.completionHandler = ^(UANativeAdRequest *request, UANativeAd *response, NSError *error) {
        handler(self, response, error);
    };
#pragma clang diagnostic pop
}

- (void)loadAdWithURL:(NSURL *)URL
{
    if (self.loading) {
        UALogWarn(@"Native ad request is already loading an ad. Wait for previous load to finish.");
        return;
    }

    UALogInfo(@"Starting ad request with URL: %@", self.URL);

    self.loading = YES;
    [self.communicator loadURL:URL];
}

- (void)getAdWithConfiguration:(UAAdConfiguration *)configuration
{
    if (configuration.customEventClass) {
        UALogInfo(@"Looking for custom event class named %@.", configuration.customEventClass);
    }

    // Adserver doesn't return a customEventClass for MoPub native ads
    if ([configuration.networkType isEqualToString:kAdTypeNative] && configuration.customEventClass == nil) {
        configuration.customEventClass = [UAMoPubNativeCustomEvent class];
        NSDictionary *classData = [NSJSONSerialization mp_JSONObjectWithData:configuration.adResponseData options:0 clearNullObjects:YES error:nil];
        configuration.customEventClassData = classData;
    }

    self.nativeCustomEvent = [[UAInstanceProvider sharedProvider] buildNativeCustomEventFromCustomClass:configuration.customEventClass delegate:self];

    if (self.nativeCustomEvent) {
        [self.nativeCustomEvent requestAdWithCustomEventInfo:configuration.customEventClassData];
    } else if ([[self.adConfiguration.failoverURL absoluteString] length]) {
        self.loading = NO;
        [self loadAdWithURL:self.adConfiguration.failoverURL];
    } else {
        [self completeAdRequestWithAdObject:nil error:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:UANativeAdErrorInvalidServerResponse userInfo:nil]];
    }
}

- (void)completeAdRequestWithAdObject:(UANativeAd *)adObject error:(NSError *)error
{
    self.loading = NO;

    if (!error) {
        UALogInfo(@"Successfully loaded native ad.");
    } else {
        UALogError(@"Native ad failed to load with error: %@", error);
    }

    if (self.completionHandler) {
        self.completionHandler(self, adObject, error);
        self.completionHandler = nil;
    }
}

#pragma mark - <UAAdServerCommunicatorDelegate>

- (void)communicatorDidReceiveAdConfiguration:(UAAdConfiguration *)configuration
{
    self.adConfiguration = configuration;

    if ([configuration.networkType isEqualToString:kAdTypeClear]) {
        UALogInfo(kUAClearErrorLogFormatWithAdUnitID, self.adUnitIdentifier);

        [self completeAdRequestWithAdObject:nil error:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:UANativeAdErrorNoInventory userInfo:nil]];
    }
    else {
        UALogInfo(@"Received data from MoPub to construct native ad.\n");
        [self getAdWithConfiguration:configuration];
    }
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    UALogDebug(@"Error: Couldn't retrieve an ad from MoPub. Message: %@", error);

    [self completeAdRequestWithAdObject:nil error:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:UANativeAdErrorHTTPError userInfo:nil]];
}

#pragma mark - <UANativeCustomEventDelegate>

- (void)nativeCustomEvent:(UANativeCustomEvent *)event didLoadAd:(UANativeAd *)adObject
{
    // Take the click tracking URL from the header if the ad object doesn't already have one.
    [adObject setEngagementTrackingURL:(adObject.engagementTrackingURL ? : self.adConfiguration.clickTrackingURL)];

    // Add the impression tracker from the header to our set.
    if (self.adConfiguration.impressionTrackingURL) {
        [adObject.impressionTrackers addObject:[self.adConfiguration.impressionTrackingURL absoluteString]];
    }

    // Error if we don't have click tracker or impression trackers.
    if (!adObject.engagementTrackingURL || adObject.impressionTrackers.count < 1) {
        [self completeAdRequestWithAdObject:nil error:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:UANativeAdErrorInvalidServerResponse userInfo:nil]];
    } else {
        [self completeAdRequestWithAdObject:adObject error:nil];
    }
}

- (void)nativeCustomEvent:(UANativeCustomEvent *)event didFailToLoadAdWithError:(NSError *)error
{
    if ([[self.adConfiguration.failoverURL absoluteString] length]) {
        self.loading = NO;
        [self loadAdWithURL:self.adConfiguration.failoverURL];
    } else {
        [self completeAdRequestWithAdObject:nil error:error];
    }
}


@end

//
//  UACoreInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UACoreInstanceProvider.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "UAAdServerCommunicator.h"
#import "UAURLResolver.h"
#import "UAAdDestinationDisplayAgent.h"
#import "UAReachability.h"
#import "UATimer.h"
#import "UAAnalyticsTracker.h"


#define MOPUB_CARRIER_INFO_DEFAULTS_KEY @"com.mopub.carrierinfo"


typedef enum
{
    UATwitterDeepLinkNotChecked,
    UATwitterDeepLinkEnabled,
    UATwitterDeepLinkDisabled
} UATwitterDeepLink;

@interface UACoreInstanceProvider ()

@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, strong) NSMutableDictionary *singletons;
@property (nonatomic, strong) NSMutableDictionary *carrierInfo;
@property (nonatomic, assign) UATwitterDeepLink twitterDeepLinkStatus;

@end

@implementation UACoreInstanceProvider

@synthesize userAgent = _userAgent;
@synthesize singletons = _singletons;
@synthesize carrierInfo = _carrierInfo;
@synthesize twitterDeepLinkStatus = _twitterDeepLinkStatus;

static UACoreInstanceProvider *sharedProvider = nil;

+ (instancetype)sharedProvider
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedProvider = [[self alloc] init];
    });

    return sharedProvider;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.singletons = [NSMutableDictionary dictionary];

        [self initializeCarrierInfo];
    }
    return self;
}


- (id)singletonForClass:(Class)klass provider:(UASingletonProviderBlock)provider
{
    id singleton = [self.singletons objectForKey:klass];
    if (!singleton) {
        singleton = provider();
        [self.singletons setObject:singleton forKey:(id<NSCopying>)klass];
    }
    return singleton;
}

// This method ensures that "anObject" is retained until the next runloop iteration when
// performNoOp: is executed.
//
// This is useful in situations where, potentially due to a callback chain reaction, an object
// is synchronously deallocated as it's trying to do more work, especially invoking self, after
// the callback.
- (void)keepObjectAliveForCurrentRunLoopIteration:(id)anObject
{
    [self performSelector:@selector(performNoOp:) withObject:anObject afterDelay:0];
}

- (void)performNoOp:(id)anObject
{
    ; // noop
}

#pragma mark - Initializing Carrier Info

- (void)initializeCarrierInfo
{
    self.carrierInfo = [NSMutableDictionary dictionary];

    // check if we have a saved copy
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:MOPUB_CARRIER_INFO_DEFAULTS_KEY];
    if(saved != nil) {
        [self.carrierInfo addEntriesFromDictionary:saved];
    }

    // now asynchronously load a fresh copy
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        [self performSelectorOnMainThread:@selector(updateCarrierInfoForCTCarrier:) withObject:networkInfo.subscriberCellularProvider waitUntilDone:NO];
    });
}

- (void)updateCarrierInfoForCTCarrier:(CTCarrier *)ctCarrier
{
    // use setValue instead of setObject here because ctCarrier could be nil, and any of its properties could be nil
    [self.carrierInfo setValue:ctCarrier.carrierName forKey:@"carrierName"];
    [self.carrierInfo setValue:ctCarrier.isoCountryCode forKey:@"isoCountryCode"];
    [self.carrierInfo setValue:ctCarrier.mobileCountryCode forKey:@"mobileCountryCode"];
    [self.carrierInfo setValue:ctCarrier.mobileNetworkCode forKey:@"mobileNetworkCode"];

    [[NSUserDefaults standardUserDefaults] setObject:self.carrierInfo forKey:MOPUB_CARRIER_INFO_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Fetching Ads
- (NSMutableURLRequest *)buildConfiguredURLRequestWithURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPShouldHandleCookies:YES];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    return request;
}

- (NSString *)userAgent
{
    if (!_userAgent) {
        self.userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }

    return _userAgent;
}

- (UAAdServerCommunicator *)buildUAAdServerCommunicatorWithDelegate:(id<UAAdServerCommunicatorDelegate>)delegate
{
    return [(UAAdServerCommunicator *)[UAAdServerCommunicator alloc] initWithDelegate:delegate];
}


#pragma mark - URL Handling

- (UAURLResolver *)buildUAURLResolver
{
    return [UAURLResolver resolver];
}

- (UAAdDestinationDisplayAgent *)buildUAAdDestinationDisplayAgentWithDelegate:(id<UAAdDestinationDisplayAgentDelegate>)delegate
{
    return [UAAdDestinationDisplayAgent agentWithDelegate:delegate];
}

#pragma mark - Utilities

- (id<UAAdAlertManagerProtocol>)buildUAAdAlertManagerWithDelegate:(id)delegate
{
    id<UAAdAlertManagerProtocol> adAlertManager = nil;

    Class adAlertManagerClass = NSClassFromString(@"UAAdAlertManager");
    if(adAlertManagerClass != nil)
    {
        adAlertManager = [[adAlertManagerClass alloc] init];
        [adAlertManager performSelector:@selector(setDelegate:) withObject:delegate];
    }

    return adAlertManager;
}

- (UAAdAlertGestureRecognizer *)buildUAAdAlertGestureRecognizerWithTarget:(id)target action:(SEL)action
{
    UAAdAlertGestureRecognizer *gestureRecognizer = nil;

    Class gestureRecognizerClass = NSClassFromString(@"UAAdAlertGestureRecognizer");
    if(gestureRecognizerClass != nil)
    {
        gestureRecognizer = [[gestureRecognizerClass alloc] initWithTarget:target action:action];
    }

    return gestureRecognizer;
}

- (NSOperationQueue *)sharedOperationQueue
{
    static NSOperationQueue *sharedOperationQueue = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedOperationQueue = [[NSOperationQueue alloc] init];
    });

    return sharedOperationQueue;
}

- (UAAnalyticsTracker *)sharedUAAnalyticsTracker
{
    return [self singletonForClass:[UAAnalyticsTracker class] provider:^id{
        return [UAAnalyticsTracker tracker];
    }];
}

- (UAReachability *)sharedUAReachability
{
    return [self singletonForClass:[UAReachability class] provider:^id{
        return [UAReachability reachabilityForLocalWiFi];
    }];
}

- (NSDictionary *)sharedCarrierInfo
{
    return self.carrierInfo;
}

- (UATimer *)buildUATimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats
{
    return [UATimer timerWithTimeInterval:seconds target:target selector:selector repeats:repeats];
}

#pragma mark - Twitter Availability

- (void)resetTwitterAppInstallCheck
{
    self.twitterDeepLinkStatus = UATwitterDeepLinkNotChecked;
}

- (BOOL)isTwitterInstalled
{

    if (self.twitterDeepLinkStatus == UATwitterDeepLinkNotChecked)
    {
        BOOL twitterDeepLinkEnabled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://timeline"]];
        if (twitterDeepLinkEnabled)
        {
            self.twitterDeepLinkStatus = UATwitterDeepLinkEnabled;
        }
        else
        {
            self.twitterDeepLinkStatus = UATwitterDeepLinkDisabled;
        }
    }

    return (self.twitterDeepLinkStatus == UATwitterDeepLinkEnabled);
}

+ (BOOL)deviceHasTwitterIntegration
{
    return !![UACoreInstanceProvider tweetComposeVCClass];
}

+ (Class)tweetComposeVCClass
{
    return NSClassFromString(@"TWTweetComposeViewController");
}

- (BOOL)isNativeTwitterAccountPresent
{
    BOOL nativeTwitterAccountPresent = NO;
    if ([UACoreInstanceProvider deviceHasTwitterIntegration])
    {
        nativeTwitterAccountPresent = (BOOL)[[UACoreInstanceProvider tweetComposeVCClass] performSelector:@selector(canSendTweet)];
    }

    return nativeTwitterAccountPresent;
}

- (UATwitterAvailability)twitterAvailabilityOnDevice
{
    UATwitterAvailability twitterAvailability = UATwitterAvailabilityNone;

    if ([self isTwitterInstalled])
    {
        twitterAvailability |= UATwitterAvailabilityApp;
    }

    if ([self isNativeTwitterAccountPresent])
    {
        twitterAvailability |= UATwitterAvailabilityNative;
    }

    return twitterAvailability;
}



@end

//
//  UANativePositionSource.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UANativePositionSource.h"
#import "UAConstants.h"
#import "UAIdentityProvider.h"
#import "UAAdPositioning.h"
#import "UAClientAdPositioning.h"
#import "UALogging.h"
#import "UANativePositionResponseDeserializer.h"

static NSString * const kPositioningSourceErrorDomain = @"com.mopub.iossdk.positioningsource";
static const NSTimeInterval kMaximumRetryInterval = 60.0;
static const NSTimeInterval kMinimumRetryInterval = 1.0;
static const CGFloat kRetryIntervalBackoffMultiplier = 2.0;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UANativePositionSource () <NSURLConnectionDataDelegate>

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, copy) NSString *adUnitIdentifier;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, copy) void (^completionHandler)(UAAdPositioning *positioning, NSError *error);
@property (nonatomic, assign) NSTimeInterval maximumRetryInterval;
@property (nonatomic, assign) NSTimeInterval minimumRetryInterval;
@property (nonatomic, assign) NSTimeInterval retryInterval;
@property (nonatomic, assign) NSUInteger retryCount;

- (NSURL *)serverURLWithAdUnitIdentifier:(NSString *)identifier;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UANativePositionSource

- (id)init
{
    if (self) {
        self.maximumRetryInterval = kMaximumRetryInterval;
        self.minimumRetryInterval = kMinimumRetryInterval;
        self.retryInterval = self.minimumRetryInterval;
    }
    return self;
}

- (void)dealloc
{
    [_connection cancel];
}

#pragma mark - Public

- (void)loadPositionsWithAdUnitIdentifier:(NSString *)identifier completionHandler:(void (^)(UAAdPositioning *positioning, NSError *error))completionHandler
{
    NSAssert(completionHandler != nil, @"A completion handler is required to load positions.");

    if (![identifier length]) {
        NSError *invalidIDError = [NSError errorWithDomain:kPositioningSourceErrorDomain code:UANativePositionSourceInvalidAdUnitIdentifier userInfo:nil];
        completionHandler(nil, invalidIDError);
        return;
    }

    self.adUnitIdentifier = identifier;
    self.completionHandler = completionHandler;
    self.retryCount = 0;
    self.retryInterval = self.minimumRetryInterval;

    UALogInfo(@"Requesting ad positions for native ad unit (%@).", identifier);

    NSURLRequest *request = [NSURLRequest requestWithURL:[self serverURLWithAdUnitIdentifier:identifier]];
    [self.connection cancel];
    [self.data setLength:0];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)cancel
{
    // Cancel any connection currently in flight.
    [self.connection cancel];

    // Cancel any queued retry requests.
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - Internal

- (NSURL *)serverURLWithAdUnitIdentifier:(NSString *)identifier
{
    NSString *URLString = [NSString stringWithFormat:@"http://%@/m/pos?id=%@&v=%@&nsv=%@&udid=%@", HOSTNAME, identifier, UA_SERVER_VERSION, UA_SDK_VERSION, [UAIdentityProvider identifier]];
    return [NSURL URLWithString:URLString];
}

- (void)retryLoadingPositions
{
    self.retryCount++;

    UALogInfo(@"Retrying positions (retry attempt #%lu).", (unsigned long)self.retryCount);

    NSURLRequest *request = [NSURLRequest requestWithURL:[self serverURLWithAdUnitIdentifier:self.adUnitIdentifier]];
    [self.connection cancel];
    [self.data setLength:0];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - <NSURLConnectionDataDelegate>

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.retryInterval >= self.maximumRetryInterval) {
        self.completionHandler(nil, error);
        self.completionHandler = nil;
    } else {
        [self performSelector:@selector(retryLoadingPositions) withObject:nil afterDelay:self.retryInterval];
        self.retryInterval = MIN(self.retryInterval * kRetryIntervalBackoffMultiplier, self.maximumRetryInterval);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!self.data) {
        self.data = [NSMutableData data];
    }

    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *deserializationError = nil;
    UAClientAdPositioning *positioning = [[UANativePositionResponseDeserializer deserializer] clientPositioningForData:self.data error:&deserializationError];

    if (deserializationError) {
        UALogDebug(@"Position deserialization failed with error: %@", deserializationError);

        NSError *underlyingError = [[deserializationError userInfo] objectForKey:NSUnderlyingErrorKey];
        if ([underlyingError code] == UANativePositionResponseDataIsEmpty) {
            // Empty response data means the developer hasn't assigned any ad positions for the ad
            // unit. No point in retrying the request.
            self.completionHandler(nil, [NSError errorWithDomain:kPositioningSourceErrorDomain code:UANativePositionSourceEmptyResponse userInfo:nil]);
            self.completionHandler = nil;
        } else if (self.retryInterval >= self.maximumRetryInterval) {
            self.completionHandler(nil, deserializationError);
            self.completionHandler = nil;
        } else {
            [self performSelector:@selector(retryLoadingPositions) withObject:nil afterDelay:self.retryInterval];
            self.retryInterval = MIN(self.retryInterval * kRetryIntervalBackoffMultiplier, self.maximumRetryInterval);
        }

        return;
    }

    self.completionHandler(positioning, nil);
    self.completionHandler = nil;
}

@end

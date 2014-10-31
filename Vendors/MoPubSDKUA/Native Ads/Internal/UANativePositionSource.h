//
//  UANativePositionSource.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UAAdPositioning;

typedef enum : NSUInteger {
    UANativePositionSourceInvalidAdUnitIdentifier,
    UANativePositionSourceEmptyResponse,
    UANativePositionSourceDeserializationFailed,
    UANativePositionSourceConnectionFailed,
} UANativePositionSourceErrorCode;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UANativePositionSource : NSObject

- (void)loadPositionsWithAdUnitIdentifier:(NSString *)identifier completionHandler:(void (^)(UAAdPositioning *positioning, NSError *error))completionHandler;
- (void)cancel;

@end

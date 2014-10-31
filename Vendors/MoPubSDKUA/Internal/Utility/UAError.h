//
//  UAAdRequestError.h
//  MoPub
//
//  Copyright (c) 2012 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kUAErrorDomain;

typedef enum {
    UAErrorNoInventory = 0,
    UAErrorNetworkTimedOut = 4,
    UAErrorServerError = 8,
    UAErrorAdapterNotFound = 16,
    UAErrorAdapterInvalid = 17,
    UAErrorAdapterHasNoInventory = 18
} UAErrorCode;

@interface UAError : NSError

+ (UAError *)errorWithCode:(UAErrorCode)code;

@end

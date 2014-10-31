//
//  UAAdRequestError.m
//  MoPub
//
//  Copyright (c) 2012 MoPub. All rights reserved.
//

#import "UAError.h"

NSString * const kUAErrorDomain = @"com.mopub.iossdk";

@implementation UAError

+ (UAError *)errorWithCode:(UAErrorCode)code
{
    return [self errorWithDomain:kUAErrorDomain code:code userInfo:nil];
}

@end

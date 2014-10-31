//
//  UAIdentityProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UAIdentityProvider : NSObject

+ (NSString *)identifier;
+ (NSString *)obfuscatedIdentifier;
+ (BOOL)advertisingTrackingEnabled;

@end

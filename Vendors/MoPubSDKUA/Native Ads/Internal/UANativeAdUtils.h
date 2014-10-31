//
//  UANativeAdUtils.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSTimeInterval const kUpdateVisibleCellsInterval;

@interface UANativeAdUtils : NSObject

+ (BOOL)addURLString:(NSString *)urlString toURLArray:(NSMutableArray *)urlArray;

@end

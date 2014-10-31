//
//  UAAdPositioning.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UAAdPositioning : NSObject <NSCopying>

@property (nonatomic, assign) NSUInteger repeatingInterval;
@property (nonatomic, strong, readonly) NSMutableOrderedSet *fixedPositions;

@end

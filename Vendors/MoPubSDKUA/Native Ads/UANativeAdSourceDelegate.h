//
//  UANativeAdSourceDelegate.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UANativeAdSource;

@protocol UANativeAdSourceDelegate <NSObject>

- (void)adSourceDidFinishRequest:(UANativeAdSource *)source;

@end

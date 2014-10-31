//
//  UANativeAdData.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UANativeAd;

@interface UANativeAdData : NSObject

@property (nonatomic, copy) NSString *adUnitID;
@property (nonatomic, strong) UANativeAd *ad;
@property (nonatomic, assign) Class renderingClass;

@end

//
//  UAMRAIDBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UABannerCustomEvent.h"
#import "MRAdView.h"
#import "UAPrivateBannerCustomEventDelegate.h"

@interface UAMRAIDBannerCustomEvent : UABannerCustomEvent <MRAdViewDelegate>

@property (nonatomic, weak) id<UAPrivateBannerCustomEventDelegate> delegate;

@end

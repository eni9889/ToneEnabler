//
//  UAHTMLBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UABannerCustomEvent.h"
#import "UAAdWebViewAgent.h"
#import "UAPrivateBannerCustomEventDelegate.h"

@interface UAHTMLBannerCustomEvent : UABannerCustomEvent <UAAdWebViewAgentDelegate>

@property (nonatomic, weak) id<UAPrivateBannerCustomEventDelegate> delegate;

@end

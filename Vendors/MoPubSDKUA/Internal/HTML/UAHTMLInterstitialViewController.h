//
//  UAHTMLInterstitialViewController.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UAAdWebViewAgent.h"
#import "UAInterstitialViewController.h"

@class UAAdConfiguration;

@interface UAHTMLInterstitialViewController : UAInterstitialViewController <UAAdWebViewAgentDelegate>

@property (nonatomic, strong) UAAdWebViewAgent *backingViewAgent;
@property (nonatomic, weak) id customMethodDelegate;

- (void)loadConfiguration:(UAAdConfiguration *)configuration;

@end

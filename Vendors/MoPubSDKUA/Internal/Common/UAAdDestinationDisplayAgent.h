//
//  UAAdDestinationDisplayAgent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAURLResolver.h"
#import "UAProgressOverlayView.h"
#import "UAAdBrowserController.h"
#import "UAStoreKitProvider.h"

@protocol UAAdDestinationDisplayAgentDelegate;

@interface UAAdDestinationDisplayAgent : NSObject <UAURLResolverDelegate, UAProgressOverlayViewDelegate, UAAdBrowserControllerDelegate, UASKStoreProductViewControllerDelegate>

@property (nonatomic, weak) id<UAAdDestinationDisplayAgentDelegate> delegate;

+ (UAAdDestinationDisplayAgent *)agentWithDelegate:(id<UAAdDestinationDisplayAgentDelegate>)delegate;
- (void)displayDestinationForURL:(NSURL *)URL;
- (void)cancel;

@end

@protocol UAAdDestinationDisplayAgentDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;
- (void)displayAgentWillPresentModal;
- (void)displayAgentWillLeaveApplication;
- (void)displayAgentDidDismissModal;

@end

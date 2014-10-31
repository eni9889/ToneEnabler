//
//  UAAdServerCommunicator.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UAAdConfiguration.h"
#import "UAGlobal.h"

@protocol UAAdServerCommunicatorDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////////

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= UA_IOS_5_0
@interface UAAdServerCommunicator : NSObject <NSURLConnectionDataDelegate>
#else
@interface UAAdServerCommunicator : NSObject
#endif

@property (nonatomic, weak) id<UAAdServerCommunicatorDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL loading;

- (id)initWithDelegate:(id<UAAdServerCommunicatorDelegate>)delegate;

- (void)loadURL:(NSURL *)URL;
- (void)cancel;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol UAAdServerCommunicatorDelegate <NSObject>

@required
- (void)communicatorDidReceiveAdConfiguration:(UAAdConfiguration *)configuration;
- (void)communicatorDidFailWithError:(NSError *)error;

@end

//
//  UAURLResolver.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAGlobal.h"

@protocol UAURLResolverDelegate;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= UA_IOS_5_0
@interface UAURLResolver : NSObject <NSURLConnectionDataDelegate>
#else
@interface UAURLResolver : NSObject
#endif

@property (nonatomic, weak) id<UAURLResolverDelegate> delegate;

+ (UAURLResolver *)resolver;
- (void)startResolvingWithURL:(NSURL *)URL delegate:(id<UAURLResolverDelegate>)delegate;
- (void)cancel;

@end

@protocol UAURLResolverDelegate <NSObject>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL;
- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL;
- (void)openURLInApplication:(NSURL *)URL;
- (void)failedToResolveURLWithError:(NSError *)error;

@end

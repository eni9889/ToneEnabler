//
//  UANativeCustomEvent.m
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UANativeCustomEvent.h"
#import "UANativeAdError.h"
#import "UAImageDownloadQueue.h"
#import "UALogging.h"

@interface UANativeCustomEvent ()

@property (nonatomic, strong) UAImageDownloadQueue *imageDownloadQueue;

@end

@implementation UANativeCustomEvent

- (id)init
{
    self = [super init];
    if (self) {
        _imageDownloadQueue = [[UAImageDownloadQueue alloc] init];
    }

    return self;
}

- (void)precacheImagesWithURLs:(NSArray *)imageURLs completionBlock:(void (^)(NSArray *errors))completionBlock
{
    if (imageURLs.count > 0) {
        [_imageDownloadQueue addDownloadImageURLs:imageURLs completionBlock:^(NSArray *errors) {
            if (completionBlock) {
                completionBlock(errors);
            }
        }];
    }
    else {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    /*override with custom network behavior*/
}

@end

//
//  UAImageDownloadQueue.m
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UAImageDownloadQueue.h"
#import "UANativeAdError.h"
#import "UALogging.h"
#import "UANativeCache.h"

#define kMaxAllowedUIImageSize (1024 * 1024)

@interface UAImageDownloadQueue ()

@property (atomic, strong) NSOperationQueue *imageDownloadQueue;
@property (atomic, assign) BOOL isCanceled;

@end

@implementation UAImageDownloadQueue

- (id)init
{
    self = [super init];

    if (self != nil) {
        _imageDownloadQueue = [[NSOperationQueue alloc] init];
        [_imageDownloadQueue setMaxConcurrentOperationCount:1]; // serial queue
    }

    return self;
}

- (void)dealloc
{
    [_imageDownloadQueue cancelAllOperations];
}

- (void)addDownloadImageURLs:(NSArray *)imageURLs completionBlock:(UAImageDownloadQueueCompletionBlock)completionBlock
{
    [self addDownloadImageURLs:imageURLs completionBlock:completionBlock useCachedImage:YES];
}

- (void)addDownloadImageURLs:(NSArray *)imageURLs completionBlock:(UAImageDownloadQueueCompletionBlock)completionBlock useCachedImage:(BOOL)useCachedImage
{
    __block NSMutableArray *errors = nil;

    for (NSURL *imageURL in imageURLs) {
        [self.imageDownloadQueue addOperationWithBlock:^{
            @autoreleasepool {
                if (![[UANativeCache sharedCache] cachedDataExistsForKey:imageURL.absoluteString] || !useCachedImage) {
                    UALogDebug(@"Downloading %@", imageURL);

                    NSURLResponse *response = nil;
                    NSError *error = nil;
                    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:imageURL]
                                                         returningResponse:&response
                                                                     error:&error];

                    BOOL validImageDownloaded = data != nil;
                    if (validImageDownloaded) {
                        UIImage *downloadedImage = [UIImage imageWithData:data];
                        BOOL validImageSize = downloadedImage.size.width * downloadedImage.size.height <= kMaxAllowedUIImageSize;
                        if (downloadedImage != nil && validImageSize) {
                            [[UANativeCache sharedCache] storeData:data forKey:imageURL.absoluteString];
                        } else {
                            if (downloadedImage == nil) {
                                UALogDebug(@"Error: invalid image data downloaded");
                            } else if (!validImageSize) {
                                UALogDebug(@"Error: image data exceeds acceptable size limit of 1 UA (actual: %@)", NSStringFromCGSize(downloadedImage.size));
                            }

                            validImageDownloaded = NO;
                        }
                    }

                    if (!validImageDownloaded) {
                        if (error == nil) {
                            error = [NSError errorWithDomain:MoPubNativeAdsSDKDomain code:UANativeAdErrorImageDownloadFailed userInfo:nil];
                        }

                        if (errors == nil) {
                            errors = [NSMutableArray array];
                        }

                        [errors addObject:error];
                    }
                }
            }
        }];
    }

    // after all images have been downloaded, invoke callback on main thread
    [self.imageDownloadQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.isCanceled) {
                completionBlock(errors);
            }
        });
    }];
}

- (void)cancelAllDownloads
{
    self.isCanceled = YES;
    [self.imageDownloadQueue cancelAllOperations];
}

@end

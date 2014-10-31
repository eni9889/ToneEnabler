//
//  UAImageDownloadQueue.h
// 
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UAImageDownloadQueueCompletionBlock)(NSArray *errors);

@interface UAImageDownloadQueue : NSObject

// pass useCachedImage:NO to force download of images. default is YES, cached images will not be re-downloaded
- (void)addDownloadImageURLs:(NSArray *)imageURLs completionBlock:(UAImageDownloadQueueCompletionBlock)completionBlock;
- (void)addDownloadImageURLs:(NSArray *)imageURLs completionBlock:(UAImageDownloadQueueCompletionBlock)completionBlock useCachedImage:(BOOL)useCachedImage;

- (void)cancelAllDownloads;

@end

//
//  UANativeCache.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UANativeCache.h"
#import "UADiskLRUCache.h"
#import "UALogging.h"

typedef enum {
    UANativeCacheMethodDisk = 0,
    UANativeCacheMethodDiskAndMemory = 1 << 0
} UANativeCacheMethod;

@interface UANativeCache () <NSCacheDelegate>

@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) UADiskLRUCache *diskCache;
@property (nonatomic, assign) UANativeCacheMethod cacheMethod;

- (BOOL)cachedDataExistsForKey:(NSString *)key withCacheMethod:(UANativeCacheMethod)cacheMethod;
- (NSData *)retrieveDataForKey:(NSString *)key withCacheMethod:(UANativeCacheMethod)cacheMethod;
- (void)storeData:(id)data forKey:(NSString *)key withCacheMethod:(UANativeCacheMethod)cacheMethod;
- (void)removeAllDataFromMemory;
- (void)removeAllDataFromDisk;

@end

@implementation UANativeCache

+ (instancetype)sharedCache;
{
    static dispatch_once_t once;
    static UANativeCache *sharedCache;
    dispatch_once(&once, ^{
        sharedCache = [[self alloc] init];
    });
    return sharedCache;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.delegate = self;

        _diskCache = [[UADiskLRUCache alloc] init];

        _cacheMethod = UANativeCacheMethodDiskAndMemory;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication]];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

#pragma mark - Public Cache Interactions

- (void)setInMemoryCacheEnabled:(BOOL)enabled
{
    if (enabled) {
        self.cacheMethod = UANativeCacheMethodDiskAndMemory;
    }
    else {
        self.cacheMethod = UANativeCacheMethodDisk;
        [self.memoryCache removeAllObjects];
    }
}

- (BOOL)cachedDataExistsForKey:(NSString *)key
{
    return [self cachedDataExistsForKey:key withCacheMethod:self.cacheMethod];
}

- (NSData *)retrieveDataForKey:(NSString *)key
{
    return [self retrieveDataForKey:key withCacheMethod:self.cacheMethod];
}

- (void)storeData:(NSData *)data forKey:(NSString *)key
{
    [self storeData:data forKey:key withCacheMethod:self.cacheMethod];
}

- (void)removeAllDataFromCache
{
    [self removeAllDataFromMemory];
    [self removeAllDataFromDisk];
}

#pragma mark - Private Cache Implementation

- (BOOL)cachedDataExistsForKey:(NSString *)key withCacheMethod:(UANativeCacheMethod)cacheMethod
{
    BOOL dataExists = NO;
    if (cacheMethod & UANativeCacheMethodDiskAndMemory) {
        dataExists = [self.memoryCache objectForKey:key] != nil;
    }

    if (!dataExists) {
        dataExists = [self.diskCache cachedDataExistsForKey:key];
    }

    return dataExists;
}

- (id)retrieveDataForKey:(NSString *)key withCacheMethod:(UANativeCacheMethod)cacheMethod
{
    id data = nil;

    if (cacheMethod & UANativeCacheMethodDiskAndMemory) {
        data = [self.memoryCache objectForKey:key];
    }

    if (data) {
        UALogDebug(@"RETRIEVE FROM MEMORY: %@", key);
    }


    if (data == nil) {
        data = [self.diskCache retrieveDataForKey:key];

        if (data && cacheMethod & UANativeCacheMethodDiskAndMemory) {
            UALogDebug(@"RETRIEVE FROM DISK: %@", key);

            [self.memoryCache setObject:data forKey:key];
            UALogDebug(@"STORED IN MEMORY: %@", key);
        }
    }

    if (data == nil) {
        UALogDebug(@"RETRIEVE FAILED: %@", key);
    }

    return data;
}

- (void)storeData:(id)data forKey:(NSString *)key withCacheMethod:(UANativeCacheMethod)cacheMethod
{
    if (data == nil) {
        return;
    }

    if (cacheMethod & UANativeCacheMethodDiskAndMemory) {
        [self.memoryCache setObject:data forKey:key];
        UALogDebug(@"STORED IN MEMORY: %@", key);
    }

    [self.diskCache storeData:data forKey:key];
    UALogDebug(@"STORED ON DISK: %@", key);
}

- (void)removeAllDataFromMemory
{
    [self.memoryCache removeAllObjects];
}

- (void)removeAllDataFromDisk
{
    [self.diskCache removeAllCachedFiles];
}

#pragma mark - Notifications

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    [self.memoryCache removeAllObjects];
}

#pragma mark - NSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    UALogDebug(@"Evicting Object");
}


@end

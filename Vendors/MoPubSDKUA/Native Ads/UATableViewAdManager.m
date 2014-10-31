//
//  UATableViewAdManager.m
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UATableViewAdManager.h"

#import "UATableViewCellImpressionTracker.h"
#import "UANativeAd+Internal.h"
#import "UALogging.h"
#import "UANativeAdRendering.h"
#import "UIView+UANativeAd.h"

@interface UATableViewAdManager () <UATableViewCellImpressionTrackerDelegate>

@property (nonatomic, strong) NSMutableSet *ads;
@property (nonatomic, strong) NSMutableSet *cells;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UATableViewCellImpressionTracker *impressionTracker;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UATableViewAdManager

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        _tableView = tableView;
        _impressionTracker = [[UATableViewCellImpressionTracker alloc] initWithTableView:tableView
                                                                                 delegate:self];
        [_impressionTracker startTracking];

        _ads = [[NSMutableSet alloc] init];
        _cells = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self removeAssociatedAdObjectsFromCells];

    [_impressionTracker stopTracking];
}

- (void)removeAssociatedAdObjectsFromCells
{
    for (UITableViewCell *cell in _cells) {
        [cell mp_removeNativeAd];
    }
}

- (UITableViewCell *)adCellForAd:(UANativeAd *)adObject cellClass:(Class)cellClass
{
    NSString *identifier = [NSString stringWithFormat:@"UA_Cell_Class_%@", NSStringFromClass(cellClass)];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [self.cells addObject:cell];
    }

    [self.ads addObject:adObject];
    [cell mp_setNativeAd:adObject];

    if ([cell conformsToProtocol:@protocol(UANativeAdRendering)]) {
        [adObject willAttachToView:cell];
        [(id<UANativeAdRendering>)cell layoutAdAssets:adObject];
    } else {
        UALogWarn(@"A cell class (%@) passed to -adCellForAd:cellClass: does not conform to the "
                  @"UANativeAdRendering protocol. The resultant cell will not display any ad assets.",
                  NSStringFromClass(cellClass));
    }

    return cell;
}

#pragma mark - <UATableViewCellImpressionTracker>

- (void)tracker:(UATableViewCellImpressionTracker *)tracker didDetectVisibleRowsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableSet *visibleAds = [NSMutableSet set];

    for (NSIndexPath *path in indexPaths) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        if ([self.cells containsObject:cell]) {
            UANativeAd *ad = [cell mp_nativeAd];

            // Edge case: if the same ad is being displayed in multiple on-screen cells,
            // simultaneously, don't set its visibility more than once (side effects).
            if (![visibleAds containsObject:ad]) {
                ad.visible = YES;
                [visibleAds addObject:ad];
            }
        }
    }

    NSMutableSet *invisibleAds = [NSMutableSet setWithSet:self.ads];
    [invisibleAds minusSet:visibleAds];

    for (UANativeAd *ad in invisibleAds) {
        ad.visible = NO;
    }
}

@end

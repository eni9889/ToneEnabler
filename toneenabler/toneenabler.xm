//
//  ToneEnabler.xm
//
//  Created by eni9889 on 12-24-2013.
//  Copyright 2013 UnlimApps Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAAdView.h"
#include "stdio.h"
#include "dlfcn.h"

#define kWebViewTag 232343

@interface TKTonePickerViewController : UITableViewController <UAAdViewDelegate>
-(UAAdView *)getAdView;
@end

@interface SoundsPrefController : UIViewController <UAAdViewDelegate>
@property (nonatomic, strong) UITableView *table;
-(UAAdView *)getAdView;
@end

%group IOS7

%hook TKToneTableController

- (id)loadRingtonesFromPlist
{
    NSDictionary *original = %orig;
    
    NSMutableDictionary *allRingtones = [NSMutableDictionary dictionary];
    NSMutableArray *classicRingtones = [NSMutableArray arrayWithArray:[original objectForKey:@"classic"]];
    NSMutableArray *modernRingtones = [NSMutableArray arrayWithArray:[original objectForKey:@"modern"]];
    
    NSString *tonesDirectory = @"/Library/Ringtones";
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum  = [localFileManager enumeratorAtPath:tonesDirectory];
    
    NSString *file;
    while ((file = [dirEnum nextObject]))
    {
        if ([[file pathExtension] isEqualToString: @"m4r"])
        {
            NSString *properToneIdentifier = [NSString stringWithFormat:@"system:%@",[file stringByDeletingPathExtension]];
            BOOL isClassicTone = [classicRingtones containsObject:properToneIdentifier];
            BOOL isModernTone  = [modernRingtones containsObject:properToneIdentifier];
            
            if(!isClassicTone && !isModernTone)
            {
                [modernRingtones addObject:properToneIdentifier];
            }
        }
    }
    
    [allRingtones setObject:classicRingtones forKey:@"classic"];
    [allRingtones setObject:modernRingtones  forKey:@"modern"];
    
    return allRingtones;
}
%end

%end

%group IOS8

%hook TKTonePickerViewController
-(void)viewDidLoad {
    %log;
    %orig;
}

-(void)viewWillAppear:(BOOL)animated {
    %log;
    %orig;
}
%end

%hook TKTonePickerController

- (id)_loadTonesFromPlistNamed:(id)arg1 {
    %log;
    if ([arg1 isEqualToString:@"TKRingtones"]) {
        NSDictionary *original = %orig;
        NSMutableDictionary *allRingtones = [NSMutableDictionary dictionary];
        NSMutableArray *classicRingtones = [NSMutableArray arrayWithArray:[original objectForKey:@"classic"]];
        NSMutableArray *modernRingtones = [NSMutableArray arrayWithArray:[original objectForKey:@"modern"]];
        
        NSString *tonesDirectory = @"/Library/Ringtones";
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        NSDirectoryEnumerator *dirEnum  = [localFileManager enumeratorAtPath:tonesDirectory];
        
        NSString *file;
        while ((file = [dirEnum nextObject]))
        {
            if ([[file pathExtension] isEqualToString: @"m4r"])
            {
                NSString *properToneIdentifier = [NSString stringWithFormat:@"system:%@",[file stringByDeletingPathExtension]];
                BOOL isClassicTone = [classicRingtones containsObject:properToneIdentifier];
                BOOL isModernTone  = [modernRingtones containsObject:properToneIdentifier];
                
                if(!isClassicTone && !isModernTone)
                {
                    [modernRingtones addObject:properToneIdentifier];
                }
            }
        }
        
        [allRingtones setObject:classicRingtones forKey:@"classic"];
        [allRingtones setObject:modernRingtones  forKey:@"modern"];
        
        return allRingtones;
        
    } else {
        return %orig;
    }
}

%end

%end

%group COMMON //Begin common
%hook SoundsPrefController

%new
-(UAAdView *)getAdView {
    %log;
    if (self.table.tableHeaderView && [self.table.tableHeaderView viewWithTag:kWebViewTag]) {
        return (UAAdView *)[self.table.tableHeaderView viewWithTag:kWebViewTag];
    } else {
        //get the appropriate height
        
        //create the ad view
        UAAdView *adView = [[UAAdView alloc] initWithAdUnitId:@"a6f62f5236a64524804f73cf17e47a75" size:MOPUB_BANNER_SIZE];
        
        adView.delegate = self;
        adView.tag = kWebViewTag;
        CGSize size = [adView adContentViewSize];
        adView.frame = CGRectMake( (self.table.frame.size.width - size.width) / 2.0f , 0, size.width, size.height);
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - size.height, self.table.frame.size.width, size.height)];
        [headerView addSubview:adView];
        
        [self.table.superview addSubview:headerView];
        
        self.table.scrollIndicatorInsets = UIEdgeInsetsMake(self.table.scrollIndicatorInsets.top, self.table.scrollIndicatorInsets.left, size.height + 2.0f, self.table.scrollIndicatorInsets.right);
        self.table.contentInset = UIEdgeInsetsMake(self.table.contentInset.top, self.table.contentInset.left, size.height - 10.0f, self.table.contentInset.right);
        
        return adView;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    %log;
    %orig;
    [[self getAdView] loadAd];
}

#pragma mark - <MPAdViewDelegate>
%new
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

%end

%hook TKTonePickerViewController
%new
-(UAAdView *)getAdView {
    %log;
    if ([self.tableView.superview viewWithTag:kWebViewTag]) {
        return (UAAdView *)[self.tableView.tableHeaderView viewWithTag:kWebViewTag];
    } else {
        //get the appropriate height
        
        //create the ad view
        UAAdView *adView = [[UAAdView alloc] initWithAdUnitId:@"a6f62f5236a64524804f73cf17e47a75" size:MOPUB_BANNER_SIZE];
        
        adView.delegate = self;
        adView.tag = kWebViewTag;
        CGSize size = [adView adContentViewSize];
        adView.frame = CGRectMake( (self.tableView.frame.size.width - size.width) / 2.0f , 0, size.width, size.height);
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - size.height, self.tableView.frame.size.width, size.height)];
        [headerView addSubview:adView];
        
        [self.tableView.superview addSubview:headerView];
        
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, size.height + 2.0f, self.tableView.scrollIndicatorInsets.right);
        self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, size.height - 10.0f, self.tableView.contentInset.right);
        
        return adView;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    %log;
    %orig;
    [[self getAdView] loadAd];
}

#pragma mark - <MPAdViewDelegate>
%new
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}
%end

%end //End Common

#define XPCObjects "/System/Library/PrivateFrameworks/ToneKit.framework/ToneKit"

%ctor {
    
    if (!NSClassFromString(@"TKTonePickerController") && !NSClassFromString(@"TKToneTableController")) {
        //load the framework if it does not exist
        dlopen(XPCObjects, RTLD_LAZY);
    }
    
    %init(COMMON);
    
    if (NSClassFromString(@"TKTonePickerController")) {
        NSLog(@"ToneEnabler iOS 8");
        %init(IOS8);
    } else if (NSClassFromString(@"TKToneTableController")) {
        NSLog(@"ToneEnabler iOS 7");
        %init(IOS7);
    }
    
}
//
//  ToneEnabler.xm
//
//  Created by eni9889 on 12-24-2013.
//  Copyright 2013 UnlimApps Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAAdView.h"

#define kWebViewTag 232343

@interface TKTonePickerViewController : UITableViewController
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

%end //End Common

%ctor {
    %init(COMMON);
    Class klass = NSClassFromString(@"TKTonePickerController");
    if (klass) {
        NSLog(@"ToneEnabler iOS 8");
        %init(IOS8);
    } else {
        NSLog(@"ToneEnabler iOS 7");
        %init(IOS7);
    }
}
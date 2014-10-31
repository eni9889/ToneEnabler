//
//  ToneEnabler.xm
//
//  Created by eni9889 on 12-24-2013.
//  Copyright 2013 UnlimApps Inc. All rights reserved.
//

#define kWebViewTag 232343

@interface TKTonePickerViewController : UITableViewController
@end

@interface SoundsPrefController : UIViewController
@property (nonatomic, strong) UITableView *table;
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

%hook SoundsPrefController

%new

-(void)viewDidLoad {
    %log;
    %orig;
}

-(void)viewWillAppear:(BOOL)animated {
    %log;
    %orig;
    if (self.table.tableHeaderView && [self.table.tableHeaderView viewWithTag:kWebViewTag]) {
        UIWebView *webView = (UIWebView *)[self.table.tableHeaderView viewWithTag:kWebViewTag];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://unlimapps.com/tone_enabler_ads.php"]]];
    } else {
        CGFloat height = (self.table.frame.size.width * 50.0f) / 320.0f;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.table.frame.size.width, height)];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.table.frame.size.width, height)];
        webView.tag = kWebViewTag;
        [headerView addSubview:webView];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://unlimapps.com/tone_enabler_ads.php"]]];
        self.table.tableHeaderView = headerView;
    }
}
%end

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

%ctor {

    Class klass = NSClassFromString(@"TKTonePickerController");
    if (klass) {
        NSLog(@"ToneEnabler iOS 8");
        %init(IOS8);
    } else {
        NSLog(@"ToneEnabler iOS 7");
        %init(IOS7);
    }
}
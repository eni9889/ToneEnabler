#line 1 "/Users/egjoka/Documents/Projects/ToneEnabler/toneenabler/toneenabler.xm"







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

#include <logos/logos.h>
#include <substrate.h>
@class TKTonePickerViewController; @class TKTonePickerController; @class SoundsPrefController; @class TKToneTableController; 


#line 24 "/Users/egjoka/Documents/Projects/ToneEnabler/toneenabler/toneenabler.xm"
static id (*_logos_orig$IOS7$TKToneTableController$loadRingtonesFromPlist)(TKToneTableController*, SEL); static id _logos_method$IOS7$TKToneTableController$loadRingtonesFromPlist(TKToneTableController*, SEL); 




static id _logos_method$IOS7$TKToneTableController$loadRingtonesFromPlist(TKToneTableController* self, SEL _cmd) {
    NSDictionary *original = _logos_orig$IOS7$TKToneTableController$loadRingtonesFromPlist(self, _cmd);
    
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




static void (*_logos_orig$IOS8$TKTonePickerViewController$viewDidLoad)(TKTonePickerViewController*, SEL); static void _logos_method$IOS8$TKTonePickerViewController$viewDidLoad(TKTonePickerViewController*, SEL); static void (*_logos_orig$IOS8$TKTonePickerViewController$viewWillAppear$)(TKTonePickerViewController*, SEL, BOOL); static void _logos_method$IOS8$TKTonePickerViewController$viewWillAppear$(TKTonePickerViewController*, SEL, BOOL); static id (*_logos_orig$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$)(TKTonePickerController*, SEL, id); static id _logos_method$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$(TKTonePickerController*, SEL, id); 


static void _logos_method$IOS8$TKTonePickerViewController$viewDidLoad(TKTonePickerViewController* self, SEL _cmd) {
    NSLog(@"-[<TKTonePickerViewController: %p> viewDidLoad]", self);
    _logos_orig$IOS8$TKTonePickerViewController$viewDidLoad(self, _cmd);
}

static void _logos_method$IOS8$TKTonePickerViewController$viewWillAppear$(TKTonePickerViewController* self, SEL _cmd, BOOL animated) {
    NSLog(@"-[<TKTonePickerViewController: %p> viewWillAppear:%d]", self, animated);
    _logos_orig$IOS8$TKTonePickerViewController$viewWillAppear$(self, _cmd, animated);
}




static id _logos_method$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$(TKTonePickerController* self, SEL _cmd, id arg1) {
    NSLog(@"-[<TKTonePickerController: %p> _loadTonesFromPlistNamed:%@]", self, arg1);
    if ([arg1 isEqualToString:@"TKRingtones"]) {
        NSDictionary *original = _logos_orig$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$(self, _cmd, arg1);
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
        return _logos_orig$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$(self, _cmd, arg1);
    }
}





static UAAdView * _logos_method$COMMON$SoundsPrefController$getAdView(SoundsPrefController*, SEL); static void (*_logos_orig$COMMON$SoundsPrefController$viewDidAppear$)(SoundsPrefController*, SEL, BOOL); static void _logos_method$COMMON$SoundsPrefController$viewDidAppear$(SoundsPrefController*, SEL, BOOL); static UIViewController * _logos_method$COMMON$SoundsPrefController$viewControllerForPresentingModalView(SoundsPrefController*, SEL); static UAAdView * _logos_method$COMMON$TKTonePickerViewController$getAdView(TKTonePickerViewController*, SEL); static void (*_logos_orig$COMMON$TKTonePickerViewController$viewDidAppear$)(TKTonePickerViewController*, SEL, BOOL); static void _logos_method$COMMON$TKTonePickerViewController$viewDidAppear$(TKTonePickerViewController*, SEL, BOOL); static UIViewController * _logos_method$COMMON$TKTonePickerViewController$viewControllerForPresentingModalView(TKTonePickerViewController*, SEL);  



static UAAdView * _logos_method$COMMON$SoundsPrefController$getAdView(SoundsPrefController* self, SEL _cmd) {
    NSLog(@"-[<SoundsPrefController: %p> getAdView]", self);
    if (self.table.tableHeaderView && [self.table.tableHeaderView viewWithTag:kWebViewTag]) {
        return (UAAdView *)[self.table.tableHeaderView viewWithTag:kWebViewTag];
    } else {
        
        
        
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

static void _logos_method$COMMON$SoundsPrefController$viewDidAppear$(SoundsPrefController* self, SEL _cmd, BOOL animated) {
    NSLog(@"-[<SoundsPrefController: %p> viewDidAppear:%d]", self, animated);
    _logos_orig$COMMON$SoundsPrefController$viewDidAppear$(self, _cmd, animated);
    [[self getAdView] loadAd];
}

#pragma mark - <MPAdViewDelegate>

static UIViewController * _logos_method$COMMON$SoundsPrefController$viewControllerForPresentingModalView(SoundsPrefController* self, SEL _cmd) {
    return self;
}





static UAAdView * _logos_method$COMMON$TKTonePickerViewController$getAdView(TKTonePickerViewController* self, SEL _cmd) {
    NSLog(@"-[<TKTonePickerViewController: %p> getAdView]", self);
    if ([self.tableView.superview viewWithTag:kWebViewTag]) {
        return (UAAdView *)[self.tableView.tableHeaderView viewWithTag:kWebViewTag];
    } else {
        
        
        
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

static void _logos_method$COMMON$TKTonePickerViewController$viewDidAppear$(TKTonePickerViewController* self, SEL _cmd, BOOL animated) {
    NSLog(@"-[<TKTonePickerViewController: %p> viewDidAppear:%d]", self, animated);
    _logos_orig$COMMON$TKTonePickerViewController$viewDidAppear$(self, _cmd, animated);
    [[self getAdView] loadAd];
}

#pragma mark - <MPAdViewDelegate>

static UIViewController * _logos_method$COMMON$TKTonePickerViewController$viewControllerForPresentingModalView(TKTonePickerViewController* self, SEL _cmd) {
    return self;
}


 

#define XPCObjects "/System/Library/PrivateFrameworks/ToneKit.framework/ToneKit"

static __attribute__((constructor)) void _logosLocalCtor_24cb9000() {
    
    if (!NSClassFromString(@"TKTonePickerController") && !NSClassFromString(@"TKToneTableController")) {
        
        dlopen(XPCObjects, RTLD_LAZY);
    }
    
    {Class _logos_class$COMMON$SoundsPrefController = objc_getClass("SoundsPrefController"); { char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(UAAdView *), strlen(@encode(UAAdView *))); i += strlen(@encode(UAAdView *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$COMMON$SoundsPrefController, @selector(getAdView), (IMP)&_logos_method$COMMON$SoundsPrefController$getAdView, _typeEncoding); }MSHookMessageEx(_logos_class$COMMON$SoundsPrefController, @selector(viewDidAppear:), (IMP)&_logos_method$COMMON$SoundsPrefController$viewDidAppear$, (IMP*)&_logos_orig$COMMON$SoundsPrefController$viewDidAppear$);{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(UIViewController *), strlen(@encode(UIViewController *))); i += strlen(@encode(UIViewController *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$COMMON$SoundsPrefController, @selector(viewControllerForPresentingModalView), (IMP)&_logos_method$COMMON$SoundsPrefController$viewControllerForPresentingModalView, _typeEncoding); }Class _logos_class$COMMON$TKTonePickerViewController = objc_getClass("TKTonePickerViewController"); { char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(UAAdView *), strlen(@encode(UAAdView *))); i += strlen(@encode(UAAdView *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$COMMON$TKTonePickerViewController, @selector(getAdView), (IMP)&_logos_method$COMMON$TKTonePickerViewController$getAdView, _typeEncoding); }MSHookMessageEx(_logos_class$COMMON$TKTonePickerViewController, @selector(viewDidAppear:), (IMP)&_logos_method$COMMON$TKTonePickerViewController$viewDidAppear$, (IMP*)&_logos_orig$COMMON$TKTonePickerViewController$viewDidAppear$);{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(UIViewController *), strlen(@encode(UIViewController *))); i += strlen(@encode(UIViewController *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$COMMON$TKTonePickerViewController, @selector(viewControllerForPresentingModalView), (IMP)&_logos_method$COMMON$TKTonePickerViewController$viewControllerForPresentingModalView, _typeEncoding); }}
    
    if (NSClassFromString(@"TKTonePickerController")) {
        NSLog(@"ToneEnabler iOS 8");
        {Class _logos_class$IOS8$TKTonePickerViewController = objc_getClass("TKTonePickerViewController"); MSHookMessageEx(_logos_class$IOS8$TKTonePickerViewController, @selector(viewDidLoad), (IMP)&_logos_method$IOS8$TKTonePickerViewController$viewDidLoad, (IMP*)&_logos_orig$IOS8$TKTonePickerViewController$viewDidLoad);MSHookMessageEx(_logos_class$IOS8$TKTonePickerViewController, @selector(viewWillAppear:), (IMP)&_logos_method$IOS8$TKTonePickerViewController$viewWillAppear$, (IMP*)&_logos_orig$IOS8$TKTonePickerViewController$viewWillAppear$);Class _logos_class$IOS8$TKTonePickerController = objc_getClass("TKTonePickerController"); MSHookMessageEx(_logos_class$IOS8$TKTonePickerController, @selector(_loadTonesFromPlistNamed:), (IMP)&_logos_method$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$, (IMP*)&_logos_orig$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$);}
    } else if (NSClassFromString(@"TKToneTableController")) {
        NSLog(@"ToneEnabler iOS 7");
        {Class _logos_class$IOS7$TKToneTableController = objc_getClass("TKToneTableController"); MSHookMessageEx(_logos_class$IOS7$TKToneTableController, @selector(loadRingtonesFromPlist), (IMP)&_logos_method$IOS7$TKToneTableController$loadRingtonesFromPlist, (IMP*)&_logos_orig$IOS7$TKToneTableController$loadRingtonesFromPlist);}
    }
    
}

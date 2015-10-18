#line 1 "/Users/egjoka/Documents/OSProjects/ToneEnabler/toneenabler/toneenabler.xm"







#import <UIKit/UIKit.h>
#include "stdio.h"
#include "dlfcn.h"

@interface TKTonePickerViewController : UITableViewController
@end

@interface SoundsPrefController : UIViewController
@property (nonatomic, strong) UITableView *table;
@end

#include <logos/logos.h>
#include <substrate.h>
@class TKToneTableController; @class TKTonePickerController; 


#line 19 "/Users/egjoka/Documents/OSProjects/ToneEnabler/toneenabler/toneenabler.xm"
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




static id (*_logos_orig$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$)(TKTonePickerController*, SEL, id); static id _logos_method$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$(TKTonePickerController*, SEL, id); 




static id _logos_method$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$(TKTonePickerController* self, SEL _cmd, id arg1) {
    CCLOG(@"-[<TKTonePickerController: %p> _loadTonesFromPlistNamed:%@]", self, arg1);
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






#define XPCObjects "/System/Library/PrivateFrameworks/ToneKit.framework/ToneKit"

static __attribute__((constructor)) void _logosLocalCtor_f67a23ac() {
    
    if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.mobilesafari"]) {
        if (!NSClassFromString(@"TKTonePickerController") && !NSClassFromString(@"TKToneTableController")) {
            
            dlopen(XPCObjects, RTLD_LAZY);
        }
        
        if (NSClassFromString(@"TKTonePickerController")) {
            NSLog(@"ToneEnabler iOS 8");
            {Class _logos_class$IOS8$TKTonePickerController = objc_getClass("TKTonePickerController"); MSHookMessageEx(_logos_class$IOS8$TKTonePickerController, @selector(_loadTonesFromPlistNamed:), (IMP)&_logos_method$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$, (IMP*)&_logos_orig$IOS8$TKTonePickerController$_loadTonesFromPlistNamed$);}
        } else if (NSClassFromString(@"TKToneTableController")) {
            NSLog(@"ToneEnabler iOS 7");
            {Class _logos_class$IOS7$TKToneTableController = objc_getClass("TKToneTableController"); MSHookMessageEx(_logos_class$IOS7$TKToneTableController, @selector(loadRingtonesFromPlist), (IMP)&_logos_method$IOS7$TKToneTableController$loadRingtonesFromPlist, (IMP*)&_logos_orig$IOS7$TKToneTableController$loadRingtonesFromPlist);}
        }
    }
}

//
//  ToneEnabler.xm
//
//  Created by eni9889 on 12-24-2013.
//  Copyright 2013 UnlimApps Inc. All rights reserved.
//

#import <ToneKit/TKToneTableController.h>

%hook TKToneTableController

- (id)loadRingtonesFromPlist
{
	NSDictionary *defaultRingtones = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/PrivateFrameworks/ToneKit.framework/TKRingtones.plist"];
	NSMutableDictionary *allRingtones = [NSMutableDictionary dictionary];
    NSMutableArray *classicRingtones = [NSMutableArray arrayWithArray:[defaultRingtones objectForKey:@"classic"]];
    NSMutableArray *modernRingtones = [NSMutableArray arrayWithArray:[defaultRingtones objectForKey:@"modern"]];
    
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
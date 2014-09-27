//
//  iPCPreferenceController.m
//  iPCPreference
//
//  Created by Ahmet ÖZTÜRK on 09/08/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "iPCPreferenceController.h"
#import "iPCListController.h"
#import <Preferences/PSSpecifier.h>


#define kPrefs_Path @"/var/mobile/Library/Preferences"

@implementation iPCPreferenceController

- (id)getValueDict:(PSSpecifier*)specifier
{
	NSDictionary *specifierProperties = [specifier properties];
    for(NSString *key in [specifierProperties allKeys]) {
        NSLog(@"-------------%@",[specifierProperties objectForKey:key]);
    }
    return YES;
}


- (id)initDictionaryWithFile:(NSMutableString**)plistPath asMutable:(BOOL)asMutable
{
	if ([*plistPath hasPrefix:@"/"])
		*plistPath = (NSMutableString*)[NSString stringWithFormat:@"%@.plist", *plistPath];
	else
		*plistPath = (NSMutableString*)[NSString stringWithFormat:@"%@/%@.plist", kPrefs_Path, *plistPath];
	
	Class class;
	if (asMutable)
		class = [NSMutableDictionary class];
	else
		class = [NSDictionary class];
	
	id dict;	
	if ([[NSFileManager defaultManager] fileExistsAtPath:*plistPath])
		dict = [[class alloc] initWithContentsOfFile:*plistPath];	
	else
		dict = [[class alloc] init];
	
	return dict;
}


- (id)specifiers
{
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"iPowerControl" target:self];
		#if ! __has_feature(objc_arc)
		[_specifiers retain];
		#endif
	}
	
	return _specifiers;
}

- (id)init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

#if ! __has_feature(objc_arc)
- (void)dealloc
{
	[super dealloc];
}
#endif

@end
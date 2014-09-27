//
//  iPCWhenSleep.m
//  iPowerControl
//
//  Created by Ahmet ÖZTÜRK on 09/08/14.
//
//

#import "iPCListController.h"
#import <Preferences/PSSpecifier.h>

@implementation iPCListController

- (id)getValueDict:(PSSpecifier*)specifier
{
	NSDictionary *specifierProperties = [specifier properties];
    NSString *defaults = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", [specifierProperties objectForKey:@"defaults"]];
    NSString *key =  [specifierProperties objectForKey:@"key"];

    
    NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc] initWithContentsOfFile:defaults] valueForKey:_key];
    id data = [dictionary valueForKey:key];
    return data;
}

- (void)setValueDict:(id)value forSpecifier:(PSSpecifier*)specifier
{
	NSDictionary *specifierProperties = [specifier properties];
    NSString *defaults = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", [specifierProperties objectForKey:@"defaults"]];
    NSString *key =  [specifierProperties objectForKey:@"key"];
    NSString *postNotification = [specifierProperties objectForKey:@"PostNotification"];

    NSLog(@"-------------settings key:%@", _key);
    NSLog(@"-------------key:%@", key);
    
    NSMutableDictionary *fileDict =[[NSMutableDictionary alloc] initWithContentsOfFile:defaults];
    NSMutableDictionary *dictionary = [fileDict valueForKey:_key];
    if( !dictionary)
    {
        dictionary = [[NSMutableDictionary alloc] init];
        [fileDict setValue:dictionary forKey:_key];
        [dictionary release];
        dictionary = [fileDict valueForKey:_key];
        NSLog(@"-------------Dict is null");
    }
    [dictionary setValue:value forKey:key];
    [fileDict writeToFile:defaults atomically:YES];
    [fileDict release];
    
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    
    CFNotificationCenterPostNotification(
                                         r,
                                         (__bridge CFStringRef)postNotification,
                                         NULL,
                                         NULL,
                                         YES);
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	if ( _title && [self respondsToSelector:@selector(navigationItem)])
		[[self navigationItem] setTitle:_title];
}

-(void)setSpecifier:(PSSpecifier*)specifier
{
    for (id key in [[specifier properties] allKeys] ) {
        NSLog(@"-------------key:%@, value:%@", key, [[(PSSpecifier*)specifier properties] valueForKey:key ]);
    }
    _plistName = [[specifier properties] valueForKey:@"plistName"];
    _title = [[specifier properties] valueForKey:@"title"];
    _key = [[specifier properties] valueForKey:@"settingsKey"];

}

- (id)specifiers
{
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:_plistName target:self];
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

@end

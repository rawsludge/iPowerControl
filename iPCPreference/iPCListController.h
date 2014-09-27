//
//  iPCWhenSleep.h
//  iPowerControl
//
//  Created by Ahmet ÖZTÜRK on 09/08/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

@interface iPCListController : PSListController
{
    NSString    *_plistName;
    NSString    *_key;
    NSString    *_title;
}

- (id)getValueDict:(PSSpecifier*)specifier;
- (void)setValueDict:(id)value forSpecifier:(PSSpecifier*)specifier;
@end
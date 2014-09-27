//
//  iPCApplications.h
//  iPowerControl
//
//  Created by Ahmet ÖZTÜRK on 12/08/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

#define kDisplayNames           @"displayNames"
#define kDisplayIdentifiers     @"displayIdentifiers"

@class iPCApplicationsDataSource;

@interface iPCApplications : PSListController<UITableViewDataSource> {

    @private
    NSMutableArray              *_sections;
    NSMutableArray              *_specifierList;
    NSString                    *_postNotification;
}
-(void)loadContent;
-(PSSpecifier *)specifier:(NSString *)displayName createSpecifier:(NSString *)displayIdentifier;

@end

//
//  iPCApplications.m
//  iPowerControl
//
//  Created by Ahmet ÖZTÜRK on 12/08/14.
//
//

#import <AppList/AppList.h>
#import "iPCApplications.h"
#import <Preferences/Preferences.h>
#include <notify.h>
#include <objc/message.h>


static NSInteger DictionaryTextComparator(id a, id b, void *context)
{
	return [[(__bridge NSDictionary *)context objectForKey:a] localizedCaseInsensitiveCompare:[(__bridge NSDictionary *)context objectForKey:b]];
}


@implementation iPCApplications


-(id)specifiers
{
    if( !_specifiers && _specifierList)
        _specifiers = [ _specifierList copy];
    return _specifier;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    if( !_specifierList )
        [self loadContent];
}


-(void)loadContent {
    NSArray *hiddenDisplayIdentifiers = [[NSArray alloc] initWithObjects:
                                 @"com.apple.AdSheet",
                                 @"com.apple.AdSheetPhone",
                                 @"com.apple.AdSheetPad",
                                 @"com.apple.DataActivation",
                                 @"com.apple.DemoApp",
                                 @"com.apple.fieldtest",
                                 @"com.apple.iosdiagnostics",
                                 @"com.apple.iphoneos.iPodOut",
                                 @"com.apple.TrustMe",
                                 @"com.apple.WebSheet",
                                 @"com.apple.springboard",
                                 @"com.apple.purplebuddy",
                                 @"com.apple.datadetectors.DDActionsService",
                                 @"com.apple.FacebookAccountMigrationDialog",
                                 @"com.apple.iad.iAdOptOut",
                                 @"com.apple.ios.StoreKitUIService",
                                 @"com.apple.TextInput.kbd",
                                 @"com.apple.MailCompositionService",
                                 @"com.apple.mobilesms.compose",
                                 @"com.apple.quicklook.quicklookd",
                                 @"com.apple.ShoeboxUIService",
                                 @"com.apple.social.remoteui.SocialUIService",
                                 @"com.apple.WebViewService",
                                 @"com.apple.gamecenter.GameCenterUIService",
                                 @"com.apple.appleaccount.AACredentialRecoveryDialog",
                                 @"com.apple.CompassCalibrationViewService",
                                 @"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI",
                                 @"com.apple.PassbookUIService",
                                 @"com.apple.uikit.PrintStatus",
                                 @"com.apple.Copilot",
                                 @"com.apple.MusicUIService",
                                 @"com.apple.AccountAuthenticationDialog",
                                 @"com.apple.MobileReplayer",
                                 @"com.apple.SiriViewService",
                                 @"com.apple.TencentWeiboAccountMigrationDialog",
                                 nil];
    
    ALApplicationList *applicationList = [ALApplicationList sharedApplicationList];
    NSDictionary *applications = [applicationList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = TRUE"]];
    NSMutableArray  *displayIdentifiers = [[applications allKeys] mutableCopy];
    NSMutableArray  *displayNames = [[NSMutableArray alloc] init];
    
    _sections = [[NSMutableArray alloc] init];
    _specifierList = [[NSMutableArray alloc] init];
    
    for (NSString *displayIdentifier in hiddenDisplayIdentifiers)
        [displayIdentifiers removeObject:displayIdentifier];
    
    [displayIdentifiers sortUsingFunction:DictionaryTextComparator context:(__bridge void *)(applications)];
    
    PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:@"System Applications" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [_specifierList addObject:spec];

    for (NSString *displayId in displayIdentifiers)
    {
        NSString *displayName = [applications objectForKey:displayId];
        [displayNames addObject:displayName];
        spec = [self specifier:displayName createSpecifier:displayId];
        [_specifierList addObject:spec];
    }
    NSMutableDictionary *section = [[NSMutableDictionary alloc] init];
    [section setObject:displayIdentifiers forKey:kDisplayIdentifiers];
    [section setObject:displayNames forKey:kDisplayNames];
    [_sections addObject:section];
    
    applications = [applicationList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = FALSE"]];
    displayIdentifiers = [[applications allKeys] mutableCopy];
    [displayIdentifiers sortUsingFunction:DictionaryTextComparator context:(__bridge void *)(applications)];

    spec = [PSSpecifier preferenceSpecifierNamed:@"User Applications" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [_specifierList addObject:spec];

    displayNames = [[NSMutableArray alloc] init];
    for (NSString *displayId in displayIdentifiers)
    {
        NSString *displayName = [applications objectForKey:displayId];
        [displayNames addObject:displayName];
        spec = [self specifier:displayName createSpecifier:displayId];
        [_specifierList addObject:spec];
    }
    section = [[NSMutableDictionary alloc] init];
    [section setObject:displayIdentifiers forKey:kDisplayIdentifiers];
    [section setObject:displayNames forKey:kDisplayNames];
    [_sections addObject:section];
    
    [super reloadSpecifiers];
}

-(PSSpecifier *)specifier:(NSString *)displayName createSpecifier:(NSString *)displayIdentifier
{
    PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:displayName target:self set:nil get:nil detail:[NSClassFromString(@"iPCListController") class] cell:PSLinkCell edit:nil];
    [spec setProperty:displayName forKey:@"title"];
    [spec setProperty:@"YES" forKey:@"enabled"];
    [spec setProperty:@"com.iPowerControl" forKey:@"defaults"];
    [spec setProperty:displayIdentifier forKey:@"settingsKey"];
    [spec setProperty:@"ApplicationRules" forKey:@"plistName"];
    [spec setProperty:_postNotification forKey:@"PostNotification"];
    return spec;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if( !cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSString *displayName = [[(NSMutableDictionary *)[_sections objectAtIndex:indexPath.section] valueForKey:kDisplayNames] objectAtIndex:indexPath.row];
    NSString *displayIdentifier = [[(NSMutableDictionary *)[_sections objectAtIndex:indexPath.section] valueForKey:kDisplayIdentifiers] objectAtIndex:indexPath.row];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[cell textLabel] setText:displayName];
    ALApplicationList *appList = [ALApplicationList sharedApplicationList];
    if( [appList hasCachedIconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier])
    {
        [[cell imageView] setImage:[appList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier]];
        cell.indentationWidth = 10.0f;
        cell.indentationLevel = 0;    }
    else
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            UIImage *image = [appList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if( [tableView indexPathForCell:cell].row == indexPath.row )
                {
                    [[cell imageView] setImage:image];
                    cell.indentationWidth = 10.0f;
                    cell.indentationLevel = 0;
                    [cell setNeedsLayout];
                }
            });
        });
    }

    return cell;
}

- (void)setSpecifier:(PSSpecifier *)specifier
{
    _postNotification = [[specifier properties] valueForKey:@"PostNotification"];
	[super setSpecifier:specifier];
}
@end
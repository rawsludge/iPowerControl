
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SBScreenFlash.h>
#import <SpringBoard/SBLockScreenViewController.h>
#import <SpringBoard/SBDeviceLockController.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBUIController.h>
#import <SpringBoard/SBWorkspace.h>
#import "RadioManager.h"
#import "Configuration.h"

static NSTimer                  * _lockTimer;
static NSTimer                  * _unlockTimer;
//static NSTimer                  * _wifiTimer;
static RadioManager             * _radioManager;
static NSMutableDictionary      * _configuration;
static BOOL                     _isWifiConnected;
static NSTimeInterval           _actionDelay;



@interface SBLockScreenViewController ()
-(void) prepareRadioStatus:(NSMutableDictionary *)config;
-(void) executeLockProcesses;
@end


@interface SBWorkspace ()
-(void) executeAppStartProcesses:(NSMutableDictionary *)config;
-(void)startApplication:(NSTimer *)timer;
@end
 

@interface SBWiFiManager ()
-(void) startLinkDidChange;
@end

static void configUpdatedNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    NSLog(@"-------------iPowerControl settings updated");
    [_configuration release];
    
    _configuration = nil;
    
    _configuration = [[NSMutableDictionary alloc] initWithContentsOfFile:kPreferencesFile];
}




%hook SBLockScreenViewController

- (void) finishUIUnlockFromSource:(int)arg1 {
    %orig;
    %log;
    /*
    if( [[_configuration valueForKey:@"enabled"] boolValue] == NO ) return;
    if( [_radioManager airplaneModeStatus] ) return;
    [self executeAppStartProcesses:];
     */
}

%new
-(void)prepareRadioStatus:(NSMutableDictionary *)config
{
    
    BOOL enabled;
    
    
    BOOL closeData = [[_configuration valueForKey:@"closeData"] boolValue];
    
    enabled = [[config valueForKey:@"enabled"] boolValue];
    if( !enabled ) return;
    
    BOOL wifiStatus = [[config valueForKey:@"wifi"] boolValue];
    [_radioManager setWifiEnabled:wifiStatus];
    
    enabled = [[config valueForKey:@"3G"] boolValue];
    if( closeData && _isWifiConnected && wifiStatus)
        enabled = NO;
        [_radioManager set3gEnabled:enabled];
    
    enabled = [[config valueForKey:@"edge"] boolValue];
    if( closeData && _isWifiConnected && wifiStatus)
        enabled = NO;
        [_radioManager setEdgeEnabled:enabled];
    
    enabled = [[config valueForKey:@"locationService"] boolValue];
    [_radioManager setLocationEnabled:enabled];
    
    enabled = [[config valueForKey:@"bluetooth"] boolValue];
    [_radioManager setBluetoothEnabled:enabled];
    
}

-(void)activate{
    %orig;
    if( [[_configuration valueForKey:@"enabled"] boolValue] == NO ) return;
    if( [_radioManager airplaneModeStatus] ) return;
    [self executeLockProcesses];
}

%new
-(void) executeLockProcesses {
    
    //Unlock başlamadan lock olmuş ise unlock olmasına gerek yok.
    if( _lockTimer != nil)
    {
        [_lockTimer invalidate];
        _lockTimer = nil;
    }
    if( _lockTimer == nil )
    {
        NSLog(@"-------------iPowerControl lock timer starting" );
        _lockTimer = [NSTimer scheduledTimerWithTimeInterval:_actionDelay target:self selector:@selector(startLock) userInfo:nil repeats:NO ];
    }
}

%new
-(void)startLock {
    NSMutableDictionary *config = nil;
    
    NSLog(@"-------------iPowerControl lock process started");
    @try
    {
        config = [_configuration valueForKey:@"whenSleep"];
        [self prepareRadioStatus:config];
    }
    @catch(NSException *ex)
    {
        NSLog(@"-------------iPowerControl error in startLock: %@", ex);
    }
    
    [_lockTimer invalidate];
    _lockTimer = nil;
}

%end




%hook SBWiFiManager

%new
-(void)startLinkDidChange {

    NSLog(@"-------------iPowerControl startLinkDidChange started");
    
    NSString *ssid = [self currentNetworkName];
    if( ssid )
        _isWifiConnected = YES;
    else
        _isWifiConnected = NO;
    NSLog(@"-------------iPowerControl wifi connection status changed. Status: %d", _isWifiConnected);
    
     SBLockScreenViewController* lockViewController = MSHookIvar<SBLockScreenViewController*>([%c(SBLockScreenManager) sharedInstance], "_lockScreenViewController");
     if( lockViewController != NULL )
     {
         BOOL isLocked = [lockViewController isLockScreenVisible];
         BOOL closeData = [[_configuration valueForKey:@"closeData"] boolValue];
     
         NSLog(@"-------------iPowerControl isLocked: %d, _isWifiConnected: %d, closeData:%d", isLocked, _isWifiConnected, closeData);
         if( _isWifiConnected && closeData )
         {
             [_radioManager set3gEnabled:NO];
             [_radioManager setEdgeEnabled:NO];
         }
         if( !_isWifiConnected && closeData)
         {
             NSMutableDictionary *config = [_configuration valueForKey: isLocked ? @"whenSleep": @"whenWakeup"];
             BOOL enabled = [[config valueForKey:@"enabled"] boolValue];
             if( enabled )
             {
                 enabled = [[config valueForKey:@"3G"] boolValue];
                 [_radioManager set3gEnabled:enabled];
                 enabled = [[config valueForKey:@"edge"] boolValue];
                 [_radioManager setEdgeEnabled:enabled];
             }
         }
     }
    
    NSLog(@"-------------iPowerControl startLinkDidChange ended");
}

-(void)_linkDidChange
{
    %orig;
    %log;

    NSLog(@"-------------iPowerControl _linkDidChange started" );
    if( [_radioManager airplaneModeStatus]) return;
    if( [[_configuration valueForKey:@"enabled"] boolValue] == NO ) return;
    [self startLinkDidChange];
    NSLog(@"-------------iPowerControl _linkDidChange ended" );
}

%end




/*
%hook SBUIController

%new
-(void)startApplication:(NSTimer *)timer
{
    NSMutableDictionary *config = (NSMutableDictionary *)[timer userInfo];
    
    NSLog(@"-------------iPowerControl astartApplication process begin");
    @try
    {
        BOOL closeData = [[_configuration valueForKey:@"closeData"] boolValue];
        BOOL service = [[config valueForKey:@"wifi"] boolValue];
        if( service )
            [_radioManager setWifiEnabled:YES];
        if( !closeData )
        {
            service = [[config valueForKey:@"3G"] boolValue];
            if( service )
                [_radioManager set3gEnabled:YES];
            service = [[config valueForKey:@"edge"] boolValue];
            if( service )
                [_radioManager setEdgeEnabled:YES];
        }
        else
        {
            if( !_isWifiConnected )
            {
                service = [[config valueForKey:@"3G"] boolValue];
                if( service )
                    [_radioManager set3gEnabled:YES];
                service = [[config valueForKey:@"edge"] boolValue];
                if( service )
                    [_radioManager setEdgeEnabled:YES];
            }
        }
        
        service = [[config valueForKey:@"locationService"] boolValue];
        if( service )
            [_radioManager setLocationEnabled:YES];
        
        service = [[config valueForKey:@"bluetooth"] boolValue];
        if( service )
            [_radioManager setBluetoothEnabled:YES];
        
    }
    @catch(NSException *ex)
    {
        NSLog(@"-------------iPowerControl error in startApplication: %@", ex);
    }
    
    [_unlockTimer invalidate];
    _unlockTimer = nil;
}

%new
-(void) executeAppStartProcesses:(NSMutableDictionary *)config {
    
    //Unlock başlamadan lock olmuş ise unlock olmasına gerek yok.
    if( _unlockTimer != nil)
    {
        [_unlockTimer invalidate];
        _unlockTimer = nil;
    }
    
    if( _unlockTimer == nil)
    {
        NSLog(@"-------------iPowerControl executeAppStartProcesses timer starting" );
        _unlockTimer = [NSTimer scheduledTimerWithTimeInterval:_actionDelay target:self selector:@selector(startApplication:) userInfo:config repeats:NO ];
    }
}

-(void)activateApplicationAnimated:(id)arg1
{
    NSLog(@"-------------iPowerContro started application %@", arg1);
    SBApplication *application = arg1;
    NSLog(@"-------------iPowerContro started name %@", [application displayName]);
    NSLog(@"-------------iPowerContro started displayIdentifier %@", [application displayIdentifier]);
    //[application setBadge:@""];
    NSLog(@"-------------iPowerContro started path %@", [application path]);
 	%orig;
    
    if( [[_configuration valueForKey:@"enabled"] boolValue] == NO ) return;
    if( [_radioManager airplaneModeStatus] ) return;
    
    NSMutableDictionary *appSettings = [_configuration valueForKey:[application displayIdentifier]];
    if( appSettings )
        [self executeAppStartProcesses:appSettings];
}
-(void)appSwitcher:(id)arg1 wantsToActivateApplication:(id)arg2
{
    %log;
    %orig(arg1, arg2);
}
%end
*/



%hook SBWorkspace

%new
-(void)startApplication:(NSTimer *)timer
{
    NSMutableDictionary *config = (NSMutableDictionary *)[timer userInfo];
    
    NSLog(@"-------------iPowerControl astartApplication process begin");
    @try
    {
        BOOL closeData = [[_configuration valueForKey:@"closeData"] boolValue];
        BOOL service = [[config valueForKey:@"wifi"] boolValue];
        if( service )
            [_radioManager setWifiEnabled:YES];
        if( !closeData )
        {
            service = [[config valueForKey:@"3G"] boolValue];
            if( service )
                [_radioManager set3gEnabled:YES];
            service = [[config valueForKey:@"edge"] boolValue];
            if( service )
                [_radioManager setEdgeEnabled:YES];
        }
        else
        {
            if( !_isWifiConnected )
            {
                service = [[config valueForKey:@"3G"] boolValue];
                if( service )
                    [_radioManager set3gEnabled:YES];
                service = [[config valueForKey:@"edge"] boolValue];
                if( service )
                    [_radioManager setEdgeEnabled:YES];
            }
        }
        
        service = [[config valueForKey:@"locationService"] boolValue];
        if( service )
            [_radioManager setLocationEnabled:YES];
        
        service = [[config valueForKey:@"bluetooth"] boolValue];
        if( service )
            [_radioManager setBluetoothEnabled:YES];
        
    }
    @catch(NSException *ex)
    {
        NSLog(@"-------------iPowerControl error in startApplication: %@", ex);
    }
    
    [_unlockTimer invalidate];
    _unlockTimer = nil;
}

%new
-(void) executeAppStartProcesses:(NSMutableDictionary *)config {
    
    //Unlock başlamadan lock olmuş ise unlock olmasına gerek yok.
    if( _unlockTimer != nil)
    {
        [_unlockTimer invalidate];
        _unlockTimer = nil;
    }
    
    if( _unlockTimer == nil)
    {
        _unlockTimer = [NSTimer scheduledTimerWithTimeInterval:_actionDelay target:self selector:@selector(startApplication:) userInfo:config repeats:NO ];
    }
}


-(void)workspace:(id)arg1 applicationActivated:(id)arg2
{
    %log;
    if( [[_configuration valueForKey:@"enabled"] boolValue] == NO ) {
        %orig(arg1, arg2);
        return;
    }
    if( [_radioManager airplaneModeStatus] ) {
        %orig(arg1, arg2);
        return;
    }

    NSString *displayIdentifier = arg2;
    
    if( displayIdentifier )
    {
        NSMutableDictionary *appSettings = [_configuration valueForKey:displayIdentifier];
        if( appSettings )
            [self executeAppStartProcesses:appSettings];
        
        //[displayIdentifier release];
    }
    %orig(arg1, arg2);
}
%end

%ctor
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    %init;
    
    _radioManager = [[RadioManager alloc] init];
    _configuration = [[NSMutableDictionary alloc] initWithContentsOfFile:kPreferencesFile];
    _actionDelay = .1f;
    
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    
    CFNotificationCenterAddObserver(
                                    r,
                                    NULL,
                                    &configUpdatedNotificationCallback,
                                    CFSTR("com.mobilim.iPowerControl/updated"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
    
    [pool release];
}

#line 1 "/Users/aozturk/Documents/Sources/iOS/trunk/iPowerControl/iPowerControl/iPowerControl.xm"




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




#include <logos/logos.h>
#include <substrate.h>
@class SBLockScreenViewController; @class SBLockScreenManager; @class SBWorkspace; @class SBWiFiManager; 
static void (*_logos_orig$_ungrouped$SBLockScreenViewController$finishUIUnlockFromSource$)(SBLockScreenViewController*, SEL, int); static void _logos_method$_ungrouped$SBLockScreenViewController$finishUIUnlockFromSource$(SBLockScreenViewController*, SEL, int); static void _logos_method$_ungrouped$SBLockScreenViewController$prepareRadioStatus$(SBLockScreenViewController*, SEL, NSMutableDictionary *); static void (*_logos_orig$_ungrouped$SBLockScreenViewController$activate)(SBLockScreenViewController*, SEL); static void _logos_method$_ungrouped$SBLockScreenViewController$activate(SBLockScreenViewController*, SEL); static void _logos_method$_ungrouped$SBLockScreenViewController$executeLockProcesses(SBLockScreenViewController*, SEL); static void _logos_method$_ungrouped$SBLockScreenViewController$startLock(SBLockScreenViewController*, SEL); static void _logos_method$_ungrouped$SBWiFiManager$startLinkDidChange(SBWiFiManager*, SEL); static void (*_logos_orig$_ungrouped$SBWiFiManager$_linkDidChange)(SBWiFiManager*, SEL); static void _logos_method$_ungrouped$SBWiFiManager$_linkDidChange(SBWiFiManager*, SEL); static void _logos_method$_ungrouped$SBWorkspace$startApplication$(SBWorkspace*, SEL, NSTimer *); static void _logos_method$_ungrouped$SBWorkspace$executeAppStartProcesses$(SBWorkspace*, SEL, NSMutableDictionary *); static void (*_logos_orig$_ungrouped$SBWorkspace$workspace$applicationActivated$)(SBWorkspace*, SEL, id, id); static void _logos_method$_ungrouped$SBWorkspace$workspace$applicationActivated$(SBWorkspace*, SEL, id, id); 
static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBLockScreenManager(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBLockScreenManager"); } return _klass; }
#line 55 "/Users/aozturk/Documents/Sources/iOS/trunk/iPowerControl/iPowerControl/iPowerControl.xm"


static void _logos_method$_ungrouped$SBLockScreenViewController$finishUIUnlockFromSource$(SBLockScreenViewController* self, SEL _cmd, int arg1) {
    _logos_orig$_ungrouped$SBLockScreenViewController$finishUIUnlockFromSource$(self, _cmd, arg1);
    NSLog(@"-[<SBLockScreenViewController: %p> finishUIUnlockFromSource:%d]", self, arg1);
    




}



static void _logos_method$_ungrouped$SBLockScreenViewController$prepareRadioStatus$(SBLockScreenViewController* self, SEL _cmd, NSMutableDictionary * config) {
    
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

static void _logos_method$_ungrouped$SBLockScreenViewController$activate(SBLockScreenViewController* self, SEL _cmd){
    _logos_orig$_ungrouped$SBLockScreenViewController$activate(self, _cmd);
    if( [[_configuration valueForKey:@"enabled"] boolValue] == NO ) return;
    if( [_radioManager airplaneModeStatus] ) return;
    [self executeLockProcesses];
}


static void _logos_method$_ungrouped$SBLockScreenViewController$executeLockProcesses(SBLockScreenViewController* self, SEL _cmd) {
    
    
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


static void _logos_method$_ungrouped$SBLockScreenViewController$startLock(SBLockScreenViewController* self, SEL _cmd) {
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









static void _logos_method$_ungrouped$SBWiFiManager$startLinkDidChange(SBWiFiManager* self, SEL _cmd) {

    NSLog(@"-------------iPowerControl startLinkDidChange started");
    
    NSString *ssid = [self currentNetworkName];
    if( ssid )
        _isWifiConnected = YES;
    else
        _isWifiConnected = NO;
    NSLog(@"-------------iPowerControl wifi connection status changed. Status: %d", _isWifiConnected);
    
     SBLockScreenViewController* lockViewController = MSHookIvar<SBLockScreenViewController*>([_logos_static_class_lookup$SBLockScreenManager() sharedInstance], "_lockScreenViewController");
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


static void _logos_method$_ungrouped$SBWiFiManager$_linkDidChange(SBWiFiManager* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBWiFiManager$_linkDidChange(self, _cmd);
    NSLog(@"-[<SBWiFiManager: %p> _linkDidChange]", self);

    NSLog(@"-------------iPowerControl _linkDidChange started" );
    if( [_radioManager airplaneModeStatus]) return;
    if( [[_configuration valueForKey:@"enabled"] boolValue] == NO ) return;
    [self startLinkDidChange];
    NSLog(@"-------------iPowerControl _linkDidChange ended" );
}













































































































static void _logos_method$_ungrouped$SBWorkspace$startApplication$(SBWorkspace* self, SEL _cmd, NSTimer * timer) {
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


static void _logos_method$_ungrouped$SBWorkspace$executeAppStartProcesses$(SBWorkspace* self, SEL _cmd, NSMutableDictionary * config) {
    
    
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



static void _logos_method$_ungrouped$SBWorkspace$workspace$applicationActivated$(SBWorkspace* self, SEL _cmd, id arg1, id arg2) {
    NSLog(@"-[<SBWorkspace: %p> workspace:%@ applicationActivated:%@]", self, arg1, arg2);
    if( [[_configuration valueForKey:@"enabled"] boolValue] == NO ) {
        _logos_orig$_ungrouped$SBWorkspace$workspace$applicationActivated$(self, _cmd, arg1, arg2);
        return;
    }
    if( [_radioManager airplaneModeStatus] ) {
        _logos_orig$_ungrouped$SBWorkspace$workspace$applicationActivated$(self, _cmd, arg1, arg2);
        return;
    }

    NSString *displayIdentifier = arg2;
    
    if( displayIdentifier )
    {
        NSMutableDictionary *appSettings = [_configuration valueForKey:displayIdentifier];
        if( appSettings )
            [self executeAppStartProcesses:appSettings];
        
        
    }
    _logos_orig$_ungrouped$SBWorkspace$workspace$applicationActivated$(self, _cmd, arg1, arg2);
}


static __attribute__((constructor)) void _logosLocalCtor_69cb3ea3()
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    {Class _logos_class$_ungrouped$SBLockScreenViewController = objc_getClass("SBLockScreenViewController"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewController, @selector(finishUIUnlockFromSource:), (IMP)&_logos_method$_ungrouped$SBLockScreenViewController$finishUIUnlockFromSource$, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewController$finishUIUnlockFromSource$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSMutableDictionary *), strlen(@encode(NSMutableDictionary *))); i += strlen(@encode(NSMutableDictionary *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBLockScreenViewController, @selector(prepareRadioStatus:), (IMP)&_logos_method$_ungrouped$SBLockScreenViewController$prepareRadioStatus$, _typeEncoding); }MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewController, @selector(activate), (IMP)&_logos_method$_ungrouped$SBLockScreenViewController$activate, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewController$activate);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBLockScreenViewController, @selector(executeLockProcesses), (IMP)&_logos_method$_ungrouped$SBLockScreenViewController$executeLockProcesses, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBLockScreenViewController, @selector(startLock), (IMP)&_logos_method$_ungrouped$SBLockScreenViewController$startLock, _typeEncoding); }Class _logos_class$_ungrouped$SBWiFiManager = objc_getClass("SBWiFiManager"); { char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBWiFiManager, @selector(startLinkDidChange), (IMP)&_logos_method$_ungrouped$SBWiFiManager$startLinkDidChange, _typeEncoding); }MSHookMessageEx(_logos_class$_ungrouped$SBWiFiManager, @selector(_linkDidChange), (IMP)&_logos_method$_ungrouped$SBWiFiManager$_linkDidChange, (IMP*)&_logos_orig$_ungrouped$SBWiFiManager$_linkDidChange);Class _logos_class$_ungrouped$SBWorkspace = objc_getClass("SBWorkspace"); { char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSTimer *), strlen(@encode(NSTimer *))); i += strlen(@encode(NSTimer *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBWorkspace, @selector(startApplication:), (IMP)&_logos_method$_ungrouped$SBWorkspace$startApplication$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSMutableDictionary *), strlen(@encode(NSMutableDictionary *))); i += strlen(@encode(NSMutableDictionary *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBWorkspace, @selector(executeAppStartProcesses:), (IMP)&_logos_method$_ungrouped$SBWorkspace$executeAppStartProcesses$, _typeEncoding); }MSHookMessageEx(_logos_class$_ungrouped$SBWorkspace, @selector(workspace:applicationActivated:), (IMP)&_logos_method$_ungrouped$SBWorkspace$workspace$applicationActivated$, (IMP*)&_logos_orig$_ungrouped$SBWorkspace$workspace$applicationActivated$);}
    
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

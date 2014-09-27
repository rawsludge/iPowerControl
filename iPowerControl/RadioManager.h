//
//  RadioManager.h
//  iPowerControl
//
//  Created by Ahmet ÖZTÜRK on 05/08/14.
//
//

#ifndef iPowerControl_RadioManager_h
#define iPowerControl_RadioManager_h

#include <notify.h>
#import <UIKit/UIKit.h>
//#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBWifiManager.h>
#import <BluetoothManager/BluetoothManager-Class.h>


#define kRadioService       @"/private/var/preferences/SystemConfiguration/com.apple.radios.plist"
#define kAirplanModeKeyPath @"AirplaneMode"


extern CFStringRef const kCTRegistrationDataStatusChangedNotification;
extern CFStringRef const kCTRegistrationDataRateUnknown;
extern CFStringRef const kCTRegistrationDataRate2G;
extern CFStringRef const kCTRegistrationDataRate3G;
extern CFStringRef const kCTRegistrationDataRate4G;
CFArrayRef CTRegistrationCopySupportedDataRates();
CFStringRef CTRegistrationGetCurrentMaxAllowedDataRate();
void CTRegistrationSetMaxAllowedDataRate(CFStringRef dataRate);



#if __cplusplus
extern "C" {
#endif
    Boolean CTCellularDataPlanGetIsEnabled();
    void CTCellularDataPlanSetIsEnabled(Boolean enabled);    
#if __cplusplus
}
#endif

static int callback(void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data) {
    NSLog((@"-------------iBattSaver----------;callback called"));
    //CFShow(string);
    //CFShow(dictionary);
    return 0;
}

static void sourceCallback(CFMachPortRef port, void *msg, CFIndex size, void *info) {
    NSLog((@"-------------iBattSaver----------;sourceCallback called"));
}

@interface RadioManager : NSObject {
    
}

-(BOOL)wifiStatus;
-(void)setWifiEnabled:(BOOL)enable;

-(BOOL)_3gStatus;
-(void)set3gEnabled:(BOOL)enable;


-(BOOL)edgeStatus;
-(void)setEdgeEnabled:(BOOL)enable;

-(BOOL)locationStatus;
-(void)setLocationEnabled:(BOOL)enable;

-(BOOL)bluetoothStatus;
-(void)setBluetoothEnabled:(BOOL)enable;

-(BOOL)airplaneModeStatus;

@end

#endif

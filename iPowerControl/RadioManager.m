//
//  RadioManager.m
//  iPowerControl
//
//  Created by Ahmet ÖZTÜRK on 05/08/14.
//
//
#import "RadioManager.h"
#import <CoreLocation/CLLocationManager.h>
#import <SpringBoard/SBTelephonyManager.h>

@interface RadioManager(private)
//-(void)set3gState:(BOOL)state;
//-(NSString *)getLocationKey;
-(BOOL)supportLTE;
@end

@interface CLLocationManager()
+ (void)setLocationServicesEnabled:(BOOL)arg1;
@end


@implementation RadioManager

-(RadioManager *)init {
    self = [super init];
    if (self) {
        // Custom initialization
        BOOL status = [self wifiStatus];
        status = [self _3gStatus];
        status = [self edgeStatus];
        status = [self locationStatus];
        status = [self bluetoothStatus];
        status = [self airplaneModeStatus];
        
    }
    return self;
}

-(BOOL)supportLTE
{
	CFArrayRef supportedDataRates = CTRegistrationCopySupportedDataRates();
	if (supportedDataRates) {
		if ([(NSArray *)supportedDataRates containsObject:(id)kCTRegistrationDataRate3G]) {
			if ([(NSArray *)supportedDataRates containsObject:(id)kCTRegistrationDataRate4G]) {
				return YES;
			}
		}
	}
	return NO;
}

-(BOOL)wifiStatus{
    SBWiFiManager *wifi = [NSClassFromString(@"SBWiFiManager") sharedInstance];
    BOOL retVal = [wifi wiFiEnabled];
    NSLog(@"-------------iPowerControl Wifi status:%d", retVal);
    return retVal;
}
-(void)setWifiEnabled:(BOOL)enable {
    SBWiFiManager *wifi = [NSClassFromString(@"SBWiFiManager") sharedInstance];
    BOOL currentStatus = [wifi wiFiEnabled];
    if( enable && !currentStatus ) {
        [wifi setWiFiEnabled:YES];
        NSLog(@"-------------iPowerControl wifi enabled");
    }
    if( !enable && currentStatus ) {
        [wifi setWiFiEnabled:NO];
        NSLog(@"-------------iPowerControl wifi disabled");
    }
}

-(BOOL)_3gStatus{
    BOOL retVal = NO;
    CFStringRef currentDataRates = CTRegistrationGetCurrentMaxAllowedDataRate();
    if([self supportLTE] )
    {
        if( currentDataRates == kCTRegistrationDataRate4G)
            retVal = YES;
    }
    else
    {
        if ( currentDataRates == kCTRegistrationDataRate3G )
            retVal = YES;
    }
    NSLog(@"-------------iPowerControl 3G status:%d", retVal);
    return retVal;
}

-(void)set3gEnabled:(BOOL)enable {
    BOOL currentStatus = [self _3gStatus];
    
    if (currentStatus && !enable) {
        CTRegistrationSetMaxAllowedDataRate(kCTRegistrationDataRate2G);
        NSLog(@"-------------iPowerControl 3G status changed to 2G");
        return;
    }
    if ( !currentStatus && enable ) {
        if ([self supportLTE]) {
            CTRegistrationSetMaxAllowedDataRate(kCTRegistrationDataRate4G);
            NSLog(@"-------------iPowerControl 3G status changed to LTE");
            return;
        }
        else {
            CTRegistrationSetMaxAllowedDataRate(kCTRegistrationDataRate3G);
            NSLog(@"-------------iPowerControl 3G status changed to 3G");
            return;
        
        }
    }
}

-(BOOL)edgeStatus{
    BOOL retVal = CTCellularDataPlanGetIsEnabled();
    NSLog(@"-------------iPowerControl data status:%d", retVal);
    return retVal;
}
-(void)setEdgeEnabled:(BOOL)enable {
    BOOL currentStatus = [self edgeStatus];
    if( enable && !currentStatus) {
        CTCellularDataPlanSetIsEnabled(YES);
        NSLog(@"-------------iPowerControl data enabled");
    }
    if( !enable && currentStatus) {
            CTCellularDataPlanSetIsEnabled(NO);
        NSLog(@"-------------iPowerControl data disabled");
    }
}

-(BOOL)locationStatus{
    BOOL retVal = [CLLocationManager locationServicesEnabled];
    NSLog(@"-------------iPowerControl location status:%d", retVal);
    return retVal;
}
-(void)setLocationEnabled:(BOOL)enable {
    BOOL currentStatus = [self locationStatus];
    if( enable && !currentStatus) {
        [CLLocationManager setLocationServicesEnabled:YES];
        NSLog(@"-------------iPowerControl location enabled");
    }
    if( !enable && [self locationStatus]) {
        [CLLocationManager setLocationServicesEnabled:NO];
        NSLog(@"-------------iPowerControl location disabled");
    }
}

-(BOOL)bluetoothStatus{
    BluetoothManager *blutoothManager = [NSClassFromString(@"BluetoothManager") sharedInstance ];
    BOOL retVal = [blutoothManager enabled];
    NSLog(@"-------------iPowerControl bluetooth status:%d", retVal);
    return retVal;
}
-(void)setBluetoothEnabled:(BOOL)enable {
    BluetoothManager *blutoothManager = [NSClassFromString(@"BluetoothManager") sharedInstance ];
    BOOL currentStatus = [self bluetoothStatus];
    if( enable && !currentStatus ) {
        [blutoothManager setPowered:YES];
        [blutoothManager setEnabled:YES];
        NSLog(@"-------------iPowerControl bluetooth enabled");
    }
    if( !enable && currentStatus) {
        [blutoothManager setEnabled:NO];
        [blutoothManager setPowered:NO];
        NSLog(@"-------------iPowerControl bluetooth disabled");
    }
}

-(BOOL)airplaneModeStatus {
    SBTelephonyManager *telephonyManager = [NSClassFromString(@"SBTelephonyManager") sharedTelephonyManager ];
    BOOL retVal = [telephonyManager isInAirplaneMode];
    NSLog(@"-------------iPowerControl airplane mode:%d", retVal);
    return retVal;
}

@end
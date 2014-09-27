//
//  Configuration.h
//  iPowerControl
//
//  Created by Ahmet ÖZTÜRK on 06/08/14.
//
//

#ifndef iPowerControl_Configuration_h
#define iPowerControl_Configuration_h

#import <Foundation/Foundation.h>

#define kPreferencesFile @"/var/mobile/Library/Preferences/com.iPowerControl.plist"


@interface Configuration : NSObject

-(Configuration *)init;
-(void)saveConfiguration;

@property (strong, nonatomic) NSMutableDictionary *configuration;

/*
 @property (readwrite) NSString *configKeyPath;
 @property (readwrite) BOOL enabled;
 @property (readwrite) BOOL data3G;
 @property (readwrite) BOOL dataEdge;
 @property (readwrite) BOOL wifi;
 @property (readwrite) BOOL locationService;
 */

@end

#endif

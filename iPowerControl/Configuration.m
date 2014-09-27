//
//  Configuration.m
//  iPowerControl
//
//  Created by Ahmet ÖZTÜRK on 06/08/14.
//
//

#import "Configuration.h"
#include <notify.h>

@interface Configuration (private)
-(void)loadConfiguration;
-(BOOL)createConfiguration:(NSString *)fileName;
-(BOOL)fileExist: (NSString *)fileName;
@end

@implementation Configuration

@synthesize configuration;

/*
 @synthesize configKeyPath;
 @synthesize enabled;
 @synthesize data3G;
 @synthesize dataEdge;
 @synthesize wifi;
 @synthesize locationService;
 */

-(Configuration *)init{
    self = [super init];
    if( self )
        [self loadConfiguration];
    
    return self;
}

-(void)saveConfiguration{
    
    NSString *path = kPreferencesFile;
#if DEBUG
    NSBundle *mainBundle = [NSBundle mainBundle];
    path = [[mainBundle resourcePath] stringByAppendingString:@"net.mobilim.iBattSaver.plist"];
#endif
    
    if (![configuration writeToFile:path atomically:YES ]) {
        @throw [NSException  exceptionWithName:@"ConfigFileWrite" reason:[NSString stringWithFormat:@"Could not write configuration file :%@", path] userInfo:nil ];
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"net.mobilim.iBattSaver/changeSettings" object:nil];
    
    
    
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    
    CFNotificationCenterPostNotification(
                                         r,
                                         (CFStringRef)@"com.mobilim.iPowerControl/updated",
                                         NULL,
                                         NULL,
                                         YES);
    
    NSLog(@"-------------iPowerControl configuration saved");
}


#pragma Private Methods

-(void)loadConfiguration{
    
    NSString *path = kPreferencesFile;
#if DEBUG
    NSBundle *mainBundle = [NSBundle mainBundle];
    path = [[mainBundle resourcePath] stringByAppendingString:@"net.mobilim.iBattSaver.plist"];
#endif
    
    if( ![self fileExist:path ] ){
        if( ![self createConfiguration:path] )
        {
            NSLog(@"-------------iPowerControl Could not crete configuration file:'%@'", path);
            @throw [NSException  exceptionWithName:@"ConfigFileCreate" reason:[NSString stringWithFormat:@"Could not crete configuration file :%@", path] userInfo:nil ];
        }
    }
    
    configuration = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
}


-(BOOL)createConfiguration:(NSString *)path {
    
    configuration = [[NSMutableDictionary alloc] init];
    
    [configuration setValue:[NSNumber numberWithBool:YES] forKeyPath:@"enabled" ];
    [configuration setValue:[NSNumber numberWithInt:5] forKeyPath:@"actionDelay"];
    [configuration setValue:[NSNumber numberWithBool:YES] forKeyPath:@"closeData"];
    [configuration setValue:[[NSMutableDictionary alloc] init] forKeyPath:@"whenSleep"];
    [configuration setValue:[[NSMutableDictionary alloc] init] forKeyPath:@"whenWakeup"];
    
    return [configuration writeToFile:path atomically:YES];
}

-(BOOL)fileExist: (NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:fileName];
}

@end
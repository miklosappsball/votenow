//
//  DeviceUtil.m
//  Feedback
//
//  Created by Andris Konfar on 21/08/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "DeviceUtil.h"
#import "Communication.h"
#import "ChatVC.h"

#define DEVICE_ID @"DEVICE_ID"
#define ANGELAPP_ID @"ANGELAPP_ID"
#define MESSAGES @"MESSAGES"



@implementation DeviceUtil

static NSString* deviceId = NULL;

+ (void) setDeviceId:(NSString*) deviceId_
{
    deviceId = deviceId_;
}

+ (NSString*) deviceId
{
    if(deviceId == nil) return @"NO_DEVICE";
    return deviceId;
}

+ (NSString*) deviceType
{
#ifdef DEBUG
    if(DEBUG) return @"IOSD";
    else return @"IOS";
#else
    return @"IOS";
#endif
}

+ (void) setAngelAppId:(NSString*)angelAppId
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:angelAppId forKey:ANGELAPP_ID];
    [defaults synchronize];
}

static NSString* testAngelId = nil;

+ (void) setTestAngelId:(NSString*)testId
{
    testAngelId = testId;
}

+ (NSString*) angelAppId
{
    if(testAngelId != nil) return testAngelId;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:ANGELAPP_ID];
}

+ (void) setTimeStamp:(NSString*)angelAppId
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:angelAppId forKey:FIELD_TIMESTAMP];
    [defaults synchronize];
}

+ (NSString*) timeStamp
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:FIELD_TIMESTAMP];
}

+ (void) getAllPreviousMessages:(ChatVC*) chatVC
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* array = [defaults objectForKey:MESSAGES];
    if (array != nil)
    {
        for(NSDictionary* msg in array)
        {
            NSLog(@"prev messages x: %@", msg);
            [chatVC messageRecieved:msg];
        }
    }
}

+ (void) saveMessage:(NSDictionary*)msg
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* prevArray = [defaults objectForKey:MESSAGES];
    if(prevArray == nil) prevArray = [NSArray arrayWithObjects: nil];
    NSMutableArray* array = [NSMutableArray arrayWithArray:prevArray];
    [array addObject:msg];
    [defaults setObject:array forKey:MESSAGES];
    
    NSLog(@"message: %@", msg);
}

@end

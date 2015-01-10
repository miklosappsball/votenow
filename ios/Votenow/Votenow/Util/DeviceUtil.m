//
//  DeviceUtil.m
//  Feedback
//
//  Created by Andris Konfar on 21/08/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "DeviceUtil.h"

#define DEVICE_ID @"DEVICE_ID"



@implementation DeviceUtil

static NSString* deviceId = NULL;

+ (void) setDeviceId:(NSString*) deviceId_
{
    deviceId = deviceId_;
}

+ (NSString*) deviceId
{
    /*
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* did = [defaults objectForKey:DEVICE_ID];
    if(did == nil)
    {
        NSLog(@"creating new device id");
        NSString* str = [[NSString alloc] initWithFormat:@"ABC_%d", rand()];
        [defaults setObject:str forKey:DEVICE_ID];
        did = str;
        [defaults synchronize];
    }
    NSLog(@"device id: %@", did);
    return did;
     */
    if(deviceId == nil) return @"IOS_DEVICE_ID_1";
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

@end

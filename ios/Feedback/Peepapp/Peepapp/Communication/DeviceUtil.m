//
//  DeviceUtil.m
//  Feedback
//
//  Created by Andris Konfar on 21/08/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "DeviceUtil.h"

#define DEVICE_ID @"DEVICE_ID"
#define PHONE_NUMBER @"PHONE_NUMBER"



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
    return @"IOS";
}

+ (void) setPhoneNumber:(NSString*)phoneNumber
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:phoneNumber forKey:PHONE_NUMBER];
    [defaults synchronize];
}

+ (NSString*) phoneNumber
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:PHONE_NUMBER];
}

static NSString* peekBackNumber = nil;

+ (void) setPeekBackNumber:(NSString*)phoneNumber
{
    peekBackNumber = phoneNumber;
}

+ (NSString*) peekBackNumber
{
    return peekBackNumber;
}

@end

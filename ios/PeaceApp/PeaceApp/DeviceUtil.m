//
//  DeviceUtil.m
//  PeaceApp
//
//  Created by Andris Konfar on 30/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "DeviceUtil.h"

#define PEACE_ID_KEY @"PEACE_ID_KEY"
#define PEACE_ID_KEY_NUMBER @"PEACE_ID_KEY_NUMBER"

@implementation DeviceUtil

+ (NSString*) getId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PEACE_ID_KEY];
}

+ (void) setId:(NSString*)pid number:(NSNumber*) number
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:pid forKey:PEACE_ID_KEY];
    [defs setObject:number forKey:PEACE_ID_KEY_NUMBER];
    [defs synchronize];
}

@end

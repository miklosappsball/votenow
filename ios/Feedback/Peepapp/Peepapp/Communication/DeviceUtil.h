//
//  DeviceUtil.h
//  Feedback
//
//  Created by Andris Konfar on 21/08/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtil : NSObject

+ (NSString*) deviceId;
+ (NSString*) deviceType;

+ (NSString*) phoneNumber;
+ (void) setPhoneNumber:(NSString*)phoneNumber;

+ (void) setDeviceId:(NSString*) deviceId_;

+ (void) setPeekBackNumber:(NSString*)phoneNumber;
+ (NSString*) peekBackNumber;

@end
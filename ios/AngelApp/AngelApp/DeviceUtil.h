//
//  DeviceUtil.h
//  Feedback
//
//  Created by Andris Konfar on 21/08/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatVC;

@interface DeviceUtil : NSObject

+ (NSString*) deviceId;
+ (NSString*) deviceType;
+ (void) setDeviceId:(NSString*) deviceId_;

+ (void) setAngelAppId:(NSString*)angelAppId;
+ (void) setTestAngelId:(NSString*)testId;
+ (NSString*) angelAppId;

+ (void) setTimeStamp:(NSString*)angelAppId;
+ (NSString*) timeStamp;

+ (void) getAllPreviousMessages:(ChatVC*) chatVC;
+ (void) saveMessage:(NSDictionary*)msg;

@end

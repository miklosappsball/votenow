//
//  DeviceUtil.h
//  PeaceApp
//
//  Created by Andris Konfar on 30/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtil : NSObject

+ (NSString*) getId;
+ (void) setId:(NSString*)pid;
+ (void) setId:(NSString*)pid number:(NSNumber*) number;

@end

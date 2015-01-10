//
//  AnalyticsHelper.h
//  Peepapp
//
//  Created by Andris Konfar on 06/01/15.
//  Copyright (c) 2015 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyticsHelper : NSObject

+ (void) send:(NSString*)action;
+ (void) send:(NSString*)action label:(NSString*)label;
+ (void) initAnalytics;

@end

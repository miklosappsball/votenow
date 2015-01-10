//
//  AnalyticsHelper.m
//  Peepapp
//
//  Created by Andris Konfar on 06/01/15.
//  Copyright (c) 2015 Andris Konfar. All rights reserved.
//

#import "AnalyticsHelper.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@implementation AnalyticsHelper

+ (void) send:(NSString*)action
{
    [AnalyticsHelper send:action label:nil];
}

+ (void) send:(NSString*)action label:(NSString*)label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:nil
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
}

+ (void) initAnalytics
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelError];
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-56118414-1"];
}

@end

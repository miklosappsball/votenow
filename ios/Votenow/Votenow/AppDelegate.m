//
//  AppDelegate.m
//  Feedback
//
//  Created by Andris Konfar on 15/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "MainViewController.h"
#import "DeviceUtil.h"
#import "RateResultViewController.h"
#import "AnalyticsHelper.h"

@interface AppDelegate ()
{
    NSString* code;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AnalyticsHelper initAnalytics];
    [AnalyticsHelper send:@"AppStarted"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = ROOTVIEWCONTROLLER;
    [self.window makeKeyAndVisible];
    ROOTVIEWCONTROLLER.view.frame = self.window.bounds;
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    /*
    NSDictionary* dict = [[NSDictionary alloc] initWithObjects:
                          [NSArray arrayWithObjects:
                                            [NSDictionary dictionaryWithObject:@"Server question text" forKey:@"alert"],
//                                                                    @"677457", nil]
                                                                        @"764147", nil]
//                                                                    @"842964", nil]
                                                       forKeys:[NSArray arrayWithObjects:@"aps", @"code", nil]];
    [self application:application didReceiveRemoteNotification:dict];
    */
    
    NSLog(@"%@", [DeviceUtil deviceType]);
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    NSLog(@"notification settings");
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceTokenD
{
    NSString* deviceToken = [NSString stringWithFormat:@"%@", deviceTokenD];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    NSLog(@"devicetoken: %@", deviceToken);
    
    [DeviceUtil setDeviceId:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"error: %@",str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary* dict = [userInfo objectForKey:@"aps"];
    code = [userInfo objectForKey:@"code"];
    NSString* msg = @"Couldn't recognize the message";
    if(dict != nil)
    {
        NSLog(@"Items:");
        for(NSString* str in dict) NSLog(@"item: %@ - %@", str, dict[str]);
        NSString* str = [dict objectForKey:@"alert"];
        if(str!=nil)
        {
            msg = str;
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:@"is rated and the result was sent to your email! Do you want to check it here right now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok",nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [MAIN_VIEW_CONTROLLER changeToViewController:[[RateResultViewController alloc] initWithCode:code]];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

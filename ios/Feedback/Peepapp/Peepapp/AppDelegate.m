//
//  AppDelegate.m
//  Peepapp
//
//  Created by Andris Konfar on 19/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "AppDelegate.h"
#import "RegisterVC.h"
#import "DeviceUtil.h"
#import "LoadingIndicatorViewController.h"
#import "CameraVC.h"
#import "ContactsVC.h"
#import "Communication.h"
#import "PushData.h"
#import "AnswerPageVC.h"
#import "QueueHandler.h"
#import "MainNavigationController.h"
#import "InfoViewController.h"
#import "AnalyticsHelper.h"

@interface AppDelegate ()
{
    MainNavigationController* navController;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AnalyticsHelper initAnalytics];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    [self.window makeKeyAndVisible];
    
    UIViewController* registerVC = [[InfoViewController alloc] init];
    navController = [[MainNavigationController alloc] initWithRootViewController:registerVC];
    [MainNavigationController setInstance:navController];
    
    self.window.rootViewController = navController;
    [navController.view addSubview:LOADING_INDICATOR.view];
    
    if([DeviceUtil phoneNumber] != nil)
    {
        UIViewController* contactsVC = [[ContactsVC alloc] init];
        [navController pushViewController:contactsVC animated:NO];
    }
         
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
    return YES;
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

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    NSLog(@"notification settings");
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"error: %@",str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary* dict = [userInfo objectForKey:@"aps"];
    NSString* msg = @"nil";
    if(dict != nil)
    {
        NSString* str = [dict objectForKey:@"alert"];
        if(str!=nil)
        {
            msg = str;
        }
    }
    PushData* pd = [[PushData alloc] initFromDictionary:userInfo];
    pd.msg = msg;
    
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        [QUEUE_HANDLER addPushDataToQueueOrStart:pd];
    }
    else
    {
        [QUEUE_HANDLER addPushDataToQueue:pd];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

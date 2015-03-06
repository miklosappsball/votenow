//
//  QueueHandler.m
//  Peepapp
//
//  Created by Andris Konfar on 10/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "QueueHandler.h"
#import "AnswerPageVC.h"
#import "ContactsVC.h"
#import "CameraVC.h"
#import "MainNavigationController.h"
#import "Communication.h"
#import "AnalyticsHelper.h"

#define QUEUE @"PUSHDATA_QUEUE"

#define TYPE @"TYPE"
#define TYPE_ALERT @"TYPE_ALERT"
#define TYPE_PEEKBACK @"TYPE_PEEKBACK"
#define TYPE_SMS_NEEDED @"TYPE_SMS_NEEDED"
#define TITLE @"TITLE"
#define MESSAGE @"MSG"
#define PHONE_NUMBER @"PHONE"

@interface QueueHandler ()
{
    NSDictionary* actualDictionary;
    BOOL shown;
}

@end


@implementation QueueHandler

static QueueHandler* instance = nil;

+ (QueueHandler*)instance
{
    if(instance == nil)
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:QUEUE];
        [defaults synchronize];
        instance = [[QueueHandler alloc] init];
    }
    return instance;
}

- (void) addPushDataToQueue:(PushData*)pd
{
    [self addObjectToQueue:[pd dictionaryRepr]];
}


- (void) addPushDataToQueueOrStart:(PushData*)pd
{
    if(shown)
    {
        [self addPushDataToQueueOrStart:pd];
    }
    else
    {
        [self doPushDataFunctions:pd];
    }
}

- (void) addAlertToQueue:(NSString*)title withString:(NSString *)str
{
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          TYPE_ALERT,TYPE,
                          title, TITLE,
                          str, MESSAGE,
                           nil];
    [self addObjectToQueue:dict];
}

- (void) addPeekBackToQueue:(PushData*)pd
{
    NSString* msg = [NSString stringWithFormat:@"Your photo was sent to %@ (%@). The photo will be displayed on that device only one time for 3 seconds, save is not supported.", pd.name, pd.phoneNumber];
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          TYPE_PEEKBACK, TYPE,
                          pd.phoneNumber, PHONE_NUMBER,
                          msg, MESSAGE,
                          nil];
    [self addObjectToQueue:dict];
}

- (void) addSMSNeededToQueue:(NSString*)phone
{
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          TYPE_SMS_NEEDED, TYPE,
                          phone, PHONE_NUMBER,
                          nil];
    [self addObjectToQueue:dict];
}


- (void) addObjectToQueue:(NSObject*)obj
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* array = [defaults objectForKey:QUEUE];
    if(array == nil) array = [[NSMutableArray alloc] init];
    array = [[NSMutableArray alloc] initWithArray:array];
    [array addObject:obj];
    
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSString* answer = ((NSDictionary*)obj)[@"answer"];
        if([@"F" isEqualToString:answer])
        {
            [AnalyticsHelper send:@"IncomingPeek"];
        }
        if([@"T" isEqualToString:answer])
        {
            [AnalyticsHelper send:@"SuccessfulPeek"];
        }
    }

    
    [defaults setObject:array forKey:QUEUE];
    [defaults synchronize];
    
    [[MainNavigationController instance] tryToShowPopup];
}

- (void) createNextItem
{
    if(shown) return;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* array = [defaults objectForKey:QUEUE];
    if(array == nil || array.count == 0) return;
    array = [[NSMutableArray alloc] initWithArray:array];
    
    shown = YES;
    NSDictionary* dict = array[0];
    actualDictionary = dict;
    [array removeObjectAtIndex:0];
    
    [defaults setObject:array forKey:QUEUE];
    [defaults synchronize];
    
    NSString* type = dict[TYPE];
    NSLog(@"alert: %@",type);
    if(type == nil)
    {
        PushData* pd = [[PushData alloc] initFromDictionary:dict];
        NSString* title = @"Peek request";
        if(pd.answer)
        {
            title = @"Successfull peek";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:pd.msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if([type isEqualToString:TYPE_ALERT])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:actualDictionary[TITLE] message:actualDictionary[MESSAGE] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if([type isEqualToString:TYPE_PEEKBACK])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successfull" message:actualDictionary[MESSAGE] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Peek back!", nil];
        [alert show];
        return;
    }
    if([type isEqualToString:TYPE_SMS_NEEDED])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SMS needed" message:@"Your friend is not registred to PeekApp, yet. Invite her/him via sms/text and your peek request will be delivered by the app." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    shown = NO;
    NSString* type = actualDictionary[TYPE];
    if(type == nil)
    {
        PushData* pd = [[PushData alloc] initFromDictionary:actualDictionary];
        
        [self doPushDataFunctions:pd];
    }
    if([type isEqualToString:TYPE_PEEKBACK])
    {
        if(buttonIndex == 1)
        {
            [AnalyticsHelper send:@"PeekBackSent"];
            [ContactsVC startpeep:actualDictionary[PHONE_NUMBER] anonym:NO contactsVC:nil];
        }
    }
    if([type isEqualToString:TYPE_SMS_NEEDED])
    {
        [AnalyticsHelper send:@"PeekRequestSentNeedsSms"];
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            shown = YES;
            NSString* phone_to = actualDictionary[PHONE_NUMBER];
            controller.body = @"Hey there, I want to take a peek at you right now, please install peekapp in http://appsball.com/peekappinstall and let me take a peek at you!";
            controller.recipients = [NSArray arrayWithObjects:phone_to, nil];
            controller.messageComposeDelegate = [MainNavigationController instance];
            [[MainNavigationController instance] presentViewController:controller animated:YES completion:nil];
        }
    }
    
    [[MainNavigationController instance] tryToShowPopup];
}

- (void) doPushDataFunctions:(PushData*) pd
{
    if(pd.answer)
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        UIViewController* cameraVC = [[AnswerPageVC alloc] initWithPushId:pd.pushId];
        [[MainNavigationController instance] pushViewController:cameraVC animated:YES];
        NSMutableArray* contacts = [defaults objectForKey:LAST_CONTACTS_UD];
        if(contacts == nil) contacts = [[NSMutableArray alloc] initWithCapacity:10];
        else contacts = [NSMutableArray arrayWithArray:contacts];
        
        NSMutableArray* temp = [[NSMutableArray alloc] initWithCapacity:10];
        
        for(NSDictionary* pdDict in contacts)
        {
            PushData* contact = [[PushData alloc] initFromDictionary:pdDict];
            if([contact.phoneNumber isEqualToString:pd.phoneNumber]) [temp addObject:pdDict];
        }
        for(NSDictionary* pdDict in temp) [contacts removeObject:pdDict];
        
        [contacts insertObject:[pd dictionaryRepr] atIndex:0];
        
        if(contacts.count>10) [contacts removeLastObject];
        [defaults setObject:contacts forKey:LAST_CONTACTS_UD];
        [defaults synchronize];
        
        for(UIViewController* vc in [MainNavigationController instance].viewControllers)
        {
            if([vc isKindOfClass:[ContactsVC class]])
            {
                [((ContactsVC*)vc) createLastContacts];
            }
        }
    }
    else
    {
        UIViewController* cameraVC = [[CameraVC alloc] initWithPushId:pd];
        // [DeviceUtil setPeekBackNumber:pd.phoneNumber];
        [[MainNavigationController instance] pushViewController:cameraVC animated:YES];
    }
}

- (void) setShown:(BOOL)v
{
    shown = v;
    if(!shown) [self createNextItem];
}

@end

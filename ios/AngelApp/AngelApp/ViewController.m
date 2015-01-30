//
//  ViewController.m
//  AngelApp
//
//  Created by Andris Konfar on 26/11/14.
//  Copyright (c) 2014 Appsball. All rights reserved.
//

#import "ViewController.h"
#import "Communication.h"
#import "DeviceUtil.h"
#import "ChatVC.h"

#define GAP 10

#define TEST NO
#define BUTTON_HEIGHT 60

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@interface ViewController ()
{
    UIActivityIndicatorView* activity;
    UILabel* label;
    UIButton* button;
}

@end

@implementation ViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // [DeviceUtil setAngelAppId:@"3"];
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activity startAnimating];
        
        CGFloat x = self.view.frame.size.width / 2 - activity.frame.size.width / 2;
        CGFloat y = self.view.frame.size.height / 2 - activity.frame.size.height / 2;
        activity.frame = CGRectMake(x, y, activity.frame.size.width, activity.frame.size.height);
        [self.view addSubview:activity];
        
        button = [UIButton buttonWithType:UIButtonTypeInfoDark];
        button.frame = CGRectMake(self.view.frame.size.width - GAP - button.frame.size.width, 20+GAP, button.frame.size.width, button.frame.size.height);
        [self.view addSubview:button];
        [button addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
        
        if(TEST)
        {
            CGFloat width = self.view.frame.size.width / 4;
            for(int i=1;i<=4;i++)
            {
                UIButton* b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [b setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
                b.frame = CGRectMake((i-1)*width, self.view.frame.size.height - 50, width, 50);
                [b addTarget:self action:@selector(selectId:) forControlEvents:UIControlEventTouchUpInside];
                b.tag = i;
                [self.view addSubview:b];
            }
        }
        
        [self startRegistration];
    }
    return self;
}

- (void)startRegistration0
{
    [NSThread sleepForTimeInterval:1];
    [self performSelectorOnMainThread:@selector(startRegistration) withObject:nil waitUntilDone:YES];
}

- (void)startRegistration
{
    if(![@"NO_DEVICE" isEqualToString:[DeviceUtil deviceId]])
    {
        COMMUNICATION.registrationCallback = self;
        if([DeviceUtil angelAppId] != nil)
        {
            [self registrationCallbackMethod:[NSDictionary dictionaryWithObjectsAndKeys:[DeviceUtil angelAppId], FIELD_ID, [DeviceUtil timeStamp], FIELD_TIMESTAMP, nil]];
        }
        else
        {
            [COMMUNICATION registration:@"hu"];
        }
    }
    else
    {
        [self performSelectorInBackground:@selector(startRegistration0) withObject:nil];
    }
}

- (void) showInfo
{
    NSString* helpText = [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@\n\n%@",
                          @"This application was developed to create a social space where people can help each other by advices or just able to discuss the everyday issues of the Life with someone else. You can have a virtual friend and you can be a virtual friend of an other unknown person. You will not be alone anymore!",
                          @"For this reason the application will link you randomly with an unknown person (maybe from a different part of the world, having a different culture, age, religion,...) who can turn you for help or advise.",
                          @"At the same time you will have an Angel who will help you in every situation of your life by advises.",
                          @"Take your task and mission (to be a real ANGEL) seriously! Someone count on you!",
                          @"PLEASE restrict your real identity to avoid any illegal use of the application. Do not provide any personal information (eg. full name, address, phone number, financial information,...) about yourself in the application and always make your own decision based on any advices."];
    
    UIViewController* vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    CGFloat y = 20+GAP;
    UITextView* tv = [[UITextView alloc] initWithFrame:CGRectMake(GAP, y, vc.view.frame.size.width - GAP - GAP, vc.view.frame.size.height - y - BUTTON_HEIGHT)];
    tv.text = helpText;
    tv.font = [UIFont systemFontOfSize:17];
    [vc.view addSubview:tv];
    [self presentViewController:vc animated:YES completion:^{}];

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"OK" forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, vc.view.frame.size.height - BUTTON_HEIGHT, vc.view.frame.size.width, BUTTON_HEIGHT);
    [vc.view addSubview:btn];
    [btn addTarget:self action:@selector(infoOk) forControlEvents:UIControlEventTouchUpInside];
    
    /*
    if(SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        [[[UIAlertView alloc] initWithTitle:@"Info" message:helpText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        UIAlertController* c = [UIAlertController alertControllerWithTitle:@"Info" message:helpText preferredStyle:UIAlertControllerStyleAlert];
        [c addAction: [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [c dismissViewControllerAnimated:YES completion:nil];
                             }]];
        [self presentViewController:c animated:YES completion:^{}];
    }
          */
}

- (void)infoOk
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void) selectId:(UIButton*) sender
{
    [DeviceUtil setTestAngelId:[NSString stringWithFormat:@"%d", sender.tag]];
    [self presentViewController:[[ChatVC alloc] init] animated:YES completion:nil];
    [COMMUNICATION login];
}

- (void) registrationCallbackMethod:(NSDictionary*) dict
{
    NSString* appid = [NSString stringWithFormat:@"%@", [dict objectForKey:FIELD_ID]];
    [DeviceUtil setAngelAppId:appid];
    
    NSString* time = [dict objectForKey:FIELD_TIMESTAMP];
    [DeviceUtil setTimeStamp:time];
    
    /*
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:10];
    NSString* str = [df stringFromDate:date];
    [DeviceUtil setTimeStamp:str];
    */
    
    [COMMUNICATION login];
}

- (void) loggedIn:(NSDictionary*) dict
{
    if(((NSNumber*)[dict objectForKey:FIELD_ID_ANGEL]).intValue < 1 &&
       ((NSNumber*)[dict objectForKey:FIELD_ID_PROTEGE]).intValue < 1)
    {
        NSString* helpText = [NSString stringWithFormat:@"%@\n\n%@\n\n%@",
                              @"Magic has already started! Your Angel is coming and You can help your Protege soon...",
                              @"You are not alone anymore! Please read carefully our help for further instruction and information!",
                              @"Activitation in a few minutes. Time remained:"];
        
        NSString* time = [DeviceUtil timeStamp];
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDate* date = [df dateFromString:time];
        
        NSTimeInterval tm = [date timeIntervalSinceDate:[NSDate date]];
        if(tm < 0)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [NSThread sleepForTimeInterval:7];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [COMMUNICATION login];
                });
            });
            return;
        }
        
        UILabel* helpLabel = [[UILabel alloc] init];
        helpLabel.textAlignment = NSTextAlignmentCenter;
        helpLabel.text = helpText;
        helpLabel.numberOfLines = 0;
        CGSize size = [helpText  sizeWithFont:helpLabel.font constrainedToSize:CGSizeMake(self.view.frame.size.width-GAP-GAP, 10000) lineBreakMode:helpLabel.lineBreakMode];
        CGFloat y = self.view.frame.size.height / 4 - size.height / 2 + 40;
        helpLabel.frame = CGRectMake(GAP, y, size.width, size.height);
        [self.view addSubview:helpLabel];
        
        y = self.view.frame.size.height / 2 + 20;
        label = [[UILabel alloc] initWithFrame:CGRectMake(GAP, y, self.view.frame.size.width - GAP - GAP, 50)];
        label.text = @"";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor redColor];
        label.font = [UIFont boldSystemFontOfSize:24];
        label.alpha = 0;
        [self.view addSubview:label];
        
        y += 100 + GAP;
        UILabel* label2 = [[UILabel alloc] initWithFrame:CGRectMake(GAP, y, self.view.frame.size.width - GAP - GAP, 50)];
        label2.text = [NSString stringWithFormat:@"Your id: %@", [DeviceUtil angelAppId]];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.textColor = [UIColor redColor];
        label2.font = [UIFont boldSystemFontOfSize:22];
        label2.alpha = 0;
        [self.view addSubview:label2];
        
        [self performSelectorInBackground:@selector(calculateDiff:) withObject:date];
        
        [UIView animateWithDuration:0.25 animations:^{
            activity.alpha = 0;
            label2.alpha = 1;
            label.alpha = 1;
        }];
    }
    else
    {
        ChatVC* chat = [[ChatVC alloc] init];
        [chat loggedIn:dict];
        [self presentViewController:chat animated:YES completion:nil];
    }
}

- (void) calculateDiff:(NSDate*) date
{
    NSTimeInterval tm = [date timeIntervalSinceDate:[NSDate date]];
    double msleft = tm - floor(tm);
    if(tm < 0)
    {
        [UIView animateWithDuration:0.25 animations:^{
            for(UIView* v in self.view.subviews)
            {
                if(v != activity && v != button)
                {
                    [v removeFromSuperview];
                }
            }
            activity.alpha = 1;
        }];
        [COMMUNICATION login];
        return;
    }
    
    long timeto = (long)(tm);
    
    int s = timeto % 60;
    timeto /= 60;
    
    int m = timeto % 60;
    timeto /= 60;
    
    int h = timeto % 24;
    timeto /= 24;
    
    int d = (int)timeto;
    
    NSString* calcbackstr = [NSString stringWithFormat:@"%d days %02d:%02d:%02d", d,h,m,s];
    
    [label performSelectorOnMainThread:@selector(setText:) withObject:calcbackstr waitUntilDone:NO];
    [NSThread sleepForTimeInterval:msleft];
    
    [self performSelectorInBackground:@selector(calculateDiff:) withObject:date];
}

@end

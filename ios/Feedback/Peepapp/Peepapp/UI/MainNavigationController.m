//
//  MainNavigationController.m
//  Peepapp
//
//  Created by Andris Konfar on 13/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "MainNavigationController.h"
#import "ContactsVC.h"
#import "QueueHandler.h"
#import "AnalyticsHelper.h"

@interface MainNavigationController ()

@end

@implementation MainNavigationController

static MainNavigationController* instance = nil;

+ (MainNavigationController*)instance
{
    return instance;
}

+ (void)setInstance:(MainNavigationController*)i
{
    instance = i;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController* vc = [super popViewControllerAnimated:animated];
    [self tryToShowPopup];
    return vc;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
}

- (void)tryToShowPopup
{
    if([self.viewControllers.lastObject isKindOfClass:[ContactsVC class]])
    {
        [QUEUE_HANDLER createNextItem];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString* event = @"SMSCancelled";
    if(MessageComposeResultSent == result) event = @"SMSSent";
    if(MessageComposeResultFailed == result) event = @"SMSFailed";
    
    [AnalyticsHelper send:event];
    
    [QUEUE_HANDLER setShown:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

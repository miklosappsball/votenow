//
//  RootViewController.m
//  Feedback
//
//  Created by Andris Konfar on 15/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "RootViewController.h"
#import "MainViewController.h"
#import "HomePageViewController.h"

@interface RootViewController ()
{
    MainViewController* mainVC;
}
@end

@implementation RootViewController

static RootViewController* instance = nil;

+ (RootViewController*) getInstance
{
    if(instance == nil)
    {
        instance = [[RootViewController alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.view.backgroundColor = [UIColor blackColor];
        mainVC = MAIN_VIEW_CONTROLLER;
        [self.view addSubview:mainVC.view];
        mainVC.view.frame = self.view.bounds;
        
        [MAIN_VIEW_CONTROLLER changeToViewController:[[HomePageViewController alloc] init]];
        
        /*
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                while (YES)
                {
                    [NSThread sleepForTimeInterval:1];
                    NSLog(@"view: %@", NSStringFromCGRect(self.view.frame));
                    NSLog(@"mainview: %@", NSStringFromCGRect(mainVC.view.frame));
                }
            }
        });
         */
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(UIInterfaceOrientationPortrait == toInterfaceOrientation) return YES;
    return NO;
}

- (BOOL)shouldAutorotate
{
    /*
    if (!IPHONE) {
        return YES;
    }
    return NO;
     */
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end

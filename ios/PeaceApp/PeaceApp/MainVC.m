//
//  MainVC.m
//  PeaceApp
//
//  Created by Andris Konfar on 25/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "MainVC.h"
#import "CameraVC.h"
#import "WebserviceCalls.h"
#import "DeviceUtil.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface MainVC ()

@end

@implementation MainVC

+ (void) doLoading:(UILabel*) label number:(UILabel*)number indicator:(UIActivityIndicatorView*)indicator
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    NSDate *dt = [NSDate date];
    NSString *dateAsString = [formatter stringFromDate:dt];
    label.text = [NSString stringWithFormat:@"PEACE COMMUNITY\n(%@):",dateAsString];
    
    number.alpha = 0;
    [indicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
    {
        NSNumber* retNumber = [WebserviceCalls getCount];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if(retNumber != nil)
            {
                number.text = [retNumber stringValue];
            }
            else
            {
                number.text = @"Communication error!";
            }
            [UIView animateWithDuration:0.25 animations:^(){
                number.alpha = 1;
                indicator.alpha = 0;
            }];
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MainPage"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [MainVC doLoading:self.label number:self.number indicator:self.indicator];
    
    self.peaceId.text = [NSString stringWithFormat:@"Your peace ID:\n%@", [DeviceUtil getId]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PRESS"
                                                              action:@"touch"
                                                               label:@"share"
                                                               value:nil] build]];
        
        UIViewController *myVC = [[CameraVC alloc] init];
        [self presentViewController:myVC animated:YES completion:nil];
    }
}

- (IBAction)share:(UIButton*) button
{
    [[[UIAlertView alloc] initWithTitle:@"Announcement" message:@"If you proceed, a photo will be taken, which you can review and then upload to selected social sites with your declaration." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] show];
}

@end

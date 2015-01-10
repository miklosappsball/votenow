//
//  ViewController.m
//  PeaceApp
//
//  Created by Andris Konfar on 20/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>
#import "MainVC.h"
#import "WebserviceCalls.h"
#import "DeviceUtil.h"

@interface ViewController ()
{
    BOOL load;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MainVC doLoading:self.label number:self.number indicator:self.indicator];
}

- (IBAction) ok:(UIButton*) sender
{
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidden = YES;
    indicator.frame = CGRectMake(sender.frame.origin.x + sender.frame.size.width / 2 - indicator.frame.size.width / 2, sender.frame.origin.y + sender.frame.size.height/2 - indicator.frame.size.height/2, indicator.frame.size.width, indicator.frame.size.height);
    [indicator startAnimating];
    [self.view addSubview:indicator];
    
    [UIView animateWithDuration:0.25 animations:^(){
        sender.hidden = YES;
        indicator.hidden = NO;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       NSNumber* retNumber = [WebserviceCalls addId];
                       [NSThread sleepForTimeInterval:3];
                       
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           
                           if(retNumber != nil)
                           {
                               [[[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"Congratulation and thank you for thinking on millions of people who are living in war at this moment!\nYou successfully joined the peace community and will enforce decision makers to stop wars and find solution to any problem!\nTake a photo with your peace ID and share it right now!"
                                                         delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                               
                               NSString* ids = [retNumber stringValue];
                               while(ids.length < 9) ids = [NSString stringWithFormat:@"0%@", ids];
                               int i = ids.length-3;
                               while(i>0)
                               {
                                   ids = [NSString stringWithFormat:@"%@.%@", [ids substringToIndex:i], [ids substringFromIndex:i]];
                                   i = i-3;
                               }
                               [DeviceUtil setId:ids number:retNumber];
                               NSLog(@"ids: %@", ids);
                               
                               [self goOnMain];
                           }
                           else
                           {
                               [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Communication error, please try again!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                               [UIView animateWithDuration:0.25 animations:^() {
                                   sender.hidden = NO;
                                   indicator.hidden = YES;
                               } completion:^(BOOL finished)
                                {
                                    [indicator removeFromSuperview];
                                }];
                           }
                           
                       });
                   });
}

- (void) goOnMain
{
    UIStoryboard *storyboard = self.storyboard;
    UIViewController *myVC = (UIViewController*)[storyboard instantiateViewControllerWithIdentifier:@"MainVC"];
    [self presentViewController:myVC animated:YES completion:nil];
}

@end

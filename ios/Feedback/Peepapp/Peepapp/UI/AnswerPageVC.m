//
//  AnswerPageVC.m
//  Peepapp
//
//  Created by Andris Konfar on 03/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "AnswerPageVC.h"
#import "LoadingIndicatorViewController.h"
#import "Communication.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CameraVC.h"
#import "AnalyticsHelper.h"

@interface AnswerPageVC ()
{
    UIImageView * imageView;
    NSString* pushId;
    UILabel* label;
}

@end

@implementation AnswerPageVC

- (instancetype)initWithPushId:(NSString*) pushId_
{
    self = [super init];
    if (self) {
        [self.navigationItem setHidesBackButton:YES animated:YES];
        pushId = pushId_;
        
        self.view.backgroundColor = COLOR_BACKGROUND_1;
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.width)];
        
        [self.view addSubview:imageView];
        
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-100, self.view.frame.size.width, 100)];
        label.font = [UIFont boldSystemFontOfSize:32];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = TEXT_COLOR_1;
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        [self download];
    }
    return self;
}

- (void) download
{
    [LOADING_INDICATOR showLoadingIndicator];
    
    [[Communication instance] downloadImage:pushId answerFunction: ^(NSDictionary* answer){
        NSString* message = [answer objectForKey:FIELD_MESSAGE];
        [LOADING_INDICATOR hideLoadingIndicator];
        
        if([@"DATA_RECEIVED" isEqualToString:message])
        {
            [AnalyticsHelper send:@"PeekPhotoWatched"];
            
            if(SHUTTER)
            {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            }
            NSData* data = [[Communication instance] lastReceivedData];
            UIImage* image = [UIImage imageWithData:data];
            [imageView setImage:image];
            [CameraVC calculateBackward:label int:3 endString:@"DELETED!"];
            
            [[Communication instance] close];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [NSThread sleepForTimeInterval:3];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = nil;
                });
            });
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [NSThread sleepForTimeInterval:4];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            });
            
        }
        else
        {
            [AnalyticsHelper send:@"ServerErrorOccured" label:@"download"];   
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error during downloading the image" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again!", nil] show];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if(buttonIndex == 1)
    {
        [self download];
    }
}

@end

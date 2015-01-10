//
//  HomeTopViewController.m
//  Feedback
//
//  Created by Andris Konfar on 16/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "HomeTopViewController.h"
#import "Colors.h"
#import "MainViewController.h"
#import "FeedbackViewController.h"
#import "WebserviceCalls.h"
#import "AnswerGetQuestion.h"
#import "ButtonUtil.h"



#define LABEL_QID_SIZE 20
#define TF_FEEDBACK_HEIGHT 30


@interface HomeTopViewController ()
{
    UITextField* tfFeedbackCode;
}
@end

@implementation HomeTopViewController

- (id)initWithFrame:(CGRect) rect
{
    self = [super init];
    if (self)
    {
        self.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        
        CGFloat y = 30;
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y-LABEL_HEIGHT/2, self.view.frame.size.width-LEFT_MARGIN-LEFT_MARGIN, TF_FEEDBACK_HEIGHT)];
        label.text = @"Vote now!";
        label.font = [UIFont boldSystemFontOfSize:LABEL_QID_SIZE];
        // label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        y = 70;
        
        tfFeedbackCode = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y-TF_FEEDBACK_HEIGHT/2, self.view.frame.size.width-LEFT_MARGIN-LEFT_MARGIN, TF_FEEDBACK_HEIGHT)];
        tfFeedbackCode.placeholder = @"... enter vote code ...";
        tfFeedbackCode.font = [UIFont systemFontOfSize:25];
        tfFeedbackCode.textColor = COLOR_TEXTFIELD_T1;
        tfFeedbackCode.textAlignment = NSTextAlignmentCenter;
        tfFeedbackCode.keyboardType = UIKeyboardTypeDecimalPad;
        tfFeedbackCode.layer.borderWidth = 1;
        tfFeedbackCode.layer.borderColor = [COLOR_TEXTFIELD_T1 CGColor];
        tfFeedbackCode.layer.cornerRadius = 7;
        [self.view addSubview:tfFeedbackCode];
        
        y = 120;
        
        UIButton* button = [ButtonUtil createButtonOnWhite];
        button.frame = CGRectMake(self.view.frame.size.width/2 - button.frame.size.width/2, y - BUTTON_HEIGHT/2, button.frame.size.width, BUTTON_HEIGHT);
        [button setTitle:@"Vote" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(rateButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        // tfFeedbackCode.text = @"241684";
    }
    return self;
}


-(void) rateButton
{
    [MAIN_VIEW_CONTROLLER.view endEditing:YES];
    [LOADING_INDICATOR showLoadingIndicator];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString* code = tfFeedbackCode.text;
        AnswerGetQuestion* answer = [WebserviceCalls getQuestion:code];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [LOADING_INDICATOR hideLoadingIndicator];
            
            if([answer showError]) return;
            
            FeedbackViewController* fbvc = [[FeedbackViewController alloc] initWithQuestion:answer code:code];
            [MAIN_VIEW_CONTROLLER changeToViewController:fbvc];
        });
    });
}

@end

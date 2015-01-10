//
//  HomeBottomViewController.m
//  Feedback
//
//  Created by Andris Konfar on 21/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "HomeBottomViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Colors.h"
#import "TextFieldDelegate.h"
#import "MainViewController.h"
#import "WebserviceCalls.h"
#import "AnswerAncestor.h"
#import "ButtonUtil.h"

#define EMAIL_IN_USR_DEF @"EMAIL_IN_USR_DEF"

@interface HomeBottomViewController ()
{
    UITextView* question;
    UITextField* email;
    TextFieldDelegate* tfDelegate;
}


@end

@implementation HomeBottomViewController

- (id)initWithFrame:(CGRect) rect;
{
    self = [super init];
    if (self) {
        self.view.frame = rect;
        self.view.backgroundColor = COLOR_BACKGROUND_2;
        
        tfDelegate = [[TextFieldDelegate alloc] init];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 15, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, LABEL_HEIGHT)];
        label.text = @"Ask feedback!";
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        // label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        question = [[UITextView alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 60, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, 90)];
        question.backgroundColor = [UIColor whiteColor];
        question.layer.cornerRadius = CORNER_RADIUS;
        question.font = [UIFont systemFontOfSize:16];
        question.textAlignment = NSTextAlignmentCenter;
        question.delegate = tfDelegate;
        question.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        [self.view addSubview:question];
        
        email = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 170, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, 30)];
        email.backgroundColor = [UIColor whiteColor];
        email.layer.cornerRadius = CORNER_RADIUS;
        email.font = [UIFont systemFontOfSize:16];
        email.textAlignment = NSTextAlignmentCenter;
        email.delegate = tfDelegate;
        email.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        email.placeholder = @"... your email (to send report) ...";
        email.keyboardType = UIKeyboardTypeEmailAddress;
        email.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.view addSubview:email];
        
        NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
        email.text = [defs objectForKey:EMAIL_IN_USR_DEF];
        [defs synchronize];
        
        UIButton* button = [ButtonUtil createButton];
        button.frame = CGRectMake(self.view.frame.size.width / 2 - button.frame.size.width/2, 220, button.frame.size.width, button.frame.size.height);
        [self.view addSubview:button];
        [button setTitle:@"Get rate code" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(askQuestion) forControlEvents:UIControlEventTouchUpInside];
        
        
        //question.text = @"How do you like this low design?";
        //email.text = @"konfar.andras@gmail.com";
    }
    return self;
}

- (void) askQuestion
{
    NSString* msg = nil;
    if(question.text == nil || question.text.length == 0) msg = @"The question field is required!";
    else if(email.text == nil || email.text.length == 0)  msg = @"The email field is required!";
        
    if(msg != nil)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [MAIN_VIEW_CONTROLLER.view endEditing:YES];
    [LOADING_INDICATOR showLoadingIndicator];
    NSLog(@"Get rate code");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AnswerAncestor* answer = [WebserviceCalls createQuestion:question.text description:@"" email:email.text seconds:@"180"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [LOADING_INDICATOR hideLoadingIndicator];
            
            if([answer showError]) return;
            
            NSString* msg = [NSString stringWithFormat:@"Your questionnaire rate code is: %@. Ask people to rate now with this code – within 3 minutes!", answer.value];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
            question.text = @"";
            NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
            [defs setObject:email.text forKey:EMAIL_IN_USR_DEF];
            [defs synchronize];
        });
    });

}

@end

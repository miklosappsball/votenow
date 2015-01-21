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
    UIView* dateShowerButtonView;
    UILabel* dateLabel;
    UIDatePicker* datePicker;
    UIDatePicker* datePickerStart;
    NSDate* timeLimitDate;
    NSDate* timeStartDate;
    long time;
    UIButton* button_Form;
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
        
        dateShowerButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(email.frame)+LEFT_MARGIN, self.view.frame.size.width, 50)];
        [self.view addSubview:dateShowerButtonView];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 0, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, dateShowerButtonView.frame.size.height)];
        label.text = @"Time limit:\n 3 mins";
        label.numberOfLines = 0;
        label.textColor = COLOR_BACKGROUND_1;
        label.backgroundColor = [UIColor clearColor];
        [dateShowerButtonView addSubview:label];
        dateLabel = label;
        
        UIButton* dateShowerButton = [ButtonUtil createButton];
        dateShowerButton.frame = CGRectMake(self.view.frame.size.width - LEFT_MARGIN - 50, dateShowerButtonView.frame.size.height / 2 - 30/2, 50, 30);
        dateShowerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [dateShowerButtonView addSubview:dateShowerButton];
        [dateShowerButton setTitle:@"Set" forState:UIControlStateNormal];
        [dateShowerButton addTarget:self action:@selector(showDateSelector) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        UIButton* button = [ButtonUtil createButton];
        button.frame = CGRectMake(self.view.frame.size.width / 2 - button.frame.size.width/2, 220, button.frame.size.width, button.frame.size.height);
        [self.view addSubview:button];
        [button setTitle:@"Get rate code" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(askQuestion) forControlEvents:UIControlEventTouchUpInside];
        button_Form = button;
        
        [MAIN_VIEW_CONTROLLER scrollSize:0];
    }
    return self;
}

- (void) showDateSelector
{
    UIViewController* vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    
    UIButton* selectDate = [ButtonUtil createButtonOnWhite];
    [selectDate setTitle:@"Select" forState:UIControlStateNormal];
    selectDate.frame = CGRectMake(vc.view.frame.size.width - LEFT_MARGIN - 150, vc.view.frame.size.height - LEFT_MARGIN - selectDate.frame.size.height, 150, selectDate.frame.size.height);
    selectDate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [selectDate addTarget:self action:@selector(selectedDate) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:selectDate];
    
    UIDatePicker* dp = [[UIDatePicker alloc] init];
    dp.frame = CGRectMake(0, CGRectGetMinY(selectDate.frame)-dp.frame.size.height, dp.frame.size.width, dp.frame.size.height);
    dp.minimumDate = [NSDate dateWithTimeIntervalSinceNow:180];
    [vc.view addSubview:dp];
    dp.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    datePicker = dp;
    
    dp = [[UIDatePicker alloc] init];
    dp.frame = CGRectMake(0, CGRectGetMinY(datePicker.frame)-dp.frame.size.height, dp.frame.size.width, dp.frame.size.height);
    dp.minimumDate = [NSDate date];
    [vc.view addSubview:dp];
    dp.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    datePickerStart = dp;
    [datePickerStart addTarget:self action:@selector(changedStartDate) forControlEvents:UIControlEventValueChanged];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, CGRectGetMaxY(datePickerStart.frame) - 20/2, vc.view.frame.size.width - LEFT_MARGIN, 20)];
    lbl.text = @"End:";
    [vc.view addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, CGRectGetMinY(datePickerStart.frame) - 20/2, vc.view.frame.size.width - LEFT_MARGIN, 20)];
    lbl.text = @"Start:";
    [vc.view addSubview:lbl];
    
    [MAIN_VIEW_CONTROLLER presentViewController:vc animated:YES completion:^{}];
}

- (void)changedStartDate
{
    NSDate* dateplus60 = [datePickerStart.date dateByAddingTimeInterval:60];
    if([dateplus60 compare:datePicker.date] == NSOrderedDescending)
    {
        datePicker.date = [datePickerStart.date dateByAddingTimeInterval:180];
    }
    
    datePicker.minimumDate = [datePickerStart.date dateByAddingTimeInterval:60];
}

- (void) selectedDate
{
    NSLog(@"selected date: ");
    [MAIN_VIEW_CONTROLLER dismissViewControllerAnimated:YES completion:^{}];
    timeLimitDate = datePicker.date;
    timeStartDate = datePickerStart.date;
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    dateLabel.text = [NSString stringWithFormat:@"Start of vote:\n    %@\n\nTime limit:\n    %@", [df stringFromDate:timeStartDate], [df stringFromDate:timeLimitDate]];
    dateLabel.frame = CGRectMake(LEFT_MARGIN, 0, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, 500);
    [dateLabel sizeToFit];
    dateShowerButtonView.frame = CGRectMake(0, dateShowerButtonView.frame.origin.y, dateShowerButtonView.frame.size.width, dateLabel.frame.size.height);
    
    button_Form.frame = CGRectMake(button_Form.frame.origin.x, CGRectGetMaxY(dateShowerButtonView.frame)+LEFT_MARGIN, button_Form.frame.size.width, button_Form.frame.size.height);
    [MAIN_VIEW_CONTROLLER dismissViewControllerAnimated:YES completion:^{}];
    
    CGFloat height = CGRectGetMaxY(button_Form.frame)+LEFT_MARGIN;
    [MAIN_VIEW_CONTROLLER scrollSize: self.view.frame.origin.y + height];
    if(self.view.frame.size.height < height) self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, height);
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
        
        
        long seconds = time;
        long secondsStart = 0;
        if(timeLimitDate != nil)
        {
            seconds = [self getMinutesPartSecondsFromNow:timeLimitDate]+60;
            secondsStart = [self getMinutesPartSecondsFromNow:timeStartDate];
        }
        
        AnswerAncestor* answer = nil;
        if(seconds > 0)
        {
            answer = [WebserviceCalls createQuestion:question.text description:@"" email:email.text seconds:[NSString stringWithFormat:@"%ld", seconds] secondsStart:[NSString stringWithFormat:@"%ld", secondsStart]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [LOADING_INDICATOR hideLoadingIndicator];
            
            if(answer == nil)
            {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Your selected end time is expired!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                return;
            }
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


- (long) getMinutesPartSecondsFromNow:(NSDate*) date
{
    NSDateComponents *comps = [[NSCalendar currentCalendar]
                               components:NSSecondCalendarUnit
                               fromDate:date];
    
    return [date timeIntervalSinceDate:[NSDate date]]-[comps second];
}

@end

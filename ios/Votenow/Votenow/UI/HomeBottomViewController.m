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
#import "AnalyticsHelper.h"

#define EMAIL_IN_USR_DEF @"EMAIL_IN_USR_DEF"

@interface Holder : NSObject

@property (nonatomic, strong) UITextField* textView;
@property (nonatomic, strong) UIButton* button;
@property (nonatomic, strong) UILabel* letter;

@end

@implementation Holder
@end

@interface HomeBottomViewController ()
{
    UITextField* question;
    UITextField* email;
    TextFieldDelegate* tfDelegate;
    UISwitch* swMulti;
    UISwitch* swAnonym;
    NSMutableArray* choices;
    UIButton* button;
    UIButton* plusButton;
    CGRect defaulRect;
    
    UIView* dateShowerButtonView;
    UILabel* dateLabel;
    long time;
    
    NSDate* timeLimitDate;
    NSDate* timeStartDate;
    UIDatePicker* datePicker;
    UIDatePicker* datePickerStart;
    
}


@end

@implementation HomeBottomViewController

- (id)initWithFrame:(CGRect) rect;
{
    self = [super init];
    if (self) {
        defaulRect = rect;
        self.view.frame = rect;
        self.view.backgroundColor = COLOR_BACKGROUND_2;
        
        self.view.autoresizingMask = UIViewAutoresizingNone;
        
        tfDelegate = [[TextFieldDelegate alloc] init];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 15, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, LABEL_HEIGHT)];
        label.text = @"Ask to vote!";
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = COLOR_BACKGROUND_1;
        label.backgroundColor = [UIColor clearColor];
        // label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        swAnonym = [[UISwitch alloc] init];
        swAnonym.frame = CGRectMake(LEFT_MARGIN, 60, swAnonym.frame.size.width, swAnonym.frame.size.height);
        [swAnonym setOn:YES animated:NO];
        [self.view addSubview:swAnonym];
        
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(swAnonym.frame)+5, swAnonym.frame.origin.y, 211, swAnonym.frame.size.height)];
        lbl.text = @"Anonymous";
        lbl.font = [UIFont systemFontOfSize:14];
        lbl.textColor = COLOR_BACKGROUND_1;
        [self.view addSubview:lbl];
        
        NSLog(@"lbl: %@", NSStringFromCGRect(lbl.frame));
        
        swMulti = [[UISwitch alloc] init];
        swMulti.frame = CGRectMake(self.view.frame.size.width/2, 60, swMulti.frame.size.width, swMulti.frame.size.height);
        [self.view addSubview:swMulti];
        
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(swMulti.frame)+5, swMulti.frame.origin.y, 211, swMulti.frame.size.height)];
        lbl.text = @"Multichoice";
        lbl.font = [UIFont systemFontOfSize:14];
        lbl.textColor = COLOR_BACKGROUND_1;
        [self.view addSubview:lbl];
        
        NSLog(@"lbl: %@", NSStringFromCGRect(lbl.frame));
        
        question = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 110, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, 40)];
        question.backgroundColor = [UIColor whiteColor];
        question.placeholder = @"...question to be choosen...";
        question.layer.cornerRadius = CORNER_RADIUS;
        question.font = [UIFont systemFontOfSize:18];
        question.textAlignment = NSTextAlignmentCenter;
        question.delegate = tfDelegate;
        question.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        [self.view addSubview:question];
        tfDelegate.wasQuestionEdited = NO;
        tfDelegate.question = question;
        
        email = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 170, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, 40)];
        email.backgroundColor = [UIColor whiteColor];
        email.layer.cornerRadius = CORNER_RADIUS;
        email.font = [UIFont systemFontOfSize:18];
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
        
        button = [ButtonUtil createButton];
        button.frame = CGRectMake(self.view.frame.size.width / 2 - button.frame.size.width/2, 220, button.frame.size.width, button.frame.size.height);
        [self.view addSubview:button];
        [button setTitle:@"Get vote code" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(askQuestion) forControlEvents:UIControlEventTouchUpInside];
        
        plusButton = [ButtonUtil createButton];
        plusButton.frame = CGRectMake(0, 0, 30, 30);
        [self.view addSubview:plusButton];
        [plusButton setTitle:@"+" forState:UIControlStateNormal];
        [plusButton addTarget:self action:@selector(addNewItem) forControlEvents:UIControlEventTouchUpInside];
        
        dateShowerButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        [self.view addSubview:dateShowerButtonView];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 0, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, dateShowerButtonView.frame.size.height)];
        label.text = @"Time limit:\n 3 mins";
        label.numberOfLines = 0;
        label.textColor = COLOR_BACKGROUND_1;
        label.backgroundColor = [UIColor clearColor];
        [dateShowerButtonView addSubview:label];
        dateLabel = label;
        time = 180;
        
        UIButton* dateShowerButton = [ButtonUtil createButton];
        dateShowerButton.frame = CGRectMake(self.view.frame.size.width - LEFT_MARGIN - 50, dateShowerButtonView.frame.size.height / 2 - 30/2, 50, 30);
        dateShowerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [dateShowerButtonView addSubview:dateShowerButton];
        [dateShowerButton setTitle:@"Set" forState:UIControlStateNormal];
        [dateShowerButton addTarget:self action:@selector(showDateSelector) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addNewItem:NO];
        [self addNewItem:NO];
        
        email.text = @"konfar.andras@gmail.com";
        question.text = @"My question!";
    }
    return self;
}

- (void) addNewItem
{
    [self addNewItem:YES];
}

- (void) addNewItem:(BOOL)animate
{
    if(choices == nil) choices = [[NSMutableArray alloc] initWithCapacity:15];
    
    CGFloat y = 0;
    if(choices.count > 0) y = CGRectGetMaxY( ((Holder*)choices[choices.count-1]).textView.frame );
    
    UITextField* tv = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width+50, y, self.view.frame.size.width-LEFT_MARGIN-LEFT_MARGIN-30 - plusButton.frame.size.width - 5, 30)];
    tv.backgroundColor = [UIColor whiteColor];
    tv.layer.cornerRadius = CORNER_RADIUS;
    tv.font = [UIFont systemFontOfSize:16];
    tv.textAlignment = NSTextAlignmentCenter;
    tv.delegate = tfDelegate;
    tv.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:tv];
    
    UIButton* minusBtn = [ButtonUtil createButton];
    minusBtn.frame = CGRectMake(CGRectGetMaxX(tv.frame), y, plusButton.frame.size.width, plusButton.frame.size.height);
    [self.view addSubview:minusBtn];
    [minusBtn setTitle:@"-" forState:UIControlStateNormal];
    [minusBtn addTarget:self action:@selector(removeItem:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* letter = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y, LETTER_WIDTH, tv.frame.size.height)];
    letter.font = [UIFont boldSystemFontOfSize:20];
    letter.textColor = COLOR_BACKGROUND_1;
    [self.view addSubview:letter];
    
    Holder* holder = [[Holder alloc] init];
    holder.textView = tv;
    holder.button = minusBtn;
    holder.letter = letter;
    [choices addObject:holder];
    
    
    [MAIN_VIEW_CONTROLLER.view endEditing:YES];
    [self calculatePositions:animate];
}

- (void) removeItem:(UIButton*) sender
{
    if(choices.count <=2) return;
    
    Holder* holder = choices[sender.tag];
    [choices removeObject:holder];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect r = holder.textView.frame;
        r.origin.x = r.origin.x + self.view.frame.size.width*2;
        holder.textView.frame = r;
        r = holder.button.frame;
        r.origin.x = r.origin.x + self.view.frame.size.width*2;
        holder.button.frame = r;
        holder.letter.alpha = 0;
    }];
    
    [MAIN_VIEW_CONTROLLER.view endEditing:YES];
    [self calculatePositions:YES];
}

- (void) calculatePositions:(BOOL)animate
{
    CGFloat duration = animate ? 0.25:0;
    [UIView animateWithDuration:duration animations:^{
        
        CGFloat y = 170;
        
        CGFloat btnx = self.view.frame.size.width-LEFT_MARGIN-plusButton.frame.size.width;
        
        int i=0;
        for(Holder* holder in choices)
        {
            holder.textView.frame = CGRectMake(LEFT_MARGIN+LETTER_WIDTH, y, holder.textView.frame.size.width, holder.textView.frame.size.height);
            holder.button.frame = CGRectMake(btnx, y, plusButton.frame.size.width, plusButton.frame.size.height);
            holder.letter.frame = CGRectMake(LEFT_MARGIN, y, LETTER_WIDTH, holder.textView.frame.size.height);
            holder.letter.text = [NSString stringWithFormat:@"%c:",'A'+i];
            
            if(i+'A'>='Z')
            {
                plusButton.alpha = 0.1;
                plusButton.userInteractionEnabled = NO;
            }
            else
            {
                plusButton.alpha = 1;
                plusButton.userInteractionEnabled = YES;
            }
            
            holder.button.tag = i++;
            holder.textView.placeholder = [NSString stringWithFormat:@"... alternative %d ...", i];
            
            if(choices.count <= 2) holder.button.alpha = 0.1;
            else holder.button.alpha = 1;
            
            y = CGRectGetMaxY(holder.textView.frame) + 5;
        }
        
        plusButton.frame = CGRectMake(btnx, y, plusButton.frame.size.width, plusButton.frame.size.height);
        y = CGRectGetMaxY(plusButton.frame)+5;
        
        // email field position
        CGRect r = email.frame;
        r.origin.y = y + 20;
        email.frame = r;
        
        // button position
        r = button.frame;
        r.origin.y = CGRectGetMaxY(email.frame)+dateShowerButtonView.frame.size.height+40;
        button.frame = r;
        y = CGRectGetMaxY(button.frame)+20;
        
        // dateShowerButton
        dateShowerButtonView.frame = CGRectMake(0, button.frame.origin.y - 20 - dateShowerButtonView.frame.size.height, dateShowerButtonView.frame.size.width, dateShowerButtonView.frame.size.height);
        NSLog(@"datesbv: %@", NSStringFromCGRect(dateShowerButtonView.frame));
        
        r = defaulRect;
        if(y > r.size.height) r.size.height = y;
        self.view.frame = r;
        
        r = self.view.superview.frame;
        r.size.height = CGRectGetMaxY(self.view.frame);
        self.view.superview.frame = r;
        
        [MAIN_VIEW_CONTROLLER scrollSize:CGRectGetMaxY(self.view.frame)];
    }];
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
    
    /*
    NSArray* texts = [NSArray arrayWithObjects:@"5 mins", @"15 mins", @"1 hour", @"1 day", @"1 week", nil];
    NSArray* times = [NSArray arrayWithObjects:
                      [NSNumber numberWithLong:5*60],
                      [NSNumber numberWithLong:15*60],
                      [NSNumber numberWithLong:60*60],
                      [NSNumber numberWithLong:24*60*60],
                      [NSNumber numberWithLong:7*24*60*60],
                      nil];
    
    for(int i=0;i<texts.count;i++)
    {
        UIButton* btn = [ButtonUtil createButtonOnWhite];
        [btn setTitle:texts[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectedTimeLimit:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = ((NSNumber*)times[i]).longValue;
        btn.frame = CGRectMake(self.view.frame.size.width / 2 - button.frame.size.width / 2, LEFT_MARGIN + i*(LEFT_MARGIN/2+button.frame.size.height), button.frame.size.width, button.frame.size.height);
        if(CGRectGetMaxY(btn.frame) < dp.frame.origin.y) [vc.view addSubview:btn];
    }
    */
     
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
    
    [self calculatePositions:NO];
    
    [MAIN_VIEW_CONTROLLER dismissViewControllerAnimated:YES completion:^{}];
}

- (void) selectedTimeLimit:(UIButton*) btn
{
    dateLabel.text = [NSString stringWithFormat:@"Time limit:\n %@", btn.titleLabel.text];
    timeLimitDate = nil;
    time = btn.tag;
    [MAIN_VIEW_CONTROLLER dismissViewControllerAnimated:YES completion:^{}];
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
    NSLog(@"Get vote code");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:choices.count];
        
        for(Holder* h in choices)
        {
            NSString* str = [NSString stringWithFormat:@"%@ %@", h.letter.text, h.textView.text];
            [array addObject:str];
        }
        
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
             answer = [WebserviceCalls createQuestion:question.text
                                                               email:email.text
                                                        secondsStart:[NSString stringWithFormat:@"%ld", secondsStart]
                                                             seconds:[NSString stringWithFormat:@"%ld", seconds]
                                                         multichoice:swMulti.on
                                                              anonym:swAnonym.on
                                                             answers:array];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [LOADING_INDICATOR hideLoadingIndicator];
            
            if(answer == nil)
            {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Your selected end time is expired!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                return;
            }
            if([answer showError]) return;
            
            NSString* msg = [NSString stringWithFormat:@"Your questionnaire vote code is: %@. Ask people to vote now with this code – within 3 minutes!", answer.value];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
            for(Holder* h in choices)
            {
                h.textView.text = @"";
            }
            
            tfDelegate.wasQuestionEdited = NO;
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

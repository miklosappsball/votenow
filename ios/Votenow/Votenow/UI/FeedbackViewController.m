//
//  FeedbackViewController.m
//  Feedback
//
//  Created by Andris Konfar on 22/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Colors.h"
#import "TextFieldDelegate.h"
#import "MainViewController.h"
#import "HomePageViewController.h"
#import "AnswerAncestor.h"
#import "WebserviceCalls.h"
#import "ButtonUtil.h"

@interface FeedbackViewController ()
{
    UITextView* feedBackAnswer;
    TextFieldDelegate* tfDelegate;
    NSString* code;
    NSMutableArray* switches;
    BOOL multi;
    UITextField* name;
}

@end

@implementation FeedbackViewController

- (id)initWithQuestion:(AnswerGetQuestion*) answer code:(NSString*)_code
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = COLOR_BACKGROUND_1;
        code = _code;
        
        tfDelegate = [[TextFieldDelegate alloc] init];
        
        // top label
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 20, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, LABEL_HEIGHT)];
        label.text = @"Vote now";
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20];
        [self.view addSubview:label];
        
        // helper label
        label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 50, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, LABEL_HEIGHT)];
        int sec = answer.leftTimeInSec.intValue;
        label.text = [NSString stringWithFormat:@"You have %d:%02d minutes to rate by tapping the stars and adding your comment!", sec/60, sec%60];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 2;
        label.font = [UIFont systemFontOfSize:11];
        [self.view addSubview:label];
        
        // question
        label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 0, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, 5000)];
        label.text = answer.value;
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:22];
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        label.frame = CGRectMake(LEFT_MARGIN, 90, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, label.frame.size.height);
        [self.view addSubview:label];
        
        // bottom view section
        CGFloat y = CGRectGetMaxY(label.frame)+20;
        UIView* rateView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - y)];
        rateView.backgroundColor = COLOR_BACKGROUND_2;
        [self.view addSubview:rateView];
        
        y = LEFT_MARGIN;
        
        switches = [[NSMutableArray alloc] initWithCapacity:answer.choices.count];
        multi = answer.multi;
        
        for(NSString* a in answer.choices)
        {
            UISwitch* sw = [[UISwitch alloc] init];
            sw.frame = CGRectMake(LEFT_MARGIN, y, sw.frame.size.width, sw.frame.size.height);
            [rateView addSubview:sw];
            [sw addTarget:self action:@selector(onSwitchChange:) forControlEvents:UIControlEventValueChanged];
            [switches addObject:sw];
            
            if(multi && switches.count == 1) [sw setOn:YES];
            
            UILabel* lb = [[UILabel alloc] init];
            lb.textColor = COLOR_BACKGROUND_1;
            lb.text = a;
            lb.numberOfLines = 0;
            [rateView addSubview:lb];
            
            CGFloat x = CGRectGetMaxX(sw.frame) + 5;
            CGSize size = [lb.text sizeWithFont:lb.font constrainedToSize:CGSizeMake(self.view.frame.size.width - x, 10000)];
            if(size.height < sw.frame.size.height) size.height = sw.frame.size.height;
            lb.frame = CGRectMake(x, y, self.view.frame.size.width - x, size.height);
            
            y = MAX(CGRectGetMaxY(sw.frame), CGRectGetMaxY(lb.frame)) + LEFT_MARGIN;
        }
        
        if(answer.anonym)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y, self.view.frame.size.width, LABEL_HEIGHT)];
            label.text = @"This is anonymous vote!";
            label.textColor = [UIColor whiteColor];
            [rateView addSubview:label];
            y += label.frame.size.height + LEFT_MARGIN;
        }
        else
        {
            name = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, 40)];
            name.backgroundColor = [UIColor whiteColor];
            name.layer.cornerRadius = CORNER_RADIUS;
            name.font = [UIFont systemFontOfSize:18];
            name.textAlignment = NSTextAlignmentCenter;
            name.delegate = tfDelegate;
            name.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            name.placeholder = @"... enter your name or email ...";
            name.keyboardType = UIKeyboardTypeEmailAddress;
            name.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [rateView addSubview:name];
            
            y += name.frame.size.height + LEFT_MARGIN;
        }
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y, self.view.frame.size.width, LABEL_HEIGHT)];
        label.text = @"Constructive advice:";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:20];
        label.backgroundColor = [UIColor clearColor];
        [rateView addSubview:label];
        
        y += LABEL_HEIGHT + LEFT_MARGIN;
        
        // feedback answer string
        feedBackAnswer = [[UITextView alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, 90)];
        feedBackAnswer.backgroundColor = [UIColor whiteColor];
        feedBackAnswer.layer.cornerRadius = CORNER_RADIUS;
        feedBackAnswer.font = [UIFont systemFontOfSize:16];
        feedBackAnswer.textAlignment = NSTextAlignmentCenter;
        feedBackAnswer.delegate = tfDelegate;
        [rateView addSubview:feedBackAnswer];
        
        // the cancel and ok button
        y = CGRectGetMaxY(feedBackAnswer.frame)+20;
        CGFloat width = (self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN - LEFT_MARGIN)/2;
        
        UIButton* button = [ButtonUtil createButton];
        button.frame = CGRectMake(LEFT_MARGIN, y, width, button.frame.size.height);
        [button setTitle:@"Cancel" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [rateView addSubview:button];
        
        button = [ButtonUtil createButton];
        button.frame = CGRectMake(LEFT_MARGIN + width + LEFT_MARGIN, y, width, button.frame.size.height);
        [button setTitle:@"Ok" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
        [rateView addSubview:button];
        
        y = CGRectGetMaxY(button.frame) + LEFT_MARGIN;
        CGRect r = rateView.frame;
        if(r.size.height < y) r.size.height = y;
        rateView.frame = r;
        
        r = self.view.frame;
        r.size.height = CGRectGetMaxY(rateView.frame);
        self.view.frame = r;
        
        [MAIN_VIEW_CONTROLLER scrollSize:CGRectGetMaxY(rateView.frame)];
    }
    return self;
}

- (void) onSwitchChange:(UISwitch*)sender
{
    NSLog(@"switch change !!!");
    if(!multi)
    {
        for(UISwitch* sw in switches)
        {
            if(sender != sw) [sw setOn:NO animated:YES];
        }
    }
}

- (void) ok
{
    [MAIN_VIEW_CONTROLLER.view endEditing:YES];
    [LOADING_INDICATOR showLoadingIndicator];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString* answers = @"";
        for(UISwitch* sw in switches)
        {
            if(sw.on) answers = [answers stringByAppendingString:@"1"];
            else answers = [answers stringByAppendingString:@"0"];
        }
        
        NSString* nameStr = name.text;
        if(nameStr == nil) nameStr = @"";
        AnswerAncestor* answer = [WebserviceCalls createAnswer:code answers:answers name:nameStr message:feedBackAnswer.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [LOADING_INDICATOR hideLoadingIndicator];
            
            if([answer showError]) return;
            
            NSString* msg = @"Successfull answer!";
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
            [self cancel];
        });
    });
}

- (void) cancel
{
    HomePageViewController* hpvc = [[HomePageViewController alloc] init];
    [MAIN_VIEW_CONTROLLER changeToViewController:hpvc];
}


@end

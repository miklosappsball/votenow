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
    UIImage* star, *starEmpty;
    NSMutableArray* buttons;
    UITextView* feedBackAnswer;
    TextFieldDelegate* tfDelegate;
    NSString* code;
    int rate;
}

@end

@implementation FeedbackViewController

- (id)initWithQuestion:(NSString*) question code:(NSString*)_code time:(NSString*) time
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = COLOR_BACKGROUND_1;
        code = _code;
        
        tfDelegate = [[TextFieldDelegate alloc] init];
        
        // top label
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 20, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, LABEL_HEIGHT)];
        label.text = @"Rate now";
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20];
        [self.view addSubview:label];
        
        // helper label
        label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 50, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, LABEL_HEIGHT)];
        NSDecimalNumber* decimalNumber = [NSDecimalNumber decimalNumberWithString:time];
        int sec = decimalNumber.intValue;
        label.text = [NSString stringWithFormat:@"You have %d:%02d minutes to rate by tapping the stars and adding your comment!", sec/60, sec%60];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 2;
        label.font = [UIFont systemFontOfSize:11];
        [self.view addSubview:label];
        
        // question
        label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 0, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, 5000)];
        label.text = question;
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:22];
        label.textAlignment = UITextAlignmentCenter;
        [label sizeToFit];
        label.frame = CGRectMake(LEFT_MARGIN, 90, self.view.frame.size.width - LEFT_MARGIN - LEFT_MARGIN, label.frame.size.height);
        [self.view addSubview:label];
        
        // bottom view section
        CGFloat y = CGRectGetMaxY(label.frame)+20;
        UIView* rateView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - y)];
        rateView.backgroundColor = COLOR_BACKGROUND_2;
        [self.view addSubview:rateView];
        
        // the star buttons
        star = [UIImage imageNamed:@"star.png"];
        starEmpty = [UIImage imageNamed:@"star_empty.png"];
        y = 20;
        
        buttons = [[NSMutableArray alloc] initWithCapacity:5];
        
        for(int i=0;i<5;i++)
        {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(LEFT_MARGIN + i*8 + star.size.width*i, y, star.size.width, star.size.height);
            [button setImage:star forState:UIControlStateNormal];
            button.tag = i;
            [button addTarget:self action:@selector(rateChange:) forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:button];
            [rateView addSubview:button];
        }
        [self rateChange:buttons[2]];
        
        y += star.size.height+LEFT_MARGIN;
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
    }
    return self;
}

- (void) ok
{
    [MAIN_VIEW_CONTROLLER.view endEditing:YES];
    [LOADING_INDICATOR showLoadingIndicator];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AnswerAncestor* answer = [WebserviceCalls createAnswer:code rating:rate message:feedBackAnswer.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [LOADING_INDICATOR hideLoadingIndicator];
            
            if([answer showError]) return;
            
            NSString* msg = @"Succesfull rating!";
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

- (void) rateChange:(UIButton*) button
{
    rate = button.tag;
    for(int i=0;i<buttons.count;i++)
    {
        UIButton* b = buttons[i];
        if(i<=button.tag)
        {
            [b setImage:star forState:UIControlStateNormal];
            [b setImage:star forState:UIControlStateHighlighted];
        }
        else
        {
            [b setImage:starEmpty forState:UIControlStateNormal];
            [b setImage:starEmpty forState:UIControlStateHighlighted];
        }
    }
    NSLog(@"rate: %d", rate);
}


@end

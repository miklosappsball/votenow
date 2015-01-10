//
//  RegisterVCViewController.m
//  Peepapp
//
//  Created by Andris Konfar on 24/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "RegisterVC.h"
#import "ButtonUtil.h"
#import "Communication.h"
#import "LoadingIndicatorViewController.h"
#import "ContactsVC.h"
#import "DeviceUtil.h"
#import "AnalyticsHelper.h"

@interface RegisterVC ()
{
    UITextField* tfName;
    UITextField* tfPhone;
}

@end

@implementation RegisterVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"ID Registration";
        self.view.backgroundColor = COLOR_BACKGROUND_1;
        
        UIScrollView* scrollview = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:scrollview];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, LEFT_MARGIN, self.view.frame.size.width-LEFT_MARGIN-LEFT_MARGIN, 1000)];
        label.text = @"Your friends (who knows your phone number) can take a peek at you and you can take a peek at your friends with your phone number. So please first set it up – and then you are ready to take a peek at anybody from your contact list by one tap.";
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textColor = TEXT_COLOR_1;
        label.font = [UIFont systemFontOfSize:FONT_SIZE];
        label.numberOfLines = 0;
        [label sizeToFit];
        [scrollview addSubview:label];
        
        CGFloat y = CGRectGetMaxY(label.frame)+DEFAULT_GAP/2;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y, self.view.frame.size.width-LEFT_MARGIN-LEFT_MARGIN, 1000)];
        label.text = @"Your full name is required to identify yourself in peek requests.";
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textColor = TEXT_COLOR_1;
        label.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        label.numberOfLines = 0;
        [label sizeToFit];
        [scrollview addSubview:label];
        
        y = CGRectGetMaxY(label.frame)+DEFAULT_GAP;
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, TEXT_FIELD_HEIGHT*2)];
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = [BORDER_COLOR CGColor];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.backgroundColor = ITEM_BG_COLOR;
        [scrollview addSubview:view];
        
        tfName = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 0, self.view.frame.size.width-LEFT_MARGIN, TEXT_FIELD_HEIGHT)];
        tfName.placeholder = @"...enter your full name...";
        tfName.textColor = TEXT_COLOR_1;
        tfName.font = [UIFont boldSystemFontOfSize:FONT_TEXTFIELD];
        [view addSubview:tfName];
        
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(LEFT_MARGIN, TEXT_FIELD_HEIGHT, self.view.frame.size.width-LEFT_MARGIN, 0.5f)];
        separator.backgroundColor = BORDER_COLOR;
        [view addSubview:separator];
        
        CGFloat leftMargin = LEFT_MARGIN+15;
        tfPhone = [[UITextField alloc] initWithFrame:CGRectMake(leftMargin, TEXT_FIELD_HEIGHT, self.view.frame.size.width-leftMargin, TEXT_FIELD_HEIGHT)];
        tfPhone.placeholder = @"enter your phone number";
        tfPhone.textColor = TEXT_COLOR_1;
        tfPhone.font = [UIFont boldSystemFontOfSize:FONT_TEXTFIELD];
        [view addSubview:tfPhone];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, TEXT_FIELD_HEIGHT, 15, TEXT_FIELD_HEIGHT)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = TEXT_COLOR_1;
        label.font = [UIFont boldSystemFontOfSize:FONT_TEXTFIELD];
        label.text = @"+";
        [view addSubview:label];
        
        y = CGRectGetMaxY(view.frame)+DEFAULT_GAP;
        
        UIButton* button = [ButtonUtil createButton];
        [button setTitle:@"Register" forState:UIControlStateNormal];
        button.frame = CGRectMake(-0.5, y, self.view.frame.size.width+1, BUTTON_HEIGHT);
        [button addTarget:self action:@selector(registration) forControlEvents:UIControlEventTouchUpInside];
        [scrollview addSubview:button];
        
        /*
        tfName.text = @"Konfar Andras";
        tfPhone.text = @"36309740410";
        */
        
        scrollview.contentSize = CGSizeMake(0, 1000);
    }
    return self;
}

- (void) registration
{
    [LOADING_INDICATOR showLoadingIndicator];
    
    NSString* phoneNumber = [NSString stringWithFormat:@"+%@",tfPhone.text];
    [[Communication instance] registrationWithName:tfName.text phone:phoneNumber answerFunction: ^(NSDictionary* answer){
        
        [[Communication instance]close];
        [LOADING_INDICATOR hideLoadingIndicator];
        
        NSString* msg = [answer objectForKey:FIELD_MESSAGE];
        if([msg isEqualToString:@"SUCCESS"])
        {
            NSString* number = [answer objectForKey:FIELD_NUMBER];
            if(number == nil || number.length == 0 || [@"0" isEqualToString:number])
            {
                [AnalyticsHelper send:@"RegistrationWithoutRequest"];
            }
            else
            {
                [AnalyticsHelper send:@"RegistrationWithPendingRequests" label:number];
            }
            
            [DeviceUtil setPhoneNumber:phoneNumber];
        
            ContactsVC* contacts = [[ContactsVC alloc] init];
            [self.navigationController pushViewController:contacts animated:YES];
        }
        else
        {
            [AnalyticsHelper send:@"ServerErrorOccured" label:@"registration"];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in communication! Please try again!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

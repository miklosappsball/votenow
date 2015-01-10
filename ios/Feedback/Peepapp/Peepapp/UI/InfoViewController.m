//
//  InfoViewController.m
//  Peepapp
//
//  Created by Andris Konfar on 24/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "InfoViewController.h"
#import "ButtonUtil.h"
#import "RegisterVC.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.view.backgroundColor = COLOR_BACKGROUND_1;
        self.title = @"Peekapp help";
        
        UIScrollView* scrollview = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:scrollview];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, LEFT_MARGIN, self.view.frame.size.width-LEFT_MARGIN-LEFT_MARGIN, self.view.frame.size.height-LEFT_MARGIN-LEFT_MARGIN)];
        label.numberOfLines=0;
        label.text = @"LET ME TAKE A PEEK AT YOU NOW!\n\n1. Select who you want to take a peek at\n\n2. She/he will be photod by the app\n\n3. You receive the photo immediately\n\nSaving the photo is not supported and visible only for 3 seconds.\n\nIf your friend has not installed the application yet then your request (invitation) can be sent via sms/text for the first time.\n\nSupport: peekapphelp@appsball.com";
        label.textColor = TEXT_COLOR_1;
        label.font = [UIFont systemFontOfSize:16.0];
        [scrollview addSubview:label];
        [label sizeToFit];
        
        UIButton* button = [ButtonUtil createButton];
        [scrollview addSubview:button];
        [button setTitle:@"Ok" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(forward) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(-0.5, CGRectGetMaxY(label.frame)+DEFAULT_GAP, self.view.frame.size.width+1, BUTTON_HEIGHT);
        
        scrollview.contentSize = CGSizeMake(0, CGRectGetMaxY(button.frame)+DEFAULT_GAP);
    }
    return self;
}

-(void)forward
{
    UIViewController* registerVC = [[RegisterVC alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

@end

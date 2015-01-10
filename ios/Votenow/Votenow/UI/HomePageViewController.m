//
//  HomePageViewController.m
//  Feedback
//
//  Created by Andris Konfar on 15/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "HomePageViewController.h"
#import "HomeTopViewController.h"
#import "HomeBottomViewController.h"
#import "Colors.h"

#define TOPVIEW_HEIGHT 160


@interface HomePageViewController ()
{
    HomeTopViewController* topView;
    HomeBottomViewController* bottomView;
}


@end

@implementation HomePageViewController

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        self.view.backgroundColor = COLOR_BACKGROUND_1;
        self.view.autoresizingMask = UIViewAutoresizingNone;
        
        topView = [[HomeTopViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TOPVIEW_HEIGHT)];
        [self.view addSubview:topView.view];
        
        CGFloat y = CGRectGetMaxY(topView.view.frame);
        bottomView = [[HomeBottomViewController alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height-y)];
        [self.view addSubview:bottomView.view];
        [bottomView calculatePositions:NO];
    }
    return self;
}

@end

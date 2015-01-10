//
//  ButonUtil.m
//  Feedback
//
//  Created by Andris Konfar on 24/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "ButtonUtil.h"

#import "Colors.h"

@implementation ButtonUtil

+ (UIButton*) createButton
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    button.layer.cornerRadius = CORNER_RADIUS;
    button.layer.borderWidth = 2;
    button.layer.borderColor = [COLOR_BACKGROUND_1 CGColor];
    [button setTitleColor:COLOR_BACKGROUND_1 forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    return button;
}


+ (UIButton*) createButtonOnWhite
{
    UIButton* button = [ButtonUtil createButton];
    button.layer.borderColor = [COLOR_BACKGROUND_2 CGColor];
    [button setTitleColor:COLOR_BACKGROUND_2 forState:UIControlStateNormal];
    return button;
}

@end

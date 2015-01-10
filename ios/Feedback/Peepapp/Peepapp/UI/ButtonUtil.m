//
//  ButtonUtil.m
//  Peepapp
//
//  Created by Andris Konfar on 24/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "ButtonUtil.h"

@implementation ButtonUtil

+ (UIButton*) createButton
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 200, BUTTON_HEIGHT);
    button.backgroundColor = BUTTON_BG_COLOR;
    button.layer.borderColor = [BUTTON_BORDER_COLOR CGColor];
    button.layer.borderWidth = 0.5;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button setTitleColor:TEXT_COLOR_1 forState:UIControlStateNormal];
    return button;
}



@end

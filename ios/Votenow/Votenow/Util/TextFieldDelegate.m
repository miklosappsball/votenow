//
//  TextFieldDelegate.m
//  Feedback
//
//  Created by Andris Konfar on 21/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "TextFieldDelegate.h"
#import "MainViewController.h"
#import "AnalyticsHelper.h"

@interface TextFieldDelegate ()

@end

@implementation TextFieldDelegate


- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [MAIN_VIEW_CONTROLLER scrollToFitView:textField];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    [MAIN_VIEW_CONTROLLER scrollToFitView:textView];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.question)
    {
        if(!self.wasQuestionEdited)
        {
            [AnalyticsHelper send:@"QuestionEdited"];
            self.wasQuestionEdited = YES;
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([@"\n" isEqualToString:text])
    {
        [MAIN_VIEW_CONTROLLER.view endEditing:YES];
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([@"\n" isEqualToString:string])
    {
        [MAIN_VIEW_CONTROLLER.view endEditing:YES];
        return NO;
    }
    
    return YES;
}


@end

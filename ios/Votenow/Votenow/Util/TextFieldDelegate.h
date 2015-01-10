//
//  TextFieldDelegate.h
//  Feedback
//
//  Created by Andris Konfar on 21/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldDelegate : NSObject <UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField* question;
@property (nonatomic) BOOL wasQuestionEdited;

@end

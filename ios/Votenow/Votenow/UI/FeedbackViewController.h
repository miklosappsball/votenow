//
//  FeedbackViewController.h
//  Feedback
//
//  Created by Andris Konfar on 22/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AnswerGetQuestion.h"

@interface FeedbackViewController : UIViewController

- (id)initWithQuestion:(AnswerGetQuestion*) answer code:(NSString*)code;

@end

//
//  AnswerGetQuestionResult.h
//  Feedback
//
//  Created by Andris Konfar on 27/08/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnswerAncestor.h"

@interface AnswerGetQuestionResult : AnswerAncestor

@property (nonatomic, strong) NSDictionary* json;

@end

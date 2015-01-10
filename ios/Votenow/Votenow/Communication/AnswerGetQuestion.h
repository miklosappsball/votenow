//
//  AnswerGetQuestion.h
//  Feedback
//
//  Created by Andris Konfar on 23/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "AnswerAncestor.h"

@interface AnswerGetQuestion : AnswerAncestor

@property (nonatomic, strong) NSNumber* leftTimeInSec;
@property (nonatomic, strong) NSArray* choices;
@property (nonatomic) BOOL multi;
@property (nonatomic) BOOL anonym;

@end

//
//  WebserviceCalls.h
//  Feedback
//
//  Created by Andris Konfar on 23/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AnswerGetQuestion;
@class AnswerAncestor;
@class AnswerGetQuestionResult;



#define FIELD_ANONYMOUS @"ANONYMOUS"
#define FIELD_TIME_FN_START @"TIME_FN_START"
#define FIELD_TIME_FN @"TIME_FN"
#define FIELD_DEVICE_TYPE @"DEVICE_TYPE"
#define FIELD_DEVICE_ID @"DEVICE_ID"
#define FIELD_CHOICES @"CHOICES"
#define FIELD_EMAIL @"EMAIL"
#define FIELD_MULTICHOICE @"MULTICHOICE"
#define FIELD_QUESTION @"QUESTION"


@interface WebserviceCalls : NSObject

+ (AnswerAncestor*) createQuestion:(NSString*)question email:(NSString*)email secondsStart:(NSString*)secondsStart seconds:(NSString*)seconds multichoice:(BOOL)multi anonym:(BOOL)anonym answers:(NSArray*)answers;
+ (AnswerAncestor*) createAnswer:(NSString*)code answers:(NSString*)answers name:(NSString*)name message:(NSString*)message;
+ (AnswerGetQuestion*) getQuestion:(NSString*)questionCode;
+ (AnswerGetQuestionResult*) getQuestionResult:(NSString*)code;

@end

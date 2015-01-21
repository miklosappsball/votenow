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

@interface WebserviceCalls : NSObject

+ (AnswerAncestor*) createQuestion:(NSString*)question description:(NSString*)description email:(NSString*)email  seconds:(NSString*)seconds secondsStart:(NSString*)secondsStart;
+ (AnswerAncestor*) createAnswer:(NSString*)code rating:(int)rate message:(NSString*)message;
+ (AnswerGetQuestion*) getQuestion:(NSString*)questionCode;
+ (AnswerGetQuestionResult*) getQuestionResult:(NSString*)code;

@end

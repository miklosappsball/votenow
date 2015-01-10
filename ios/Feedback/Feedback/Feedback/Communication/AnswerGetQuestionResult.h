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

@property (nonatomic, strong) NSString* median;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* avarage;
@property (nonatomic, strong) NSString* numberofrates;
@property (nonatomic, strong) NSString* modus;
@property (nonatomic, strong) NSString* sdeviation;
@property (nonatomic, strong) NSMutableArray* rateStrings;
@property (nonatomic, strong) NSMutableArray* percentageStrings;
@property (nonatomic, strong) NSMutableArray* messages;

@end

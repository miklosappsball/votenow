//
//  AnswerGetQuestion.m
//  Feedback
//
//  Created by Andris Konfar on 23/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "AnswerGetQuestion.h"

@implementation AnswerGetQuestion

- (id)initWithAnswerString:(NSString*) string
{
    self = [super initWithAnswerString:string];
    if (self)
    {
        if(![self isError])
        {
            NSArray* array = [string componentsSeparatedByString:SEPARATOR_CHARACTER];
            self.value = array[0];
            self.leftTimeInSec = array[1];
        }
    }
    return self;
}

@end

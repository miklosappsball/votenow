//
//  AnswerGetQuestionResult.m
//  Feedback
//
//  Created by Andris Konfar on 27/08/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "AnswerGetQuestionResult.h"

@implementation AnswerGetQuestionResult

- (id)initWithAnswerString:(NSString*) string
{
    self = [super initWithAnswerString:string];
    if (self)
    {
        if(![self isError])
        {
            NSData* data = [self.value dataUsingEncoding:NSUTF8StringEncoding];
            NSError* e = nil;
            NSDictionary* jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
            
            if (!jsonArray) {
                self.errorMessage = @"Error with the communication! Please contact us on Apple Store!";
            }
            else
            {
                self.json = jsonArray;
            }
        }
    }
    return self;
}

@end

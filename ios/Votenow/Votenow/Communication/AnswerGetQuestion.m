//
//  AnswerGetQuestion.m
//  Feedback
//
//  Created by Andris Konfar on 23/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "AnswerGetQuestion.h"
#import "WebserviceCalls.h"

@implementation AnswerGetQuestion

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
                self.value = jsonArray[FIELD_QUESTION];
                self.leftTimeInSec = jsonArray[FIELD_TIME_FN];
                self.choices = jsonArray[FIELD_CHOICES];
                self.multi = ((NSNumber*)jsonArray[FIELD_MULTICHOICE]).boolValue;
                self.anonym = ((NSNumber*)jsonArray[FIELD_MULTICHOICE]).boolValue;
            }
        }
    }
    return self;
}

@end

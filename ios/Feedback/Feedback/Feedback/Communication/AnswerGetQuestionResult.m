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
                self.avarage = [jsonArray objectForKey:@"avarage"];
                self.title = [jsonArray objectForKey:@"title"];
                self.median = [jsonArray objectForKey:@"median"];
                self.numberofrates = [jsonArray objectForKey:@"numberOfRates"];
                self.modus = [jsonArray objectForKey:@"modus"];
                self.sdeviation = [jsonArray objectForKey:@"sdeviation"];
                
                self.rateStrings = [[NSMutableArray alloc] init];
                self.percentageStrings = [[NSMutableArray alloc] init];
                
                NSArray* array = [jsonArray objectForKey:@"rates"];
                for(NSDictionary* d in array)
                {
                    [self.percentageStrings addObject:[d objectForKey:@"percentage"]];
                    [self.rateStrings addObject:[d objectForKey:@"rate"]];
                }
                
                
                array = [jsonArray objectForKey:@"messages"];
                self.messages = [[NSMutableArray alloc] init];
                for(NSArray* a in array)
                {
                    NSMutableArray* msgsDown = [[NSMutableArray alloc] init];
                    [self.messages addObject:msgsDown];
                    for(NSString* s in a)
                    {
                        [msgsDown addObject:s];
                    }
                    
                    // [msgsDown addObject:@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."];
                }
            }
        }
    }
    return self;
}

@end

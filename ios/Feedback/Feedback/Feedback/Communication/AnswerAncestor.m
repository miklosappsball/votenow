//
//  AnswerAncestor.m
//  Feedback
//
//  Created by Andris Konfar on 23/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#define ERROR_BEGIN @"ERROR:"

#import "AnswerAncestor.h"

@implementation AnswerAncestor

- (id)initWithAnswerString:(NSString*) string
{
    self = [super init];
    if (self)
    {
        if([string hasPrefix:ERROR_BEGIN])
        {
            self.errorMessage = [string substringFromIndex:ERROR_BEGIN.length];
        }
        else
        {
            self.value = string;
        }
    }
    return self;
}

- (BOOL) isError
{
    return self.errorMessage != nil;
}

- (BOOL) showError
{
    if([self isError])
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:self.errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        return YES;
    }
    return NO;
}

@end

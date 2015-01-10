//
//  PushData.m
//  Peepapp
//
//  Created by Andris Konfar on 02/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "PushData.h"

@implementation PushData

- (instancetype)initFromDictionary:(NSDictionary*) userInfo
{
    self = [super init];
    if (self) {
        self.pushId = [userInfo objectForKey:@"id"];
        self.phoneNumber = [userInfo objectForKey:@"phone"];
        self.name = [userInfo objectForKey:@"name"];
        self.msg = [userInfo objectForKey:@"msg"];
        self.answer = [@"F" isEqualToString:[userInfo objectForKey:@"answer"]] ? NO : YES;
    }
    return self;
}

- (NSDictionary*) dictionaryRepr
{
    NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:
                       self.pushId,                 @"id",
                       self.name,                   @"name",
                       self.phoneNumber,            @"phone",
                       self.msg,                    @"msg",
                       (self.answer ? @"T": @"F"),  @"answer", nil];
    return d;
}


@end

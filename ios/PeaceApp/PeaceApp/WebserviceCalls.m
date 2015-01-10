//
//  WebserviceCalls.m
//  Feedback
//
//  Created by Andris Konfar on 23/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "WebserviceCalls.h"
#import "WSUtil.h"

@implementation WebserviceCalls

+ (NSString*) createCallWithXML:(NSString*) soapXML
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:soapXML ofType:@"xml"];
    NSData* data = [[NSData alloc] initWithContentsOfFile:filePath];
    return [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
}

+ (NSNumber*) addId
{
    NSString* soapMessage = [WebserviceCalls createCallWithXML:@"soap"];
    return [WebserviceCalls getNumberAnswer:soapMessage];
}

+ (NSNumber*) getCount
{
    NSString* soapMessage = [WebserviceCalls createCallWithXML:@"soap-count"];
    return [WebserviceCalls getNumberAnswer:soapMessage];
}

+ (NSNumber*) getNumberAnswer:(NSString*) soapMessage
{
    NSString* str = [WSUtil getDataFromServer:soapMessage];
    str = [WebserviceCalls getAnswerFromWSResponse:str];
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber* answer = [numberFormatter numberFromString:str];
    return answer;
}

+ (NSString*) getAnswerFromWSResponse:(NSString*) str
{
    NSRange r1 = [str rangeOfString:@"<return>"];
    NSRange r2 = [str rangeOfString:@"</return>"];
    NSLog(@"answer: %@", str);
    
    if(r1.length > 0 && r2.length > 0)
    {
        NSRange r = NSMakeRange(r1.location + r1.length, r2.location - r1.location-r1.length);
        return [str substringWithRange:r];
    }
    else
    {
        return @"ERROR:Communication error!";
    }
}

@end

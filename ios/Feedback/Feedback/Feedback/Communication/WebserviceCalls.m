//
//  WebserviceCalls.m
//  Feedback
//
//  Created by Andris Konfar on 23/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "WebserviceCalls.h"
#import "WSUtil.h"
#import "AnswerAncestor.h"
#import "AnswerGetQuestion.h"
#import "AnswerGetQuestionResult.h"
#import "DeviceUtil.h"

@implementation WebserviceCalls

+ (NSString*) createCallWithXML:(NSString*) soapXML
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:soapXML ofType:@"xml"];
	NSData* data = [[NSData alloc] initWithContentsOfFile:filePath];
    return [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
}

+ (AnswerAncestor*) createQuestion:(NSString*)question description:(NSString*)description email:(NSString*)email  seconds:(NSString*)seconds
{
    NSString* soapMessage = [WebserviceCalls createCallWithXML:@"soap-question"];
    soapMessage = [NSString stringWithFormat:soapMessage, email, question, description, seconds, [DeviceUtil deviceType], [DeviceUtil deviceId]];
    NSString* str = [WSUtil getDataFromServer:soapMessage];
    str = [WebserviceCalls getAnswerFromWSResponse:str];
    AnswerAncestor* answer = [[AnswerAncestor alloc] initWithAnswerString:str];
    return answer;
}

+ (AnswerGetQuestion*) getQuestion:(NSString*)questionCode
{
    NSString* soapMessage = [WebserviceCalls createCallWithXML:@"soap-getquestion"];
    soapMessage = [NSString stringWithFormat:soapMessage, questionCode, [DeviceUtil deviceType], [DeviceUtil deviceId]];
    NSString* str = [WSUtil getDataFromServer:soapMessage];
    str = [WebserviceCalls getAnswerFromWSResponse:str];
    AnswerGetQuestion* answer = [[AnswerGetQuestion alloc] initWithAnswerString:str];
    return answer;
}

+ (AnswerAncestor*) createAnswer:(NSString*)code rating:(int)rate message:(NSString*)message
{
    NSString* soapMessage = [WebserviceCalls createCallWithXML:@"soap-answer"];
    soapMessage = [NSString stringWithFormat:soapMessage, code, rate, message, [DeviceUtil deviceType], [DeviceUtil deviceId]];
    NSString* str = [WSUtil getDataFromServer:soapMessage];
    str = [WebserviceCalls getAnswerFromWSResponse:str];
    AnswerAncestor* answer = [[AnswerAncestor alloc] initWithAnswerString:str];
    return answer;
}

+ (AnswerGetQuestionResult*) getQuestionResult:(NSString*)code
{
    NSString* soapMessage = [WebserviceCalls createCallWithXML:@"soap-getquestionresult"];
    soapMessage = [NSString stringWithFormat:soapMessage, code, [DeviceUtil deviceId]];
    NSString* str = [WSUtil getDataFromServer:soapMessage];
    str = [WebserviceCalls getAnswerFromWSResponse:str];
    AnswerGetQuestionResult* answer = [[AnswerGetQuestionResult alloc] initWithAnswerString:str];
    NSLog(@"result: %@", answer.value);
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

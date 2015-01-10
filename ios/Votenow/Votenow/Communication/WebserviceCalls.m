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

+ (AnswerAncestor*) createQuestion:(NSString*)question email:(NSString*)email secondsStart:(NSString*)secondsStart seconds:(NSString*)seconds multichoice:(BOOL)multi anonym:(BOOL)anonym answers:(NSArray*)answers
{
    NSString* soapMessage = [WebserviceCalls createCallWithXML:@"soap-question"];
    
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] initWithCapacity:11];
    
    [dictionary setObject:email forKey:FIELD_EMAIL];
    [dictionary setObject:question forKey:FIELD_QUESTION];
    [dictionary setObject:secondsStart forKey:FIELD_TIME_FN_START];
    [dictionary setObject:seconds forKey:FIELD_TIME_FN];
    [dictionary setObject:[NSNumber numberWithBool:multi] forKey:FIELD_MULTICHOICE];
    [dictionary setObject:[NSNumber numberWithBool:anonym] forKey:FIELD_ANONYMOUS];
    [dictionary setObject:[DeviceUtil deviceId] forKey:FIELD_DEVICE_ID];
    [dictionary setObject:[DeviceUtil deviceType] forKey:FIELD_DEVICE_TYPE];
    [dictionary setObject:answers forKey:FIELD_CHOICES];
    
    NSError* error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if(error != nil)
    {
        NSLog(@"%@", error);
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    soapMessage = [NSString stringWithFormat:soapMessage, jsonString];
    
    NSLog(@"soapmessage:\n%@", soapMessage);
    
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

+ (AnswerAncestor*) createAnswer:(NSString*)code answers:(NSString*)answers name:(NSString*)name message:(NSString*)message
{
    NSString* soapMessage = [WebserviceCalls createCallWithXML:@"soap-answer"];
    soapMessage = [NSString stringWithFormat:soapMessage, code, answers, name, message, [DeviceUtil deviceType], [DeviceUtil deviceId]];
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

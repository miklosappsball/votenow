//
//  WSUtil.m
//  Feedback
//
//  Created by Andris Konfar on 23/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "WSUtil.h"

// #define WS_URL @"http://10.62.1.219:8080/votenow/votenowWSDL"
#define WS_URL @"http://votenow-appsball2.rhcloud.com/votenowWSDL"

@implementation WSUtil


+(NSString*) getDataFromServer:(NSString*) soapMessage
{
    // creating request
    NSURL *url = [NSURL URLWithString:WS_URL];
    NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString* msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:WS_URL forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setTimeoutInterval:60];
    
    NSLog(@"soap message: \n\n%@\n\n", soapMessage);
    
    NSHTTPURLResponse* response = nil;
    NSError *error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    if(responseData == nil)
    {
        return @"ERROR:Communication error!";
    }
    return [[NSString alloc] initWithBytes:[responseData bytes] length:responseData.length encoding:NSUTF8StringEncoding];
}

@end

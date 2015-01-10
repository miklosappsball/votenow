//
//  WSUtil.m
//  Feedback
//
//  Created by Andris Konfar on 23/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "WSUtil.h"

@implementation WSUtil

+(NSData*) getDataFrom:(NSString*) urlStr
{
	NSURL *url = [NSURL URLWithString:urlStr];
	NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:url];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"iPhone" forHTTPHeaderField:@"User-Agent"];
	[theRequest setValue:0 forHTTPHeaderField:@"Content-length"];
	[theRequest setTimeoutInterval:60];
    
	NSHTTPURLResponse* response = nil;
	NSError *error = [[NSError alloc] init];
	NSLog(@"Connecting to server: %@", urlStr);
	NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	NSLog(@"Connection finished");
    
	if([response statusCode] != 200 || responseData == nil)
	{
		NSLog(@"response status code: %d", [response statusCode]);
		return nil;
	}
    
	// logInfo(@"file size: %d ",[responseData length]);
    
	// logInfo(@"%@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    
	return responseData;
}

@end

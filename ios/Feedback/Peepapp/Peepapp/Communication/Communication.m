//
//  Communication.m
//  Peepapp
//
//  Created by Andris Konfar on 24/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "Communication.h"
#import "DeviceUtil.h"
#import "LoadingIndicatorViewController.h"


#define FUNCTION @"FUNCTION"
#define FUNCTION_REGISTRATION @"REGISTER"
#define FUNCTION_STARTPEEP @"STARTPEEP"
#define FUNCTION_STARTUPLOAD @"STARTUPLOAD"
#define FUNCTION_STARTDOWNLOAD @"STARTDOWNLOAD"





@interface Communication ()
{
    SRWebSocket* _webSocket;
    BOOL connected;
    answercompetition answerFunction;
    long totalSize, totalTraffic;
    
    NSData* lastReceivedData;
}

@end


@implementation Communication

static Communication* instance = nil;

+ (Communication*) instance
{
    if(instance == nil)
    {
        instance = [[Communication alloc] init];
    }
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initWebSocket];
    }
    return self;
}

- (void) initWebSocket
{
    NSLog(@"initialization!");
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://peepapp-appsball.rhcloud.com:8000/fileupload"]]];
    // _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://192.168.0.7:8080/peepapp/fileupload"]]];
    _webSocket.delegate = self;
    [_webSocket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Connected!");
    connected = true;
}

- (void) close
{
    [_webSocket close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    if([message isKindOfClass:[NSString class]])
    {
        if(answerFunction != nil)
        {
            NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSError* e = nil;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
            
            
            if (!json) {
                answerFunction([NSDictionary dictionaryWithObject:@"Error in communication!" forKey:FIELD_MESSAGE]);
            }
            else
            {
                NSString* msg = [json objectForKey:FIELD_MESSAGE];
                if([FIELD_FILESIZE isEqualToString:msg])
                {
                    NSNumber*  progress = [json objectForKey:FIELD_FILE_LOAD_PROGRESS];
                    totalSize = progress.longValue;
                    return;
                }
                if([@"STATUS" isEqualToString:msg])
                {
                    NSNumber*  progress = [json objectForKey:FIELD_FILE_LOAD_PROGRESS];
                    totalTraffic = totalSize / 2 + progress.intValue;
                    return;
                }
                
                answerFunction(json);
            }
        }
    }
    
    if([message isKindOfClass:[NSData class]])
    {
        lastReceivedData = (NSData*)message;
        answerFunction([NSDictionary dictionaryWithObject:@"DATA_RECEIVED" forKey:FIELD_MESSAGE]);
    }
}

- (NSData*) lastReceivedData
{
    return lastReceivedData;
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"error!!! %@", error);
    connected = false;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"disconnected!");
    connected = false;
}

- (void)webSocket:(SRWebSocket *)webSocket byteTraffic:(NSInteger)traffic
{
    totalTraffic += traffic;
    if(totalSize != 0)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
                      // NSLog(@"traffic: %ld  (%ld/%ld)", 100 * totalTraffic / totalSize, totalTraffic, totalSize);
                      [LOADING_INDICATOR progress:100 * totalTraffic / totalSize];
        });
    }
}

- (void)waitForConnectionWithJson:(NSDictionary*)json answerFunction:(answercompetition) answerc
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        answerFunction = answerc;
        int i = 0;
        CGFloat timeinterval = 0.5;
        if(!connected)
        {
            [self initWebSocket];
        }
        while (!connected)
        {
            [NSThread sleepForTimeInterval:timeinterval];
            CGFloat total = timeinterval*i++;
            NSLog(@"Waiting for connection! %f",total);
            if((i++) > 10.0*1/timeinterval)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    answerFunction([NSDictionary dictionaryWithObject:@"Error in communication!" forKey:FIELD_MESSAGE]);
                    return;
                });
                return;
            }
        }
        
        if (! jsonData) {
            
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"sending: %@", jsonString);
            [_webSocket send:jsonString];
        }
    });
}

- (void) registrationWithName:(NSString*)name phone:(NSString*)phone answerFunction:(answercompetition) answerc
{
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setObject:name forKey:FIELD_NAME];
    [json setObject:phone forKey:FIELD_PHONENUMBER];
    [json setObject:[DeviceUtil deviceId] forKey:FIELD_DEVICE_ID];
    [json setObject:[DeviceUtil deviceType] forKey:FIELD_DEVICE_TYPE];
    [json setObject:FUNCTION_REGISTRATION forKey:FUNCTION];
    totalSize = 0;
    
    [self waitForConnectionWithJson:json answerFunction:answerc];
}

- (void) peepNumber:(NSString*)number anonymus:(BOOL)anonym answerFunction:(answercompetition) answerc
{
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setObject:number forKey:FIELD_PHONENUMBER_TO];
    [json setObject:[DeviceUtil phoneNumber] forKey:FIELD_PHONENUMBER_FROM];
    [json setObject:anonym ? @"true" : @"false" forKey:FIELD_ANONYMUS];
    [json setObject:FUNCTION_STARTPEEP forKey:FUNCTION];
    totalSize = 0;
    
    [self waitForConnectionWithJson:json answerFunction:answerc];
}


- (void) uploadImage:(NSData*)image pushId:(NSString*)pushId answerFunction:(answercompetition) answerc
{
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setObject:pushId forKey:FIELD_PUSH_ID];
    [json setObject:[DeviceUtil phoneNumber] forKey:FIELD_PHONENUMBER];
    [json setObject:FUNCTION_STARTUPLOAD forKey:FUNCTION];
    
    totalSize = image.length * 2;
    totalTraffic = 0;
    
    [self waitForConnectionWithJson:json answerFunction:^(NSDictionary* answer){
        
        if([[answer objectForKey:FIELD_MESSAGE] isEqualToString:FIELD_UPLOAD_STARTED])
        {
            [_webSocket send:image];
        }
        else
        {
            answerc(answer);
        }
    }];
}

- (void) downloadImage:(NSString*)pushId answerFunction:(answercompetition) answerc
{
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setObject:pushId forKey:FIELD_PUSH_ID];
    [json setObject:[DeviceUtil phoneNumber] forKey:FIELD_PHONENUMBER];
    [json setObject:FUNCTION_STARTDOWNLOAD forKey:FUNCTION];
    
    totalTraffic = 0;
    
    [self waitForConnectionWithJson:json answerFunction:answerc];
}



@end

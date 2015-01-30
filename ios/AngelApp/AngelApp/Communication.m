//
//  Communication.m
//  Peepapp
//
//  Created by Andris Konfar on 24/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "Communication.h"
#import "DeviceUtil.h"

#import "ViewController.h"
#import "ChatVC.h"


#define FUNCTION_REGISTRATION @"REGISTER"
#define FUNCTION_SUCCESSFULL_REGISTRATION @"SUCCESSFULL_REGISTRATION"
#define FUNCTION_MESSAGE @"MESSAGE"
#define FUNCTION_LOGIN @"LOGIN"
#define FUNCTION_SUCCESSFULL_LOGIN @"SUCCESSFULL_LOGIN"
#define FUNCTION_GETMSG @"GETMSG"
#define FUNCTION_MSGSENT @"MSGSENT"

@interface Communication ()
{
    SRWebSocket* _webSocket;
    BOOL connected, connecting;
    
    NSMutableArray* msgQueue;
    
    NSDate* lastRecievedDate;
    BOOL keepalivesent;
    
    NSMutableDictionary* messages;
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
        msgQueue = [[NSMutableArray alloc] initWithCapacity:20];
        connected = NO;
        connecting = NO;
        [self initWebSocket];
        
        messages = [[NSMutableDictionary alloc] initWithCapacity:30];
        
        [self performSelectorInBackground:@selector(keepAliveThread) withObject:nil];
    }
    return self;
}

- (void) initWebSocket
{
    connecting = YES;
    NSLog(@"Connecting ...");
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://angelapp-appsball.rhcloud.com:8000/ws"]]];
    // _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://192.168.0.7:8080/peepapp/fileupload"]]];
    _webSocket.delegate = self;
    [_webSocket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Connected!");
    connected = true;
    [self sendMessagesInQueue];
    lastRecievedDate = [NSDate date];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"websocket errored!");
    if(webSocket == _webSocket) [self closeMessage];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"websocket closed!");
    if(webSocket == _webSocket) [self closeMessage];
}

- (void) keepAliveThread
{
    while (YES) {
        [NSThread sleepForTimeInterval:2];
        
        if(connected)
        {
            NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:lastRecievedDate];
            NSLog(@"time: %lf", time);
            
            if(time > 20 && !keepalivesent)
            {
                keepalivesent = YES;
                [_webSocket send:@"K"];
            }
            if(time > 30)
            {
                NSLog(@"websocket closing");
                [_webSocket close];
                [self webSocket:_webSocket didCloseWithCode:0 reason:@"" wasClean:NO];
            }
        }
    }
}


- (void)closeMessage
{
    _webSocket = nil;
    connected = NO;
    connecting = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        [NSThread sleepForTimeInterval:1];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.chatCallback != nil)
            {
                [self.chatCallback beginConnection];
            }
            
        });
    });
}

- (void) close
{
    [_webSocket close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    lastRecievedDate = [NSDate date];
    keepalivesent = NO;
    
    if([message isKindOfClass:[NSString class]])
    {
        NSLog(@"received: %@", message);
        
        NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError* e = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
        
        if(!json)
        {
            
        }
        else
        {
            NSString* function = [json objectForKey:FIELD_FUNCTION];
            if([FUNCTION_SUCCESSFULL_REGISTRATION isEqualToString:function])
            {
                if(self.registrationCallback != nil) [self.registrationCallback registrationCallbackMethod:json];
            }
            if([FUNCTION_MESSAGE isEqualToString:function])
            {
                [DeviceUtil saveMessage:json];
                if(self.chatCallback != nil) [self.chatCallback messageRecieved:json];
            }
            if([FUNCTION_SUCCESSFULL_LOGIN  isEqualToString:function])
            {
                if(self.registrationCallback != nil && self.chatCallback == nil)
                {
                    [self.registrationCallback loggedIn:json];
                }
                else{
                    [self.chatCallback loggedIn:json];
                }
            }
            if([FUNCTION_GETMSG isEqualToString:function])
            {
                NSObject* obj = json[FIELD_MESSAGE];
                if([obj isKindOfClass:[NSString class]])
                {
                    if([@"ENDED" isEqualToString:json[FIELD_MESSAGE]]) [self.chatCallback getMsgEnd];
                }
                if([obj isKindOfClass:[NSArray class]])
                {
                    NSArray* array = (NSArray*)obj;
                    for(NSDictionary* msg in array)
                    {
                        if(self.chatCallback != nil) [self.chatCallback messageRecieved:msg];
                    }
                }
            }
            if([FUNCTION_MSGSENT isEqualToString:function])
            {
                NSNumber* timeStamp = [json objectForKey:FIELD_TIMESTAMP];
                NSNumber* msg_id = [json objectForKey:FIELD_ID];
                NSLog(@"msg: %@, %@", timeStamp, msg_id);
                
                NSMutableDictionary* messageDict = messages[timeStamp];
                [messageDict setObject:msg_id forKey:FIELD_ID];
                [DeviceUtil saveMessage:messageDict];
                
                [self.chatCallback msgsent:timeStamp];
            }
        }
    }
    
    if([message isKindOfClass:[NSData class]])
    {
        NSLog(@"Hooo ez megint nem johetne!");
    }
}



- (void)webSocket:(SRWebSocket *)webSocket byteTraffic:(NSInteger)traffic
{
    // NSLog(@"ilyennek nem kellene jonnie he!!!");
}

- (void) sendMessagesInQueue
{
    if(connected)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            while([msgQueue count] > 0 && connected)
            {
                NSString* msg = msgQueue[0];
                [_webSocket send:msg];
                [msgQueue removeObjectAtIndex:0];
                NSLog(@"sent: %@", msg);
            }
        });
    }
    else
    {
        if(!connecting)
        {
            [self initWebSocket];
        }
    }
}

- (void) registration:(NSString*)locale
{
    // {"FUNCTION":"REGISTER","LOCALE":"hu","DEVICE_ID":"TestDeviceIdJustForMe","DEVICE_TYPE":"Android:_..."}
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setObject:locale forKey:FIELD_LOCALE];
    [json setObject:FUNCTION_REGISTRATION forKey:FIELD_FUNCTION];
    [json setObject:[DeviceUtil deviceId] forKey:FIELD_DEVICE_ID];
    [json setObject:[DeviceUtil deviceType] forKey:FIELD_DEVICE_TYPE];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"sending: %@", jsonString);
    [msgQueue addObject:jsonString];
    [self sendMessagesInQueue];
}

- (void) login
{
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setObject:FUNCTION_LOGIN forKey:FIELD_FUNCTION];
    [json setObject:[DeviceUtil angelAppId] forKey:FIELD_ID];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    BOOL add = YES;
    if(msgQueue.count > 0)
    {
        NSString* message  =  [msgQueue objectAtIndex:0];
        NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError* e = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
        
        if(json != nil && [FUNCTION_LOGIN isEqualToString:json[FIELD_FUNCTION]]) add = NO;
    }
    
    if(add) [msgQueue insertObject:jsonString atIndex:0];
    [self sendMessagesInQueue];
}

static long number = 0;

- (long) sendMessageIdAngel: (NSString*) angel idProtege:(NSString*)protege toAngel:(BOOL)to_angel message:(NSString*) message
{
    @synchronized(self)
    {
        number++;
        
        NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
        [json setObject:FUNCTION_MESSAGE forKey:FIELD_FUNCTION];
        [json setObject:[NSString stringWithFormat:@"%ld", number] forKey:FIELD_TIMESTAMP];
        [json setObject:angel forKey:FIELD_ID_ANGEL];
        [json setObject:protege forKey:FIELD_ID_PROTEGE];
        [json setObject:[NSNumber numberWithBool:to_angel] forKey:FIELD_TO_ANGEL];
        [json setObject:message forKey:FIELD_MESSAGE];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"sending: %@", jsonString);
        [msgQueue addObject:jsonString];
        [self sendMessagesInQueue];
        
        [messages setObject:json forKey:[NSNumber numberWithLong:number]];
        
        return number;
    }
}

- (void) getAllMessages: (NSString*) angel idProtege:(NSString*)protege fromId:(NSString*)mid
{
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setObject:FUNCTION_GETMSG forKey:FIELD_FUNCTION];
    [json setObject:angel forKey:FIELD_ID_ANGEL];
    [json setObject:protege forKey:FIELD_ID_PROTEGE];
    [json setObject:mid forKey:FIELD_ID];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"sending: %@", jsonString);
    [msgQueue addObject:jsonString];
    [self sendMessagesInQueue];
}

/*
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
*/


@end

//
//  Communication.h
//  Peepapp
//
//  Created by Andris Konfar on 24/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@class ViewController;
@class ChatVC;

#define FIELD_FUNCTION @"FUNCTION"
#define FIELD_LOCALE @"LOCALE"
#define FIELD_DEVICE_ID @"DEVICE_ID"
#define FIELD_DEVICE_TYPE @"DEVICE_TYPE"
#define FIELD_TIMESTAMP @"TIMESTAMP"
#define FIELD_ID @"ID"
#define FIELD_MESSAGE @"MESSAGE"
#define FIELD_TO_ANGEL @"TO_ANGEL"
#define FIELD_ID_ANGEL @"ID_ANGEL"
#define FIELD_ID_PROTEGE @"ID_PROTEGE"



#define COMMUNICATION [Communication instance]

@interface Communication : NSObject <SRWebSocketDelegate>

+ (Communication*) instance;
- (void) registration:(NSString*)locale;
- (void) login;
- (long) sendMessageIdAngel: (NSString*) angel idProtege:(NSString*)protege toAngel:(BOOL)to_angel message:(NSString*) message;
- (void) getAllMessages: (NSString*) angel idProtege:(NSString*)protege  fromId:(NSString*)mid;

@property (nonatomic, retain) ViewController* registrationCallback;
@property (nonatomic, retain) ChatVC* chatCallback;

@end

//
//  Communication.h
//  Peepapp
//
//  Created by Andris Konfar on 24/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"



#define FIELD_NAME @"NAME"
#define FIELD_PHONENUMBER @"PHONENUMBER"
#define FIELD_PHONENUMBER_TO @"PHONENUMBER_TO"
#define FIELD_PHONENUMBER_FROM @"PHONENUMBER_FROM"
#define FIELD_DEVICE_ID @"DEVICE_ID"
#define FIELD_DEVICE_TYPE @"DEVICE_TYPE"
#define FIELD_PUSH_ID @"PUSH_ID"
#define FIELD_MESSAGE @"MESSAGE"
#define FIELD_NUMBER @"NUMBER"
#define FIELD_ERROR @"ERROR"
#define FIELD_UPLOAD_STARTED @"UPLOAD_STARTED"
#define FIELD_FILE_LOAD_PROGRESS @"FILE_LOAD_PROGRESS"
#define FIELD_ANONYMUS @"ANONYMUS"
#define FIELD_FILESIZE @"FILESIZE"

#define LAST_CONTACTS_UD @"LAST_CONTACTS_UD"


typedef void(^answercompetition)(NSDictionary*);

@interface Communication : NSObject <SRWebSocketDelegate>

+ (Communication*) instance;
- (void) close;
- (void) registrationWithName:(NSString*)name phone:(NSString*)phone answerFunction:(answercompetition) answerc;
- (void) peepNumber:(NSString*)number anonymus:(BOOL)anonym answerFunction:(answercompetition) answerc;
- (void) uploadImage:(NSData*)image pushId:(NSString*)pushId answerFunction:(answercompetition) answerc;
- (void) downloadImage:(NSString*)pushId answerFunction:(answercompetition) answerc;
- (NSData*) lastReceivedData;

@end

//
//  QueueHandler.h
//  Peepapp
//
//  Created by Andris Konfar on 10/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushData.h"

#define QUEUE_HANDLER [QueueHandler instance]

@interface QueueHandler : NSObject

+ (QueueHandler*)instance;
- (void) addPushDataToQueue:(PushData*)pd;
- (void) addPushDataToQueueOrStart:(PushData*)pd;
- (void) addAlertToQueue:(NSString*)title withString:(NSString*) str;
- (void) addPeekBackToQueue:(PushData*)str;
- (void) addSMSNeededToQueue:(NSString*)phone;
- (void) createNextItem;

- (void) setShown:(BOOL)v;

@end

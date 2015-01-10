//
//  ChatVC.h
//  AngelApp
//
//  Created by Andris Konfar on 08/12/14.
//  Copyright (c) 2014 Appsball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatVC : UIViewController

- (void) messageRecieved:(NSDictionary*) dict;
- (void) loggedIn:(NSDictionary*) dict;
- (void) msgsent:(NSNumber*)timestamp;
- (void) beginConnection;
- (void) getMsgEnd;

@end

//
//  ChatterScrollView.h
//  AngelApp
//
//  Created by Andris Konfar on 08/12/14.
//  Copyright (c) 2014 Appsball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatterScrollView : UIViewController <UITextViewDelegate>

- (void) messageRecieved:(NSDictionary*) dict;
- (BOOL) isAtBottom;
- (void) scrollToBottom;
- (void) firstRB;

- (instancetype) initWithAngel:(BOOL)to_angel;
- (void)messageSent:(NSNumber*)timestamp;

@property (nonatomic, strong) NSString* angel;
@property (nonatomic, strong) NSString* protege;
@property (nonatomic) BOOL to_angel;


@end

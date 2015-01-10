//
//  ChatVC.m
//  AngelApp
//
//  Created by Andris Konfar on 08/12/14.
//  Copyright (c) 2014 Appsball. All rights reserved.
//

#import "ChatVC.h"
#import "ChatterScrollView.h"
#import "Communication.h"
#import "DeviceUtil.h"
#import "Colors.h"
#import "ButtonUtil.h"

#define SCROLL_TOPS 70
#define GAP 6

@interface ChatVC ()
{
    ChatterScrollView* angelc, *protegec;
    UIButton* btnProtege, *btnAngel;
    BOOL shown;
    BOOL onAngel;
    BOOL pulsing;
    UIView* connectionView;
    long max_id;
    
    int ended;
}

@end

@implementation ChatVC


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        shown = 0;
        self.view.backgroundColor = [UIColor whiteColor];
        
        // create buttons
        UIButton* angel = [ButtonUtil createButtonOnWhite];
        [angel addTarget:self action:@selector(goOnAngel) forControlEvents:UIControlEventTouchUpInside];
        [angel setTitle:@"ANGEL" forState:UIControlStateNormal];
        angel.frame = CGRectMake(GAP, 20, self.view.frame.size.width / 2 - GAP - GAP/2, SCROLL_TOPS-20-GAP);
        [self.view addSubview:angel];
        btnAngel = angel;
        
        UIButton* protege = [ButtonUtil createButton];
        [protege addTarget:self action:@selector(goOnProtege) forControlEvents:UIControlEventTouchUpInside];
        [protege setTitle:@"PROTEGE" forState:UIControlStateNormal];
        protege.frame = CGRectMake(self.view.frame.size.width / 2 + GAP/2, 20, self.view.frame.size.width / 2 - GAP/2 - GAP, SCROLL_TOPS-20-GAP);
        [self.view addSubview:protege];
        btnProtege = protege;
        
        // create scrollviews
        angelc = [[ChatterScrollView alloc] initWithAngel: YES];
        angelc.view.frame = CGRectMake(0, SCROLL_TOPS, self.view.frame.size.width, self.view.frame.size.height-SCROLL_TOPS);
        [self.view addSubview:angelc.view];
        
        protegec = [[ChatterScrollView alloc] initWithAngel: NO];
        protegec.view.frame = CGRectMake(self.view.frame.size.width, SCROLL_TOPS, self.view.frame.size.width, self.view.frame.size.height-SCROLL_TOPS);
        [self.view addSubview:protegec.view];
        [self goOnProtege];
        
        [self registerForKeyboardNotifications];
        
        [DeviceUtil getAllPreviousMessages:self];
        
        COMMUNICATION.chatCallback = self;
        [self createConnectionViewAndStartConnection];
    }
    return self;
}

- (void) createConnectionViewAndStartConnection
{
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicator startAnimating];
    indicator.frame = CGRectMake(indicator.frame.size.height / 4, indicator.frame.size.height / 4, indicator.frame.size.width, indicator.frame.size.height);
    connectionView = [[UIView alloc] initWithFrame:CGRectMake(0, SCROLL_TOPS, self.view.frame.size.width, indicator.frame.size.height*1.5)];
    connectionView.backgroundColor = COLOR_CONNECTION_BG;
    [self.view addSubview:connectionView];
    [connectionView addSubview:indicator];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, connectionView.frame.size.width, connectionView.frame.size.height)];
    lbl.text = @"Connecting...";
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor whiteColor];
    lbl.backgroundColor = [UIColor clearColor];
    [connectionView addSubview:lbl];
}

- (void) beginConnection
{
    [UIView animateWithDuration:0.25 animations:^{
        connectionView.alpha = 1;
    }];
    [COMMUNICATION login];
}

- (void) goOnAngel
{
    onAngel = YES;
    pulsing = NO;
    [UIView animateWithDuration:0.25 animations:^{
        angelc.view.frame = CGRectMake(0, angelc.view.frame.origin.y, angelc.view.frame.size.width, angelc.view.frame.size.height);
        protegec.view.frame = CGRectMake(self.view.frame.size.width, protegec.view.frame.origin.y, protegec.view.frame.size.width, protegec.view.frame.size.height);
    }];
    if(shown) [angelc firstRB];
}

- (void) goOnProtege
{
    onAngel = NO;
    pulsing = NO;
    [UIView animateWithDuration:0.25 animations:^{
        angelc.view.frame = CGRectMake(-self.view.frame.size.width, angelc.view.frame.origin.y, angelc.view.frame.size.width, angelc.view.frame.size.height);
        protegec.view.frame = CGRectMake(0, protegec.view.frame.origin.y, protegec.view.frame.size.width, protegec.view.frame.size.height);
    }];
    if(shown) [protegec firstRB];
}

- (void) startPulsing:(UIButton*) button
{
    pulsing = YES;
    while(pulsing)
    {
        [self performSelectorOnMainThread:@selector(pulseButton:) withObject:button waitUntilDone:YES];
        [NSThread sleepForTimeInterval:3];
    }
}

- (void)pulseButton:(UIButton*) button
{
    [UIView animateWithDuration:0.2 animations:^{
        
        button.transform = CGAffineTransformMakeScale(1.15, 1.15);
        
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.8 animations:^{
            button.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }
     ];
}

- (void) msgsent:(NSNumber*)timestamp
{
    [angelc messageSent:timestamp];
    [protegec messageSent:timestamp];
}

- (void) messageRecieved:(NSDictionary*) dict
{
    max_id = ((NSNumber*)[dict objectForKey:FIELD_ID]).longValue;
    if([[DeviceUtil angelAppId] isEqualToString:[dict objectForKey:FIELD_ID_ANGEL]])
    {
        if(onAngel && !pulsing) [self performSelectorInBackground:@selector(startPulsing:) withObject:btnProtege];
        [protegec messageRecieved:dict];
    }
    else
    {
        if(!onAngel && !pulsing) [self performSelectorInBackground:@selector(startPulsing:) withObject:btnAngel];
        [angelc messageRecieved:dict];
    }
}

- (void) loggedIn:(NSDictionary*) dict
{
    angelc.angel = [dict objectForKey:FIELD_ID_ANGEL];
    angelc.protege = [DeviceUtil angelAppId];
    
    protegec.protege = [dict objectForKey:FIELD_ID_PROTEGE];
    protegec.angel = [DeviceUtil angelAppId];
    
    ended = 2;
    [COMMUNICATION getAllMessages:angelc.angel idProtege:[DeviceUtil angelAppId] fromId:[NSString stringWithFormat:@"%ld", max_id]];
    [COMMUNICATION getAllMessages:[DeviceUtil angelAppId] idProtege:protegec.protege fromId:[NSString stringWithFormat:@"%ld", max_id]];
}

- (void) getMsgEnd
{
    ended--;
    if(ended == 0)
    {
        [UIView animateWithDuration:0.25 animations:^{
            connectionView.alpha = 0;
        }];
    }
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    shown = YES;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self resizeChatters:kbSize.height];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    shown = NO;
    [self resizeChatters:0];
}

- (void) resizeChatters:(CGFloat) minus
{
    for(ChatterScrollView* chatter in [NSArray arrayWithObjects:angelc, protegec, nil])
    {
        BOOL bottom = [chatter isAtBottom];
        
        UIView* view = chatter.view;
        CGRect frame = view.frame;
        frame.size.height = self.view.frame.size.height - SCROLL_TOPS - minus;
        view.frame = frame;
        
        if(bottom) [chatter scrollToBottom];
    }
}



@end

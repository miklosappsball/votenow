//
//  ChatterScrollView.m
//  AngelApp
//
//  Created by Andris Konfar on 08/12/14.
//  Copyright (c) 2014 Appsball. All rights reserved.
//

#import "ChatterScrollView.h"
#import "Communication.h"
#import "ButtonUtil.h"
#import "Colors.h"
#import "DeviceUtil.h"

#define GAP 5
#define Y_GAP 15

#define TEXTAREA_HEIGHT 50


@interface ChatterScrollView ()
{
    UIScrollView* scrollView;
    CGFloat currentPosition;
    UITextView * textView;
    
    UIColor* colorOwn;
    UIColor* colorOther;
    
    NSMutableDictionary* lblDictionary;
    
    UIImage* angelImage, *protegeImage;
}

@end

@implementation ChatterScrollView

- (instancetype) initWithAngel:(BOOL)to_angel
{
    self = [super init];
    if (self)
    {
        self.to_angel = to_angel;
        
        angelImage = [UIImage imageNamed:@"angel.png"];
        protegeImage = [UIImage imageNamed:@"protege.png"];
        
        if(to_angel)
        {
            self.angel = @"4";
            self.protege = [DeviceUtil angelAppId];
        }
        else
        {
            self.protege = @"2";
            self.angel = [DeviceUtil angelAppId];
            
        }
        
        scrollView = [[UIScrollView alloc] init];
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.backgroundColor = to_angel ? COLOR_BACKGROUND_1 : COLOR_BACKGROUND_2;
        [self.view addSubview:scrollView];
        
        UILabel* firstLbl = [[UILabel alloc] initWithFrame:CGRectMake(GAP, GAP, self.view.frame.size.width-GAP-GAP, self.view.frame.size.height)];
        firstLbl.text = to_angel ?
        @"Welcome! Your ANGEL is ready to help you! You can contact her/him right now in this chat window!":
        @"Welcome! You became an ANGEL and you have a Protege to take care! HELP NOW! You can contact her/him right now in this chat window!";
        firstLbl.textColor = COLOR_OWN;
        firstLbl.numberOfLines = 0;
        firstLbl.textAlignment = NSTextAlignmentCenter;
        CGSize size = [firstLbl.text sizeWithFont:firstLbl.font constrainedToSize:CGSizeMake(self.view.frame.size.width-GAP-GAP, 10000) lineBreakMode:firstLbl.lineBreakMode];
        CGRect r = firstLbl.frame;
        r.size.height = size.height;
        firstLbl.frame = r;
        [scrollView addSubview:firstLbl];
        
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TEXTAREA_HEIGHT, self.view.frame.size.width - BUTTON_WIDTH, TEXTAREA_HEIGHT)];
        [self.view addSubview:textView];
        textView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        textView.returnKeyType = UIReturnKeyDone;
        textView.delegate = self;
        textView.font = [UIFont systemFontOfSize:17];
        textView.backgroundColor = [UIColor whiteColor];
        
        UIButton* button = [ButtonUtil createButtonOnWhite];
        button.frame = CGRectMake(self.view.frame.size.width - BUTTON_WIDTH, self.view.frame.size.height - TEXTAREA_HEIGHT + GAP, BUTTON_WIDTH - GAP, TEXTAREA_HEIGHT-GAP-GAP);
        [button addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Send" forState:UIControlStateNormal];
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        // button.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:button];
        
        currentPosition = CGRectGetMaxY(firstLbl.frame) + GAP;
        
        if(self.to_angel)
        {
            UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scrollView.frame) - 2, self.view.frame.size.width, 2)];
            separator.backgroundColor = COLOR_BACKGROUND_2;
            separator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            [self.view addSubview:separator];
        }
        
        lblDictionary = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    return self;
}

- (void) firstRB
{
    [textView becomeFirstResponder];
}

- (void)send
{
    NSString* text = textView.text;
    if(text.length <= 0) return;
    long timestamp = [COMMUNICATION sendMessageIdAngel: self.angel idProtege: self.protege toAngel: self.to_angel message: text];
    textView.text = @"";
    
    UILabel* lbl = [self addText:text own:YES];
    [lblDictionary setObject:lbl forKey:[NSNumber numberWithLong:timestamp]];
    lbl.alpha = 0.5;
}

- (void)messageSent:(NSNumber*)timestamp
{
    UILabel* lbl = lblDictionary[timestamp];
    NSLog(@"lbl is: %@", lbl);
    if(lbl != nil)
    {
        lbl.alpha = 1;
        [lblDictionary removeObjectForKey:timestamp];
    }
}

- (BOOL)textView:(UITextView *)textView_ shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(text.length > 0 && [text characterAtIndex:0] == '\n')
    {
        [textView_ resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) messageRecieved:(NSDictionary*) dict
{
    BOOL toangel = ((NSNumber *) [dict objectForKey:FIELD_TO_ANGEL]).boolValue;
    NSString* str = [dict objectForKey:FIELD_MESSAGE];
    
    BOOL o = NO;
    if(toangel == true && self.to_angel) o = YES;
    if(toangel == false && !self.to_angel) o = YES;
    
    [self addText:str own:o];
}

- (UILabel*) addText:(NSString*) str own:(BOOL) own
{
    UIImage* image = angelImage;
    if(own)
    {
        if(self.to_angel) image = protegeImage;
    }
    else
    {
        if(!self.to_angel) image = protegeImage;
    }
    
    UIImageView* iv = [[UIImageView alloc] initWithImage: image];
    iv.frame = CGRectMake(0, 0, 30, 30);
    [scrollView addSubview:iv];
    
    CGRect rect = CGRectMake(GAP, currentPosition, scrollView.frame.size.width - GAP - GAP - iv.frame.size.width - GAP, 100000);
    UILabel* lbl = [[UILabel alloc] initWithFrame:rect];
    
    lbl.text = str;
    lbl.numberOfLines = 0;
    CGSize size = [str sizeWithFont:lbl.font constrainedToSize:rect.size lineBreakMode:lbl.lineBreakMode];
    rect.size.height = ceil(size.height);
    lbl.frame = rect;
    lbl.textColor = own ? COLOR_OWN : (self.to_angel ? COLOR_BACKGROUND_2 : COLOR_BACKGROUND_1);
    lbl.backgroundColor = [UIColor clearColor];
    
    if((own && self.to_angel) || (!own && !self.to_angel))
    {
        lbl.textAlignment = NSTextAlignmentRight;
        iv.frame = CGRectMake(self.view.frame.size.width - GAP - iv.frame.size.width, lbl.frame.origin.y, iv.frame.size.width, iv.frame.size.height);
        rect = lbl.frame;
    }
    else
    {
        rect = lbl.frame;
        rect.origin.x = GAP+GAP+iv.frame.size.width;
        lbl.frame = rect;
        iv.frame = CGRectMake(GAP, lbl.frame.origin.y, iv.frame.size.width, iv.frame.size.height);
    }
    
    NSLog(@"lbl %@    iv %@", NSStringFromCGRect(lbl.frame), NSStringFromCGRect(iv.frame));
    
    [scrollView addSubview:lbl];
    
    currentPosition = CGRectGetMaxY(lbl.frame) + Y_GAP;
    scrollView.contentSize = CGSizeMake(0, currentPosition);
    [self scrollToBottom];
    
    return lbl;
}

- (BOOL) isAtBottom
{
    if(scrollView.contentSize.height < scrollView.frame.size.height) return YES;
    if(scrollView.contentOffset.y + scrollView.frame.size.height + 10 < scrollView.contentSize.height) return NO;
    return YES;
}

- (void) scrollToBottom
{
    [UIView animateWithDuration:0.25 animations:^{
        if(currentPosition > scrollView.frame.size.height)
        {
            scrollView.contentOffset = CGPointMake(0, currentPosition - scrollView.frame.size.height);
        }
    }];
}

@end

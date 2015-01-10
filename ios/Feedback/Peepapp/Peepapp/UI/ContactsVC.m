//
//  ContactsVC.m
//  Peepapp
//
//  Created by Andris Konfar on 24/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "ContactsVC.h"
#import "ButtonUtil.h"
#import "LoadingIndicatorViewController.h"
#import "Communication.h"
#import "CameraVC.h"
#import <AddressBook/AddressBook.h>
#import "PushData.h"
#import <MessageUI/MessageUI.h>
#import "DeviceUtil.h"
#import "AnswerPageVC.h"
#import "AnalyticsHelper.h"
#import "QueueHandler.h"
#import "MainNavigationController.h"

@interface ContactsVC ()
{
    UITextField* tfPhoneTo;
    UISwitch* sw;
    UIView* lastContactsView;
    BOOL clearPhoneNumber;
}

@end

@implementation ContactsVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.title = @"Peek request";
        [self.navigationItem setHidesBackButton:YES animated:YES];
        self.view.backgroundColor = COLOR_BACKGROUND_1;
        
        UIScrollView* scrollview = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:scrollview];
        
        CGFloat y = DEFAULT_GAP;
        
        UIView* tfView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, TEXT_FIELD_HEIGHT*2)];
        tfView.layer.borderWidth = 0.5;
        tfView.layer.borderColor = [BORDER_COLOR CGColor];
        tfView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tfView.backgroundColor = ITEM_BG_COLOR;
        [scrollview addSubview:tfView];
        
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(LEFT_MARGIN, TEXT_FIELD_HEIGHT, self.view.frame.size.width-LEFT_MARGIN, 0.5f)];
        separator.backgroundColor = BORDER_COLOR;
        [tfView addSubview:separator];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 0, self.view.frame.size.width-LEFT_MARGIN, TEXT_FIELD_HEIGHT)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = TEXT_COLOR_1;
        label.text = @"Anonymous peek";
        [tfView addSubview:label];
        
        sw = [[UISwitch alloc] init];
        sw.frame = CGRectMake(self.view.frame.size.width - RIGHT_MARGIN - sw.frame.size.width, (TEXT_FIELD_HEIGHT - sw.frame.size.height)/2, sw.frame.size.width, sw.frame.size.height);
        sw.tintColor = BORDER_COLOR;
        sw.onTintColor = TEXT_COLOR_1;
        [tfView addSubview:sw];
        
        tfPhoneTo = [[UITextField alloc] init];
        tfPhoneTo.frame = CGRectMake(LEFT_MARGIN, TEXT_FIELD_HEIGHT, self.view.frame.size.width-LEFT_MARGIN, TEXT_FIELD_HEIGHT);
        tfPhoneTo.text = @"";
        tfPhoneTo.placeholder = @"phone number";
        tfPhoneTo.textColor = TEXT_COLOR_1;
        tfPhoneTo.keyboardType = UIKeyboardTypePhonePad;
        [tfView addSubview:tfPhoneTo];
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        button.frame = CGRectMake(self.view.frame.size.width - RIGHT_MARGIN - button.frame.size.width, TEXT_FIELD_HEIGHT + (TEXT_FIELD_HEIGHT - button.frame.size.height)/2, button.frame.size.width, button.frame.size.height);
        [button addTarget:self action:@selector(showContacts) forControlEvents:UIControlEventTouchUpInside];
        [tfView addSubview:button];
        
        y += TEXT_FIELD_HEIGHT*2 + DEFAULT_GAP;
        
        button = [ButtonUtil createButton];
        [button setTitle:@"Peek at her/him!" forState:UIControlStateNormal];
        button.frame = CGRectMake(-0.5, y, self.view.frame.size.width+1, BUTTON_HEIGHT);
        [button addTarget:self action:@selector(startpeep) forControlEvents:UIControlEventTouchUpInside];
        [scrollview addSubview:button];
        
        y += button.frame.size.height + DEFAULT_GAP;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y, self.view.frame.size.width-LEFT_MARGIN-LEFT_MARGIN, TEXT_FIELD_HEIGHT)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = TEXT_COLOR_1;
        label.text = @"Last contacts:";
        [scrollview addSubview:label];
        
        y += TEXT_FIELD_HEIGHT;
        lastContactsView = [[UIView alloc] initWithFrame:CGRectMake(-1, y, self.view.frame.size.width+2, self.view.frame.size.height-y)];
        lastContactsView.layer.borderWidth = 0.5;
        lastContactsView.layer.borderColor = [BORDER_COLOR CGColor];
        [scrollview addSubview:lastContactsView];
        [self createLastContacts];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self createLastContacts];
}

- (void) createLastContacts
{
    for(UIView* v in lastContactsView.subviews) [v removeFromSuperview];
    
    CGFloat y=0;
    NSArray* array = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_CONTACTS_UD];
    if(array == nil) return;
    
    int i=0;
    for(NSDictionary* d in array)
    {
        PushData* pd = [[PushData alloc] initFromDictionary:d];
        UIButton* button = [ButtonUtil createButton];
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderWidth = 0;
        [button setTitle:[NSString stringWithFormat:@"%@ (%@)", pd.phoneNumber, pd.name] forState:UIControlStateNormal];
        button.frame = CGRectMake(-0.5, y, self.view.frame.size.width+1, BUTTON_HEIGHT);
        [button addTarget:self action:@selector(setAsContact:) forControlEvents:UIControlEventTouchUpInside];
        [lastContactsView addSubview:button];
        button.tag = i++;
        y += button.frame.size.height;
        
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y, self.view.frame.size.width-LEFT_MARGIN, 0.5f)];
        separator.backgroundColor = BORDER_COLOR;
        [lastContactsView addSubview:separator];
    }
}

- (void) setAsContact:(UIButton*) button
{
    NSArray* array = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_CONTACTS_UD];
    NSDictionary* d = array[button.tag];
    PushData* pd = [[PushData alloc] initFromDictionary:d];
    
    [AnalyticsHelper send:@"LastContactSelected"];
    
    [ContactsVC startpeep:pd.phoneNumber anonym:sw.on contactsVC:nil];
}

- (void) showContacts
{
    [AnalyticsHelper send:@"ShowContactsList"];
    
    [QUEUE_HANDLER setShown:YES];
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    if([picker respondsToSelector:@selector(setPredicateForEnablingPerson:)]) picker.predicateForEnablingPerson = [NSPredicate predicateWithFormat:@"%K.@count > 0", ABPersonPhoneNumbersProperty];
    picker.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],nil];
    [self presentViewController:picker animated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self peoplePickerNavigationController:peoplePicker didSelectPerson:person property:property identifier:identifier];
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
    CFIndex peopleIndex = ABMultiValueGetIndexForIdentifier(phoneProperty, identifier);
    NSString *phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneProperty, peopleIndex);
    
    NSMutableString* str = [[NSMutableString alloc] initWithCapacity:phone.length];
    for(int i=0;i<phone.length;i++)
    {
        if([phone characterAtIndex:i] == '+')
        {
            [str appendString:@"+"];
        }
        if([phone characterAtIndex:i] >= '0' && [phone characterAtIndex:i] <= '9')
        {
            [str appendFormat:@"%c", [phone characterAtIndex:i]];
        }
    }
    
    NSLog(@"name: %@", [self getName:person]);
    
    tfPhoneTo.text = str;
    [QUEUE_HANDLER setShown:NO];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [QUEUE_HANDLER setShown:NO];
}


- (NSString*) getName:(ABRecordRef)ref
{
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
    if(firstName == nil || [@"(null)" isEqualToString:firstName] || firstName.length == 0) firstName = nil;
    if(lastName == nil || [@"(null)" isEqualToString:lastName] || lastName.length == 0) lastName = nil;
    NSString *fullName = nil;
    if(firstName == nil)
    {
        fullName = lastName;
    }
    if (lastName == nil)
    {
        fullName = firstName;
    }
    if(fullName == nil)
    {
        if (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst)
        {
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
        else
        {
            fullName = [NSString stringWithFormat:@"%@, %@", lastName, firstName];
        }
    }
    
    return fullName;
}

- (void) startpeep
{
    [self.view endEditing:YES];
    
    [AnalyticsHelper send:@"LastContactSelected"];
    
    clearPhoneNumber = YES;
    
    [ContactsVC startpeep:tfPhoneTo.text anonym:sw.on contactsVC:self];
}

+ (void) startpeep:(NSString*) phone_to anonym:(BOOL) anonym contactsVC:(ContactsVC*) cvc
{
    [LOADING_INDICATOR showLoadingIndicator];
    
    if(anonym)
    {
        [AnalyticsHelper send:@"PeekRequestAnonym"];
    }
    else
    {
        [AnalyticsHelper send:@"PeekRequestWithName"];
    }
    
    [[Communication instance] peepNumber:phone_to anonymus:anonym answerFunction:^(NSDictionary* answer)
     {
         [LOADING_INDICATOR hideLoadingIndicator];
         
         [[Communication instance] close];
         
         NSLog(@"message!!: %@", answer);
         
         BOOL error = NO;
         
         NSString* msg = [answer objectForKey:FIELD_MESSAGE];
         if([msg isEqualToString:@"SUCCESS"])
         {
             [AnalyticsHelper send:@"PeekRequestSentToRegisteredUser"];
             
             [QUEUE_HANDLER addAlertToQueue:@"Peek" withString:@"Succesfull peek request!"];
         }
         else if([msg isEqualToString:@"SMS_NEEDED"])
         {
             [QUEUE_HANDLER addSMSNeededToQueue:phone_to];
         }
         else
         {
             error = YES;
             
             [AnalyticsHelper send:@"ServerErrorOccured" label:@"sendingpeek"];
             
             [QUEUE_HANDLER addAlertToQueue:@"Error" withString:@"Error in communication, please try again!"];
         }
         
         if(cvc != nil) [cvc clearPhoneNumber:error];
     }];
}

- (void) clearPhoneNumber:(BOOL) error
{
    if(!error && clearPhoneNumber) tfPhoneTo.text = @"";
    clearPhoneNumber = NO;
}


@end

//
//  ContactsVC.h
//  Peepapp
//
//  Created by Andris Konfar on 24/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface ContactsVC : UIViewController <ABPeoplePickerNavigationControllerDelegate>

- (void) createLastContacts;
+ (void) startpeep:(NSString*) phone_to anonym:(BOOL) anonym contactsVC:(ContactsVC*) cvc;

@end

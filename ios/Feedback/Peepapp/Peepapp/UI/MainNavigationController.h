//
//  MainNavigationController.h
//  Peepapp
//
//  Created by Andris Konfar on 13/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MainNavigationController : UINavigationController <MFMessageComposeViewControllerDelegate>

+ (MainNavigationController*)instance;
+ (void)setInstance:(MainNavigationController*)i;
- (void) tryToShowPopup;

@end

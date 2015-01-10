//
//  MainVC.h
//  PeaceApp
//
//  Created by Andris Konfar on 25/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController <UIAlertViewDelegate>

@property IBOutlet UILabel* label;
@property IBOutlet UILabel* number;
@property IBOutlet UILabel* peaceId;
@property IBOutlet UIActivityIndicatorView* indicator;

- (IBAction)share:(UIButton*) button;

+ (void) doLoading:(UILabel*) label number:(UILabel*)number indicator:(UIActivityIndicatorView*)indicator;


@end

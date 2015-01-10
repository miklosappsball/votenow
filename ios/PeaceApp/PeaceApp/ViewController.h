//
//  ViewController.h
//  PeaceApp
//
//  Created by Andris Konfar on 20/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property IBOutlet UILabel* label;
@property IBOutlet UILabel* number;
@property IBOutlet UIActivityIndicatorView* indicator;

- (IBAction) ok:(UIButton*) sender;

@end


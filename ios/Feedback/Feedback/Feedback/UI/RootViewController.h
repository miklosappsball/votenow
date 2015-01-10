//
//  RootViewController.h
//  Feedback
//
//  Created by Andris Konfar on 15/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>


#define ROOTVIEWCONTROLLER [RootViewController getInstance]

@interface RootViewController : UIViewController

+ (RootViewController*) getInstance;

@end

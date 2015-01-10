//
//  MainViewController.h
//  Feedback
//
//  Created by Andris Konfar on 15/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingIndicatorViewController.h"


#define MAIN_VIEW_CONTROLLER [MainViewController getInstance]
#define LOADING_INDICATOR [[MainViewController getInstance] getLoadingIndicator]



@interface MainViewController : UIViewController

+ (MainViewController*) getInstance;
- (void) changeToViewController:(UIViewController*) viewController;
- (LoadingIndicatorViewController*) getLoadingIndicator;

- (void) scrollToFitView:(UIView*) view;
- (void) scrollSize:(CGFloat)y;

@end

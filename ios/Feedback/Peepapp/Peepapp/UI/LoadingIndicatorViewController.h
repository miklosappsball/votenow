//
//  LoadingIndicatorViewController.h
//  Feedback
//
//  Created by Andris Konfar on 21/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LOADING_INDICATOR [LoadingIndicatorViewController instance]

@interface LoadingIndicatorViewController : UIViewController

+ (LoadingIndicatorViewController*) instance;
- (void) showLoadingIndicator;
- (void) hideLoadingIndicator;
- (void) progress:(int) progress;
- (BOOL) isShown;


@end

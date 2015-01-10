//
//  LoadingIndicatorViewController.h
//  Feedback
//
//  Created by Andris Konfar on 21/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingIndicatorViewController : UIViewController

- (void) showLoadingIndicator;
- (void) hideLoadingIndicator;
- (BOOL) isShown;


@end

//
//  MainViewController.m
//  Feedback
//
//  Created by Andris Konfar on 15/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "MainViewController.h"
#import "LoadingIndicatorViewController.h"
#import "Colors.h"
#import "AnalyticsHelper.h"


@interface MainViewController ()
{
    UIViewController* currentViewController;
    UIScrollView* mainView;
    LoadingIndicatorViewController* loadingIndicator;
    CGFloat isKeyboardHeight;
    
    UIView* waitedView;
    CGFloat contentSizeY;
}


@end

@implementation MainViewController


static MainViewController* instance = nil;

+ (MainViewController*) getInstance
{
    if(instance == nil)
    {
        instance = [[MainViewController alloc] init];
    }
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height)];
        } else {
            mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
        }
        
        loadingIndicator = [[LoadingIndicatorViewController alloc] init];
        loadingIndicator.view.frame = self.view.bounds;
        [self.view addSubview:mainView];
        [self.view addSubview:loadingIndicator.view];
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeInfoDark];
        CGFloat top = 30;
        button.frame = CGRectMake(self.view.frame.size.width - 10 - button.frame.size.width, top, button.frame.size.width, button.frame.size.height);
        [button addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image = [UIImage imageNamed:@"appsball_logo.png"];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(openAppsball) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat imgWidth = 60;
        CGFloat imgHeight = 45;
        
        button.frame = CGRectMake(self.view.frame.size.width - imgWidth, self.view.frame.size.height - 10 -imgHeight, imgWidth, imgHeight);
        [self.view addSubview:button];
        
        [self registerForKeyboardNotifications];
    }
    return self;
}

- (void) openAppsball
{
    [AnalyticsHelper send:@"AppsBallIconPressed"];
    NSURL *url = [NSURL URLWithString:@"http://www.appsball.com"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) scrollSize:(CGFloat)y
{
    contentSizeY = y;
    mainView.contentSize = CGSizeMake(0, y);
}

- (void) showInfo
{
    [AnalyticsHelper send:@"InfoButtonPressed"];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Vote now! - HELP" message:@"100% fast, 100% anonim, 100% confident\n\nIf somebody asked you to vote a question\n1. enter vote code and\n2. choose from the alternatives (single or multichoice) with your comment\nwithin didplayed time limit (default: 3 minutes).\nIn case of non-anonymous question set your agreed ID (eg. name or email address,...) otherwise we keep your privacy and only the anonymous/aggregated result will be accessible for the questioner.\nIf you want to ask people to vote\n1. enter your question (max. 500 character) with answer alternatives\n 2. set question parameters: anonymous/non-anonymous and single/multichoise\n3. share the vote code with people who installed this application\n4. set question validity intervall (start-end)\nThe application will generate and send vote code via push notification and email.\nAfter you shared it with your target audiance they have the set time frame default: 3 minutes) to respond.\nBetter to ask your target audiance to install the application preliminary!\nAfter expiry only you will receive a push notification and email to access your result.\nResult contain answers with comments." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void) changeToViewController:(UIViewController*) viewController
{
    CATransition *animation = [CATransition animation];
    animation.duration = ANIMATION_DEFAULT_TIME;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.view.layer addAnimation:animation forKey:@"changeMainView"];
    
    for(UIView* v in mainView.subviews)
    {
        [v removeFromSuperview];
    }
    [mainView addSubview:viewController.view];
    // viewController.view.frame = mainView.bounds;
    
    currentViewController = viewController;
}

- (LoadingIndicatorViewController*) getLoadingIndicator
{
    return loadingIndicator;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardWillShowNotification is sent.
- (void)keyboardWillShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize s = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    isKeyboardHeight = s.width > s.height ? s.height : s.width;
    mainView.contentSize = CGSizeMake(0, contentSizeY + isKeyboardHeight);
    
    if(waitedView != nil)
    {
        [self scrollToFitView:waitedView];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    isKeyboardHeight = 0;
    [UIView animateWithDuration:ANIMATION_DEFAULT_TIME delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
//         mainView.contentOffset = CGPointMake(0, 0);
         mainView.contentSize = CGSizeMake(0, contentSizeY);
     } completion:^(BOOL finished) {
     }];
}

- (void) scrollToFitView:(UIView*) view
{
    CGFloat y = 0;
    
    UIView* tmp = view;
    while(tmp != nil && tmp != mainView)
    {
        y += tmp.frame.origin.y;
        tmp = tmp.superview;
    }
    
    CGRect rect = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);
    
    if(isKeyboardHeight == 0)
    {
        waitedView = view;
    }
    else
    {
        waitedView = nil;
    }
    
    if(mainView.contentOffset.y > rect.origin.y)
    {
        [self scrollMainViewToOffset:rect.origin.y-5-mainView.contentInset.top animated:YES];
        return;
    }
    
    if(mainView.contentOffset.y + mainView.frame.size.height - mainView.contentInset.top - isKeyboardHeight < CGRectGetMaxY(rect))
    {
        CGFloat y = CGRectGetMaxY(rect) + 5 + mainView.contentInset.top - (mainView.frame.size.height - isKeyboardHeight);
        [self scrollMainViewToOffset:y animated:YES];
    }
}

- (void) scrollMainViewToOffset:(CGFloat) positionY animated:(BOOL)animated
{
    double duration = 0.0;
    if(animated) duration = ANIMATION_DEFAULT_TIME;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:duration delay:0 options:options animations:^
     {
         mainView.contentOffset = CGPointMake(0, positionY);
     } completion:^(BOOL finished) {
     }];
}

@end

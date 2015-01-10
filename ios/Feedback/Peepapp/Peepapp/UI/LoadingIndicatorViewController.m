
#import "LoadingIndicatorViewController.h"
#import "Colors.h"
#import <QuartzCore/QuartzCore.h>

#define INDICATOR_SIZE 25.0f
#define INDICATOR_MARGIN 25.0f
#define INDICATOR_CORNER_RADIOUS 7.0f

@interface LoadingIndicatorViewController ()
{
    UILabel* label;
}

@end

@implementation LoadingIndicatorViewController

static LoadingIndicatorViewController* instance;

+ (LoadingIndicatorViewController*) instance
{
    if(instance == nil)
    {
        instance = [[LoadingIndicatorViewController alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        // creating a nearly transparent bg view
        UIView* loadingIndicator = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 200, 200)];
        loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:loadingIndicator];
        [loadingIndicator setBackgroundColor:COLOR_LOADING_INDICATOR_BG];
        
        UIView* inview = [[UIView alloc] initWithFrame:CGRectZero];
        [inview setBackgroundColor:COLOR_LOADING_INDICATOR_MID_BG];
        inview.layer.cornerRadius = INDICATOR_CORNER_RADIOUS;
        [loadingIndicator addSubview:inview];
        inview.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhiteLarge;
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        [indicator startAnimating];
        [inview addSubview:indicator];
        
        // adding the indicator spinner
        float x = loadingIndicator.frame.size.width / 2 - INDICATOR_SIZE / 2;
        float y = loadingIndicator.frame.size.height / 2 - INDICATOR_SIZE / 2;
        
        float plus = INDICATOR_MARGIN;
        
        inview.frame = CGRectMake(x-plus, y-plus, 25 + 2*plus, 25 + 2*plus);
        indicator.frame = CGRectMake(plus, plus, INDICATOR_SIZE, INDICATOR_SIZE);
        
        loadingIndicator.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.view.hidden = YES;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(inview.frame.origin.x, CGRectGetMaxY(inview.frame) - 10, inview.frame.size.width, 20)];
        label.text = @"0%";
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithWhite:255 alpha:0.8];
        label.hidden = YES;
        [loadingIndicator addSubview:label];
    }
    return self;
}

- (void) progress:(int) progress
{
    NSLog(@"in progress: %d", progress);
    label.text = [NSString stringWithFormat:@"%d %%", progress];
    label.hidden = NO;
}

- (void) showLoadingIndicator
{
    label.hidden = YES;
    [self.view.superview bringSubviewToFront:self.view];
    CATransition *animation = [CATransition animation];
    animation.duration = ANIMATION_DEFAULT_TIME;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.view.layer addAnimation:animation forKey:@"showMainIndicator"];
    self.view.hidden = NO;
}

- (BOOL) isShown
{
    return !self.view.hidden;
}

- (void) hideLoadingIndicator
{
    
    CATransition *animation = [CATransition animation];
    animation.duration = ANIMATION_DEFAULT_TIME;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.view.layer addAnimation:animation forKey:@"hideMainIndicator"];
    
    label.hidden = YES;
    self.view.hidden = YES;
}

@end
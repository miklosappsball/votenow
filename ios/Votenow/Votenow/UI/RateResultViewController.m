//
//  RateResultViewController.m
//  Feedback
//
//  Created by Andris Konfar on 27/08/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "RateResultViewController.h"
#import "MainViewController.h"
#import "WebServiceCalls.h"
#import "AnswerGetQuestionResult.h"
#import "Colors.h"
#import "ButtonUtil.h"
#import "HomePageViewController.h"

@interface RateResultViewController ()
{
    UIScrollView* scrollView;
    CGFloat width;
}

@end

@implementation RateResultViewController

- (id)initWithCode:(NSString*) code
{
    self = [super init];
    if (self)
    {
        [MAIN_VIEW_CONTROLLER scrollSize:0];
        [MAIN_VIEW_CONTROLLER.view endEditing:YES];
        [LOADING_INDICATOR showLoadingIndicator];
        
        self.view.backgroundColor = COLOR_BACKGROUND_2;
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:scrollView];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            AnswerGetQuestionResult* answer = [WebserviceCalls getQuestionResult:code];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [LOADING_INDICATOR hideLoadingIndicator];
                
                width = self.view.frame.size.width-LEFT_MARGIN-LEFT_MARGIN;
                CGFloat y = [self addTextTop:LEFT_MARGIN text:@"Result of your survey" size:24];
                y = [self addTextTop:y text:@"It was sent to your email, as well" size:11];
                y += LEFT_MARGIN;
                y = [self addTextTop:y text:answer.json[@"title"] size:24 textAlignment:NSTextAlignmentCenter];
                y += LEFT_MARGIN;
                
                [self addTextTop:y text:@"# of votes:" size:15];
                y = [self addTextTop:y text:answer.json[@"numberOfRates"] size:15 left:160];
                
                [self addTextTop:y text:@"Type:" size:15];
                
                NSString* anonymous = ((NSNumber*)answer.json[@"anonym"]).boolValue ? @"anonymous" : @"non-anonymous";
                y = [self addTextTop:y text:anonymous size:15 left:160];
                NSString* mutlistr = ((NSNumber*)answer.json[@"multichoice"]).boolValue ? @"multichoice" : @"single-choice";
                [self addTextTop:y text:mutlistr size:15 left:160];
                
                y+= LEFT_MARGIN;
                y = [self addTextTop:y + LEFT_MARGIN text:@"Choices:" size:22];
                
                NSArray* choices = answer.json[@"choices"];
                if(choices != nil)
                {
                    for(int i=0;i<choices.count;i++)
                    {
                        NSDictionary* choice = choices[i];
                        y = [self writeOutChoice:choice y:y isMulti:((NSNumber*)answer.json[@"multichoice"]).boolValue];
                    }
                }
                
                if(answer.json[@"comments"] != nil)
                {
                    y = [self addTextTop:y + LEFT_MARGIN text:@"Comments:" size:22];
                    y = [self writeOutComments:answer.json[@"comments"] y:y isMulti:NO];
                }
                
                y += LEFT_MARGIN;
                
                UIButton* button = [ButtonUtil createButton];
                [button setTitle:@"Ok" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
                [scrollView addSubview:button];
                button.frame = CGRectMake(self.view.frame.size.width / 2 - button.frame.size.width/2, y, button.frame.size.width, button.frame.size.height);
                y += button.frame.size.height;
                
                scrollView.contentSize = CGSizeMake(0, y + LEFT_MARGIN+LEFT_MARGIN);
            });
        });
    }
    return self;
}

- (CGFloat) writeOutChoice:(NSDictionary*) choice y:(CGFloat)y isMulti:(BOOL)multi
{
    y = [self addTextTop:y + LEFT_MARGIN text:choice[@"choice"] size:20];
    y = [self addTextTop:y + LEFT_MARGIN/4 text:[NSString stringWithFormat:@"Selected: %@ (%@)", choice[@"number"], choice[@"percentage"]] size:14];
    y = [self writeOutComments:choice[@"comments"] y:y isMulti:multi];
    
    return y;
}

- (CGFloat) writeOutComments:(NSArray*) comments y:(CGFloat)y isMulti:(BOOL)multi
{
    if(comments != nil)
    {
        NSString* str = @"";
        for(int i=0;i<comments.count;i++)
        {
            y+= LEFT_MARGIN/2;
            NSDictionary* dict = comments[i];
            if(multi)
            {
                str = [str stringByAppendingFormat:@"%@, ", dict[@"name"]];
            }
            else
            {
                if(dict[@"name"] != nil) y = [self addTextTop:y text:dict[@"name"] size:14];
                if(dict[@"comment"] != nil) y = [self addTextTop:y text:dict[@"comment"] size:12];
            }
        }
        
        if(multi)
        {
            if(str.length > 2)
            {
                str = [str substringToIndex:str.length-2];
            }
            y = [self addTextTop:y text:str size:12];
        }
    }
    return y;
}

- (void) ok
{
    [MAIN_VIEW_CONTROLLER changeToViewController:[[HomePageViewController alloc] init]];
}

- (CGFloat) addTextTop:(CGFloat)top text:(NSString*) str size:(CGFloat) size
{
    return [self addTextTop:top text:str size:size textAlignment:NSTextAlignmentLeft left:LEFT_MARGIN];
}

- (CGFloat) addTextTop:(CGFloat)top text:(NSString*) str size:(CGFloat) size left:(CGFloat) left
{
    return [self addTextTop:top text:str size:size textAlignment:NSTextAlignmentLeft left:left];
}

- (CGFloat) addTextTop:(CGFloat)top text:(NSString*) str size:(CGFloat) size textAlignment:(NSTextAlignment)textalignment
{
    return [self addTextTop:top text:str size:size textAlignment:textalignment left:LEFT_MARGIN];
}

- (CGFloat) addTextTop:(CGFloat)top text:(NSString*) str size:(CGFloat) size textAlignment:(NSTextAlignment)textalignment left:(CGFloat) left
{
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 1000)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = str;
    lbl.numberOfLines = 0;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont boldSystemFontOfSize:size];
    lbl.textAlignment = textalignment;
    
    [lbl sizeToFit];
    CGSize height = lbl.frame.size;
    
    NSLog(@"size: %@ ", NSStringFromCGSize(height));
    
    lbl.frame = CGRectMake(left, top, width, height.height);
    [scrollView addSubview:lbl];
    NSLog(@"size: %@   %f", NSStringFromCGRect(lbl.frame), CGRectGetMaxY(lbl.frame));
    return CGRectGetMaxY(lbl.frame);
}

- (CGFloat) addStars:(int)i rateString:rate percentageStr:percentage top:(CGFloat)top   lblText:(NSString*) lblText   valueText : (NSString*) valueText
{
    UILabel* lbl = [[UILabel alloc] init];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = [NSString stringWithFormat:@"%@   %@%%", rate, percentage];
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:12];
    [lbl sizeToFit];
    lbl.frame = CGRectMake(LEFT_MARGIN, top, 70, lbl.frame.size.height);
    [scrollView addSubview:lbl];
    
    CGFloat retval = CGRectGetMaxY(lbl.frame);
    
    CGFloat size = lbl.frame.size.height;
    CGFloat left = CGRectGetMaxX(lbl.frame);
    
    [self addStars:i left:left top:top size:size];
    
    lbl = [[UILabel alloc] init];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = lblText;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:12];
    [lbl sizeToFit];
    lbl.frame = CGRectMake(200, top, 70, lbl.frame.size.height);
    [scrollView addSubview:lbl];
    
    lbl = [[UILabel alloc] init];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = valueText;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:12];
    [lbl sizeToFit];
    lbl.frame = CGRectMake(270, top, 30, lbl.frame.size.height);
    [scrollView addSubview:lbl];
    
    return retval;
}

- (void) addStars:(int)i left:(CGFloat) left top:(CGFloat) top size:(CGFloat) size
{
    for(CGFloat x=left; x<left + size*i + size/2; x += size)
    {
        UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(x, top, size, size)];
        image.image = [UIImage imageNamed:@"star.png"];
        image.contentMode = UIViewContentModeScaleToFill;
        [scrollView addSubview:image];
    }
}

@end
//
//  InfoViewController.m
//  PeaceApp
//
//  Created by Andris Konfar on 05/11/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) ok:(UIButton*) sender
{
    UIStoryboard *storyboard = self.storyboard;
    UIViewController *myVC = (UIViewController*)[storyboard instantiateViewControllerWithIdentifier:@"AddId"];
    [self presentViewController:myVC animated:YES completion:nil];
}

@end

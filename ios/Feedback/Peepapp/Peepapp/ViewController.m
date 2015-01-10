//
//  ViewController.m
//  Peepapp
//
//  Created by Andris Konfar on 19/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    SRWebSocket* _webSocket;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"finished1");
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://peepapp-appsball.rhcloud.com:8000/fileupload"]]];
    _webSocket.delegate = self;
    [_webSocket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    [_webSocket send:@"HAHAFirst!!!"];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"data recieved: %@", message);
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"error!!! %@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

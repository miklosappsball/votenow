//
//  CameraVC.h
//  Peepapp
//
//  Created by Andris Konfar on 26/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class PushData;

@interface CameraVC : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate>

- (instancetype)initWithPushId:(PushData*)pushid;
+ (void) calculateBackward:(UILabel*) label int:(int) number endString:(NSString*)str;

@end

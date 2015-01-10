//
//  CameraVC.m
//  Peepapp
//
//  Created by Andris Konfar on 26/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "CameraVC.h"
#import <AVFoundation/AVFoundation.h>
#import "Communication.h"
#import "LoadingIndicatorViewController.h"
#import "QueueHandler.h"
#import "PushData.h"
#import "AnalyticsHelper.h"

@interface CameraVC ()
{
    AVCaptureStillImageOutput* stillImageOutput;
    UIImageView* imageView;
    PushData* pushId;
}

@property AVCaptureSession* captureSession;
@property AVCaptureVideoPreviewLayer* prevLayer;

@end

@implementation CameraVC

- (instancetype)initWithPushId:(PushData*)pushid
{
    self = [super init];
    if (self)
    {
        pushId = pushid;
        self.title = @"Taking photo";
        [self.navigationItem setHidesBackButton:YES animated:YES];
        
        [self initcamera];
        CGFloat y = self.view.frame.size.height/2 - self.view.frame.size.width/2;
        CGFloat size = self.view.frame.size.width;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, size, size)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        
        UIView* bview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, y)];
        bview.backgroundColor = COLOR_BACKGROUND_1;
        [self.view addSubview:bview];
        bview = [[UIView alloc] initWithFrame:CGRectMake(0, y+size, size, self.view.frame.size.height-y-size)];
        bview.backgroundColor = COLOR_BACKGROUND_1;
        [self.view addSubview:bview];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bview.frame.size.width, bview.frame.size.height)];
        label.font = [UIFont boldSystemFontOfSize:32];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = TEXT_COLOR_1;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"";
        [bview addSubview:label];
        [CameraVC calculateBackward: label int:3 endString:@"CHEESE!"];
        
        // [self sendImage:[UIImage imageNamed:@"DSC_1999.jpg"]];
    }
    return self;
}

- (void) sendImage:(UIImage*)image
{
    [imageView setImage:image];
    
    NSData* data = UIImageJPEGRepresentation(image, 1.0f);
    [LOADING_INDICATOR showLoadingIndicator];
    
    [[Communication instance] uploadImage:data pushId:pushId.pushId answerFunction: ^(NSDictionary* answer){
        NSString* message = [answer objectForKey:FIELD_MESSAGE];
        [LOADING_INDICATOR hideLoadingIndicator];
        [[Communication instance] close];
        
        if([@"END" isEqualToString:message])
        {
            [AnalyticsHelper send:@"PeekPhotoSent"];
            
            [self.navigationController popViewControllerAnimated:YES];
            [QUEUE_HANDLER addPeekBackToQueue:pushId];
        }
        else
        {
            [AnalyticsHelper send:@"ServerErrorOccured" label:@"upload"];
            
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error during uploading the image" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again!", nil] show];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if(buttonIndex == 1)
    {
        [self sendImage:imageView.image];
    }
}

- (void) initcamera
{
    // ellenorzesek, hogy hasznalhato-e az eszkoz csekkbeolvasasra
    AVCaptureDevice *device = nil;
    
    for(AVCaptureDevice* d in [AVCaptureDevice devices])
    {
        device = d;
        if([d position] == AVCaptureDevicePositionFront)
        {
            break;
        }
    }
    
    // We setup the input
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput
                                          deviceInputWithDevice:device
                                          error:nil];
    
    // We setupt the output
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    //We create a serial queue to handle the processing of our frames
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", 0);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    // And we create a capture session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    [self.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    // We add input and output
    [self.captureSession addInput:captureInput];
    [self.captureSession addOutput:captureOutput];
    
    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];
    self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    self.prevLayer.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    //self.prevLayer.borderColor= [[UIColor yellowColor] CGColor];
    //self.prevLayer.borderWidth= 3;
    self.prevLayer.backgroundColor = [COLOR_BACKGROUND_1 CGColor];
    self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer insertSublayer:self.prevLayer atIndex:1];
    
    
    // CaptureStillImageOutput for the actual picture
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [self.captureSession addOutput:stillImageOutput];
    
    [self.captureSession startRunning];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [NSThread sleepForTimeInterval:3];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self captureNow];
        });
    });
    
}

+ (void) calculateBackward:(UILabel*) label int:(int) number endString:(NSString*) str
{
    label.text = [NSString stringWithFormat:@"%d", number];
    
    NSLog(@"number");
    if(number <= 0)
    {
        label.text = str;
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        label.transform = CGAffineTransformMakeScale(2, 2);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.8 animations:^{
            label.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [NSThread sleepForTimeInterval:1];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [CameraVC calculateBackward: label int:number-1 endString:str];
        });
    });
}

-(void) captureNow
{
    // ertelmet az apple-tol kerdezzetek, hogy miert ilyen marha bonyolult a tortenet...
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         if(SHUTTER) AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         // image resizing and rotating to correct style
         CGFloat width = image.size.width;
         if(image.size.height<width) width = image.size.height;
         CGFloat x = (image.size.width - width)/2;
         CGFloat y = (image.size.height - width)/2;
         CGRect rect = CGRectMake(y, x, width, width);
         // rect = CGRectMake(y,x , width/4, width/4);
         CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
         CGFloat rads = M_PI * 1/2;
         CGSize size =  CGSizeMake(width, width);
         UIGraphicsBeginImageContext(size);
         CGContextRef ctx = UIGraphicsGetCurrentContext();
         CGContextTranslateCTM(ctx, width/2, width/2);
         CGContextRotateCTM(ctx, rads);
         CGContextScaleCTM(ctx, 1.0, -1.0);
         CGContextDrawImage(ctx,CGRectMake(-width/2,-width/2,size.width, size.height),imageRef);
         CGImageRelease(imageRef);
         UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         
         cropped = [UIImage imageWithCGImage:cropped.CGImage scale:1 orientation:UIImageOrientationUp];
         [self.captureSession stopRunning];
         
         [self sendImage:cropped];
     }];
}


@end

//
//  CameraVC.m
//  Peepapp
//
//  Created by Andris Konfar on 26/09/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import "CameraVC.h"
#import <AVFoundation/AVFoundation.h>
#import "Colors.h"
#import "DeviceUtil.h"

#define FONT_NAME @"GillSans-Bold"

@interface CameraVC ()
{
    AVCaptureStillImageOutput* stillImageOutput;
    UIImageView* imageView;
}

@property AVCaptureSession* captureSession;
@property AVCaptureVideoPreviewLayer* prevLayer;

@end

@implementation CameraVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.title = @"Taking photo";
        [self.navigationItem setHidesBackButton:YES animated:YES];
        
        [self initcamera];
        CGFloat y = self.view.frame.size.height/2 - self.view.frame.size.width/2;
        CGFloat size = self.view.frame.size.width;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, size, size)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = COLOR_BACKGROUND_1;
        imageView.hidden = YES;
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
    }
    return self;
}

- (void) sendImage:(UIImage*)image
{
    imageView.hidden = NO;
    [imageView setImage:image];
    
    NSString *string = [NSString stringWithFormat:@"Peace text, what i don't know still ... By the way your peace ID: %@", [DeviceUtil getId]];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[string, image] applicationActivities:nil];
    controller.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePrint];
    [self presentViewController:controller animated:YES completion:nil];
    
    [controller setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
     {
         [self dismissViewControllerAnimated:YES completion:nil];
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
         [self.captureSession stopRunning];
         
         // image resizing and rotating to correct style
         
         // crop the image to square size
         CGFloat width = image.size.width;
         if(image.size.height<width) width = image.size.height;
         CGFloat x = (image.size.width - width)/2;
         CGFloat y = (image.size.height - width)/2;
         CGRect rect = CGRectMake(y, x, width, width);
         CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
         
         // rotate the image to correct orientation
         CGFloat rads = M_PI * 1/2;
         CGSize size =  CGSizeMake(width, width);
         UIGraphicsBeginImageContext(size);
         CGContextRef ctx = UIGraphicsGetCurrentContext();
         CGContextTranslateCTM(ctx, width/2, width/2);
         CGContextRotateCTM(ctx, rads);
         
         // mirror the image
         CGContextScaleCTM(ctx, 1.0, -1.0);
         CGContextDrawImage(ctx,CGRectMake(-width/2,-width/2,size.width, size.height),imageRef);
         CGImageRelease(imageRef);
         UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
         cropped = [UIImage imageWithCGImage:cropped.CGImage scale:1 orientation:UIImageOrientationUp];
         UIGraphicsEndImageContext();
         
         // adding the other image
         // UIImage* otherImage = [UIImage imageNamed:@"qr.png"];
         // CGFloat width2 = otherImage.size.width * width / otherImage.size.height;
         size =  CGSizeMake(width, width);
         UIGraphicsBeginImageContext(size);
         ctx = UIGraphicsGetCurrentContext();
         [cropped drawInRect:CGRectMake(0, 0, cropped.size.width, cropped.size.height)];
         // [otherImage drawInRect:CGRectMake(cropped.size.width, 0, width2, width)];
         
         // adding bottom watermark
         NSString* text = [DeviceUtil getId];
         CGFloat textSize = width * 0.12f;
         UIFont *font = [UIFont fontWithName:FONT_NAME size:textSize];
         NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, RGBA(255, 255, 255, 255), NSForegroundColorAttributeName, RGBA(0, 0, 0, 255), NSStrokeColorAttributeName, nil];
         CGFloat textWidth = [text sizeWithAttributes:attrsDictionary].width;
         
         /*
         CGFloat rectHeight = textHeight*1.5f;
         CGFloat rectWidth = textWidth + rectHeight - textHeight ;
         CGContextSetFillColorWithColor(ctx, RGBA(255, 100, 100, 128).CGColor);
         CGRect fillRect = CGRectMake(width - rectWidth, width - rectHeight, rectWidth, rectHeight);
         CGContextFillRect(ctx, fillRect);
          */
         // [[UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:textSize / 2] fill];
         
         // adding the watermark text
         NSLog(@"font: %f", textSize);
         CGContextSetLineWidth(ctx, textSize*0.08);
         CGContextSetTextDrawingMode(ctx, kCGTextFillStroke);
         
         CGFloat totalWidth = textWidth + textSize * 1.5;
         x = (width - totalWidth) / 2;
         y = width - textSize*1.5;
         
         UIImage* otherImage = [UIImage imageNamed:@"myicon.png"];
         [otherImage drawInRect:CGRectMake(x, y, textSize, textSize)];
         
         x += textSize * 1.5;
         [text drawAtPoint:CGPointMake(x, y) withAttributes:attrsDictionary];
         
         textWidth = 0;
         textSize = 10;
         text = @"I declare my commitment to peace";
         while (textWidth < width*0.95f) {
             font = [UIFont fontWithName:FONT_NAME size:textSize+=2];
             attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, RGBA(255, 255, 255, 255), NSForegroundColorAttributeName, RGBA(0, 0, 0, 255), NSStrokeColorAttributeName, nil];
             textWidth = [text sizeWithAttributes:attrsDictionary].width;
         }
         
         textSize -= 2;
         CGContextSetLineWidth(ctx, textSize*0.07);
         font = [UIFont fontWithName:FONT_NAME size:textSize];
         attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, RGBA(255, 255, 255, 255), NSForegroundColorAttributeName, RGBA(0, 0, 0, 255), NSStrokeColorAttributeName, nil];
         textWidth = [text sizeWithAttributes:attrsDictionary].width;
         [text drawAtPoint:CGPointMake((width - textWidth)/2,textSize / 2) withAttributes:attrsDictionary];
         
         /*
         fillRect = CGRectMake(width - rectWidth + (rectHeight-textHeight) / 2, width - (rectHeight + textHeight) / 2, textWidth, textHeight);
         CGContextFillRect(ctx, fillRect);
          */
         
         UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         
         [self sendImage:result];
     }];
}


@end

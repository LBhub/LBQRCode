//
//  ViewController.m
//  QRCode
//
//  Created by li on 16/6/18.
//  Copyright © 2016年 li. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) UIView *boxView;
@property (nonatomic) BOOL isReading;
@property (strong, nonatomic) CALayer *scanLayer;
@property (nonatomic,strong) UIView *viewPreview;

//捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//展示layer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewPreview = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_viewPreview];
    
    _captureSession = nil;
    _isReading = NO;
    [self startReading];
    
}

- (BOOL)startReading {
    NSError *error;
    
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    
    //4.1.将输入流添加到会话
    [_captureSession addInput:input];
    
    //4.2.将媒体输出流添加到会话中
    [_captureSession addOutput:captureMetadataOutput];
    
    //5.创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1.设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //5.2.设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
   // _viewPreview.alpha = 0.6;
    
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    
    //9.将图层添加到预览view的图层上
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    //10.设置扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    
    //10.1.扫描框
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(0,0,  _viewPreview.bounds.size.width * 0.6f,_viewPreview.bounds.size.width * 0.6f)];
    _boxView.center = _viewPreview.center;
    
    _boxView.layer.borderColor = _boxViewColor.CGColor ?: [UIColor whiteColor].CGColor;
    _boxView.layer.borderWidth = 1.0f;
    
    /***************增加背景遮罩********************/
    //top
    UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _viewPreview.frame.size.width, _boxView.frame.origin.y)];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = 0.5;
    [_viewPreview addSubview:shadow];
    
    //bottom
    shadow = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_boxView.frame), _viewPreview.frame.size.width, _viewPreview.frame.size.height - CGRectGetMaxY(_boxView.frame))];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = 0.5;
    [_viewPreview addSubview:shadow];
    
    //left
    shadow = [[UIView alloc] initWithFrame:CGRectMake(0,_boxView.frame.origin.y, _boxView.frame.origin.x, _boxView.frame.size.height)];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = 0.5;
    [_viewPreview addSubview:shadow];
    
    //right
    shadow = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_boxView.frame),_boxView.frame.origin.y,_viewPreview.frame.size.width - CGRectGetMaxX(_boxView.frame),_boxView.frame.size.height)];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = 0.5;
    [_viewPreview addSubview:shadow];
    /***********************************/

    [_viewPreview addSubview:_boxView];
    
    //10.2.扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor =  _scanColor.CGColor ?: [UIColor colorWithRed:45/255.0 green:130/255.0 blue:215/255.0 alpha:1].CGColor;

    [_boxView.layer addSublayer:_scanLayer];
    
    [self addAngle];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(_boxView.frame) + 20,_viewPreview.frame.size.width, 15)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _tips ?: @"对准二维码到框内即可扫描";
    [_viewPreview addSubview:label];    
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    [timer fire];
    
    //10.开始扫描
    [_captureSession startRunning];

    return YES;
}

///添加四个角
- (void)addAngle{
    CGFloat w = 2;
    CGFloat h = 15;
    CGFloat d = 0;
    CGPoint point = CGPointZero;
    UIColor *color = _angleColor ?:  [UIColor colorWithRed:45/255.0 green:130/255.0 blue:215/255.0 alpha:1];
    
    //left - top
    point = CGPointMake(_boxView.frame.origin.x - w - d, _boxView.frame.origin.y - w - d);
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, w, h)];
    view.backgroundColor = color;
    [self.view addSubview:view];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, h, w)];
    view.backgroundColor = color;
    [_viewPreview addSubview:view];
    
    //left - down
    point = CGPointMake(_boxView.frame.origin.x - w - d, _boxView.frame.origin.y + _boxView.frame.size.height + d + w - h);
    view = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, w, h)];
    view.backgroundColor = color;
    [_viewPreview addSubview:view];
    
    point = CGPointMake(point.x, _boxView.frame.origin.y + _boxView.frame.size.height + d);
    view = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, h, w)];
    view.backgroundColor = color;
    [_viewPreview addSubview:view];
    
    //right - top
    point = CGPointMake(_boxView.frame.origin.x + _boxView.frame.size.width + d, _boxView.frame.origin.y - w - d);
    view = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, w, h)];
    view.backgroundColor = color;
    [_viewPreview addSubview:view];
    
    point = CGPointMake(_boxView.frame.origin.x + _boxView.frame.size.width + w + d - h, point.y);
    view = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, h, w)];
    view.backgroundColor = color;
    [_viewPreview addSubview:view];
    
    //right - down
    point = CGPointMake(_boxView.frame.origin.x + _boxView.frame.size.width + d, _boxView.frame.origin.y + _boxView.frame.size.height + w + d - h);
    view = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, w, h)];
    view.backgroundColor = color;
    [self.view addSubview:view];
    
    point = CGPointMake(point.x + w - h, _boxView.frame.origin.y + _boxView.frame.size.height + d);
    view = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, h, w)];
    view.backgroundColor = color;
    [_viewPreview addSubview:view];
}


-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_scanLayer removeFromSuperlayer];
    //[_videoPreviewLayer removeFromSuperlayer];
}



#pragma mark AVCaptureMetadataOutputObjectsDelegate
    
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
        
        //判断是否有数据
        if (metadataObjects != nil && [metadataObjects count] > 0) {
            AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
            //判断回传的数据类型
            if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
                NSLog(@"扫描识别的结果为:%@",[metadataObj stringValue]);
                
                NSString *reslut = [metadataObj stringValue] ?: @"";
                if (_qrcodeContent) {
                     _qrcodeContent(reslut);
                    [self stopReading];
                    
                    if ([self.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]){
                        
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.navigationController popViewControllerAnimated:YES];
                         });
                        
                   }else if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:YES completion:nil];
                        });
                   }
                    
                }
              
                _isReading = NO;
            }
        }
        
}

- (void)moveScanLayer:(NSTimer *)timer{
    CGRect frame = _scanLayer.frame;
    if (_boxView.frame.size.height < _scanLayer.frame.origin.y) {
        frame.origin.y = 0;
        _scanLayer.frame = frame;
    }else{
        
        frame.origin.y += 5;
        
        [UIView animateWithDuration:0.05 animations:^{
            _scanLayer.frame = frame;
        }];
    }
}

///闪关灯
- (void)turnTorchOn:(bool) on {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];

            }else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

@end

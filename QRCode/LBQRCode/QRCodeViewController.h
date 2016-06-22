//
//  ViewController.h
//  QRCode
//
//  Created by li on 16/6/18.
//  Copyright © 2016年 li. All rights reserved.
//

#import <UIKit/UIKit.h>

///二维码扫描库

@interface QRCodeViewController : UIViewController

///扫描提示
@property (nonatomic,strong) NSString *tips;

///角颜色
@property (nonatomic,strong) UIColor *angleColor;

///扫描线颜色
@property (nonatomic,strong) UIColor *scanColor;

///扫描框边框颜色
@property (nonatomic,strong) UIColor *boxViewColor;

@property (copy,nonatomic) void (^qrcodeContent)(NSString *result);

@end


//
//  UIImage+Qrcode.h
//  paiKa
//
//  Created by lb on 16/4/7.
//  Copyright © 2016年 李波. All rights reserved.
//

#import <UIKit/UIKit.h>

//生成二维码
@interface UIImage (Qrcode)

+ (UIImage *)getQrcodeImageWithString:(NSString *)string size:(CGSize)size;

///裁剪二维码并添加logo，logo需为正方形，否则会被压缩
+ (UIImage *)getQrcodeImageWithString:(NSString *)string size:(CGSize)size logoImage:(UIImage *)logoImage;

@end

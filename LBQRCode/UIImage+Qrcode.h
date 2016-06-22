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


@end

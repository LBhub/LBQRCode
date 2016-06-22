//
//  UIImage+Qrcode.m
//  paiKa
//
//  Created by lb on 16/4/7.
//  Copyright © 2016年 李波. All rights reserved.
//

#import "UIImage+Qrcode.h"

@implementation UIImage (Qrcode)


+ (UIImage *)getQrcodeImageWithString:(NSString *)string size:(CGSize)size{
    
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // return qrFilter.outputImage;
    
    UIImage *image = [self createNonInterpolatedUIImageFormCIImage:qrFilter.outputImage withSize:size];
    return image;
}

+ (UIImage *)getQrcodeImageWithString:(NSString *)string size:(CGSize)size logoImage:(UIImage *)logoImage{
    
    UIImage *image = [self getQrcodeImageWithString:string size:size];
    return [self addImage:image logoImage:logoImage];
    
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGSize)size {
    
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat widthScale = size.width/CGRectGetWidth(extent);
    CGFloat heightScale = size.height/CGRectGetHeight(extent);
    // 创建bitmap;
    size_t width = size.width;
    size_t height = size.height;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, widthScale, heightScale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


///添加logo
+ (UIImage *)addImage:(UIImage *)img logoImage:(UIImage *)logoImage{
    int w = img.size.width;
    int h = img.size.height;
    int subWidth = logoImage.size.width;
    int subHeight = logoImage.size.height;
    
    if (subWidth > 50) {
        subWidth = 50;
        subHeight = 50;
    }
    
    if (subWidth >= w * 0.3) {
        subWidth = w * 0.3;
        subHeight = subWidth;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake( (w-subWidth)/2, (h - subHeight)/2, subWidth, subHeight), [logoImage CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return [UIImage imageWithCGImage:imageMasked];
    
}

@end

//
//  ViewController.m
//  demo1
//
//  Created by li on 16/6/20.
//  Copyright © 2016年 li. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeViewController.h"
#import "UIImage+Qrcode.h"

@interface ViewController ()

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"点击屏幕扫描";
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _imageView.center = self.view.center;
    
    [self.view addSubview:_imageView];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    QRCodeViewController *vc = [[QRCodeViewController alloc] init];
    vc.tips = @"扫一扫";
    vc.title = @"测试";
    vc.qrcodeContent = ^(NSString *result){
    
        [self createImage:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:result delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
            
        });
        
        
    };
    
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)createImage:(NSString *)content{
   
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage getQrcodeImageWithString:content size:_imageView.frame.size logoImage:[UIImage imageNamed:@"01.png"]];
        _imageView.image = image;

    });


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

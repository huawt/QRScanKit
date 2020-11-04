//
//  QRViewController.m
//  QRScanKit
//
//  Created by huawentao on 07/26/2019.
//  Copyright (c) 2019 huawentao. All rights reserved.
//

#import "QRViewController.h"
#import <QRScanKit/QRScanKit.h>

@interface QRViewController ()<QRScanViewDelegate>
@property (nonatomic,strong)  CAShapeLayer *layer;
@end

@implementation QRViewController
/*** 专门用于保存描边的图层 ***/

- (void)QRScanMetadataObjectByScan:(AVMetadataMachineReadableCodeObject *)metadataObj{
//    [self drawLine:metadataObj];
}

- (void)drawLine:(AVMetadataMachineReadableCodeObject *)objc
{

    NSArray *array = objc.corners;

    
    // 1.创建形状图层, 用于保存绘制的矩形
    if (!self.layer) {
        self.layer = [[CAShapeLayer alloc] init];
    }

    // 设置线宽
    self.layer.lineWidth = 2;
    // 设置描边颜色
    self.layer.strokeColor = [UIColor greenColor].CGColor;
    self.layer.fillColor = [UIColor clearColor].CGColor;

    // 2.创建UIBezierPath, 绘制矩形
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint point = CGPointZero;
    int index = 0;

    CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
    // 把点转换为不可变字典
    // 把字典转换为点，存在point里，成功返回true 其他false
    CGPointMakeWithDictionaryRepresentation(dict, &point);

    CGSize size = [UIScreen mainScreen].bounds.size;
    
    // 设置起点
    CGPoint newPoint = CGPointMake(point.y * size.width, point.x *size.height);
    [path moveToPoint:newPoint];
    NSLog(@"X:%f -- Y:%f",point.x,point.y);

    // 2.2连接其它线段
    for (int i = 1; i<array.count; i++) {
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[i], &point);
        newPoint = CGPointMake(point.y * size.width , point.x * size.height);
        [path addLineToPoint:newPoint];
        NSLog(@"X:%f -- Y:%f",point.x,point.y);
    }
    // 2.3关闭路径
    [path closePath];
    self.layer.path = path.CGPath;
    [self.layer setNeedsDisplay];
    // 3.将用于保存矩形的图层添加到界面上
    
    [self.view.layer addSublayer:self.layer];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    QRScanView *scan = [QRScanView scanViewWidthFrame:self.view.bounds scanDelegate:self];
    scan.fullScreenScan = YES;
    [self.view addSubview:scan];
    [scan startQRScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

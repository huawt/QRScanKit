//
//  QRViewController.m
//  QRScanKit
//
//  Created by huawentao on 07/26/2019.
//  Copyright (c) 2019 huawentao. All rights reserved.
//

#import "QRViewController.h"
#import <QRScanKit/QRScanKit.h>

@interface QRViewController ()

@end

@implementation QRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    QRScanView *scan = [QRScanView scanViewWidthFrame:self.view.bounds scanDelegate:nil];
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

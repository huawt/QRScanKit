
#import "QRScanView.h"
#import "QRScanLEDControl.h"
#import "QRScanLanguage.h"
#import <LRTools/LRToos.h>

#define kIPhone5 (CGRectGetHeight([UIScreen mainScreen].bounds) - 568 ? NO : YES)
#define kKDeviceWidth [UIScreen mainScreen].bounds.size.width
#define kKDeviceHeight [UIScreen mainScreen].bounds.size.height

#define kCaptureWidth (kKDeviceWidth - 90)

#define fx ((kKDeviceWidth - fw) / 2)
#define fy (kKDeviceHeight / 2.0 - kCaptureWidth / 2.0)
#define fw (kCaptureWidth * (kIPhone5 ? 0.8 : 1))
#define fh (kCaptureWidth * (kIPhone5 ? 0.8 : 1))
#define kScanRayH 47

#define kFlashTopSpace (25 * (kIPhone5 ? 0.6 : 1))

#define kScanWindowX (fx - 2)
#define kScanWindowY (fy - 2)
#define kScanWindowW (fw + 4)
#define kScanWindowH (fh + 4)


@interface QRScanView ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) id<QRScanViewDelegate>delegate;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewlayer;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureSession * session;

@end

@implementation QRScanView

- (void)dealloc
{
    [self stopQRScan];
}

+ (BOOL)checkSupportScan
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    return input != nil;
}

+ (instancetype)scanViewWidthFrame:(CGRect)frame scanDelegate:(id<QRScanViewDelegate>)delegate
{
    QRScanView *scanView = [[QRScanView alloc] initWithFrame:frame];
    scanView.delegate = delegate;
    return scanView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self configure];
    }
    return self;
}

- (void)configure
{
    [self configureUI];
    [self configureScan];
    [self configureObserver];
}

- (void)configureUI
{
    [self addSubview:self.flashlightBtn];
    [self addSubview:self.remindBtn];
}

- (void)ledControl:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [[QRScanLEDControl control] turnTorchOn:!btn.isSelected completeBlock:^(BOOL isOn) {
        [btn setSelected:isOn];
    }];
}


- (void)configureScan
{
    // 1.判断是否能够将输入添加到会话中
    if (![self.session canAddInput:self.input]) {
        return;
    }
    // 2.判断是否能够将输出添加到会话中
    if (![self.session canAddOutput:self.output]) {
        return;
    }
    
    // 3.将输入和输出都添加到会话中
    [self.session addInput:self.input];
    [self.session addOutput:self.output];
    
    //设置扫码的范围
    [self.output setRectOfInterest:CGRectMake(fy / self.frame.size.height, fx / kKDeviceWidth, fh / self.frame.size.height, fw / kKDeviceWidth)];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,//二维码
                                        AVMetadataObjectTypeEAN13Code,//我国商品码主要就是这和 EAN8 必须是12数字
                                        AVMetadataObjectTypeEAN8Code,//必须是7位或者8位数字
                                        AVMetadataObjectTypeUPCECode,//据说用于美国部分地区的条码 长度必须是6位或者11位
                                        AVMetadataObjectTypeCode39Code,//一种字母和简单的字符共三十九个字符组成的条形码
                                        AVMetadataObjectTypeCode39Mod43Code,//是上面的一种扩展
                                        AVMetadataObjectTypeCode93Code,// 据听说是 Code39升级版
                                        AVMetadataObjectTypeCode128Code,//包含字母数字所有字符 包含三个表格更好的对数据进行编码
                                        AVMetadataObjectTypePDF417Code,//也是一种二维码
                                        AVMetadataObjectTypeAztecCode,// Aztec这个也是一种二维码的制式，主要用于航空
                                        AVMetadataObjectTypeInterleaved2of5Code,//类型二进五出码 条形码 查到好像是偶数位的条码  只支持数字 最长10位
                                        AVMetadataObjectTypeITF14Code,//全球贸易货号。主要用于运输方面的条形码。iOS8以后才支持
                                        AVMetadataObjectTypeDataMatrixCode];// 又是一种二维码制式
    
    
    [self configCaputreWindow];
}

- (void)configCaputreWindow
{
    if (self.fullScreenScan == NO) {
        if (!self.capturelayer.superlayer) {
            [self.layer addSublayer:self.capturelayer];
        }
        if (!self.raylayer.superlayer) {
            [self.capturelayer addSublayer:self.raylayer];
        }
    }else{
        if (self.capturelayer.superlayer) {
            [self.capturelayer removeFromSuperlayer];
        }
        if (self.raylayer.superlayer) {
            [self.raylayer removeFromSuperlayer];
        }
    }
    if (!self.previewlayer.superlayer) {
        [self.layer insertSublayer:self.previewlayer atIndex:0];
    }
}

- (void)configureObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidEnterBackgroundHandler:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)DidEnterBackgroundHandler:(NSNotification *)notification
{
    [self stopQRScan];
}

- (void)setShowLEDButton:(BOOL)showLEDButton
{
    _showLEDButton = showLEDButton;
    self.flashlightBtn.hidden = !_showLEDButton;
}

- (void)setShowScanRemind:(BOOL)showScanRemind{
    _showScanRemind = showScanRemind;
    self.remindBtn.hidden = !_showScanRemind;
}

- (void)setFullScreenScan:(BOOL)fullScreenScan{
    _fullScreenScan = fullScreenScan;
    [self configCaputreWindow];
    [self fixPreviewOpacity];
    [self configRectofInterest];
}

- (void)configRectofInterest{
    if (self.fullScreenScan) {
        [self.output setRectOfInterest:CGRectMake(0, 0, 1, 1)];
    }else{
        [self.output setRectOfInterest:CGRectMake(fy / self.frame.size.height, fx / kKDeviceWidth, fh / self.frame.size.height, fw / kKDeviceWidth)];
    }
}

#pragma mark - 扫描

- (void)startQRScan
{
    [self checkCameraAuthorization];
}

- (void)checkCameraAuthorization
{
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ScanLocalizedString(@"未获得授权使用摄像头") message:ScanLocalizedString(@"请在\"设置\"－\"隐私\"－\"相机\"中开启摄像头使用授权") preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *setting = [UIAlertAction actionWithTitle:ScanLocalizedString(@"设置") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(QRScanNoAuthorizationGoSetting)]) {
                [weakSelf.delegate QRScanNoAuthorizationGoSetting];
            }else{
                NSURL *setting = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:setting]) {
                    [[UIApplication sharedApplication] openURL:setting];
                }
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:ScanLocalizedString(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(QRScanNoAuthorizationGoBack)]) {
                [weakSelf.delegate QRScanNoAuthorizationGoBack];
            }else{
                
            }
        }];
        
        [alertController addAction:setting];
        [alertController addAction:cancel];
        
        UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        if (![viewController isKindOfClass:[UIAlertController class]]) {
            [viewController presentAlertViewController:alertController];
        } 
    }else {
        [self start];
    }
}

- (void)start
{
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
    if (self.fullScreenScan == NO) {
        [self startMoveScanLayer];
    }
}

- (void)stopQRScan
{
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
    [self stopMoveScanLayer];
    [self turnOffTheFlashlight];
}

- (void)turnOffTheFlashlight
{
    [[QRScanLEDControl control] turnTorchOn:NO completeBlock:^(BOOL isOn) {
        [self.flashlightBtn setSelected:isOn];
    }];
}

- (void)stopMoveScanLayer
{
    [self.raylayer removeAllAnimations];
    self.raylayer.position = CGPointMake(kScanWindowW / 2, 4);
}
- (void)startMoveScanLayer
{
    CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animate.fromValue = @(4);
    animate.toValue = @(kScanWindowH - 4);
    animate.duration = 3;
    animate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animate.repeatCount = NSIntegerMax;
    animate.removedOnCompletion = NO;
    [self.raylayer addAnimation:animate forKey:nil];
}

- (void)checkLED
{
    self.flashlightBtn.selected = [QRScanLEDControl control].torchIsOn;
}

#pragma mark - 扫描结果

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        if (self.delegate && [self.delegate respondsToSelector:@selector(QRScanMetadataObjectByScan:)]) {
            [self.delegate QRScanMetadataObjectByScan:metadataObject];
        }
    }
}

#pragma mark - 配置

- (AVCaptureDevice *)device
{
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [_device lockForConfiguration:nil];
        if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        if ([_device isAutoFocusRangeRestrictionSupported]) {
            [_device setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNone];
        }
        if ([_device isSmoothAutoFocusSupported]) {
            [_device setSmoothAutoFocusEnabled:YES];
        }
        [_device unlockForConfiguration];
    }
    return _device;
}
- (AVCaptureDeviceInput *)input
{
    if (!_input) {
        NSError *error = nil;
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    }
    return _input;
}
- (AVCaptureMetadataOutput *)output
{
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc]init];
        //设置代理
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _output;
}
- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
        //高质量采集率 AVCaptureSessionPreset1920x1080  AVCaptureSessionPresetHigh
        if ([self.device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [_session setSessionPreset:AVCaptureSessionPreset1920x1080];
        }else{
            [_session setSessionPreset:AVCaptureSessionPresetHigh];
        }
    }
    return _session;
}
- (CALayer *)capturelayer
{
    if (!_capturelayer) {
        _capturelayer = [CALayer layer];
        _capturelayer.masksToBounds = YES;
        _capturelayer.bounds = CGRectMake(0, 0, kScanWindowW, 0);
        _capturelayer.position = self.center;
        _capturelayer.contents = (id)[UIImage imageNamed:@"ScanResource.bundle/scan_capture"].CGImage;
        _capturelayer.frame = CGRectMake(kScanWindowX, kScanWindowY, kScanWindowW, kScanWindowH);
    }
    return _capturelayer;
}
- (CALayer *)raylayer
{
    if (!_raylayer) {
        _raylayer = [CALayer layer];
        _raylayer.frame = CGRectMake(4, 4, kScanWindowW - 8, 2);
        _raylayer.contents = (id)[UIImage imageNamed:@"ScanResource.bundle/scan_ray"].CGImage;
    }
    return _raylayer;
}

- (AVCaptureVideoPreviewLayer *)previewlayer
{
    if (!_previewlayer) {
        _previewlayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewlayer.frame = self.bounds;
        [self fixPreviewOpacity];
    }
    
    return _previewlayer;
}

- (void)fixPreviewOpacity
{
    for (UIView *subView in self.subviews) {
        if (subView.tag > 100 && subView .tag< 105) {
            [subView removeFromSuperview];
        }
    }
    
    if (self.fullScreenScan == YES) {
        return;
    }
    
    UIView *topLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kKDeviceWidth, fy)];
    topLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    topLayer.tag = 101;
    [self insertSubview:topLayer atIndex:0];
    
    UIView *leftLayer = [[UIView alloc] initWithFrame:CGRectMake(0, fy, fx, fh)];
    leftLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    leftLayer.tag = 102;
    [self insertSubview:leftLayer atIndex:0];
    
    UIView *rightLayer = [[UIView alloc] initWithFrame:CGRectMake(kKDeviceWidth - fx, fy, fx, fh)];
    rightLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    rightLayer.tag = 103;
    [self insertSubview:rightLayer atIndex:0];
    
    CGFloat preLayerHeight = self.previewlayer.frame.size.height;
    UIView *bottomLayer = [[UIView alloc] initWithFrame:CGRectMake(0, fy + fh, kKDeviceWidth, preLayerHeight - fy - fh)];
    bottomLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
    bottomLayer.tag = 104;
    [self insertSubview:bottomLayer atIndex:0];
}

- (UIButton *)flashlightBtn
{
    if (!_flashlightBtn) {
        _flashlightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashlightBtn.frame = CGRectMake((kKDeviceWidth - 60) / 2, fy + fh + kFlashTopSpace, 60, 60);
        [_flashlightBtn setImage:[UIImage imageNamed:@"ScanResource.bundle/手电筒"] forState:UIControlStateNormal];
        [_flashlightBtn setImage:[UIImage imageNamed:@"ScanResource.bundle/手电筒-已开启"] forState:UIControlStateSelected];
        [_flashlightBtn addTarget:self action:@selector(ledControl:) forControlEvents:UIControlEventTouchUpInside];
        _flashlightBtn.selected = [QRScanLEDControl control].torchIsOn;
    }
    return _flashlightBtn;
}

- (UIButton *)remindBtn
{
    if (!_remindBtn) {
        _remindBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _remindBtn.frame = CGRectMake((kKDeviceWidth - 170) / 2, fy / 2 -13, 170, 26);
        [_remindBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _remindBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        UIImage *bgImage = [[UIImage imageNamed:@"ScanResource.bundle/扫一扫-圆角矩形"] stretchableImageWithLeftCapWidth:50 topCapHeight:13];
        [_remindBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
        [_remindBtn setTitle:ScanLocalizedString(@"请对准二维码/条形码") forState:UIControlStateNormal];
    }
    return _remindBtn;
}

@end

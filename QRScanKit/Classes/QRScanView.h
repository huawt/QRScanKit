
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "QRCaptureLayer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QRScanViewDelegate <NSObject>

@optional
/**
 扫描出结果，自动停止扫描

 @param metadataObj 元数据
 */
- (void)QRScanMetadataObjectByScan:(AVMetadataMachineReadableCodeObject *)metadataObj;

/**
 无摄像头权限
 */
- (void)QRScanNoAuthorizationGoSetting;
/**
 无摄像头权限
 */
- (void)QRScanNoAuthorizationGoBack;

@end


/**
 扫描视图
 */
@interface QRScanView : UIView

/// 扫码小窗
@property (nonatomic, strong) QRCaptureLayer *capturelayer;
/// 扫描线
@property (nonatomic, strong) CALayer *raylayer;
/// 闪光灯
@property (nonatomic, strong) UIButton *flashlightBtn;
/// 提醒
@property (nonatomic, strong) UIButton *remindBtn;

/**
 是否显示闪光灯按钮
 */
@property (nonatomic, assign) BOOL showLEDButton;
/**
扫描类型 小窗 还是全屏
*/
@property (nonatomic, assign) BOOL fullScreenScan;
/**
是否显示 对准提醒
*/
@property (nonatomic, assign) BOOL showScanRemind;
/**
是否显示 扫描框
*/
@property (nonatomic, assign) BOOL showScanWindow;

/**
 生成扫描视图
 */
+ (instancetype)scanViewWidthFrame:(CGRect)frame scanDelegate:(id<QRScanViewDelegate>)delegate;

/// 检查是否支持扫码
+ (BOOL)checkSupportScan;

/**
 开始扫描
 */
- (void)startQRScan;

/**
 停止扫描
 */
- (void)stopQRScan;

/**
 检查闪光灯
 */
- (void)checkLED;

@end

NS_ASSUME_NONNULL_END

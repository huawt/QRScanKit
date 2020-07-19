
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QRScanResultModel;

/**
 二维码结果展示框
 */
@interface QRCodeAlertWindow : UIView

/**
 自己处理扫描出来的 url,请实现改 block
 */
@property(nonatomic, copy) void(^openUrl)(NSString *url);

/**
 关闭时需要处理,请实现改 block
 */
@property(nonatomic, copy) void(^closeWindow)(void);

/**
  显示扫描结果
 */
- (void)showQRResult:(QRScanResultModel *)resultModel;

@end

NS_ASSUME_NONNULL_END

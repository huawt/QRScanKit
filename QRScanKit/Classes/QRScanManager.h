
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QRScanResultModel;

/**
 二维码结果处理器
 */
@interface QRScanManager : NSObject

/**
 输入指定内容和大小，生成二维码图片
 */
+ (UIImage *)generalQRImage:(NSString *)string width:(CGFloat)width;

/**
 识别图片中的二维码
 */
+ (QRScanResultModel *)scanResultByImage:(UIImage *)image;

/**
 识别扫描出来的二维码
 */
+ (QRScanResultModel *)scanResultByMetadataObject:(AVMetadataMachineReadableCodeObject *)metadataObj;

/**
 访问相册得出结果 -- @"由于图片选择器的使用不同,顾废弃该方法"
 */
//+ (void)scanResultByLocalAlbumFrom:(UIViewController *)viewController finished:(void(^)(UIImage *image, QRScanResultModel *resultModel))finishHandler ;


@end

NS_ASSUME_NONNULL_END

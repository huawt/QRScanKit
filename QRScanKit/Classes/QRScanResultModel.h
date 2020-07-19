
#import <Foundation/Foundation.h>

/**
 扫描结果类型

 - QRScanResultType_None: 无结果
 - QRScanResultType_QRCodeType: 二维码
 - QRScanResultType_BarCodeType: 条形码
 */
typedef NS_OPTIONS(NSInteger, QRScanResultType) {
    QRScanResultType_None = 1,
    QRScanResultType_QRCodeType = 1 << 1,
    QRScanResultType_BarCodeType = 1 << 2
};



NS_ASSUME_NONNULL_BEGIN

/**
 扫描结果模型
 */
@interface QRScanResultModel : NSObject

/**
 码类型
 */
@property (nonatomic, assign) QRScanResultType resultType;

/**
 结果字符串
 */
@property (nonatomic, copy) NSString *resultString;

/**
 是否是多个码共存
 */
@property (nonatomic, assign) BOOL isMultipleResult;

@end

NS_ASSUME_NONNULL_END


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DidClickQRLinkBlock)(NSString *linkValue);

/**
 富文本 Label
 */
@interface QRScanRichLabel : UILabel

/**
 如果存在 url, 实现该 block,处理链接
 */
@property (nonatomic, copy) DidClickQRLinkBlock clickBlock;

/**
 扫描结果字符串, 也可设置 text
 */
@property (nonatomic, copy) NSString *qrResultString;

@end

NS_ASSUME_NONNULL_END


#import <Foundation/Foundation.h>

/**
 控制闪光灯后,返回最终状态
 */
typedef void(^turnTorcBlock)(BOOL isOn);

/**
 闪光灯控制
 */
@interface QRScanLEDControl : NSObject

/**
 是否开启闪光灯
 */
@property (nonatomic, assign, readonly) BOOL torchIsOn;

/**
 单例
 */
+ (instancetype)control;

/**
 切换闪光灯 启动状态
 */
- (void)turnTorchOn:(bool)on completeBlock:(turnTorcBlock) block;
@end

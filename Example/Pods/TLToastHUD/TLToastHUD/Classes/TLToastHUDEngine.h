
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 弹框配置引擎
 */
@interface TLToastHUDEngine : NSObject

/**
 配置 HUD 的图片数组
 */
+ (void)configProcessHUDImages:(NSArray *)images;

/**
 获取 HUD 的图片数组
 */
+ (NSArray *)getProcessHUDImages;
@end

NS_ASSUME_NONNULL_END


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 NSBundle分类, 多语言使用
 */
@interface NSBundle (QRScan)

/**
 QRScanKit 所在的 Bundle
 */
+ (instancetype)scanKitBundle;

/**
 多语言字符
 */
+ (NSString *)scanKit_localizedStringForKey:(NSString *)key;
/**
 多语言字符
 */
+ (NSString *)scanKit_localizedStringForKey:(NSString *)key value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END

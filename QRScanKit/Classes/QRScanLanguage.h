
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 语言类型

 - Language_Chinese: 中文
 - Language_English: 英文
 */
typedef NS_OPTIONS(NSInteger, ScanLanguageType) {
    Language_Chinese = 1,
    Language_English = 1 << 1,
};

/**
 语言切换
 */
@interface QRScanLanguage : NSObject

/**
 根据主 App 控制当前语言 - 不设置跟随系统
 */
+ (void)configCurrentLanguage:(ScanLanguageType)language;

/**
 快捷获取对应多语言
 */
NSString *ScanLocalizedString(NSString *key);

/**
 如果自己有多语言文件,可以在这里设置,需要实现 ScanResource.bundle 文件里的多语言key
 */
+ (void)configLocalizedString:(NSString *)stringsDocPath table:(NSString *)table language:(ScanLanguageType)language;

@end

NS_ASSUME_NONNULL_END

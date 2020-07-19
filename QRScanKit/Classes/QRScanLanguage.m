
#import "QRScanLanguage.h"
#import "NSBundle+QRScan.h"

@interface QRScanLanguage ()
@property (nonatomic, assign) ScanLanguageType currentLanguage;
@property (nonatomic, strong) NSMutableDictionary *languageDictionary;
@end

@implementation QRScanLanguage

+ (instancetype)sharedManager
{
    static dispatch_once_t __singletonToken;
    static id __singleton__;
    dispatch_once( &__singletonToken, ^{ __singleton__ = [[self alloc] initPrivate]; } );
    return __singleton__;
}
- (instancetype)init
{
    NSAssert(NO, @"");
    return nil;
}
- (instancetype)initPrivate
{
    if (self = [super init]) {
        _currentLanguage = Language_Chinese;
        _languageDictionary = @{}.mutableCopy;
    }
    return self;
}
NSString *ScanLocalizedString(NSString *key){
    NSDictionary *languageDic = [QRScanLanguage sharedManager].languageDictionary;
    if ([languageDic count]) {
        NSDictionary *dicitonary = [languageDic objectForKey:@([QRScanLanguage sharedManager].currentLanguage).stringValue];
        if (dicitonary) {
            NSString *documentPath = [dicitonary objectForKey:@"path"];
            NSString *table = [dicitonary objectForKey:@"table"];
            NSString *value = [[NSBundle bundleWithPath:documentPath] localizedStringForKey:key value:key table:table];
            return value;
        }else{
            return [QRScanLanguage scanLocalizedString:key];
        }
    }else{
        return [QRScanLanguage scanLocalizedString:key];
    }
}

+ (NSString *)scanLocalizedString:(NSString *)key
{
    return [NSBundle scanKit_localizedStringForKey:key];
}

+ (void)configCurrentLanguage:(ScanLanguageType)language
{
    [QRScanLanguage sharedManager].currentLanguage = language;
}

+ (void)configLocalizedString:(NSString *)stringsDocPath table:(NSString *)table  language:(ScanLanguageType)language
{
    BOOL checkPath = stringsDocPath && [stringsDocPath isKindOfClass:[NSString class]] && [stringsDocPath length];
    BOOL checkTable = table && [table isKindOfClass:[NSString class]] && [table length];
    if (checkPath && checkTable) {
        NSDictionary *dicitonary  = @{@"path": stringsDocPath, @"table": table};
        [[QRScanLanguage sharedManager].languageDictionary setObject:dicitonary forKey:@(language).stringValue];
    }
}


@end

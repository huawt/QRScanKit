
#import "NSBundle+QRScan.h"
#import "QRScanView.h"

NSString *const QRScanKitStrings = @"QRScanKitStrings";

@implementation NSBundle (QRScan)

+ (instancetype)scanKitBundle
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[QRScanView class]] pathForResource:@"ScanResource" ofType:@"bundle"]];
    }
    return bundle;
}

+ (NSString *)scanKit_localizedStringForKey:(NSString *)key
{
    return [self scanKit_localizedStringForKey:key value:nil];
}

+ (NSString *)scanKit_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    value = [[self scanKitBundle] localizedStringForKey:key value:value table:QRScanKitStrings];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:QRScanKitStrings];
}


@end

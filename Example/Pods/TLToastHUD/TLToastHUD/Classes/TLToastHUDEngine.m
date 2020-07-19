
#import "TLToastHUDEngine.h"

@interface TLToastHUDEngine ()
@property (nonatomic, strong) NSArray *images;
@end

@implementation TLToastHUDEngine

+ (instancetype)shareEngine
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
        
    }
    return self;
}

+ (void)configProcessHUDImages:(NSArray *)images
{
    [TLToastHUDEngine shareEngine].images = images;
}
+ (NSArray *)getProcessHUDImages
{
    return [TLToastHUDEngine shareEngine].images;
}
@end

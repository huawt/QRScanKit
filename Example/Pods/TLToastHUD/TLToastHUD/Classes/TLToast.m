
#import "TLToast.h"
#import "TLAlertView.h"
#import "TLToastHeader.h"

double const kWebJSShowToastDefaultDuration = 1.5;

@implementation TLToast

+ (void)showToast:(NSString *)toast duration:(NSTimeInterval)duration completion:(void (^)(BOOL))completion
{
    if (!toast || ![toast length] || duration < 0) {
        if (completion) {
            completion(NO);
        }
    }else{
        BOOL isP = NO;
        for (UIView * iv in [UIApplication sharedApplication].keyWindow.subviews) {
            if ([iv isKindOfClass:[TLAlertView class]]) {
                isP = YES;
            }
        }
        if(!isP){
            TLAlertView *sAlert = [[TLAlertView alloc] initWithFrame:CGRectMake((kTLSWidth - 170) / 2.0, kTLSHeight / 2.0 - 110.0, 170, 80) text:toast];
            [[UIApplication sharedApplication].delegate.window addSubview:sAlert];
            [sAlert show:duration];
            !completion?:completion(YES);
        }
    }
}

@end

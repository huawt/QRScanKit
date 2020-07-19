
#import <UIKit/UIKit.h>

extern NSString * const kTLProcessHUDDefaultStatus;

@interface TLProcessHUD : UIView
+ (void)showWithStatus:(NSString *)status on:(UIView *)superview autoDismissDelay:(double)delay completion:(void(^)(BOOL success))handler;
+ (void)dismissOn:(UIView *)superview;
+ (void)dismissAllOn:(UIView *)superview;
@end

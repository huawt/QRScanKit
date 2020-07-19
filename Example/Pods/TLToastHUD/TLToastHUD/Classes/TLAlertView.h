
#import <UIKit/UIKit.h>

/**
 Toast提示
 */
@interface TLAlertView : UIImageView

+ (TLAlertView *)showOnView:(UIView *)superView toast:(NSString *)toast delay:(NSTimeInterval)delayTime;

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)content;
- (void)show;
- (void)show:(NSTimeInterval)delaytimeHideView;
- (void)hide;

@end

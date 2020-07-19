
#import <UIKit/UIKit.h>

@interface UIViewController (AlertPresented) <UIPopoverPresentationControllerDelegate>

- (void)popOverToViewController:(UIViewController *)viewController;
- (void)removeBlurEffect;

@end

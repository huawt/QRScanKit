
#import <UIKit/UIKit.h>

@interface UIViewController (AlertPresented) <UIPopoverPresentationControllerDelegate>

- (void)presentAlertViewController:(UIViewController *)viewController;
- (void)removeBlurEffect;

@end

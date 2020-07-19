
#import <Foundation/Foundation.h>

extern double const kWebJSShowToastDefaultDuration;

/**
 提示框
 */
@interface TLToast : NSObject
+ (void)showToast:(nonnull NSString *)toast duration:(NSTimeInterval)duration completion:(void(^)(BOOL success))completion;
@end

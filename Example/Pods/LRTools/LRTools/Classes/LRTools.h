

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __has_include(<LRToos/LRToos.h>)

FOUNDATION_EXPORT double LRToolsVersionNumber;
FOUNDATION_EXPORT const unsigned char LRToolsVersionString[];

#import <LRTools/UIViewController+AlertPresented.h>
#import <LRTools/NSString+Addtionss.h>
#import <LRTools/UIViewController+DismissKeyboard.h>
#import <LRTools/UIButton+Vertical.h>

#else

#import "UIViewController+AlertPresented.h"
#import "NSString+Addtionss.h"
#import "UIViewController+DismissKeyboard.h"
#import "UIButton+Vertical.h"

#endif

@interface LRTools : NSObject

+ (UIViewController *)getCurrentViewController;

@end

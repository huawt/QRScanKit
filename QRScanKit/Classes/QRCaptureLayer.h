
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRCaptureLayer : CALayer

@property (nonatomic, assign) BOOL isFullScreen;

- (void)configureCaptureContents:(UIImage *)image rect:(CGRect)contentRect;

@end

NS_ASSUME_NONNULL_END

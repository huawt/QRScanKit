
#import "QRCaptureLayer.h"

@interface QRCaptureLayer ()

@property (nonatomic, strong) CALayer *captureLayer;

@end

@implementation QRCaptureLayer

- (instancetype)init{
    if (self = [super init]) {
        [self addSublayer:self.captureLayer];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)configureCaptureContents:(UIImage *)image rect:(CGRect)contentRect{
    if (!image) {
        return;
    }
    self.captureLayer.contents =  (id)image.CGImage;
    self.captureLayer.frame = contentRect;
    [self setNeedsDisplay];
}

- (void)setIsFullScreen:(BOOL)isFullScreen{
    _isFullScreen = isFullScreen;
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx{

    if (self.isFullScreen) {
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 0);
        CGContextFillRect(ctx, self.bounds);
        return;
    }
    
    //非扫码区域半透明
    {
        //设置非识别区域颜色
        
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.3f);

        CGRect capRect = self.captureLayer.frame;
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        //扫码区域上面填充
        CGRect rect = CGRectMake(0, 0, width, capRect.origin.y);
        CGContextFillRect(ctx, rect);
        
        //扫码区域左边填充
        rect = CGRectMake(0, capRect.origin.y, capRect.origin.x, capRect.size.height);
        CGContextFillRect(ctx, rect);
        
        //扫码区域右边填充
        rect = CGRectMake(width - capRect.origin.x, capRect.origin.y, capRect.origin.x, capRect.size.height);
        CGContextFillRect(ctx, rect);
        
        //扫码区域下面填充
        rect = CGRectMake(0, capRect.origin.y + capRect.size.height, width, height - capRect.origin.y - capRect.size.height);
        CGContextFillRect(ctx, rect);
    }
}

- (CALayer *)captureLayer
{
    if (!_captureLayer) {
        _captureLayer = [CALayer layer];
        _captureLayer.masksToBounds = YES;
    }
    return _captureLayer;
}

@end

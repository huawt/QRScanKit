
#import "TLAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Masonry/Masonry.h>
#import "TLToastHeader.h"

@interface TLAlertView ()
@property (strong,nonatomic) UILabel *contentLabel;
@end

@implementation TLAlertView

+ (TLAlertView *)showOnView:(UIView *)superView toast:(NSString *)toast delay:(NSTimeInterval)delayTime
{
    TLAlertView *alert = [[TLAlertView alloc] initWithFrame:CGRectMake((kTLSWidth - 170) / 2.0, kTLSHeight / 2.0 - 110.0, 170, 80) text:toast];
    [superView addSubview:alert];
    
    if (delayTime > 0) {
        [alert show:delayTime];
    }else{
        [alert show];
    }

    return alert;
}

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)content
{
    frame = CGRectMake(0, 0, kTLSWidth - 160, 30);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
        self.layer.cornerRadius = 10;

        if (content) {
            _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0,10.0, 200, 20)];
            _contentLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
            _contentLabel.numberOfLines = 0;
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.textColor = [UIColor whiteColor];
            
            NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:content];
            NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle1 setLineSpacing:7];

            [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [content length])];
            [_contentLabel setAttributedText:attributedString1];
            
            //先把大小计算出来，自动布局只布局位置
            CGSize size = [_contentLabel sizeThatFits:CGSizeMake(200, kTLSHeight - 100)];
            if(size.height < 25){
                [paragraphStyle1 setLineSpacing:0];
                size.height = 15;
            }
            CGRect frame = _contentLabel.frame;
            frame.size = size;
            _contentLabel.frame= frame;
            
            _contentLabel.textAlignment = NSTextAlignmentCenter;

            [self addSubview:_contentLabel];
        }
    }
    return self;
}

- (void)show
{
    UIView *superView = self.superview;
    
    if(superView != nil){
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(superView.mas_centerX);
            make.centerY.equalTo(superView.mas_centerY).offset(-100);
            make.left.equalTo(self.contentLabel.mas_left).offset(-10);
            make.right.equalTo(self.contentLabel.mas_right).offset(10);
            make.top.equalTo(self.contentLabel.mas_top).offset(-10);
            make.bottom.equalTo(self.contentLabel.mas_bottom).offset(10);
        }];
        
    }
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_lessThanOrEqualTo(200);
        make.centerY.equalTo(self.mas_centerY).priority(100);
    }];
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.6;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    self.alpha = 1;
    
    [self.layer addAnimation:popAnimation forKey:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(hide) withObject:nil afterDelay:1.5];
    });

}

- (void)show:(NSTimeInterval)delaytimeHideView
{
    UIView *superView = self.superview;
    if(superView != nil){
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(superView.mas_centerX);
            make.centerY.equalTo(superView.mas_centerY).offset(-100);
            make.left.equalTo(self.contentLabel.mas_left).offset(-10);
            make.right.equalTo(self.contentLabel.mas_right).offset(10);
            make.top.equalTo(self.contentLabel.mas_top).offset(-10);
            make.bottom.equalTo(self.contentLabel.mas_bottom).offset(10);
        }];
        
    }
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_lessThanOrEqualTo(200);
        make.centerY.equalTo(self.mas_centerY).priority(100);
    }];

    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.6;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    self.alpha = 1;
    
    [self.layer addAnimation:popAnimation forKey:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(hide) withObject:nil afterDelay:delaytimeHideView];
    });
    
}

- (void)hide
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    //NSLog(@"animationDidStop");
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

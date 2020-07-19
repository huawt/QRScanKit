
#import "TLProcessHUD.h"
#import <Masonry/Masonry.h>
#import "TLToastHUDEngine.h"

NSString * const kTLProcessHUDDefaultStatus = @"加载中···";

@interface TLProcessHUD ()

@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSArray *images;
@end

@implementation TLProcessHUD

- (instancetype)init
{
    if (self = [super init]) {
        [self configSubViews];
    }
    return self;
}

- (NSArray *)images
{
    return [TLToastHUDEngine getProcessHUDImages];
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.hidden = YES;
    }
    return _indicatorView;
}

- (UIView *)centerView
{
    if (!_centerView) {
        _centerView = [[UIView alloc] init];
        _centerView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.4];
        _centerView.layer.cornerRadius = 5.0;
    }
    return _centerView;
}
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.animationDuration = 0.7;
        _imageView.animationRepeatCount = 0;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}
- (UILabel *)statusLabel
{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.font = [UIFont systemFontOfSize:12.0f];
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _statusLabel;
}
- (void)configSubViews
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    [self addSubview:self.centerView];
    [self.centerView addSubview:self.imageView];
    [self.imageView addSubview:self.indicatorView];
    [self.centerView addSubview:self.statusLabel];

    [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        if ([self isiPhoneX]) {
            make.centerY.equalTo(self).offset(-44);
        }else{
            make.centerY.equalTo(self).offset(-32);
        }
        make.width.height.mas_equalTo(100);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(80);
        make.centerX.equalTo(self.centerView);
        make.centerY.equalTo(self.centerView).offset(-10);
    }];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.imageView);
        make.width.height.equalTo(self.imageView);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.centerView);
        make.height.mas_equalTo(30);
    }];
}

- (BOOL)isiPhoneX
{
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        if (window.safeAreaInsets.left > 0 || window.safeAreaInsets.bottom > 0) {
            return YES;
        }
    }
    return NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.statusLabel.isHidden) {
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.centerView);
            make.width.height.mas_equalTo(80);
        }];
    }else{
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(80);
            make.centerX.equalTo(self.centerView);
            make.centerY.equalTo(self.centerView).offset(-10);
        }];
        [self.statusLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.centerView);
            make.height.mas_equalTo(30);
        }];
    }
}
+ (void)showWithStatus:(NSString *)status on:(UIView *)superview autoDismissDelay:(double)delay completion:(void (^)(BOOL))handler
{
    if (!superview || ![superview isKindOfClass:[UIView class]]) {
        if (handler) {
            handler(NO);
        }
        return;
    }

    for (UIView *subView in superview.subviews) {
        if ([subView isKindOfClass:[TLProcessHUD class]]) {
            if (handler) {
                handler(YES);
            }
            return;
        }
    }
    TLProcessHUD *hud = [[TLProcessHUD alloc] init];
    [hud configureWithStatus:status];
    [superview addSubview:hud];
    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(hud.superview);
    }];
    [hud startRun];
    if (handler) {
        handler(YES);
    }
    if (delay > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissOn:superview hud:hud];
        });
    }
}



+ (void)dismissOn:(UIView*)superview
{
    [self dismissOn:superview hud:nil];
}

+ (void)dismissAllOn:(UIView *)superview
{
    if (!superview || ![superview isKindOfClass:[UIView class]]) {
        return;
    }
    NSMutableArray *hudArr = @[].mutableCopy;
    for (UIView *subview in superview.subviews) {
        if ([subview isKindOfClass:[TLProcessHUD class]]) {
            [(TLProcessHUD *)subview stopRun];
            [hudArr addObject:subview];
        }
    }
    [hudArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
    hudArr = nil;
}

+ (void)dismissOn:(UIView *)superview hud:(TLProcessHUD *)hud {
    if (!superview || ![superview isKindOfClass:[UIView class]]) {
        return;
    }
    for (UIView *subview in superview.subviews) {
        if ([subview isKindOfClass:[TLProcessHUD class]]) {
            if (hud && ![hud isEqual:subview]) {
                continue;
            }
            [(TLProcessHUD *)subview stopRun];
            [subview removeFromSuperview];
            break;
        }
    }
}

- (void)configureWithStatus:(NSString *)status
{
    if (self.images && self.images.count) {
        self.imageView.animationImages = self.images;
        self.indicatorView.hidden = YES;
    }else{
        self.indicatorView.hidden = NO;
    }
    if ([status length]) {
        self.statusLabel.hidden = NO;
        self.statusLabel.text = status;
    }else{
        self.statusLabel.hidden = YES;
        self.statusLabel.text = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)startRun {
    if (self.indicatorView.isHidden) {
        if (!self.imageView.isAnimating) {
            [self.imageView startAnimating];
        }
    }else{
        if (!self.indicatorView.isAnimating) {
            [self.indicatorView startAnimating];
        }
    }
}

- (void)stopRun {
    if (self.indicatorView.isHidden) {
        if (self.imageView.isAnimating) {
            [self.imageView stopAnimating];;
        }
    }else{
        if (self.indicatorView.isAnimating) {
            [self.indicatorView stopAnimating];
        }
    }
}

@end

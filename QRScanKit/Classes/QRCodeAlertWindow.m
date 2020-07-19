
#import "QRCodeAlertWindow.h"
#import "QRScanRichLabel.h"
#import "QRScanResultModel.h"
#import <Masonry/Masonry.h>
#import <TLToastHUD/TLToastHUD.h>
#import "QRScanLanguage.h"

@interface QRCodeAlertWindow()
@property(nonatomic, strong) UIButton *titleBtn;
@property(nonatomic, strong) UIButton *copybtn;
@property(nonatomic, strong) UIButton *closeBtn;

@property(nonatomic, strong) QRScanRichLabel *textBtn;

@property(nonatomic, strong) UIView *bgView;
@end

@implementation QRCodeAlertWindow

-(UIView *)bgView{
    if(!_bgView){
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_bgView];
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.8);
        }];
        
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

-(UIButton *)closeBtn{
    if(!_closeBtn)
    {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_closeBtn];
        
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.bgView.mas_bottom).offset(20);
        }];
        [_closeBtn addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setImage:[UIImage imageNamed:@"ScanResource.bundle/qrCodeClose"]  forState:UIControlStateNormal];
    }
    return _closeBtn;
}

-(UIButton *)titleBtn{
    if(!_titleBtn)
    {
        _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgView addSubview:_titleBtn];
        
        [_titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bgView);
            make.top.equalTo(self.bgView).offset(15);
        }];
        _titleBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_titleBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        _titleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3);
        _titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, -3);
    }
    return _titleBtn;
}

-(UIButton *)copybtn{
    if(!_copybtn)
    {
        _copybtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgView addSubview:_copybtn];
        
        [_copybtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bgView);
            make.height.mas_equalTo(46);
            make.bottom.equalTo(self.bgView.mas_bottom).offset(-20);
            make.left.equalTo(self.bgView).offset(30);
            make.right.equalTo(self.bgView).offset(-30);
        }];
        
        _copybtn.layer.cornerRadius = 23;
        _copybtn.layer.masksToBounds = YES;
        _copybtn.backgroundColor = [UIColor colorWithRed:250/255.0f green:80/255.0f blue:27/255.0f alpha:1];
        [_copybtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _copybtn.titleLabel.font = [UIFont systemFontOfSize:16];
        
        [_copybtn addTarget:self action:@selector(copytext) forControlEvents:UIControlEventTouchUpInside];
    }
    return _copybtn;
}

-(QRScanRichLabel *)textBtn{
    if(!_textBtn)
    {
        _textBtn = [[QRScanRichLabel alloc] init];
        _textBtn.numberOfLines = 0;
        [self.bgView addSubview:_textBtn];
        
        [_textBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bgView);
            make.top.equalTo(self.titleBtn.mas_bottom).offset(20);
            make.bottom.equalTo(self.copybtn.mas_top).offset(-30);
            make.left.equalTo(self.bgView).offset(30);
            make.right.equalTo(self.bgView).offset(-30);
        }];
    }
    return _textBtn;
}

- (void)showQRResult:(QRScanResultModel *)resultModel
{
    UIView *showView = [UIApplication sharedApplication].delegate.window;
    self.frame = showView.bounds;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [showView addSubview:self];
    
    [self.copybtn setTitle:ScanLocalizedString(@"复制") forState:UIControlStateNormal];
    self.closeBtn.hidden = NO;
    
    if(resultModel.resultType == QRScanResultType_QRCodeType)
    {
        [self.titleBtn setImage:[UIImage imageNamed:@"ScanResource.bundle/qrCodeImg"] forState:UIControlStateNormal];
        [self.titleBtn setTitle:ScanLocalizedString(@"二维码") forState:UIControlStateNormal];
    }
    else if(resultModel.resultType == QRScanResultType_BarCodeType){
        [self.titleBtn setImage:[UIImage imageNamed:@"ScanResource.bundle/barCodeImg"] forState:UIControlStateNormal];
        [self.titleBtn setTitle:ScanLocalizedString(@"条形码") forState:UIControlStateNormal];
    }
    
    self.textBtn.qrResultString = resultModel.resultString;
    __weak typeof(self) weakSelf = self;
    self.textBtn.clickBlock = ^(NSString * _Nonnull linkValue) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.openUrl) {
            strongSelf.openUrl(linkValue);
        }else{
            NSURL *url = [NSURL URLWithString:linkValue];
            if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }
    };
}

-(void) copytext
{
    if([self.textBtn.text length] > 0){
        UIPasteboard *pasteboard=[UIPasteboard generalPasteboard];
        [pasteboard setString:self.textBtn.text];
        [TLToast showToast:ScanLocalizedString(@"复制成功") duration:2 completion:nil];
    }
}

-(void) closeClicked
{
    if(self.closeWindow)
    {
        self.closeWindow();
    }
    [self removeFromSuperview];
}

@end

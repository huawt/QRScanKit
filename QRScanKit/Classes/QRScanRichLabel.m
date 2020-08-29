
#import "QRScanRichLabel.h"
#import <CoreGraphics/CoreGraphics.h>
#import <LRTools/LRTools.h>

@interface QRScanRichLabel ()

@property (nonatomic,strong) NSLayoutManager *layoutManager;
@property (nonatomic,strong) NSTextStorage *textStorage;
@property (nonatomic,strong) NSMutableDictionary *links;
@property (nonatomic,strong) NSTextContainer *textContainer;

@end

@implementation QRScanRichLabel

#pragma mark - 初始化

-(instancetype)init{
    if (self = [super init]) {
        //初始化默认值
        [self defaultConfiguration];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //初始化默认值
        [self defaultConfiguration];
    }
    return self;
}

- (void)defaultConfiguration
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapOnLabel:)];
    [self addGestureRecognizer:tap];
}

- (NSMutableDictionary *)links
{
    if (!_links) {
        _links = [[NSMutableDictionary alloc] init];
    }
    return _links;
}

- (NSLayoutManager *)layoutManager
{
    if (!_layoutManager) {
        _layoutManager = [[NSLayoutManager alloc] init];
    }
    return _layoutManager;
}

- (NSTextContainer *)textContainer
{
    if (!_textContainer) {
        _textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
        _textContainer.lineFragmentPadding = 0;
        _textContainer.lineBreakMode = self.lineBreakMode;
        _textContainer.maximumNumberOfLines = self.numberOfLines;
    }
    return _textContainer;
}

#pragma mark - 赋值

- (void)setQrResultString:(NSString *)qrResultString
{
    if (qrResultString == nil || qrResultString.length == 0) {
        self.text = @"";
        return;
    }
    
    qrResultString = [qrResultString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    _qrResultString = qrResultString;
    
    NSMutableAttributedString *mutableString = [self stringToQrString:qrResultString];

    [self.layoutManager addTextContainer:self.textContainer];
    
    self.textStorage = [[NSTextStorage alloc] initWithAttributedString:mutableString];
    [self.textStorage addLayoutManager:self.layoutManager];
    
    [self.layoutManager ensureLayoutForGlyphRange:NSMakeRange(0, mutableString.length)];

    self.attributedText = mutableString;
}

-(NSMutableAttributedString *)stringToQrString:(NSString *)content{
    NSMutableAttributedString *chatString=[[NSMutableAttributedString alloc]initWithString:content];
    NSMutableArray *array=[NSMutableArray array];
    [content regularSearchToArray:@"\\[[\u4e00-\u9fa5]{2}\\]" array:array];
    for(int i = 0; i < array.count; i++){
        NSString *strReg = array[i];
        int regType = [[strReg substringToIndex:2] intValue];
        
        if (regType == 2){
            NSRange strRang=NSMakeRange([[strReg substringWithRange:NSMakeRange(2, 4)] intValue], [[strReg substringWithRange:NSMakeRange(6, 4)] intValue]);
            NSMutableDictionary *fontAttrbutes=[NSMutableDictionary dictionary];
            
            [fontAttrbutes setObject:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
            [fontAttrbutes setObject:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];
            [chatString setAttributes:fontAttrbutes range:strRang];
            NSString *url = [strReg substringWithRange:NSMakeRange(10, strReg.length-10)];
            [self.links setObject:url forKey:[NSValue valueWithRange:strRang]];
        }
    }
    
    [chatString addAttribute:NSKernAttributeName value:@(0.5) range:NSMakeRange(0, chatString.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:3.0f];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [chatString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, chatString.length)];
    return chatString;
}


-(void)handleTapOnLabel:(UITapGestureRecognizer *)recognizer{

    CGPoint location = [recognizer locationInView:recognizer.view];
    CGSize labelSize = self.bounds.size;
    
    NSTextContainer* textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = self.lineBreakMode;
    textContainer.maximumNumberOfLines = self.numberOfLines;
    textContainer.size = labelSize;
    
    NSLayoutManager* layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    
    NSTextStorage* textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    [textStorage addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, textStorage.length)];
    [textStorage addLayoutManager:layoutManager];
    
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(location.x - textContainerOffset.x, location.y - textContainerOffset.y);
    NSInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    
    for (NSValue *linkvalue in _links.allKeys) {
        NSRange linkRang = [linkvalue rangeValue];
        if (NSLocationInRange(indexOfCharacter, linkRang)) {
            if(_clickBlock){
                _clickBlock([_links objectForKey:linkvalue]);
            }
        }
    }
}

-(void)setText:(NSString *)text{
    self.qrResultString = text;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_links.count) {
        _textContainer.size = self.bounds.size;
    }
}


@end

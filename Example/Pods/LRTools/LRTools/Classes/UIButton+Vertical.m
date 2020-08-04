
#import "UIButton+Vertical.h"

@implementation UIButton (Vertical)
- (void)verticalImageAndTitle:(CGFloat)spacing
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    CGSize textSize = [self resizeToSize:CGSizeMake(self.bounds.size.width, MAXFLOAT) string:self.titleLabel.text font:self.titleLabel.font lineSpace:0];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height), 0);
}

- (CGSize)resizeToSize:(CGSize)size string:(NSString*)string font:(UIFont*)font lineSpace:(CGFloat)space
{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByCharWrapping];
    [paragraph setLineSpacing:space];
    NSDictionary * attdic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraph};
    CGSize fixSize = [string boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attdic context:nil].size;
    return fixSize;
}

@end

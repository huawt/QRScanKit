//
//  NSString+Addtionss.h
//  LRTools
//
//  Created by WinTer on 2020/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Addtionss)

-(void)regularSearchToArray:(NSString *)regular array:(NSMutableArray *)array;
-(void)findStringToArrray:(NSMutableArray *)array keyValue:(NSString *)keyValue;
-(NSDictionary *)urlStringToDictionary;

+ (NSString *)getFileMD5WithPath:(NSString*)path;
- (NSString *)md5;
- (NSString *)md5UsingEncoding:(NSStringEncoding)encoding;
- (NSString *)middleString;
- (NSString *)deleteSpace;
- (NSString *)deleteYin;

-(CGSize)size;
-(CGSize)sizeWithFontSize:(CGFloat)size;
-(CGSize)sizeWithFontSize:(CGFloat)size name:(NSString*)name contentSize:(CGSize)contentSize;

- (int)convertToInt;

- (CGSize)sizeWithStringFontSize:(double)stringFontSize contextSize:(CGSize)contextSize;
- (CGSize)sizeWithStringFontSize:(double)stringFontSize;
- (CGSize)sizeWithContextSize:(CGSize)contextSize;
- (CGSize)sizeCalculate;



@end

NS_ASSUME_NONNULL_END

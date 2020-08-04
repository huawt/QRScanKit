

#import "NSString+Addtionss.h"
#import <CommonCrypto/CommonDigest.h>

#define FileHashDefaultChunkSizeForReadingData 1024*8

@implementation NSString (Addtionss)

-(void)regularSearchToArray:(NSString *)regular array:(NSMutableArray *)array{
    if (array) {
        NSString *urlRegular=@"((http[s]{0,1}|ftp)://([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})|(\\d+\\.\\d+\\.\\d+\\.\\d+))(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([w,W]{3}.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
        NSMutableString *targeString=[[NSMutableString alloc]initWithString:[self lowercaseString]];
        [self regularSearchToArray:regular targe:targeString array:array rang:NSMakeRange(0,targeString.length )];
        [self linkSearchToArray:urlRegular targe:targeString originString:self array:array rang:NSMakeRange(0, targeString.length)];
    }
}
-(void)regularSearchToArray:(NSString *)regular targe:(NSMutableString *)targe array:(NSMutableArray *)array rang:(NSRange)rang{
    NSRange strRang=[targe rangeOfString:regular options:NSRegularExpressionSearch range:rang];
    NSString *rangString;
    if (strRang.length>0) {
        rangString=[NSString stringWithFormat:@"%02d%04lu%04lu%@",1,(unsigned long)strRang.location,(unsigned long)strRang.length,[targe substringWithRange:strRang]];
    }else{
        return;
    }
    [array addObject:rangString];
    [targe replaceCharactersInRange:strRang withString:@"占"];
    [self regularSearchToArray:regular targe:targe array:array rang:NSMakeRange(strRang.location+1, targe.length-strRang.location-1)];
}
-(void)linkSearchToArray:(NSString *)regular targe:(NSMutableString *)targe originString:(NSString *)originString array:(NSMutableArray *)array rang:(NSRange)rang{
    NSRange strRang=[targe rangeOfString:regular options:NSRegularExpressionSearch range:rang];
    NSString *rangString;
    if (strRang.length>0) {
        rangString=[NSString stringWithFormat:@"%02d%04lu%04lu%@",2,(unsigned long)strRang.location,(unsigned long)strRang.length,[originString substringWithRange:strRang]];
    }else{
        return;
    }
    [array addObject:rangString];
    [self linkSearchToArray:regular targe:targe originString:originString array:array rang:NSMakeRange(strRang.location+strRang.length, targe.length-strRang.location-strRang.length)];
}
-(void)findStringToArrray:(NSMutableArray *)array keyValue:(NSString *)keyValue{
    if (keyValue&&keyValue.length&&array) {
        [self valueSearchToArray:self keyValue:keyValue targetarray:array rang:NSMakeRange(0, self.length)];
    }
}
-(void)valueSearchToArray:(NSString *)regular keyValue:(NSString *)keyValue targetarray:(NSMutableArray *)array rang:(NSRange)rang{
    NSRange strRang=[regular rangeOfString:keyValue options:NSCaseInsensitiveSearch range:rang];
    NSString *rangString;
    if (strRang.length>0) {
        rangString=[NSString stringWithFormat:@"%04lu%04lu%@",(unsigned long)strRang.location,(unsigned long)strRang.length,[regular substringWithRange:strRang]];
    }else{
        return;
    }
    [array addObject:rangString];
    [self valueSearchToArray:regular keyValue:keyValue targetarray:array rang:NSMakeRange(strRang.location+1, regular.length-strRang.location-1)];
}

-(NSDictionary *)urlStringToDictionary{
    NSString *url=self;
    if (!url) {
        return nil;
    }
    NSMutableDictionary *dictionary;
    NSRange index=[url rangeOfString:@"?"];
    if (index.length>0) {
        dictionary=[NSMutableDictionary dictionary];
        NSString *urlPrefix=[url substringToIndex:index.location];
        NSRange urlPrefixRange=[urlPrefix rangeOfString:@"//"];
        if (urlPrefixRange.length>0) {
            [dictionary setObject:[urlPrefix substringToIndex:urlPrefixRange.location-1] forKey:@"url-scheme"];
        }else{
            urlPrefixRange=NSMakeRange(0, 0);
        }
        NSUInteger location=0;
        if (urlPrefixRange.length>0) {
            location=urlPrefixRange.location+2;
        }
        NSRange urlAddressRange=[urlPrefix rangeOfString:@"/" options:0 range:NSMakeRange(location, urlPrefix.length-location)];
        if (urlAddressRange.length>0) {
            if (urlPrefixRange.length>0) {
                [dictionary setObject:[urlPrefix substringWithRange:NSMakeRange(location, urlAddressRange.location-location)] forKey:@"url-address"];
                [dictionary setObject:[urlPrefix substringFromIndex:urlAddressRange.location] forKey:@"url-method"];
            }else{
                [dictionary setObject:[urlPrefix substringFromIndex:location] forKey:@"url-address"];
                [dictionary setObject:@"" forKey:@"url-method"];
            }
            
        }else{
            urlPrefixRange=NSMakeRange(0, 0);
        }
        
        NSString *urlParameter=[url substringFromIndex:index.location+1];
        NSArray *parameters= [urlParameter componentsSeparatedByString:@"&"];
        for (NSString *parameter in parameters) {
            NSArray *paras=[parameter componentsSeparatedByString:@"="];
            if (paras.count==2) {
                NSString *key=[[paras firstObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *value=[[paras lastObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if (key.length) {
                    NSString *keyValue=nil;
                    if (value.length) {
                        keyValue=value;
                    }else{
                        keyValue=@"";
                    }
                    [dictionary setObject:keyValue forKey:key];
                }
            }
        }
    }
    return dictionary;
}



+ (NSString*)getFileMD5WithPath:(NSString*)path{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData){
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, (CFURLRef)fileURL);
    if (!readStream) goto done;
    
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData){
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData){
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        
        if (readBytesCount == -1) break;

        if (readBytesCount == 0){
            hasMoreData = false;
            continue;
        }
        
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i){
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    
    if (readStream){
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    
    if (fileURL){
        CFRelease(fileURL);
    }
    return result;
}


- (NSString *)md5
{
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}
- (NSString *)md5UsingEncoding:(NSStringEncoding)encoding
{
    const char *cStr = [self cStringUsingEncoding:encoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
- (NSString *)middleString
{
    if (self) {
        return [self substringWithRange:NSMakeRange(1, [self length]-2)];
    } else {
        return self;
    }
}

- (NSString *)deleteSpace
{
    if (self) {
        NSMutableString *result = [NSMutableString stringWithString:self];
        
        for (int i=0; i<result.length; i++)
        {
            char temp = [result characterAtIndex:i];
            if (temp == '\0' || temp == '\n' || temp == '\r' || temp == '\t')
            {
                [result deleteCharactersInRange:NSMakeRange(i, 1)];
                i--;
            }
        }
        
        return result;
    }
    else
    {
        return self;
    }
}

- (NSString *)deleteYin
{
    
    if (self)
    {
        NSMutableString *str = [NSMutableString stringWithString:self];
        NSString *re = str;
        if ([str rangeOfString:@"'"].location!=NSNotFound)
        {
            
            re = [str stringByReplacingOccurrencesOfString:@"'" withString:@"''" options:1 range:NSMakeRange(0, str.length-1)];
        }
        
        NSMutableString *str1 = [NSMutableString stringWithString:re];
        if ([str1 hasPrefix:@"\""] && [str1 hasSuffix:@"\""] && str1.length>2)
        {
            NSString *result = [str1 substringWithRange:NSMakeRange(1, str1.length-2)];
            return result;
        }
        else
        {
            return re;
        }
        
    }
    else
    {
        return self;
    }
}

-(CGSize)size{
    return [self sizeWithFontSize:[UIFont systemFontSize]];
}
-(CGSize)sizeWithFontSize:(CGFloat)size
{
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:size],NSKernAttributeName:@(0.2f)};
    CGSize fontSize = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    return fontSize;
}
-(CGSize)sizeWithFontSize:(CGFloat)size name:(NSString*)name contentSize:(CGSize)contentSize
{
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont fontWithName:name size:size],NSKernAttributeName:@(0.2f)};
    CGSize fontSize = [self boundingRectWithSize:contentSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    return fontSize;
}

//判断字符
- (int)convertToInt
{
    int strlength = 0;
    char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

- (CGSize)sizeWithStringFontSize:(double)stringFontSize contextSize:(CGSize)contextSize
{
    NSDictionary *fontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:stringFontSize]};
    CGSize size = [self boundingRectWithSize:contextSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:fontAttributes context:nil].size;
    return size;
}
- (CGSize)sizeWithStringFontSize:(double)stringFontSize
{
    return [self sizeWithStringFontSize:stringFontSize contextSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}
- (CGSize)sizeWithContextSize:(CGSize)contextSize
{
    return [self sizeWithStringFontSize:[UIFont systemFontSize] contextSize:contextSize];
}
- (CGSize)sizeCalculate
{
    return [self sizeWithStringFontSize:[UIFont systemFontSize] contextSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}




@end

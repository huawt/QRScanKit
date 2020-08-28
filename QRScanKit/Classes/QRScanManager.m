
#import "QRScanManager.h"
#import <CoreImage/CoreImage.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ZXingObjCFork/ZXingObjC.h>
#import "QRScanResultModel.h"

@interface QRScanManager ()

@end

@implementation QRScanManager

+ (UIImage *)generalQRImage:(NSString *)string width:(CGFloat)width
{
    if([string length] < 1)
        return nil;
    //创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //过滤器恢复默认
    [filter setDefaults];
    
    //将NSString格式转化成NSData格式
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    //获取二维码过滤器生成的二维码
    CIImage *image = [filter outputImage];
    
    //将获取到的二维码添加到imageview上
    return [self createNonInterpolatedUIImageFormCIImage:image size:width];
}

/**
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image size:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

+ (QRScanResultModel *)scanResultByImage:(UIImage *)image
{
    
    QRScanResultModel *resultModel = [[QRScanResultModel alloc] init];
    
    CGImageRef imageToDecode = image.CGImage;
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    // There are a number of hints we can give to the reader, including
    // possible formats, allowed lengths, and the string encoding.
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap hints:hints error:&error];
    if (result) {
        // The coded result as a string. The raw data can be accessed with
        // result.rawBytes and result.length.
        NSString *resultString = result.text;
        
        // The barcode format, such as a QR code or UPC-A
        ZXBarcodeFormat format = result.barcodeFormat;
        
        if(format == kBarcodeFormatAztec || format == kBarcodeFormatDataMatrix || format == kBarcodeFormatMaxiCode || format == kBarcodeFormatQRCode || format == kBarcodeFormatPDF417){
            resultModel.resultType = QRScanResultType_QRCodeType;
        }
        else{
            resultModel.resultType = QRScanResultType_BarCodeType;
        }
        
        resultModel.resultString = resultString;
    } else {
        // Use error to determine why we didn't get a result, such as a barcode
        // not being found, an invalid checksum, or a format inconsistency.
        resultModel.resultType = QRScanResultType_None;
        resultModel.resultString = @"";
    }

    return resultModel;
}

+ (QRScanResultModel *)scanResultByMetadataObject:(AVMetadataMachineReadableCodeObject *)metadataObj
{
    QRScanResultModel *resultModel = [[QRScanResultModel alloc] init];
    
    NSArray *qrTypeArr =  @[AVMetadataObjectTypeQRCode,//二维码
                            AVMetadataObjectTypePDF417Code,//也是一种二维码
                            AVMetadataObjectTypeAztecCode,// Aztec这个也是一种二维码的制式，主要用于航空
                            AVMetadataObjectTypeDataMatrixCode];// 又是一种二维码制式
    
    
    if([qrTypeArr containsObject:metadataObj.type]){
        resultModel.resultType = QRScanResultType_QRCodeType;
    }
    else{
        resultModel.resultType = QRScanResultType_BarCodeType;
    }
    
    resultModel.resultString = metadataObj.stringValue;
    
    return resultModel;
}

+ (void)scanResultByLocalAlbumFrom:(UIViewController *)viewController finished:(void (^)(UIImage *, QRScanResultModel *))finishHandler
{
//    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
//    imagePickerVc.allowPickingVideo = NO;
//    imagePickerVc.allowTakePicture = NO;
//    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//        [self selectImageFinishedPhotos:photos assets:assets originImage:isSelectOriginalPhoto finished:finishHandler];
//    }];
//    if (viewController) {
//        if (viewController.parentViewController) {
//            [viewController.parentViewController presentViewController:imagePickerVc animated:YES completion:nil];
//        }else{
//            [viewController presentViewController:imagePickerVc animated:YES completion:nil];
//        }
//    }else{
//        [[JumpManager jumper].currentController presentViewController:imagePickerVc animated:YES completion:nil];
//    }
}

+ (void)selectImageFinishedPhotos:(NSArray<UIImage *> *)photos assets:(NSArray *)assets originImage:(BOOL)isSelectOriginalPhoto finished:(void (^)(UIImage *, QRScanResultModel *))finishHandler
{
    //无论是选择原图还是非原图 photos 和  assets 里面 都会有值
    //1. 获取相册里面的原图, 获取原图路径, 判断图片方向, 然后修正方向
//    PHAsset *asset = [assets firstObject];
//    NSString *localIdentifier = asset.localIdentifier;
//    if (localIdentifier != nil) {
//        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//
//            NSString *localKey = @"PHImageFileURLKey";
//            NSURL *localPath = [info objectForKey:localKey];
//            UIImage *image = nil;
//            if (isSelectOriginalPhoto) { //原图
//                image =  [UIImage imageWithContentsOfFile:localPath.absoluteString];
//
//                if(image == nil)
//                    image = [UIImage imageWithData:imageData];
//            }else{
//                image = photos.firstObject;
//            }
//
//            [self dealImage:image finished:finishHandler];
//        }];
//    }else{
//        UIImage *image = photos.firstObject;
//
//        [self dealImage:image finished:finishHandler];
//    }
}

+ (void)dealImage:(UIImage *)image finished:(void (^)(UIImage *, QRScanResultModel *))finishHandler
{
    if (image == nil) {
        !finishHandler?:finishHandler(nil, nil);
    }
    QRScanResultModel *resultModel = [self scanResultByImage:image];
    !finishHandler?:finishHandler(image, resultModel);
}

@end

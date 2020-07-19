
#import "QRScanLEDControl.h"
#import <AVFoundation/AVFoundation.h>

@implementation QRScanLEDControl

+ (instancetype)control
{
    static dispatch_once_t __singletonToken;
    static id __singleton__;
    dispatch_once( &__singletonToken, ^{ __singleton__ = [[self alloc] initPrivate]; } );
    return __singleton__;
}
- (instancetype)init
{
    NSAssert(NO, @"");
    return nil;
}
- (instancetype)initPrivate
{
    if (self = [super init]) {
        _torchIsOn = NO;
    }
    return self;
}

- (void)turnTorchOn:(bool)on completeBlock:(turnTorcBlock) block
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                _torchIsOn = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                _torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
    if (block) {
        block(self.torchIsOn);
    }
}

@end

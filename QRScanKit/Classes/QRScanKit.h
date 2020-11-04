
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __has_include(<QRScanKit/QRScanKit.h>)

FOUNDATION_EXPORT double QRScanKitVersionNumber;
FOUNDATION_EXPORT const unsigned char QRScanKitVersionString[];

#import <QRScanKit/QRCaptureLayer.h>
#import <QRScanKit/QRScanView.h>
#import <QRScanKit/QRScanManager.h>
#import <QRScanKit/QRScanResultModel.h>
#import <QRScanKit/QRCodeAlertWindow.h>
#import <QRScanKit/QRScanLEDControl.h>

#else

#import "QRCaptureLayer.h"
#import "QRScanView.h"
#import "QRScanManager.h"
#import "QRScanResultModel.h"
#import "QRCodeAlertWindow.h"
#import "QRScanLEDControl.h"

#endif

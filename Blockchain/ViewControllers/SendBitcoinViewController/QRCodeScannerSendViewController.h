// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 A view controller that handles scanning a QR code.
 `didReadQRCodeMetadata` will then be called with the given AVMetadataMachineReadableCodeObject.
 */
@interface QRCodeScannerSendViewController : UIViewController

- (void)QRCodeButtonClicked;

// This method does nothing. Override it implementing your own reaction to a QR Code.
- (void)didReadQRCodeMetadata:(nullable AVMetadataMachineReadableCodeObject *)metadata;

@end

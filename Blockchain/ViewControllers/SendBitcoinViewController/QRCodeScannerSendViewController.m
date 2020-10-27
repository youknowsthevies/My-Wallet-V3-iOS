//
//  QRCodeScannerSendViewController.m
//  Blockchain
//
//  Created by kevinwu on 9/11/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "QRCodeScannerSendViewController.h"
#import "Blockchain-Swift.h"

@interface QRCodeScannerSendViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong, nullable) AVCaptureSession *captureSession;
@property (nonatomic, strong, nullable) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong, nullable) BridgeDeepLinkQRCodeRouter *deepLinkQRCodeRouter;

@end

@implementation QRCodeScannerSendViewController

- (void)QRCodeButtonClicked
{
    self.deepLinkQRCodeRouter = [[BridgeDeepLinkQRCodeRouter alloc] init];
    
    if (!_captureSession) {
        [self startReadingQRCode];
    }
}

- (BOOL)startReadingQRCode
{
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputForQRScannerAndReturnError:&error];
    if (!input) {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
            [AlertViewPresenter.shared showNeedsCameraPermissionAlert];
        } else {
            [AlertViewPresenter.shared standardNotifyWithTitle:LocalizationConstantsObjcBridge.error message:[error localizedDescription] in:self handler:nil];
        }
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    CGRect rootFrame = UIApplication.sharedApplication.keyWindow.rootViewController.view.frame;
    [_videoPreviewLayer setFrame:rootFrame];
    
    UIView *view = [[UIView alloc] initWithFrame:rootFrame];
    [view.layer addSublayer:_videoPreviewLayer];

    __weak typeof(self) weakSelf = self;
    void (^onDismiss)(void) = ^{
        [weakSelf.captureSession stopRunning];
        weakSelf.captureSession = nil;
        [weakSelf.videoPreviewLayer removeFromSuperlayer];
    };
    [[ModalPresenter sharedInstance] showModalWithContent:view
                                                closeType:ModalCloseTypeClose
                                               showHeader:YES
                                               headerText:[LocalizationConstantsObjcBridge scanQRCode]
                                                onDismiss:onDismiss
                                                 onResume:nil];
    
    [_captureSession startRunning];
    
    return YES;
}

- (void)stopReadingQRCode
{
    [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
    _captureSession = nil;
}

- (void)didReadQRCodeMetadata:(AVMetadataMachineReadableCodeObject *)metadata
{
    // No default action.
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];

        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self performSelectorOnMainThread:@selector(stopReadingQRCode) withObject:nil waitUntilDone:NO];

            // do something useful with results
            dispatch_sync(dispatch_get_main_queue(), ^{
                if ([self.deepLinkQRCodeRouter handleWithDeepLink:[metadataObj stringValue]]) {
                    return;
                }
                [self didReadQRCodeMetadata:metadataObj];
            });
        }

    }
}

@end

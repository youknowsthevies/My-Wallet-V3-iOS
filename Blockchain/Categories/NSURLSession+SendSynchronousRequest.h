//
//  NSURLSession+SendSynchronousRequest.h
//  Blockchain
//
//  Created by Kevin Wu on 8/25/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SynchronousRequestResponse : NSObject

@property (nonatomic, copy, nullable) NSData *data;
@property (nonatomic, strong, nullable) NSHTTPURLResponse *response;
@property (nonatomic, copy, nullable) NSError *error;

- (instancetype)initWithData:(nullable NSData *)data response:(nullable NSURLResponse *)response error:(nullable NSError *)error;

@end

@interface NSURLSession (SendSynchronousRequest)

+ (SynchronousRequestResponse *)sendSynchronousRequest:(NSURLRequest *)request
                                               session:(NSURLSession *)session
                                    sessionDescription:(nullable NSString *)sessionDescription;

@end

NS_ASSUME_NONNULL_END

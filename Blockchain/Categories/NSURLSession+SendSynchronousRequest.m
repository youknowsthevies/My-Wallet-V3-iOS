// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "NSURLSession+SendSynchronousRequest.h"

@implementation NSURLSession (SendSynchronousRequest)

+ (SynchronousRequestResponse *)sendSynchronousRequest:(NSURLRequest *)request
                                               session:(NSURLSession *)session
                                    sessionDescription:(nullable NSString *)sessionDescription {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData * resultData = nil;
    __block NSURLResponse * resultResponse = nil;
    __block NSError * resultError = nil;

    session.sessionDescription = sessionDescription;

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data,
                                                                    NSURLResponse * _Nullable response,
                                                                    NSError * _Nullable error) {
        resultData = data;
        resultResponse = (NSHTTPURLResponse *)response;
        resultError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];

    dispatch_time_t thirtySeconds = dispatch_time(DISPATCH_TIME_NOW, 30*NSEC_PER_SEC);
    intptr_t status = dispatch_semaphore_wait(semaphore, thirtySeconds);

    if (status == 0) {
        // Success
        return [[SynchronousRequestResponse alloc] initWithData:resultData response:resultResponse error:resultError];
    }
    [dataTask cancel];
    NSError *cancelled = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
    return [[SynchronousRequestResponse alloc] initWithData:nil response:nil error:cancelled];
}

@end

@implementation SynchronousRequestResponse

- (instancetype)initWithData:(nullable NSData *)data response:(nullable NSHTTPURLResponse *)response error:(nullable NSError *)error;
{
    self = [super init];
    if (self) {
        self.data = data;
        self.response = response;
        self.error = error;
    }
    return self;
}

@end

//
//  NSURLSession+SendSynchronousRequest.m
//  Blockchain
//
//  Created by Kevin Wu on 8/25/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "NSURLSession+SendSynchronousRequest.h"

@implementation NSURLSession (SendSynchronousRequest)

+ (NSData * _Nullable)sendSynchronousRequest:(NSURLRequest *)request
                                     session:(NSURLSession *)session
                           returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                                       error:(__autoreleasing NSError **)errorPtr
                          sessionDescription:(NSString *)sessionDescription
{
    dispatch_semaphore_t    sem;
    __block NSData *        result;
    
    result = nil;
    
    sem = dispatch_semaphore_create(0);
    
    session.sessionDescription = sessionDescription;
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (errorPtr != NULL) {
                        *errorPtr = error;
                    }
                    if (responsePtr != NULL) {
                        *responsePtr = response;
                    }
                    if (error == nil) {
                        result = data;
                    }
                    dispatch_semaphore_signal(sem);
                }] resume];
    
    dispatch_time_t thirtySeconds = dispatch_time(DISPATCH_TIME_NOW, 30000000000);
    dispatch_semaphore_wait(sem, thirtySeconds);
        
    return result;
}

@end

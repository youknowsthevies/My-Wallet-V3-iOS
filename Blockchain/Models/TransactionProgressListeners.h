//
//  TransactionProgressListeners.h
//  Blockchain
//
//  Created by Paulo on 17/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransactionProgressListeners : NSObject

@property (nonatomic, copy) void (^ _Nonnull on_start)(void);
@property (nonatomic, copy) void (^ _Nullable on_begin_signing)(NSString*);
@property (nonatomic, copy) void (^ _Nullable on_sign_progress)(int input);
@property (nonatomic, copy) void (^ _Nullable on_finish_signing)(NSString*);
@property (nonatomic, copy) void (^ _Nullable on_success)(NSString* _Nullable secondPassword, NSString* _Nullable transactionHash, NSString* _Nullable transactionHex);
@property (nonatomic, copy) void (^ _Nonnull on_error)(NSString* _Nullable error, NSString* _Nullable secondPassword);

@end

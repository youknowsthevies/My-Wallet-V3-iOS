// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "KeychainItemWrapper.h"

@interface KeychainItemWrapper (Credentials)
+ (nullable NSString *)guid;
+ (void)setGuidInKeychain:(NSString *)guid;
+ (void)removeGuidFromKeychain;

+ (nullable NSString *)sharedKey;
+ (void)setSharedKeyInKeychain:(NSString *)sharedKey;
+ (void)removeSharedKeyFromKeychain;

+ (void)setPINInKeychain:(NSString *)pin;
+ (NSString *)pinFromKeychain;
+ (void)removePinFromKeychain;

@end

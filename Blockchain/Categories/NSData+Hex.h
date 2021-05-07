// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <Foundation/Foundation.h>

@interface NSData (Hex)

/// Returns the hexadecimal representation of this NSData. Empty string if data is empty.
- (NSString *)hexadecimalString;

@end

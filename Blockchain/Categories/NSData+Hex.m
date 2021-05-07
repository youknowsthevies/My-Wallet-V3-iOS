// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "NSData+Hex.h"

@implementation NSData (Hex)

- (NSString *)hexadecimalString {
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];

    if (!dataBuffer) {
        return [NSString string];
    }
    NSUInteger dataLength = self.length;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02x", (unsigned int)dataBuffer[i]]];
    }
    return [NSString stringWithString:hexString];
}

@end

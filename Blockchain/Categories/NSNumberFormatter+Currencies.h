// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <Foundation/Foundation.h>

@interface NSNumberFormatter (Currencies)

+ (NSString*)formatMoney:(uint64_t)value;
+ (NSString*)formatMoney:(uint64_t)value localCurrency:(BOOL)fsymbolLocal;

+ (NSString *)formatBCHAmountInAutomaticLocalCurrency:(uint64_t)amount;
+ (NSString *)formatBCHAmount:(uint64_t)amount includeSymbol:(BOOL)includeSymbol inLocalCurrency:(BOOL)localCurrency;

@end

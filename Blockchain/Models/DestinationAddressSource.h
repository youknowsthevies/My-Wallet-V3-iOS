// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <Foundation/Foundation.h>

#ifndef DestinationAddressSource_h
#define DestinationAddressSource_h

typedef NS_CLOSED_ENUM(NSInteger, DestinationAddressSource)  {
    DestinationAddressSourceNone = 0,
    DestinationAddressSourceQR,
    DestinationAddressSourcePaste,
    DestinationAddressSourceURI,
    DestinationAddressSourceDropDown,
    DestinationAddressSourceExchange,
    DestinationAddressSourceBitPay
};

#endif /* DestinationAddressSource_h */

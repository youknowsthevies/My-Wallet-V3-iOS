//
//  DestinationAddressSource.h
//  Blockchain
//
//  Created by kevinwu on 5/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

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

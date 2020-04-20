//
//  Collector.h
//

@import Foundation;

/**
 * Response block
 */
typedef void(^CollectorResponseBlock)(NSDictionary* json, NSError* error);

/**
 * Browser iD class
 */
@interface Collector: NSObject

/**
 * Stores parameters sent to server
 */
@property (strong) NSMutableDictionary *params;

/**
 * Initializes Collector object
 *
 * @param token Identifier token
 */
- (instancetype)initWithToken:(NSString *)token;

/**
 * Posts params to BrowserID server with callback
 *
 * @param block callback block, use weak self
 */
- (void)post:(CollectorResponseBlock)block;

/**
 * Posts params to address with callback
 *
 * @param url address where to send data
 * @param block callback block, use weak self
 */
- (void)postToUrl:(NSString *)url callback:(CollectorResponseBlock)block;

@end

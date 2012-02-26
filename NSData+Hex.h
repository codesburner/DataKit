//
//  NSData+Hex.h
//  DataKit
//
//  Created by Erik Aigner on 26.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Hex)

+ (NSData *)dataWithHexString:(NSString *)hex;
- (NSString *)hexString;

@end

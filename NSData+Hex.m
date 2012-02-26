//
//  NSData+Hex.m
//  DataKit
//
//  Created by Erik Aigner on 26.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "NSData+Hex.h"

@implementation NSData (Hex)

+ (NSData *)dataWithHexString:(NSString *)hex {
  NSMutableData *data = [NSMutableData new];
  for (NSUInteger i=0; i<hex.length; i+=2) {
    char high = (char)[hex characterAtIndex:i];
    char low = (char)[hex characterAtIndex:i+1];
    char bchars[3] = {high, low, '\0'};
    UInt8 byte = strtol(bchars, NULL, 16);
    [data appendBytes:&byte length:1];
  }
  
  return [NSData dataWithData:data];
}

- (NSString *)hexString {
  NSUInteger capacity = self.length * 2;
  NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:capacity];
  const unsigned char *dataBuffer = self.bytes;
  NSInteger i;
  for (i=0; i<self.length; ++i) {
    [stringBuffer appendFormat:@"%02X", (NSUInteger)dataBuffer[i]];
  }
  return [NSString stringWithString:stringBuffer];
}

@end

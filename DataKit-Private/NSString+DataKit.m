//
//  NSString+DataKit.m
//  DataKit
//
//  Created by Erik Aigner on 28.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "NSString+DataKit.h"

@implementation NSString (DataKit)

- (NSString *)URLEncoded {
  CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                  (__bridge CFStringRef)self,
                                                                  NULL,
                                                                  (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                  kCFStringEncodingUTF8 );
  return CFBridgingRelease(urlString);
}

@end

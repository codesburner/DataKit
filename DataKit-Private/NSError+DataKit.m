//
//  NSError+DataKit.m
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "NSError+DataKit.h"

#import "DKConstants.h"

@implementation NSError (DataKit)

+ (void)writeToError:(NSError **)error code:(NSInteger)code description:(NSString *)desc original:(NSError *)originalError {
  if (error != nil) {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (desc.length > 0) {
      [userInfo setObject:desc forKey:NSLocalizedDescriptionKey];
    }
    if (originalError != nil) {
      [userInfo setObject:originalError forKey:@"DKSourceError"];
    }
    *error = [NSError errorWithDomain:kDKErrorDomain code:code userInfo:userInfo];
  }
}

@end

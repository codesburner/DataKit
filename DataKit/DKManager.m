//
//  DKManager.m
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKManager.h"

@implementation DKManager

static NSString *kDKManagerAPIEndpoint;
static NSString *kDKManagerAPISecret;

+ (void)setAPIEndpoint:(NSString *)absoluteString {
  NSURL *ep = [NSURL URLWithString:absoluteString];
  if (![ep.scheme isEqualToString:@"https"]) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      NSLog(@"\n\nWARNING: DataKit API endpoint not secured! "
            "It's highly recommended to use SSL (current scheme is '%@')\n\n",
            ep.scheme);
    });
    
  }
  kDKManagerAPIEndpoint = [absoluteString copy];
}

+ (void)setAPISecret:(NSString *)secret {
  kDKManagerAPISecret = [secret copy];
}

+ (NSString *)APIEndpoint {
  if (kDKManagerAPIEndpoint.length == 0) {
    [NSException raise:NSInternalInconsistencyException format:@"No API endpoint specified"];
    return nil;
  }
  return kDKManagerAPIEndpoint;
}

+ (NSString *)APISecret {
  if (kDKManagerAPISecret.length == 0) {
    [NSException raise:NSInternalInconsistencyException format:@"No API secret specified"];
    return nil;
  }
  return kDKManagerAPISecret;
}

+ (dispatch_queue_t)queue {
  static dispatch_queue_t q;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    q = dispatch_queue_create("datakit queue", DISPATCH_QUEUE_SERIAL);
  });
  return q;
}

@end

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
    NSLog(@"\n\nWARNING: DataKit API endpoint not secured! It's highly recommended to use SSL (current scheme is '%@')\n\n", ep.scheme);
  }
  kDKManagerAPIEndpoint = [absoluteString copy];
}

+ (void)setAPISecret:(NSString *)secret {
  kDKManagerAPISecret = [secret copy];
}

+ (NSString *)APIEndpoint {
  assert(kDKManagerAPIEndpoint != nil && "[DKManager APIEndpoint] called, but no endpoint set");
  return kDKManagerAPIEndpoint;
}

+ (NSString *)APISecret {
  assert(kDKManagerAPISecret != nil && "[DKManager APISecret] called, but no secret set");
  return kDKManagerAPISecret;
}

@end

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

+ (void)setAPIEndpoint:(NSString *)absoluteString {
  kDKManagerAPIEndpoint = [absoluteString copy];
}

+ (NSString *)APIEndpoint {
  assert(kDKManagerAPIEndpoint != nil && "[DKManager APIEndpoint] called, but no endpoint set");
  return kDKManagerAPIEndpoint;
}

@end

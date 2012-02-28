//
//  DKConstants.h
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDKErrorDomain @"DKErrorDomain"

enum {
  DKCachePolicyIgnoreCache = 0,
  DKCachePolicyCacheOnly,
  DKCachePolicyNetworkOnly,
  DKCachePolicyCacheElseNetwork,
  DKCachePolicyNetworkElseCache,
  DKCachePolicyCacheThenNetwork
};
typedef NSInteger DKCachePolicy;

enum {
  DKErrorNone = 0,
  DKErrorInvalidEntityName = 100,
  DKErrorInvalidObjectID,
  DKErrorInvalidJSON,
  DKErrorConnectionFailed = 200,
  DKErrorOperationFailed = 300,
  DKErrorOperationReturnedUnknownStatus
};
typedef NSInteger DKError;
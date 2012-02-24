//
//  DKConstants.h
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
  DKCachePolicyIgnoreCache = 0,
  DKCachePolicyCacheOnly,
  DKCachePolicyNetworkOnly,
  DKCachePolicyCacheElseNetwork,
  DKCachePolicyNetworkElseCache,
  DKCachePolicyCacheThenNetwork
};
typedef NSInteger DKCachePolicy;

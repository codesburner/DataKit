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
  DKCachePolicyIgnoreCache = NSURLRequestReloadIgnoringLocalCacheData,
  DKCachePolicyUseCacheElseLoad = NSURLRequestReturnCacheDataElseLoad,
  DKCachePolicyUseCacheDontLoad = NSURLRequestReturnCacheDataDontLoad
};
typedef NSInteger DKCachePolicy;

enum {
  DKErrorNone = 0,
  DKErrorInvalidParams = 100,
  DKErrorOperationFailed = 101,
  DKErrorOperationNotAllowed = 102,
  DKErrorDuplicateKey = 103,
  DKErrorConnectionFailed = 200,
  DKErrorInvalidResponse,
  DKErrorUnknownStatus
};
typedef NSInteger DKError;

enum {
  DKRegexOptionCaseInsensitive = (1 << 0),
  DKRegexOptionMultiline = (1 << 1),
  DKRegexOptionDotall = (1 << 2)
};
typedef NSInteger DKRegexOption;

#define kDKRequestHeaderSecret @"x-datakit-secret"
#define kDKRequestHeaderFileName @"x-datakit-filename"
#define kDKRequestHeaderAssignedFileName @"x-datakit-assigned-filename"
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
  DKErrorInvalidEntityID,
  DKErrorInvalidJSON,
  DKErrorConnectionFailed,
  DKErrorOperationReturnedUnknownStatus,
  DKErrorEntityNotSet = 100,
  DKErrorEntityKeyNotSet = 101,
  DKErrorObjectIDNotSet = 102,
  DKErrorObjectIDInvalid = 103,
  DKErrorSaveFailed = 200,
  DKErrorSaveFailedDuplicateKey = 201,
  DKErrorDeleteFailed = 300,
  DKErrorRefreshFailed = 400,
  DKErrorQueryFailed = 500,
  DKErrorIndexFailed = 600,
  DKErrorPublishFailed = 700,
  DKErrorDestroyFailed = 800,
  DKErrorDestroyNotAllowed = 801,
  DKErrorStoreFailed = 900,
  DKErrorStoreFileExists = 901,
  DKErrorStoreCouldNotOpenGridFS = 902,
  DKErrorStoreCouldNotAppendToFile = 903,
  DKErrorUnlinkFailed = 1000,
  DKErrorFileExists = 1100,
  DKErrorFileExistsFailed = 1101,
  DKErrorDropFailed = 1200,
  DKErrorDropNotAllowed = 1201
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
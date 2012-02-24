//
//  DKRequest.h
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DKConstants.h"

enum {
  DKResponseStatusSuccess = 200,
  DKResponseStatusError = 400
};
typedef NSInteger DKResponseStatus;

@interface DKRequest : NSObject
@property (nonatomic, copy, readonly) NSString *endpoint;
@property (nonatomic, assign) DKCachePolicy cachePolicy;

+ (DKRequest *)request;
+ (DKRequest *)requestWithEndpoint:(NSString *)absoluteString;

- (id)initWithEndpoint:(NSString *)absoluteString;

- (id)sendRequestWithObject:(id)JSONObject method:(NSString *)apiMethod error:(NSError **)error;

@end

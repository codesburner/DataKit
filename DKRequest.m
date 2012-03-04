//
//  DKRequest.m
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKRequest.h"

#import "DKManager.h"
#import "NSError+DataKit.h"

@interface DKRequest ()
@property (nonatomic, copy, readwrite) NSString *endpoint;
@end

// DEVNOTE: Allow untrusted certs in debug version.
// This has to be excluded in production versions - private API!
#ifdef CONFIGURATION_Debug
@interface NSURLRequest (DataKit)
+ (BOOL)setAllowsAnyHTTPSCertificate:(BOOL)flag forHost:(NSString *)host;
@end
#endif

@implementation DKRequest
DKSynthesize(endpoint)
DKSynthesize(cachePolicy)

+ (DKRequest *)request {
  return [[self alloc] init];
}

+ (DKRequest *)requestWithEndpoint:(NSString *)absoluteString {
  return [[self alloc] initWithEndpoint:absoluteString];
}

- (id)init {
  return [self initWithEndpoint:[DKManager APIEndpoint]];
}

- (id)initWithEndpoint:(NSString *)absoluteString {
  self = [super init];
  if (self) {
    self.endpoint = absoluteString;
    self.cachePolicy = DKCachePolicyIgnoreCache;
  }
  return self;
}

- (id)sendRequestWithObject:(id)JSONObject method:(NSString *)apiMethod error:(NSError **)error {
  NSURL *URL = [NSURL URLWithString:[self.endpoint stringByAppendingPathComponent:apiMethod]];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:URL];
  req.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
  
  // TODO: set cache policy correctly
  
  // Encode JSON
  NSError *JSONError = nil;
  NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:&JSONError];
  if (JSONError != nil) {
    [NSError writeToError:error
                     code:DKErrorInvalidJSON
              description:NSLocalizedString(@"Could not JSON encode request object", nil)
                 original:JSONError];
    return nil;
  }
  
  // DEVNOTE: Timeout interval is quirky
  // https://devforums.apple.com/thread/25282
  req.timeoutInterval = 20.0;
  req.HTTPMethod = @"POST";
  req.HTTPBody = JSONData;
  [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [req setValue:[DKManager APISecret] forHTTPHeaderField:@"x-datakit-secret"];
  
  NSError *requestError = nil;
  NSHTTPURLResponse *response = nil;
  
  // DEVNOTE: Allow untrusted certs in debug version.
  // This has to be excluded in production versions - private API!
#ifdef CONFIGURATION_Debug
  [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:URL.host];
#endif
  
  NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&requestError];
  
//  NSLog(@"response: status => %i", response.statusCode);
//  NSLog(@"response: body => %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
  
  if (requestError != nil) {
    [NSError writeToError:error
                     code:DKErrorConnectionFailed
              description:NSLocalizedString(@"Connection failed", nil)
                 original:requestError];
  }
  else if (response.statusCode == DKResponseStatusSuccess) {
    id resultObj = nil;
    
    // A successful operation must not always return a JSON body
    if (data.length > 0) {
#ifdef CONFIGURATION_Debug
      NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      if (dataStr.length < 800) {
        NSLog(@"data => %@", dataStr);
      }
#endif
      
      resultObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
    }
    if (JSONError != nil) {
      [NSError writeToError:error
                       code:DKErrorInvalidJSON
                description:NSLocalizedString(@"Could not deserialize JSON response", nil)
                   original:JSONError];
    }
    else {
      return resultObj;
    }
  }
  else if (response.statusCode == DKResponseStatusError) {
    id resultObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
    if (JSONError != nil) {
      [NSError writeToError:error
                       code:DKErrorInvalidJSON
                description:NSLocalizedString(@"Could not deserialize JSON error response", nil)
                   original:JSONError];
    }
    else if (error != nil && [resultObj isKindOfClass:[NSDictionary class]]) {
      NSNumber *status = [resultObj objectForKey:@"status"];
      NSString *message = [resultObj objectForKey:@"message"];
      [NSError writeToError:error
                       code:DKErrorOperationFailed
                description:[NSString stringWithFormat:NSLocalizedString(@"Could not perform operation (%@: %@)", nil), status, message]
                   original:nil];
    }
  }
  else {
    [NSError writeToError:error
                     code:DKErrorOperationReturnedUnknownStatus
              description:[NSString stringWithFormat:NSLocalizedString(@"Could not perform operation (%i)", nil), response.statusCode]
                 original:nil];
  }
  return nil;
}

@end

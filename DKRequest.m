//
//  DKRequest.m
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKRequest.h"

#import "DKManager.h"

@interface DKRequest ()
@property (nonatomic, copy, readwrite) NSString *endpoint;
@end

@implementation DKRequest
DKSynthesize(endpoint)
DKSynthesize(cachePolicy)

#define kDKErrorDomain @"DKErrorDomain"

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
  }
  return self;
}

- (id)sendRequestWithObject:(id)JSONObject error:(NSError **)error {
  NSURL *URL = [NSURL URLWithString:self.endpoint];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:URL];
  req.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
  
  // Encode JSON
  NSError *JSONError = nil;
  NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:&JSONError];
  if (JSONError != nil) {
    NSLog(@"error: could not encode JSON request (%@)", JSONError.localizedDescription);
    if (error != nil) {
      *error = JSONError;
    }
    return nil;
  }
  
  // DEVNOTE: Timeout interval is quirky
  // https://devforums.apple.com/thread/25282
  req.timeoutInterval = 20.0;
  req.HTTPMethod = @"POST";
  req.HTTPBody = JSONData;
  [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSError *requestError = nil;
  NSHTTPURLResponse *response = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&requestError];
  
  if (requestError != nil) {
    if (error != nil) {
      *error = requestError;
    }
  }
  else if (response.statusCode == DKResponseStatusSuccess) {
    id resultObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
    if (JSONError != nil) {
      NSLog(@"error: could not deserialize JSON response (%@)", JSONError.localizedDescription);
      if (error != nil) {
        *error = JSONError;
      }
    }
    else {
      return resultObj;
    }
  }
  else if (response.statusCode == DKResponseStatusError) {
    id resultObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
    if (JSONError != nil) {
      NSLog(@"error: could not deserialize JSON error response (%@)", JSONError.localizedDescription);
      if (error != nil) {
        *error = JSONError;
      }
    }
    else if (error != nil && [resultObj isKindOfClass:[NSDictionary class]]) {
      NSNumber *status = [resultObj objectForKey:@"status"];
      NSString *message = [resultObj objectForKey:@"message"];
      *error = [NSError errorWithDomain:kDKErrorDomain
                                   code:[status integerValue]
                               userInfo:[NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey]];
    }
  }
  return nil;
}

@end

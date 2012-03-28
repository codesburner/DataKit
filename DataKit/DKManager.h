//
//  DKManager.h
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The manager is used to configure common DataKit parameters
 */
@interface DKManager : NSObject

/** @name API Endpoint */

/**
 The API endpoint
 @return Returns the API endpoint absolute URL string
 @exception NSInternalInconsistencyException Raises exception if API endpoint is not set
 */
+ (NSString *)APIEndpoint;

/**
 Set the API endpoint
 @param absoluteString The absolute URL string for the API endpoint
 */
+ (void)setAPIEndpoint:(NSString *)absoluteString;

/**
 Returns the URL for the specified API method
 @param method The method name
 @return The method endpoint URL
 */
+ (NSURL *)endpointForMethod:(NSString *)method;

/** @name API Secret */

/**
 The API secret
 @return Returns the API secret string
 @exception NSInternalInconsistencyException Raises exception if API secret is not set
 */
+ (NSString *)APISecret;

/**
 Set the API secret
 @param secret The API secret
 */
+ (void)setAPISecret:(NSString *)secret;

/** @name Serial Request Queue */

/**
 Dispatch queue for API requests
 @return The shared serial dispatch queue for API requests
 */
+ (dispatch_queue_t)queue;

/** @name Dropping Databases */

/**
 Drops the specified database synchronously
 
 This feature must be explicitly enabled in the server configuration to make accidental or malicious deletion attempts harder.
 
    'allowDrop': true
 
 @param dbName The name of the database to drop
 @param error The error object set on error
 @return `YES` on success, otherwise `NO`
 @warning ***Warning***: Use with extreme caution. This will permanently drop the specified database and all entity records.
 */
+ (BOOL)dropDatabase:(NSString *)dbName error:(NSError **)error;

/** @name Debug */

/**
 Enables the request log.
 
 This is useful for tracking down performance issues during development
 @param flag `YES` to enable logging, `NO` to disable
 */
+ (void)setRequestLogEnabled:(BOOL)flag;

/**
 Returns the request log status
 @return `YES` if the request log is enabled, `NO` otherwise
 */
+ (BOOL)requestLogEnabled;

@end

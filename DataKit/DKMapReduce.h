//
//  DKMapReduce.h
//  DataKit
//
//  Created by Erik Aigner on 11.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Creates a map reduce operation to be used on a <DKQuery>
 
 @warning *Important*: Use map reduce with caution. If you pass a Javascript function that fails to compile on the server, the server process may crash.
 */
@interface DKMapReduce : NSObject

/** @name Configuration */

/**
 You can pass custom context parameters for use in the map, reduce and finalize function scope.
 @warning The keys must be of type NSString and the objects JSON compliant.
 */
@property (nonatomic, strong) NSDictionary *context;

/**
 Returns the map Javascript function
 */
@property (nonatomic, copy, readonly) NSString *mapFunction;

/**
 Returns the reduce Javascript function
 */
@property (nonatomic, copy, readonly) NSString *reduceFunction;

/**
 Returns the finalize Javascript function
 */
@property (nonatomic, copy, readonly) NSString *finalizeFunction;

/** @name Processing Results */

/**
 The result processor block used to post-process the returned JSON results
 
 The default processor passes the result through.
 */
@property (nonatomic, copy) id (^resultProcessor)(id result);

/** @name Providing Functions */

/**
 Set the map and reduce Javascript functions
 
 If you want to use custom variables in your functions you can define them in the <context>
 @param mapFunc The Javascript map function as string
 @param reduceFunc The Javascript reduce function as string
 @exception NSInternalInconsistencyException Raised if a function is missing
 */
- (void)map:(NSString *)mapFunc reduce:(NSString *)reduceFunc;

/**
 Set the map and reduce Javascript functions
 
 If you want to use custom variables in your functions you can define them in the <context>
 @param mapFunc The Javascript map function as string
 @param reduceFunc The Javascript reduce function as string
 @param finalizeFunc The Javascript finalize function as string
 @exception NSInternalInconsistencyException Raised if the map or reduce function is missing
 */
- (void)map:(NSString *)mapFunc reduce:(NSString *)reduceFunc finalize:(NSString *)finalizeFunc;

@end

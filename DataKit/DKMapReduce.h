//
//  DKMapReduce.h
//  DataKit
//
//  Created by Erik Aigner on 11.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DKMapReduceResultBlock)(id JSONObject, NSError *error);

/**
 This class is used to perform a map-reduce operation on the specified entity.
 */
@interface DKMapReduce : NSObject

/** @name Creating and Initializing MapReduce Operations */

/**
 Creates a new map reduce operation
 @param entityName The entity name to operate on
 @return The map reduce operation
 */
+ (DKMapReduce *)mapReduceWithEntityName:(NSString *)entityName;

/**
 Initializes a new map reduce operation
 @param entityName The entity name to operate on
 @return The initialized map reduce operation
 */
- (id)initWithEntityName:(NSString *)entityName;

/** @name Configuration */

/**
 The entity name
 */
@property (nonatomic, copy, readonly) NSString *entityName;

/**
 You can pass custom context parameters for use in the map, reduce and finalize function scope.
 @warning The keys must be of type NSString and the objects JSON compliant.
 */
@property (nonatomic, strong) NSDictionary *context;

/** @name Functions */

/**
 Set the map and reduce Javascript functions
 @param mapFunc The Javascript map function as string
 @param reduceFunc The Javascript reduce function as string
 @exception NSInternalInconsistencyException Raised if a function is missing
 @warning If you want to use custom variables in your functions you can define them in the <context>
 */
- (void)map:(NSString *)mapFunc reduce:(NSString *)reduceFunc;

/**
 Set the map and reduce Javascript functions
 @param mapFunc The Javascript map function as string
 @param reduceFunc The Javascript reduce function as string
 @param finalizeFunc The Javascript finalize function as string
 @exception NSInternalInconsistencyException Raised if the map or reduce function is missing
 @warning If you want to use custom variables in your functions you can define them in the <context>
 */
- (void)map:(NSString *)mapFunc reduce:(NSString *)reduceFunc finalize:(NSString *)finalizeFunc;

/** @name Perform Operation */

/**
 Performs the map reduce synchronously
 @return The map reduce JSON result object
 */
- (id)perform;

/**
 Performs the map reduce synchronously
 @param error The error object set on error
 @return The map reduce JSON result object
 */
- (id)perform:(NSError **)error;

/**
 Performs the map reduce in the background
 @param block The map reduce callback block
 */
- (void)performInBackgroundWithBlock:(DKMapReduceResultBlock)block;

@end

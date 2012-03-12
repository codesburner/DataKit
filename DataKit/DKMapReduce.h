//
//  DKMapReduce.h
//  DataKit
//
//  Created by Erik Aigner on 11.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DKMapReduceResultBlock)(id JSONObject, NSError *error);
typedef id (^DKMapReduceResultProcessorBlock)(id result);

/**
 Creates a map reduce operation to be used on a <DKQuery>
 */
@interface DKMapReduce : NSObject

/** @name Templates */

/**
 Returns an operation template to randomize query results
 @param limit The maximum number of results to return. Should be equal or less than the query limit. Pass `0` if you don't want to limit the results.
 @return The initialized template.
 */
+ (DKMapReduce *)randomizeResultsWithLimit:(NSUInteger)limit;

/**
 Counts the lists at the specified keys
 
 When performed in a query, will return an `NSDictionary` for each entity with an `entityId` key, and the specified keys with their count `NSNumber` objects.
 @param keys The key names
 @return The initialized Template
 */
+ (DKMapReduce *)countForKeys:(NSArray *)keys;

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
@property (nonatomic, copy) DKMapReduceResultProcessorBlock resultProcessor;

/** @name Providing Functions */

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

@end

//
//  DKQuery.h
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKConstants.h"


@class DKEntity;
@class DKMapReduce;

typedef void (^DKQueryResultBlock)(DKEntity *entity, NSError *error);
typedef void (^DKQueryResultsBlock)(NSArray *results, NSError *error);
typedef void (^DKQueryMapReduceBlock)(id result, NSError *error);
typedef void (^DKQueryResultCountBlock)(NSUInteger count, NSError *error);

/**
 Class for performing queries on entity collections.
 */
@interface DKQuery : NSObject

/** @name Options */

/**
 The entity name to perform the query on
 */
@property (nonatomic, copy, readonly) NSString *entityName;

/**
 Limit number of returned results
 */
@property (nonatomic, assign) NSUInteger limit;

/**
 Number of results to skip. Will be ignored if map reduce is set.
 */
@property (nonatomic, assign) NSUInteger skip;

/**
 The cache policy to use for the query.
 */
@property (nonatomic, assign) DKCachePolicy cachePolicy;

/** @name Creating and Initializing Queries */

/**
 Creates a new query for the given entity name
 @param entityName The name of the entity to query
 @return The initialized query
 */
+ (DKQuery *)queryWithEntityName:(NSString *)entityName;

/**
 Initializes a new query for the given entity name
 @param entityName The name of the entity to fetch.
 @return The initialized query
 */
- (id)initWithEntityName:(NSString *)entityName;

/** @name Ordering */

/**
 Sorts the query in ascending order by key
 
 This key will be ignored when a map reduce is performed.
 @param key The sort key
 */
- (void)orderAscendingByKey:(NSString *)key;

/**
 Sorts the query in descending order by key
 
 This key will be ignored when a map reduce is performed.
 @param key The sort key
 */
- (void)orderDescendingByKey:(NSString *)key;

/** @name Logical Operators */

/**
 Add an **OR** condition to the query using the proxy object

    [[query or] whereKey:@"key" equalTo:@"value"];
    [[query or] whereKey:@"key2" equalTo:@"value2"];
 
 Conditions performed on the **OR** proxy will be concatenated with **OR**.
 
 @return or The OR proxy object.
 */
- (DKQuery *)or;

/**
 Add an **AND** condition using the proxy object
 
    [[query and] whereKey:@"key" equalTo:@"value"];
    [[query and] whereKey:@"key2" equalTo:@"value2"];
 
 Conditions performed on the **AND** proxy will be concatenated with **AND**.
 @return and The AND proxy object.
 */
- (DKQuery *)and;

/** @name Conditions */

/**
 Adds an equal condition to the query
 @param key The entity key
 @param object The condition object
 */
- (void)whereKey:(NSString *)key equalTo:(id)object;

/**
 Adds a less-than condition to the query
 @param key The entity key
 @param object The condition object
 */
- (void)whereKey:(NSString *)key lessThan:(id)object;

/**
 Adds a less-than-or-equal condition to the query
 @param key The entity key
 @param object The condition object
 */
- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object;

/*!
 Adds a greater-than condition to the query
 @param key The entity key
 @param object The condition object
 */
- (void)whereKey:(NSString *)key greaterThan:(id)object;

/**
 Adds a greater-than-or-equal condition to the query
 @param key The entity key
 @param object The condition object
 */
- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object;

/**
 Adds an not-equal condition to the query
 @param key The entity key
 @param object The condition object
 */
- (void)whereKey:(NSString *)key notEqualTo:(id)object;

/**
 Adds an contained-in condition to the query
 
 The key value must be contained in the given array.
 @param key The entity key
 @param array The objects to check
 */
- (void)whereKey:(NSString *)key containedIn:(NSArray *)array;

/**
 Adds an not-contained-in condition to the query
 
 The key value must not be contained in the given array.
 @param key The entity key
 @param array The objects to check
 */
- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array;

/**
 Adds an contains-all condition to the query
 
 The key value must contain all values in the given array.
 @param key The entity key
 @param array The objects to check
 */
- (void)whereKey:(NSString *)key containsAllIn:(NSArray *)array;

/**
 Matches the regex with no options set
 @param key The entity key
 @param regex The regex to match
 @see <whereKey:matchesRegex:options:>
 */
- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex;

/**
 Matches the regex using the provided option mask
 @param key The entity key
 @param regex The regex to match
 @param options The regex options
 */
- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex options:(DKRegexOption)options;

/**
 Checks if the object for key contains the string
 @param key The entity key
 @param string The string to match
 */
- (void)whereKey:(NSString *)key containsString:(NSString *)string;

/**
 Checks if the object for key has the given prefix
 @param key The entity key
 @param prefix The prefix string to match
 */
- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix;

/**
 Checks if the object for key has the given suffix
 @param key The entity key
 @param suffix The suffix string to match
 */
- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix;

/**
 Checks if the entity key exists
 @param key The entity key
 */
- (void)whereKeyExists:(NSString *)key;

/**
 Checks if the entity key does not exist
 @param key The entity key
 */
- (void)whereKeyDoesNotExist:(NSString *)key;

/**
 Checks if the entity ID key matches
 @param entityId The entity ID to match
 */
- (void)whereEntityIdMatches:(NSString *)entityId;

/**
 Checks if the entity sequence number matches
 @param sequenceNum The sequence number to match
 */
- (void)whereSequenceNumberMatches:(NSUInteger)sequenceNum;

/** @name Entity Referencing */

/**
 Include the <DKEntity> that has a stored <DKRelation> at `key`.
 
 This is similar to a **JOIN** in a RDBMS.
 @param key The key to include. The object stored at `key` must be a <DKRelation> object.
 @warning ***Important***: This operation might impact the query performance quite significantly if the query result set is large!
 */
- (void)includeReferenceAtKey:(NSString *)key;

/** @name Getting Entity Key Subsets */

- (void)excludeKeys:(NSArray *)keys;
- (void)includeKeys:(NSArray *)keys;

/** @name Executing Queries */

/**
 Finds all matching entities
 @return The matching entities
 */
- (NSArray *)findAll;

/**
 Finds all matching entities
 @param error The error object to set on error
 @return The matching entities
 */
- (NSArray *)findAll:(NSError **)error;

/**
 Finds all matching entities in the background and returns them to the callback block
 @param block The result callback
 */
- (void)findAllInBackgroundWithBlock:(DKQueryResultsBlock)block;

/**
 Finds the first matching entity
 @return The matched entity
 */
- (DKEntity *)findOne;

/**
 Finds the first matching entity
 @param error The error object written on error
 @return The matched entity
 */
- (DKEntity *)findOne:(NSError **)error;

/**
 Finds the first matching entity in the background and returns it to the callback block
 @param block The result callback block
 */
- (void)findOneInBackgroundWithBlock:(DKQueryResultBlock)block;

/** @name Performing a MapReduce */

/**
 Performs the map reduce
 @param mapReduce The map reduce operation
 @return The map reduce result object
 */
- (id)performMapReduce:(DKMapReduce *)mapReduce;

/**
 Performs the map reduce
 @param mapReduce The map reduce operation
 @param error The error object to set on error
 @return The map reduce result object
 */
- (id)performMapReduce:(DKMapReduce *)mapReduce error:(NSError **)error;

/**
 Performs the map reduce in the background and invokes the callback on finish
 @param mapReduce The map reduce operation
 @param block The result callback block
 */
- (void)performMapReduce:(DKMapReduce *)mapReduce inBackgroundWithBlock:(DKQueryMapReduceBlock)block;

/** @name Aggregation */

/**
 Counts the entities matching the query
 @return The matched entity count
 */
- (NSInteger)countAll;

/**
 Counts the entities matching the query
 @param error The error object that is written on error
 @return The matched entity count
 */
- (NSInteger)countAll:(NSError **)error;

/**
 Counts the entities matching the query in the background and returns the result to the block
 @param block The result callback block
 */
- (void)countAllInBackgroundWithBlock:(DKQueryResultCountBlock)block;

/** @name Resetting Conditions */

/**
 Resets all query conditions
 */
- (void)reset;

+ (id)new UNAVAILABLE_ATTRIBUTE;
- (id)init UNAVAILABLE_ATTRIBUTE;

@end

//
//  DKQuery.h
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKConstants.h"


@class DKEntity;

typedef void (^DKQueryResultBlock)(NSArray *results, NSError *error);

@interface DKQuery : NSObject
@property (nonatomic, copy, readonly) NSString *entityName;

/*!
 @property limit 
 @abstract Limit of query results.
 */
@property (nonatomic, assign) NSUInteger limit;

/*!
 @property skip
 @abstract Number of results to skip.
 */
@property (nonatomic, assign) NSUInteger skip;

@property (nonatomic, assign) DKCachePolicy cachePolicy;

/*!
 @param entityName The name of the entity to fetch.
 @abstract Initializes a new query for the given entity name.
 */
+ (DKQuery *)queryWithEntityName:(NSString *)entityName;

+ (DKEntity *)getEntity:(NSString *)entityName withId:(NSString *)entityId UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
+ (DKEntity *)getEntity:(NSString *)entityName withId:(NSString *)entityId error:(NSError **)error UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
+ (void)clearAllCachedResults UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
+ (id)new UNAVAILABLE_ATTRIBUTE;

- (id)init UNAVAILABLE_ATTRIBUTE;

/*!
 @param entityName The name of the entity to fetch.
 @abstract Initializes a new query for the given entity name.
 */
- (id)initWithEntityName:(NSString *)entityName;

/*!
 @abstract Resets all query conditions
 */
- (void)reset;

/*!
 @return or The OR proxy object.
 @abstract Add an OR condition using the proxy object.
 */
- (DKQuery *)or;

/*!
 @return and The AND proxy object.
 @abstract Add an AND condition using the proxy object.
 */
- (DKQuery *)and;

/*!
 @param key The sort key
 @abstract Sorts the query in ascending order by key.
 */
- (void)orderAscendingByKey:(NSString *)key;

/*!
 @param key The sort key
 @abstract Sorts the query in descending order by key.
 */
- (void)orderDescendingByKey:(NSString *)key;

/*!
 @param key The entity key
 @param object The condition object
 @abstract Adds an equal condition to the query.
 */
- (void)whereKey:(NSString *)key equalTo:(id)object;

/*!
 @param key The entity key
 @param object The condition object
 @abstract Adds a less-than condition to the query.
 */
- (void)whereKey:(NSString *)key lessThan:(id)object;

/*!
 @param key The entity key
 @param object The condition object
 @abstract Adds a less-than-or-equal condition to the query.
 */
- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object;

/*!
 @param key The entity key
 @param object The condition object
 @abstract Adds a greater-than condition to the query.
 */
- (void)whereKey:(NSString *)key greaterThan:(id)object;

/*!
 @param key The entity key
 @param object The condition object
 @abstract Adds a greater-than-or-equal condition to the query.
 */
- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object;

/*!
 @param key The entity key
 @param object The condition object
 @abstract Adds an not-equal condition to the query.
 */
- (void)whereKey:(NSString *)key notEqualTo:(id)object;

/*!
 @param key The entity key
 @param array The objects to check
 @abstract Adds an contained-in condition to the query.
 @discussion The key value must be contained in the given array.
 */
- (void)whereKey:(NSString *)key containedIn:(NSArray *)array;

/*!
 @param key The entity key
 @param array The objects to check
 @abstract Adds an not-contained-in condition to the query.
 @discussion The key value must not be contained in the given array.
 */
- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array;

/*!
 @param key The entity key
 @param array The objects to check
 @abstract Adds an contains-all condition to the query.
 @discussion The key value must contain all values in the given array.
 */
- (void)whereKey:(NSString *)key containsAllIn:(NSArray *)array;

/*!
 @param key The entity key
 @param regex The regex to match
 @abstract Matches the regex with no options set
 */
- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex;

/*!
 @param key The entity key
 @param regex The regex to match
 @param options The regex options
 @abstract Matches the regex using the provided option mask
 */
- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex options:(DKRegexOption)options;

/*!
 @param key The entity key
 @param string The string to match
 @abstract Checks if the object for key contains the string
 */
- (void)whereKey:(NSString *)key containsString:(NSString *)string;

/*!
 @param key The entity key
 @param prefix The prefix string to match
 @abstract Checks if the object for key has the given prefix
 */
- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix;

/*!
 @param key The entity key
 @param suffix The suffix string to match
 @abstract Checks if the object for key has the given suffix
 */
- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix;

/*!
 @param key The entity key
 @abstract Checks if the entity key exists.
 */
- (void)whereKeyExists:(NSString *)key;

/*!
 @param key The entity key
 @abstract Checks if the entity key does not exist.
 */
- (void)whereKeyDoesNotExist:(NSString *)key;

- (void)includeKey:(NSString *)key UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED

/*!
 @return The matching entities
 @abstract Finds all matching entities.
 */
- (NSArray *)findAll;

/*!
 @param error Error object if error occurred
 @return The matching entities
 @abstract Finds all matching entities.
 */
- (NSArray *)findAll:(NSError **)error;

- (void)findObjectsInBackgroundWithBlock:(DKQueryResultBlock)block UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (id)getFirstObject UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (id)getFirstObject:(NSError **)error UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (void)getFirstObjectInBackgroundWithBlock:(DKQueryResultBlock)block UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (NSInteger)countObjects UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (NSInteger)countObjects:(NSError **)error UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (void)countObjectsInBackgroundWithBlock:(DKQueryResultBlock)block UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (DKEntity *)getEntityById:(NSString *)entityId UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (DKEntity *)getEntityById:(NSString *)entityId error:(NSError **)error UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (void)getEntityById:(NSString *)entityId inBackgroundWithBlock:(DKQueryResultBlock)block UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (void)cancel UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (BOOL)hasCachedResult UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED
- (void)clearCachedResult UNAVAILABLE_ATTRIBUTE; // UNIMPLEMENTED

@end

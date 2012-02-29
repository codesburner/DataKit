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
@property (nonatomic, assign) NSUInteger limit UNIMPLEMENTED;
@property (nonatomic, assign) NSUInteger skip UNIMPLEMENTED;
@property (nonatomic, assign) DKCachePolicy cachePolicy;

/*!
 @method queryWithEntityName:
 @param entityName The name of the entity to fetch.
 @abstract Initializes a new query for the given entity name.
 */
+ (DKQuery *)queryWithEntityName:(NSString *)entityName;

+ (DKEntity *)getEntity:(NSString *)entityName withId:(NSString *)entityId UNIMPLEMENTED;
+ (DKEntity *)getEntity:(NSString *)entityName withId:(NSString *)entityId error:(NSError **)error UNIMPLEMENTED;
+ (void)clearAllCachedResults UNIMPLEMENTED;
+ (id)new UNAVAILABLE_ATTRIBUTE;

- (id)init UNAVAILABLE_ATTRIBUTE;

/*!
 @method initWithEntityName:
 @param entityName The name of the entity to fetch.
 @abstract Initializes a new query for the given entity name.
 */
- (id)initWithEntityName:(NSString *)entityName;

/*!
 @method reset
 @abstract Resets all query conditions
 */
- (void)reset;

- (void)orderAscendingByKey:(NSString *)key UNIMPLEMENTED;
- (void)orderDescendingByKey:(NSString *)key UNIMPLEMENTED;

/*!
 @method whereKey:equalTo:
 @param key The entity key
 @param object The object to check for equality.
 @abstract Adds an equal condition to the query.
 */
- (void)whereKey:(NSString *)key equalTo:(id)object;

- (void)whereKey:(NSString *)key lessThan:(id)object UNIMPLEMENTED;
- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object UNIMPLEMENTED;
- (void)whereKey:(NSString *)key greaterThan:(id)object UNIMPLEMENTED;
- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object UNIMPLEMENTED;
- (void)whereKey:(NSString *)key notEqualTo:(id)object UNIMPLEMENTED;
- (void)whereKey:(NSString *)key containedIn:(NSArray *)array UNIMPLEMENTED;
- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array UNIMPLEMENTED;
- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex UNIMPLEMENTED;
- (void)whereKey:(NSString *)key containsString:(NSString *)string UNIMPLEMENTED;
- (void)whereKey:(NSString *)key hasPrefix:(NSString *)string UNIMPLEMENTED;
- (void)whereKey:(NSString *)key hasSuffix:(NSString *)string UNIMPLEMENTED;
- (void)whereKeyExists:(NSString *)key UNIMPLEMENTED;
- (void)whereKeyDoesNotExist:(NSString *)key UNIMPLEMENTED;
- (void)includeKey:(NSString *)key UNIMPLEMENTED;

/*!
 @method findAll
 @return The matching entities
 @abstract Finds all matching entities.
 */
- (NSArray *)findAll;

/*!
 @method findAll:
 @param error Error object if error occurred
 @return The matching entities
 @abstract Finds all matching entities.
 */
- (NSArray *)findAll:(NSError **)error;

- (void)findObjectsInBackgroundWithBlock:(DKQueryResultBlock)block UNIMPLEMENTED;
- (id)getFirstObject UNIMPLEMENTED;
- (id)getFirstObject:(NSError **)error UNIMPLEMENTED;
- (void)getFirstObjectInBackgroundWithBlock:(DKQueryResultBlock)block UNIMPLEMENTED;
- (NSInteger)countObjects UNIMPLEMENTED;
- (NSInteger)countObjects:(NSError **)error UNIMPLEMENTED;
- (void)countObjectsInBackgroundWithBlock:(DKQueryResultBlock)block UNIMPLEMENTED;
- (DKEntity *)getEntityById:(NSString *)entityId UNIMPLEMENTED;
- (DKEntity *)getEntityById:(NSString *)entityId error:(NSError **)error UNIMPLEMENTED;
- (void)getEntityById:(NSString *)entityId inBackgroundWithBlock:(DKQueryResultBlock)block UNIMPLEMENTED;
- (void)cancel UNIMPLEMENTED;
- (BOOL)hasCachedResult UNIMPLEMENTED;
- (void)clearCachedResult UNIMPLEMENTED;

@end

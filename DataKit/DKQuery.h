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
@property (nonatomic, assign) NSUInteger limit;
@property (nonatomic, assign) NSUInteger skip;
@property (nonatomic, assign) DKCachePolicy cachePolicy;

+ (DKQuery *)queryWithEntityName:(NSString *)entityName;
+ (DKEntity *)getEntity:(NSString *)entityName withId:(NSString *)entityId UNIMPLEMENTED;
+ (DKEntity *)getEntity:(NSString *)entityName withId:(NSString *)entityId error:(NSError **)error UNIMPLEMENTED;
+ (void)clearAllCachedResults UNIMPLEMENTED;
+ (id)new UNAVAILABLE_ATTRIBUTE;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithEntityName:(NSString *)entityName;

- (void)orderAscendingByKey:(NSString *)key UNIMPLEMENTED;
- (void)orderDescendingByKey:(NSString *)key UNIMPLEMENTED;
- (void)whereKey:(NSString *)key equalTo:(id)object UNIMPLEMENTED;
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
- (NSArray *)findObjects UNIMPLEMENTED;
- (NSArray *)findObjects:(NSError **)error UNIMPLEMENTED;
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

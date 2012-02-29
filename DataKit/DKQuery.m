//
//  DKQuery.m
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKQuery.h"

@interface DKQuery ()
@property (nonatomic, copy, readwrite) NSString *entityName;
@end

@implementation DKQuery
DKSynthesize(entityName)
DKSynthesize(limit)
DKSynthesize(skip)
DKSynthesize(cachePolicy)

+ (DKQuery *)queryWithEntityName:(NSString *)entityName {
  return [[self alloc] initWithName:entityName];
}

+ (DKEntity *)getEntity:(NSString *)entityName withId:(NSString *)entityId {
  return nil;
}

+ (DKEntity *)getEntity:(NSString *)entityName withId:(NSString *)entityId error:(NSError **)error {
  return nil;
}

+ (void)clearAllCachedResults {
  
}

- (id)initWithEntityName:(NSString *)entityName {
  self = [super init];
  if (self) {
    self.entityName = entityName;
  }
  return self;
}

- (void)orderAscendingByKey:(NSString *)key {
  
}

- (void)orderDescendingByKey:(NSString *)key {
  
}

- (void)whereKey:(NSString *)key equalTo:(id)object {
  
}

- (void)whereKey:(NSString *)key lessThan:(id)object {
  
}

- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object {
  
}

- (void)whereKey:(NSString *)key greaterThan:(id)object {
  
}

- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object {
  
}

- (void)whereKey:(NSString *)key notEqualTo:(id)object {
  
}

- (void)whereKey:(NSString *)key containedIn:(NSArray *)array {
  
}

- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array {
  
}

- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex {
  
}

- (void)whereKey:(NSString *)key containsString:(NSString *)string {
  
}

- (void)whereKey:(NSString *)key hasPrefix:(NSString *)string {
  
}

- (void)whereKey:(NSString *)key hasSuffix:(NSString *)string {
  
}

- (void)whereKeyExists:(NSString *)key {
  
}

- (void)whereKeyDoesNotExist:(NSString *)key {
  
}

- (void)includeKey:(NSString *)key {
  
}

- (NSArray *)findObjects {
  return nil;
}

- (NSArray *)findObjects:(NSError **)error {
  return nil;
}

- (void)findObjectsInBackgroundWithBlock:(DKQueryResultBlock)block {
  
}

- (id)getFirstObject {
  return nil;
}

- (id)getFirstObject:(NSError **)error {
  return nil;
}

- (void)getFirstObjectInBackgroundWithBlock:(DKQueryResultBlock)block {
  
}

- (NSInteger)countObjects {
  return -1;
}

- (NSInteger)countObjects:(NSError **)error {
  return -1;
}

- (void)countObjectsInBackgroundWithBlock:(DKQueryResultBlock)block {
  
}

- (DKEntity *)getEntityById:(NSString *)entityId {
  return nil;
}

- (DKEntity *)getEntityById:(NSString *)entityId error:(NSError **)error {
  return nil;
}

- (void)getEntityById:(NSString *)entityId inBackgroundWithBlock:(DKQueryResultBlock)block {
  
}

- (void)cancel {
  
}

- (BOOL)hasCachedResult {
  return NO;
}

- (void)clearCachedResult {
  
}


@end

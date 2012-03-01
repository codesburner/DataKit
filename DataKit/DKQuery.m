//
//  DKQuery.m
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKQuery.h"

#import "DKQuery-Private.h"
#import "DKRequest.h"
#import "DKEntity.h"
#import "DKEntity-Private.h"

@implementation DKQuery
DKSynthesize(entityName)
DKSynthesize(limit)
DKSynthesize(skip)
DKSynthesize(cachePolicy)
DKSynthesize(equalToMap)
DKSynthesize(gltMap)

+ (DKQuery *)queryWithEntityName:(NSString *)entityName {
  return [[self alloc] initWithEntityName:entityName];
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
    self.equalToMap = [NSMutableDictionary new];
    self.gltMap = [NSMutableDictionary new];
    self.cachePolicy = DKCachePolicyIgnoreCache;
  }
  return self;
}

- (void)reset {
  [self.equalToMap removeAllObjects];
  [self.gltMap removeAllObjects];
}

- (void)orderAscendingByKey:(NSString *)key {
  
}

- (void)orderDescendingByKey:(NSString *)key {
  
}

- (void)whereKey:(NSString *)key equalTo:(id)object {
  [self.equalToMap setObject:object forKey:key];
}

- (void)whereKey:(NSString *)key lessThan:(id)object {
  NSMutableDictionary *dict = [self.gltMap objectForKey:key];
  if (dict == nil) {
    dict = [NSMutableDictionary new];
    [self.gltMap setObject:dict forKey:key];
  }
  [dict setObject:object forKey:@"$lt"];
}

- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object {
  NSMutableDictionary *dict = [self.gltMap objectForKey:key];
  if (dict == nil) {
    dict = [NSMutableDictionary new];
    [self.gltMap setObject:dict forKey:key];
  }
  [dict setObject:object forKey:@"$lte"];
}

- (void)whereKey:(NSString *)key greaterThan:(id)object {
  NSMutableDictionary *dict = [self.gltMap objectForKey:key];
  if (dict == nil) {
    dict = [NSMutableDictionary new];
    [self.gltMap setObject:dict forKey:key];
  }
  [dict setObject:object forKey:@"$gt"];
}

- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object {
  NSMutableDictionary *dict = [self.gltMap objectForKey:key];
  if (dict == nil) {
    dict = [NSMutableDictionary new];
    [self.gltMap setObject:dict forKey:key];
  }
  [dict setObject:object forKey:@"$gte"];
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

- (NSArray *)findAll {
  return [self findAll:NULL];
}

- (NSArray *)findAll:(NSError **)error {
  // Create request dict
  NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      self.entityName, @"entity", nil];
  if (self.equalToMap.count > 0) {
    [requestDict setObject:self.equalToMap forKey:@"eql"];
  }
  if (self.gltMap.count > 0) {
    [requestDict setObject:self.gltMap forKey:@"glt"];
  }
  
  // Send request synchronously
  DKRequest *request = [DKRequest request];
  request.cachePolicy = self.cachePolicy;
  
  NSError *requestError = nil;
  NSArray *results = [request sendRequestWithObject:requestDict method:@"query" error:&requestError];
  if (requestError != nil) {
    if (error != nil) {
      *error = requestError;
    }
    return nil;
  }
  
  if ([results isKindOfClass:[NSArray class]]) {
    NSMutableArray *entities = [NSMutableArray new];
    for (NSDictionary *objDict in results) {
      if ([objDict isKindOfClass:[NSDictionary class]]) {
        DKEntity *entity = [[DKEntity alloc] initWithName:self.entityName];
        entity.resultMap = objDict;
        
        [entities addObject:entity];
      }
    }
    
    return [NSArray arrayWithArray:entities];
  }
  else {
#ifdef CONFIGURATION_Debug
    NSLog(@"warning: query did not return object list");
#endif
  }
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

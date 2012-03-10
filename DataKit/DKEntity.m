//
//  DKEntity.m
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKEntity.h"
#import "DKEntity-Private.h"

#import "DKRelation.h"
#import "DKRequest.h"
#import "DKConstants.h"
#import "DKManager.h"

@implementation DKEntity
DKSynthesize(entityName)
DKSynthesize(setMap)
DKSynthesize(unsetMap)
DKSynthesize(incMap)
DKSynthesize(pushMap)
DKSynthesize(pushAllMap)
DKSynthesize(addToSetMap)
DKSynthesize(popMap)
DKSynthesize(pullAllMap)
DKSynthesize(resultMap)

#define kDKEntityIDField @"_id"
#define kDKEntityUpdatedField @"_updated"

static dispatch_queue_t kDKObjectQueue_;

+ (void)initialize {
  kDKObjectQueue_ = dispatch_queue_create("entity queue", DISPATCH_QUEUE_SERIAL);
}

+ (DKEntity *)entityWithName:(NSString *)entityName {
  return [[self alloc] initWithName:entityName];
}

+ (BOOL)saveAll:(NSArray *)objects {
  return [self saveAll:objects error:NULL];
}

+ (BOOL)saveAll:(NSArray *)objects error:(NSError **)error {
  NSMutableArray *requestObjects = [NSMutableArray new];
  
  for (DKEntity *entity in objects) {
    // Check if data has been written
    if (!entity.isDirty) {
      return YES;
    }
    
    // Prevent use of '!', '$' and '.' in keys
    static NSCharacterSet *forbiddenChars;
    if (forbiddenChars == nil) {
      forbiddenChars = [NSCharacterSet characterSetWithCharactersInString:@"$."];
    }
    
    __block id (^validateKeys)(id obj);
    validateKeys = [^(id obj) {
      if ([obj isKindOfClass:[NSDictionary class]]) {
        for (NSString *key in obj) {
          NSRange range = [key rangeOfCharacterFromSet:forbiddenChars];
          if (range.location != NSNotFound) {
            [NSException raise:NSInvalidArgumentException
                        format:@"Invalid object key '%@'. Keys may not contain '$' or '.'", key];
          }
          id obj2 = [obj objectForKey:key];
          validateKeys(obj2);
        }
      }
      else if ([obj isKindOfClass:[NSArray class]]) {
        for (id obj2 in obj) {
          validateKeys(obj2);
        }
      }
      return obj;
    } copy];
    
    // Create request dict
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        entity.entityName, @"entity", nil];
    if (entity.setMap.count > 0) {
      [requestDict setObject:validateKeys(entity.setMap) forKey:@"set"];
    }
    if (entity.unsetMap.count > 0) {
      [requestDict setObject:validateKeys(entity.unsetMap) forKey:@"unset"];
    }
    if (entity.incMap.count > 0) {
      [requestDict setObject:validateKeys(entity.incMap) forKey:@"inc"];
    }
    if (entity.pushMap.count > 0) {
      [requestDict setObject:validateKeys(entity.pushMap) forKey:@"push"];
    }
    if (entity.pushAllMap.count > 0) {
      [requestDict setObject:validateKeys(entity.pushAllMap) forKey:@"pushAll"];
    }
    if (entity.addToSetMap.count > 0) {
      [requestDict setObject:validateKeys(entity.addToSetMap) forKey:@"addToSet"];
    }
    if (entity.popMap.count > 0) {
      [requestDict setObject:validateKeys(entity.popMap) forKey:@"pop"];
    }
    if (entity.pullAllMap.count > 0) {
      [requestDict setObject:validateKeys(entity.pullAllMap) forKey:@"pullAll"];
    }
    
    NSString *oid = entity.entityId;
    if (oid.length > 0) {
      [requestDict setObject:oid forKey:@"oid"];
    }
    
    [requestObjects addObject:requestDict];
  }
  
  NSArray *results = nil;
  if (requestObjects.count > 0) {    
    // Send request synchronously
    DKRequest *request = [DKRequest request];
    request.cachePolicy = DKCachePolicyIgnoreCache;
    
    NSError *requestError = nil;
    results = [request sendRequestWithObject:requestObjects method:@"save" error:&requestError];
    if (requestError != nil) {
      if (error != nil) {
        *error = requestError;
      }
      return NO;
    }
  }
  
  NSUInteger i = 0;
  for (DKEntity *entity in objects) {
    NSError *commitError = nil;
    BOOL success = [entity commitObjectResultMap:[results objectAtIndex:i]
                                           error:&commitError];
    if (!success) {
      if (error != NULL) {
        *error = commitError;
      }
      return NO;
    }
    i++;
  }
  
  return YES;
}

+ (void)saveAllInBackground:(NSArray *)objects {
  [self saveAllInBackground:objects withBlock:NULL];
}

+ (void)saveAllInBackground:(NSArray *)objects withBlock:(DKEntityResultsBlock)block {
  block = [block copy];
  dispatch_queue_t q = dispatch_get_current_queue();
  dispatch_async(kDKObjectQueue_, ^{
    NSError *error = nil;
    [self saveAll:objects error:&error];
    if (block != NULL) {
      dispatch_async(q, ^{
        block(objects, error); 
      });
    }
  });
}

- (id)initWithName:(NSString *)entityName {
  self = [super init];
  if (self) {
    self.entityName = entityName;
    self.setMap = [NSMutableDictionary new];
    self.unsetMap = [NSMutableDictionary new];
    self.incMap = [NSMutableDictionary new];
    self.pushMap = [NSMutableDictionary new];
    self.pushAllMap = [NSMutableDictionary new];
    self.addToSetMap = [NSMutableDictionary new];
    self.popMap = [NSMutableDictionary new];
    self.pullAllMap = [NSMutableDictionary new];
  }
  return self;
}

- (NSString *)entityId {
  NSString *eid = [self.resultMap objectForKey:kDKEntityIDField];
  if ([eid isKindOfClass:[NSString class]]) {
    return eid;
  }
  return nil;
}

- (DKRelation *)entityPointer {
  if (self.entityId.length > 0 &&
      self.entityName.length > 0) {
    return [DKRelation relationWithEntityName:self.entityName
                                     entityId:self.entityId];
  }
  return nil;
}

- (NSDate *)updatedAt {
  NSNumber *updatedAt = [self.resultMap objectForKey:kDKEntityUpdatedField];
  if ([updatedAt isKindOfClass:[NSNumber class]]) {
    return [NSDate dateWithTimeIntervalSince1970:[updatedAt doubleValue]];
  }
  return nil;
}

- (NSDate *)createdAt {
  NSString *eid = self.entityId;
  if (eid.length > 8) {
    // Parse the object id creation timestamp (firts 4 bytes of oid)
    NSString *timestampHex = [eid substringToIndex:8];
    NSScanner *scanner = [NSScanner scannerWithString:timestampHex];
    
    unsigned int timestamp;
    if ([scanner scanHexInt:&timestamp]) {
      return [NSDate dateWithTimeIntervalSince1970:timestamp];
    }
  }
  return nil;
}

- (NSInteger)sequenceNumber {
  NSNumber *seq = [self.resultMap objectForKey:@"_seq"];
  if (seq != nil) {
    return [seq integerValue];
  }
  return -1;
}

- (BOOL)isNew {
  return (self.entityId.length == 0);
}

- (BOOL)isDirty {
  return (self.setMap.count +
          self.unsetMap.count +
          self.incMap.count +
          self.pushMap.count +
          self.pushAllMap.count +
          self.addToSetMap.count +
          self.popMap.count +
          self.pullAllMap.count) > 0;
}

- (void)reset {
  [self.setMap removeAllObjects];
  [self.unsetMap removeAllObjects];
  [self.incMap removeAllObjects];
  [self.pushMap removeAllObjects];
  [self.pushAllMap removeAllObjects];
  [self.addToSetMap removeAllObjects];
  [self.popMap removeAllObjects];
  [self.pullAllMap removeAllObjects];
}

- (BOOL)save {
  return [self save:NULL];
}

- (BOOL)save:(NSError **)error {
  return [isa saveAll:[NSArray arrayWithObject:self] error:error];
}

- (void)saveInBackground {
  [self saveInBackgroundWithBlock:NULL];
}

- (void)saveInBackgroundWithBlock:(DKEntityResultBlock)block {
  block = [block copy];
  dispatch_queue_t q = dispatch_get_current_queue();
  dispatch_async(kDKObjectQueue_, ^{
    NSError *error = nil;
    [self save:&error];
    if (block != NULL) {
      dispatch_async(q, ^{
        block(self, error); 
      });
    }
  });
}

- (BOOL)refresh {
  return [self refresh];
}

- (BOOL)refresh:(NSError **)error {
  // Check for valid object ID and entity name
  if (!([self hasEntityId:error] &&
        [self hasEntityName:error])) {
    return NO;
  }
  
  // Create request dict
  NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.entityName, @"entity",
                               self.entityId, @"oid", nil];
  
  // Send request synchronously
  DKRequest *request = [DKRequest request];
  request.cachePolicy = DKCachePolicyIgnoreCache;
  
  NSError *requestError = nil;
  id resultMap = [request sendRequestWithObject:requestDict method:@"refresh" error:&requestError];
  if (requestError != nil) {
    if (error != nil) {
      *error = requestError;
    }
    return NO;
  }
  
  return [self commitObjectResultMap:resultMap error:error];
}

- (void)refreshInBackground {
  [self refreshInBackgroundWithBlock:NULL];
}

- (void)refreshInBackgroundWithBlock:(DKEntityResultBlock)block {
  block = [block copy];
  dispatch_queue_t q = dispatch_get_current_queue();
  dispatch_async(kDKObjectQueue_, ^{
    NSError *error = nil;
    [self refresh:&error];
    if (block != NULL) {
      dispatch_async(q, ^{
        block(self, error); 
      });
    }
  });
}

- (BOOL)delete {
  return [self delete:NULL];
}

- (BOOL)delete:(NSError **)error {
  // Check for valid object ID and entity name
  if (!([self hasEntityId:error] &&
        [self hasEntityName:error])) {
    return NO;
  }
  
  // Create request dict
  NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.entityName, @"entity",
                               self.entityId, @"oid", nil];
  
  // Send request synchronously
  DKRequest *request = [DKRequest request];
  request.cachePolicy = DKCachePolicyIgnoreCache;
  
  NSError *requestError = nil;
  [request sendRequestWithObject:requestDict method:@"delete" error:&requestError];
  if (requestError != nil) {
    if (error != nil) {
      *error = requestError;
    }
    return NO;
  }
  
  // Remove maps
  self.resultMap = [NSDictionary new];

  [self reset];
  
  return YES;
}

- (void)deleteInBackground {
  [self deleteInBackgroundWithBlock:NULL];
}

- (void)deleteInBackgroundWithBlock:(DKEntityResultBlock)block {
  block = [block copy];
  dispatch_queue_t q = dispatch_get_current_queue();
  dispatch_async(kDKObjectQueue_, ^{
    NSError *error = nil;
    [self delete:&error];
    if (block != NULL) {
      dispatch_async(q, ^{
        block(self, error); 
      });
    }
  });
}

- (BOOL)ensureIndexForKey:(NSString *)key {
  return [self ensureIndexForKey:key unique:NO dropDuplicates:NO error:NULL];
}

- (BOOL)ensureIndexForKey:(NSString *)key unique:(BOOL)unique dropDuplicates:(BOOL)dropDups error:(NSError **)error {
  // Create request dict
  NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.entityName, @"entity",
                               key, @"key",
                               [NSNumber numberWithBool:unique], @"unique",
                               [NSNumber numberWithBool:dropDups], @"drop", nil];
  
  // Send request synchronously
  DKRequest *request = [DKRequest request];
  request.cachePolicy = DKCachePolicyIgnoreCache;
  
  NSError *requestError = nil;
  [request sendRequestWithObject:requestDict method:@"index" error:&requestError];
  if (requestError != nil) {
    if (error != nil) {
      *error = requestError;
    }
    return NO;
  }
  
  return YES;
}

- (id)objectForKey:(NSString *)key {
  id obj = [self.setMap objectForKey:key];
  if (obj == nil) {
    obj = [self.resultMap objectForKey:key];
  }
  return obj;
}

- (void)setObject:(id)object forKey:(NSString *)key {
  [self.setMap setObject:object forKey:key];
}

- (void)pushObject:(id)object forKey:(NSString *)key {
  [self.pushMap setObject:object forKey:key];
}

- (void)pushAllObjects:(NSArray *)objects forKey:(NSString *)key {
  [self.pushAllMap setObject:objects forKey:key];
}

- (void)addObjectToSet:(id)object forKey:(NSString *)key {
  [self addAllObjectsToSet:[NSArray arrayWithObject:object] forKey:key];
}

- (void)addAllObjectsToSet:(NSArray *)objects forKey:(NSString *)key {
  NSMutableArray *list = [self.addToSetMap objectForKey:key];
  if (list == nil) {
    list = [NSMutableArray new];
    [self.addToSetMap setObject:list forKey:key];
  }
  for (id obj in objects) {
    if (![list containsObject:objects]) {
      [list addObject:obj];
    }
  }
}

- (void)popObjectEnd:(NSNumber *)end forKey:(NSString *)key {
  [self.popMap setObject:end forKey:key];
}

- (void)popLastObjectForKey:(NSString *)key {
  [self popObjectEnd:[NSNumber numberWithInteger:1] forKey:key];
}

- (void)popFirstObjectForKey:(NSString *)key {
  [self popObjectEnd:[NSNumber numberWithInteger:-1] forKey:key];
}

- (void)pullObject:(id)object forKey:(NSString *)key {
  [self pullAllObjects:[NSArray arrayWithObject:object] forKey:key];
}

- (void)pullAllObjects:(NSArray *)objects forKey:(NSString *)key {
  [self.pullAllMap setObject:objects forKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
  [self.unsetMap setObject:[NSNumber numberWithInteger:1] forKey:key];
}

- (void)incrementKey:(NSString *)key {
  [self incrementKey:key byAmount:[NSNumber numberWithInteger:1]];
}

- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount {
  [self.incMap setObject:amount forKey:key];
}

- (NSURL *)generatePublicURLForFields:(NSArray *)fieldKeys error:(NSError **)error {
  // Check for valid object ID and entity name
  if (!([self hasEntityId:error] &&
        [self hasEntityName:error])) {
    return nil;
  }
  
  // Create request dict
  NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      self.entityName, @"entity",
                                      self.entityId, @"oid", nil];
  if (fieldKeys != nil) {
    [requestDict setObject:fieldKeys forKey:@"fields"];
  }
  
  // Send request synchronously
  DKRequest *request = [DKRequest request];
  request.cachePolicy = DKCachePolicyIgnoreCache;
  
  NSError *requestError = nil;
  NSString *result = [request sendRequestWithObject:requestDict method:@"publish" error:&requestError];
  if (requestError != nil || ![result isKindOfClass:[NSString class]]) {
    if (error != NULL) {
      *error = requestError;
    }
    return nil;
  }
  
  NSString *path = [@"public" stringByAppendingPathComponent:result];
  NSString *ep = [[DKManager APIEndpoint] stringByAppendingPathComponent:path];
  
  return [NSURL URLWithString:ep]; 
}

- (BOOL)isEqual:(id)object {
  if ([object isKindOfClass:isa]) {
    return [[(DKEntity *)object entityId] isEqualToString:self.entityId];
  }
  return NO;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p %@>", NSStringFromClass(isa), self, self.entityId];
}

@end

@implementation DKEntity (Private)

- (BOOL)hasEntityId:(NSError **)error {
  if (self.entityId.length == 0) {
    [NSError writeToError:error
                     code:DKErrorInvalidEntityID
              description:NSLocalizedString(@"Entity ID invalid", nil)
                 original:nil];
    return NO;
  }
  return YES;
}

- (BOOL)hasEntityName:(NSError **)error {
  if (self.entityName.length == 0) {
    [NSError writeToError:error
                     code:DKErrorInvalidEntityName
              description:NSLocalizedString(@"Entity name invalid", nil)
                 original:nil];
    return NO;
  }
  return YES;
}

- (BOOL)commitObjectResultMap:(NSDictionary *)resultMap error:(NSError **)error {
  if (![resultMap isKindOfClass:[NSDictionary class]]) {
    [NSError writeToError:error
                     code:DKErrorInvalidJSON
              description:NSLocalizedString(@"Cannot commit action because result JSON is malformed (not an object)", nil)
                 original:nil];
#ifdef CONFIGURATION_Debug
    NSLog(@"result => %@: %@", NSStringFromClass([resultMap class]), resultMap);
#endif
    return NO;
  }
  self.resultMap = resultMap;
  
  [self reset];
  
  return YES;
}

@end
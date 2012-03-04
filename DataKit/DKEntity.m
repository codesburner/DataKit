//
//  DKEntity.m
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKEntity.h"
#import "DKEntity-Private.h"

#import "DKPointer.h"
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
#define kDKEntityDataDictKey @"!dkdata"

static dispatch_queue_t kDKObjectQueue_;

+ (void)initialize {
  kDKObjectQueue_ = dispatch_queue_create("entity queue", DISPATCH_QUEUE_SERIAL);
}

+ (DKEntity *)entityWithName:(NSString *)entityName {
  return [[self alloc] initWithName:entityName];
}

+ (BOOL)saveAll:(NSArray *)objects {
  return NO;
}

+ (BOOL)saveAll:(NSArray *)objects error:(NSError **)error {
  return NO;
}

+ (BOOL)saveAllInBackground:(NSArray *)objects {
  return NO;
}

+ (BOOL)saveAllInBackground:(NSArray *)objects withBlock:(DKEntityResultBlock)block {
  return NO;
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

- (DKPointer *)entityPointer {
  if (self.entityId.length > 0 &&
      self.entityName.length > 0) {
    return [DKPointer pointerWithEntityName:self.entityName
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
  // Check if data has been written
  if (!self.isDirty) {
    return YES;
  }
  
  // Prevent use of '!', '$' and '.' in keys
  static NSCharacterSet *forbiddenChars;
  if (forbiddenChars == nil) {
    forbiddenChars = [NSCharacterSet characterSetWithCharactersInString:@"!$."];
  }
  
  __block id (^validateKeys)(id obj);
  validateKeys = [^(id obj) {
    if ([obj isKindOfClass:[NSDictionary class]]) {
      for (NSString *key in obj) {
        NSRange range = [key rangeOfCharacterFromSet:forbiddenChars];
        if (range.location != NSNotFound &&
            ![key isEqualToString:kDKEntityDataDictKey]) {
          [NSException raise:NSInvalidArgumentException
                      format:@"Invalid object key '%@'. Keys may not contain '!', '$' or '.'", key];
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
                                      self.entityName, @"entity", nil];
  if (self.setMap.count > 0) {
    [requestDict setObject:validateKeys(self.setMap) forKey:@"set"];
  }
  if (self.unsetMap.count > 0) {
    [requestDict setObject:validateKeys(self.unsetMap) forKey:@"unset"];
  }
  if (self.incMap.count > 0) {
    [requestDict setObject:validateKeys(self.incMap) forKey:@"inc"];
  }
  if (self.pushMap.count > 0) {
    [requestDict setObject:validateKeys(self.pushMap) forKey:@"push"];
  }
  if (self.pushAllMap.count > 0) {
    [requestDict setObject:validateKeys(self.pushAllMap) forKey:@"pushAll"];
  }
  if (self.addToSetMap.count > 0) {
    [requestDict setObject:validateKeys(self.addToSetMap) forKey:@"addToSet"];
  }
  if (self.popMap.count > 0) {
    [requestDict setObject:validateKeys(self.popMap) forKey:@"pop"];
  }
  if (self.pullAllMap.count > 0) {
    [requestDict setObject:validateKeys(self.pullAllMap) forKey:@"pullAll"];
  }
  
  NSString *oid = self.entityId;
  if (oid.length > 0) {
    [requestDict setObject:oid forKey:@"oid"];
  }
  
  // Send request synchronously
  DKRequest *request = [DKRequest request];
  request.cachePolicy = DKCachePolicyIgnoreCache;
  
  NSError *requestError = nil;
  id resultMap = [request sendRequestWithObject:requestDict method:@"save" error:&requestError];
  if (requestError != nil) {
    if (error != nil) {
      *error = requestError;
    }
    return NO;
  }
  
  return [self commitObjectResultMap:resultMap error:error];
}

- (void)saveInBackground {
  [self saveInBackgroundWithBlock:NULL];
}

- (void)saveInBackgroundWithBlock:(DKEntityResultBlock)block {
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

- (id)objectForKey:(NSString *)key {
  id obj = [self.setMap objectForKey:key];
  if (obj == nil) {
    obj = [self.resultMap objectForKey:key];
  }
  if ([obj isKindOfClass:[NSDictionary class]]) {
    NSString *base64 = [obj objectForKey:kDKEntityDataDictKey];
    if (base64.length > 0) {
      return [NSData dataWithBase64String:base64];
    }
  }
  return obj;
}

- (void)objectForKey:(NSString *)key inBackgroundWithBlock:(DKEntityResultBlock)block {
  
}

- (DKPointer *)pointerForKey:(NSString *)key {
  return nil;
}

- (void)setObject:(id)object forKey:(NSString *)key {
  if ([object isKindOfClass:[NSData class]]) {
    object = [NSDictionary dictionaryWithObject:[(NSData *)object base64String]
                                         forKey:kDKEntityDataDictKey];
  }
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
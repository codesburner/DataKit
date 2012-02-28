//
//  DKObject.m
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKObject.h"
#import "DKObject-Private.h"

#import "DKRequest.h"
#import "DKConstants.h"
#import "DKManager.h"

@implementation DKObject
DKSynthesize(entityName)
DKSynthesize(setMap)
DKSynthesize(unsetMap)
DKSynthesize(incMap)
DKSynthesize(resultMap)

// Database keys
#define kDKObjectIDField @"_id"
#define kDKObjectCreatedAtField @"_createdAt"
#define kDKObjectUpdatedAtField @"_updatedAt"

static dispatch_queue_t kDKObjectQueue_;

+ (void)initialize {
  kDKObjectQueue_ = dispatch_queue_create("dkobject queue", DISPATCH_QUEUE_SERIAL);
}

+ (DKObject *)objectWithEntityName:(NSString *)entityName {
  return [[self alloc] initWithEntityName:entityName];
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

+ (BOOL)saveAllInBackground:(NSArray *)objects withBlock:(DKObjectResultBlock)block {
  return NO;
}

- (id)initWithEntityName:(NSString *)entityName {
  self = [super init];
  if (self) {
    self.entityName = entityName;
    self.setMap = [NSMutableDictionary new];
    self.unsetMap = [NSMutableDictionary new];
    self.incMap = [NSMutableDictionary new];
  }
  return self;
}

- (NSString *)objectId {
  NSString *oid = [self.resultMap objectForKey:kDKObjectIDField];
  if ([oid isKindOfClass:[NSString class]]) {
    return oid;
  }
  return nil;
}

- (NSDate *)updatedAt {
  NSNumber *updatedAt = [self.resultMap objectForKey:kDKObjectUpdatedAtField];
  if ([updatedAt isKindOfClass:[NSNumber class]]) {
    return [NSDate dateWithTimeIntervalSince1970:[updatedAt doubleValue]];
  }
  return nil;
}

- (NSDate *)createdAt {
  NSNumber *createdAt = [self.resultMap objectForKey:kDKObjectCreatedAtField];
  if ([createdAt isKindOfClass:[NSNumber class]]) {
    return [NSDate dateWithTimeIntervalSince1970:[createdAt doubleValue]];
  }
  return nil;
}

- (BOOL)isNew {
  return (self.objectId.length == 0);
}

- (BOOL)isDirty {
  return (self.setMap.count + self.unsetMap.count + self.incMap.count) > 0;
}

- (void)reset {
  [self.setMap removeAllObjects];
  [self.unsetMap removeAllObjects];
  [self.incMap removeAllObjects];
}

- (BOOL)save {
  return [self save:NULL];
}

- (BOOL)save:(NSError **)error {
  // Check if data has been written
  if (!self.isDirty) {
    return YES;
  }
  
  // TODO: Prevent use of '$' and '.' in objects/keys
  
  // Create request dict
  NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      self.entityName, @"entity",
                                      self.setMap, @"set",
                                      self.unsetMap, @"unset",
                                      self.incMap, @"inc", nil];
  
  NSString *oid = self.objectId;
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

- (void)saveInBackgroundWithBlock:(DKObjectResultBlock)block {
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
  // Check if the object has an ID
  if (self.objectId.length == 0) {
    [NSError writeToError:error
                     code:DKErrorInvalidObjectID
              description:NSLocalizedString(@"Object ID invalid", nil)
                 original:nil];
    return NO;
  }
  
  // Create request dict
  NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.entityName, @"entity",
                               self.objectId, @"oid", nil];
  
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

- (void)refreshInBackgroundWithBlock:(DKObjectResultBlock)block {
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
  // Check if the object has an ID
  if (self.objectId.length == 0) {
    [NSError writeToError:error
                     code:DKErrorInvalidObjectID
              description:NSLocalizedString(@"Object ID invalid", nil)
                 original:nil];
    return NO;
  }
  
  // Create request dict
  NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.entityName, @"entity",
                               self.objectId, @"oid", nil];
  
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

- (void)deleteInBackgroundWithBlock:(DKObjectResultBlock)block {
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
  return obj;
}

- (void)objectForKey:(NSString *)key inBackgroundWithBlock:(DKObjectResultBlock)block {
  
}

- (DKPointer *)pointerForKey:(NSString *)key {
  return nil;
}

- (void)setObject:(id)object forKey:(NSString *)key {
  [self.setMap setObject:object forKey:key];
}

- (void)pushObject:(id)object forKey:(NSString *)key {
  
}

- (void)pushObjects:(NSArray *)objects forKey:(NSString *)key {

}

- (void)addObjectToSet:(id)object forKey:(NSString *)key {

}

- (void)addAllObjectsToSet:(NSArray *)objects forKey:(NSString *)key {

}

- (void)popLastObjectForKey:(NSString *)key {

}

- (void)popFirstObjectForKey:(NSString *)key {

}

- (void)pullObject:(id)object forKey:(NSString *)key {

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
  if (!([self hasObjectId:error] && [self hasEntityName:error])) {
    return nil;
  }
  
  // Create request dict
  NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      self.entityName, @"entity",
                                      self.objectId, @"oid", nil];
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

@implementation DKObject (Private)

- (BOOL)hasObjectId:(NSError **)error {
  if (self.objectId.length == 0) {
    [NSError writeToError:error
                     code:DKErrorInvalidObjectID
              description:NSLocalizedString(@"Object ID invalid", nil)
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
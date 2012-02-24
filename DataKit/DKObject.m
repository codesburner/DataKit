//
//  DKObject.m
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKObject.h"

#import "DKRequest.h"
#import "DKConstants.h"
#import "NSError+DataKit.h"

@interface DKObject ()
@property (nonatomic, copy, readwrite) NSString *entityName;
@property (nonatomic, strong) NSMutableDictionary *map;
@property (nonatomic, strong) NSDictionary *referenceMap;
@end

@interface DKObject (Private)

- (BOOL)commitObjectResultMap:(NSDictionary *)resultMap error:(NSError **)error;

@end

@implementation DKObject
DKSynthesize(entityName)
DKSynthesize(map)
DKSynthesize(referenceMap)

// Database keys
#define kDKObjectIDField @"_id"
#define kDKObjectCreatedAtField @"_createdAt"
#define kDKObjectUpdatedAtField @"_updatedAt"

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
    self.map = [NSMutableDictionary new];
  }
  return self;
}

- (NSString *)objectId {
  NSString *oid = [self.referenceMap objectForKey:kDKObjectIDField];
  if ([oid isKindOfClass:[NSString class]]) {
    return oid;
  }
  return nil;
}

- (NSDate *)updatedAt {
  NSNumber *updatedAt = [self.referenceMap objectForKey:kDKObjectUpdatedAtField];
  if ([updatedAt isKindOfClass:[NSNumber class]]) {
    return [NSDate dateWithTimeIntervalSince1970:[updatedAt doubleValue]];
  }
  return nil;
}

- (NSDate *)createdAt {
  NSNumber *createdAt = [self.referenceMap objectForKey:kDKObjectCreatedAtField];
  if ([createdAt isKindOfClass:[NSNumber class]]) {
    return [NSDate dateWithTimeIntervalSince1970:[createdAt doubleValue]];
  }
  return nil;
}

- (BOOL)isNew {
  return (self.objectId.length == 0);
}

- (BOOL)save {
  return [self save:NULL];
}

- (BOOL)save:(NSError **)error {
  // Check if data has been written
  if (self.map.count == 0) {
    [NSError writeToError:error
                     code:DKErrorInvalidEntity
              description:NSLocalizedString(@"Entity data invalid (no objects)", nil)
                 original:nil];
    return NO;
  }
  
  // TODO: Prevent use of '$' and '.' in objects/keys
  
  // Create request dict
  NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.entityName, @"entity",
                               self.map, @"obj", nil];
  
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
  
}

- (void)saveInBackgroundWithBlock:(DKObjectResultBlock)block {
  
}

- (BOOL)refresh {
  return NO;
}

- (BOOL)refresh:(NSError **)error {
  return NO;
}

- (BOOL)refreshInBackgroundWithBlock:(DKObjectResultBlock)block {
  return NO;
}

- (BOOL)delete {
  return NO;
}

- (BOOL)delete:(NSError **)error {
  return NO;
}

- (BOOL)deleteInBackgroundWithBlock:(DKObjectResultBlock)block {
  return NO;
}

- (id)objectForKey:(NSString *)key {
  return [self.map objectForKey:key];
}

- (void)objectForKey:(NSString *)key inBackgroundWithBlock:(DKObjectResultBlock)block {
  
}

- (DKPointer *)pointerForKey:(NSString *)key {
  return nil;
}

- (void)setObject:(id)object forKey:(NSString *)key {
  [self.map setObject:object forKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
  [self.map removeObjectForKey:key];
}

- (void)incrementKey:(NSString *)key {
  
}

- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount {
  
}

@end

@implementation DKObject (Private)

- (BOOL)commitObjectResultMap:(NSDictionary *)resultMap error:(NSError **)error {
  if (![resultMap isKindOfClass:[NSDictionary class]]) {
    [NSError writeToError:error
                     code:DKErrorInvalidJSON
              description:NSLocalizedString(@"Cannot commit action because result JSON is malformed (not an object)", nil)
                 original:nil];
    NSLog(@"result => %@: %@", NSStringFromClass([resultMap class]), resultMap);
    return NO;
  }
  self.referenceMap = resultMap;
  self.map = [NSMutableDictionary new];
  
  return YES;
}

@end
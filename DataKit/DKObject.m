//
//  DKObject.m
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKObject.h"

@interface DKObject ()
@property (nonatomic, copy, readwrite) NSString *objectId;
@property (nonatomic, copy, readwrite) NSString *entityName;
@property (nonatomic, copy, readwrite) NSDate *updatedAt;
@property (nonatomic, copy, readwrite) NSDate *createdAt;
@property (nonatomic, assign, readwrite) BOOL isNew;
@end

@implementation DKObject
DKSynthesize(objectId)
DKSynthesize(entityName)
DKSynthesize(updatedAt)
DKSynthesize(createdAt)
DKSynthesize(isNew)

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
  }
  return self;
}

- (BOOL)save {
  return NO;
}

- (BOOL)save:(NSError **)error {
  return NO;
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
  return nil;
}

- (void)objectForKey:(NSString *)key inBackgroundWithBlock:(DKObjectResultBlock)block {
  
}

- (DKPointer *)pointerForKey:(NSString *)key {
  return nil;
}

- (void)setObject:(id)object forKey:(NSString *)key {
  
}

- (void)removeObjectForKey:(NSString *)key {

}

- (void)incrementKey:(NSString *)key {
  
}

- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount {

}

@end

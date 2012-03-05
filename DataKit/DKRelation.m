//
//  DKRelation.m
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKRelation.h"

@interface DKRelation ()
@property (nonatomic, copy, readwrite) NSString *entityName;
@property (nonatomic, copy, readwrite) NSString *entityId;
@end

@implementation DKRelation
DKSynthesize(entityName)
DKSynthesize(entityId)

+ (DKRelation *)relationWithEntityName:(NSString *)entityName entityId:(NSString *)entityId {
  return [[self alloc] initWithEntityName:entityName entityId:entityId];
}

+ (DKRelation *)relationWithEntity:(DKEntity *)entity {
  return [[self alloc] initWithEntityName:entity.entityName entityId:entity.entityId];
}

- (id)initWithEntityName:(NSString *)entityName entityId:(NSString *)entityId {
  self = [super init];
  if (self) {
    self.entityName = entityName;
    self.entityId = entityId;
  }
  return self;
}

@end

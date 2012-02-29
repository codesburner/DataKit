//
//  DKPointer.m
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKPointer.h"

@interface DKPointer ()
@property (nonatomic, copy, readwrite) NSString *entityName;
@property (nonatomic, copy, readwrite) NSString *entityId;
@end

@implementation DKPointer
DKSynthesize(entityName)
DKSynthesize(entityId)

+ (DKPointer *)pointerWithEntityName:(NSString *)entityName entityId:(NSString *)entityId {
  return [[self alloc] initWithEntityName:entityName entityId:entityId];
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

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
@property (nonatomic, copy, readwrite) NSString *objectId;
@end

@implementation DKPointer
DKSynthesize(entityName)
DKSynthesize(objectId)

+ (DKPointer *)pointerWithEntityName:(NSString *)entityName objectId:(NSString *)objectId {
  return [[self alloc] initWithEntityName:entityName objectId:objectId];
}

- (id)initWithEntityName:(NSString *)entityName objectId:(NSString *)objectId {
  self = [super init];
  if (self) {
    self.entityName = entityName;
    self.objectId = objectId;
  }
  return self;
}

@end

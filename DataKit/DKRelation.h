//
//  DKRelation.h
//  DataKit
//
//  Created by Erik Aigner on 23.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DKEntity.h"
#import "DKQuery.h"

/**
 Defines a relation to another entity
 */
@interface DKRelation : NSObject
@property (nonatomic, copy, readonly) NSString *entityName;
@property (nonatomic, copy, readonly) NSString *entityId;

+ (DKRelation *)relationWithEntityName:(NSString *)entityName entityId:(NSString *)entityId;
+ (DKRelation *)relationWithEntity:(DKEntity *)entity;
+ (id)new UNAVAILABLE_ATTRIBUTE;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithEntityName:(NSString *)entityName entityId:(NSString *)entityId;

@end

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

/** @name Creating and Initializing Relations */

/**
 Creates a new relation from an entity name and ID
 @param entityName The entity name
 @param entityId The entidy ID
 @return The initialized relation
 */
+ (DKRelation *)relationWithEntityName:(NSString *)entityName entityId:(NSString *)entityId;

/**
 Creates a new relation using an existing <DKEntity>
 @param entity The entity to relate to
 @return The initialized relation
 */
+ (DKRelation *)relationWithEntity:(DKEntity *)entity;

/**
 Initializes a new relation from an entity name and ID
 @param entityName The entity name
 @param entityId The entity ID
 @return The initialized relation
 */
- (id)initWithEntityName:(NSString *)entityName entityId:(NSString *)entityId;

/** @name Properties */

/**
 The entity name
 */
@property (nonatomic, copy, readonly) NSString *entityName;

/**
 The entity ID
 */
@property (nonatomic, copy, readonly) NSString *entityId;

+ (id)new UNAVAILABLE_ATTRIBUTE;
- (id)init UNAVAILABLE_ATTRIBUTE;

@end

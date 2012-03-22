//
//  DKRelationTests.m
//  DataKit
//
//  Created by Erik Aigner on 05.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKRelationTests.h"

#import "DKEntity.h"
#import "DKQuery.h"
#import "DKRelation.h"
#import "DKManager.h"
#import "DKTests.h"

@implementation DKRelationTests

- (void)setUp {
  [DKManager setAPIEndpoint:kDKEndpoint];
  [DKManager setAPISecret:kDKSecret];
}

- (void)testRelationStore {
  NSString *entityName = @"EntityOne";
  NSString *entityName2 = @"EntityTwo";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  [DKEntity destroyAllEntitiesForName:entityName2 error:NULL];
  
  NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"a", @"x", @"b", @"y", nil];
  
  DKEntity *e0 = [DKEntity entityWithName:entityName];
  [e0 setObject:dataDict forKey:@"data"];
  [e0 save];
  
  DKEntity *e1 = [DKEntity entityWithName:entityName2];

  DKRelation *rel = [DKRelation relationWithEntity:e0];
  [e1 setObject:rel forKey:@"relation"];
  [e1 save];  
  
  // Test stored relation decode
  DKQuery *q = [DKQuery queryWithEntityName:entityName2];
  [q whereKey:@"_id" equalTo:e1.entityId];
  
  NSArray *results = [q findAll];
  
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  DKEntity *e2 = [results lastObject];
  
  STAssertEqualObjects(e1.entityId, e2.entityId, nil);
  
  DKRelation *rel2 = [e2 objectForKey:@"relation"];
  
  STAssertEqualObjects(e0.entityId, rel2.entityId, nil);
  STAssertEqualObjects(e0.entityName, rel2.entityName, nil);
  
  // Test key inclusion
  [q includeReferenceAtKey:@"relation"];
  [q includeReferenceAtKey:@"nonexistent"];
  
  results = [q findAll];
  
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  e2 = [results lastObject];
  
  STAssertEqualObjects(e1.entityId, e2.entityId, nil);
  
  NSDictionary *dict = [e2 objectForKey:@"relation"];
  
  STAssertEqualObjects([dict objectForKey:@"data"], dataDict, nil);
  STAssertEqualObjects([dict objectForKey:@"_id"], e0.entityId, nil);
}

@end

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

@implementation DKRelationTests

- (void)setUp {
  [DKManager setAPIEndpoint:@"http://localhost:3000"];
  [DKManager setAPISecret:@"c821a09ebf01e090a46b6bbe8b21bcb36eb5b432265a51a76739c20472908989"];
}

- (void)testRelationStore {
  DKEntity *e0 = [DKEntity entityWithName:@"Entity0"];
  [e0 setObject:@"randomData" forKey:@"data"];
  [e0 save];
  
  DKEntity *e1 = [DKEntity entityWithName:@"Entity1"];

  DKRelation *rel = [DKRelation relationWithEntity:e0];
  [e1 setObject:rel forKey:@"relation"];
  [e1 save];
  
  
  DKQuery *q = [DKQuery queryWithEntityName:@"Entity1"];
  [q whereKey:@"_id" equalTo:e1.entityId];
  
  NSArray *results = [q findAll];
  
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  DKEntity *e2 = [results lastObject];
  
  STAssertEqualObjects(e1.entityId, e2.entityId, nil);
  
  DKRelation *rel2 = [e2 objectForKey:@"relation"];
  
  STAssertEqualObjects(e0.entityId, rel2.entityId, nil);
  STAssertEqualObjects(e0.entityName, rel2.entityName, nil);
  
  [e0 delete];
  [e1 delete];
}

@end

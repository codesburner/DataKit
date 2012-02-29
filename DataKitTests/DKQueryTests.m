//
//  DKQueryTests.m
//  DataKit
//
//  Created by Erik Aigner on 29.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKQueryTests.h"

#import "DKEntity.h"
#import "DKEntity-Private.h"
#import "DKQuery.h"
#import "DKQuery-Private.h"

@implementation DKQueryTests

- (void)testEqualToQuery {
  DKEntity *e0 = [DKEntity entityWithName:@"QueryEql"];
  [e0 setObject:@"obelix" forKey:@"name"];
  [e0 save];

  DKEntity *e1 = [DKEntity entityWithName:@"QueryEql"];
  [e1 setObject:@"asterix" forKey:@"name"];
  [e1 save];
  
  // Fetch matching 'obelix'
  DKQuery *q0 = [DKQuery queryWithEntityName:@"QueryEql"];
  [q0 whereKey:@"name" equalTo:@"obelix"];
  
  NSError *error = nil;
  NSArray *results = [q0 findAll:&error];
  
  STAssertNil(error, @"%@", error);
  STAssertEquals([results count], (NSUInteger)1, nil);
  
  DKEntity *result = [results lastObject];
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  NSTimeInterval createdAt = result.createdAt.timeIntervalSince1970;
  NSTimeInterval updatedAt = result.updatedAt.timeIntervalSince1970;
  
  STAssertNotNil(result.entityId, nil);
  STAssertEqualsWithAccuracy(createdAt, now, 1.0, nil);
  STAssertEqualsWithAccuracy(updatedAt, now, 1.0, nil);
  STAssertEqualObjects([result objectForKey:@"name"], @"obelix", nil);
  
  // Fetch all
  DKQuery *q1 = [DKQuery queryWithEntityName:@"QueryEql"];

  error = nil;
  results = [q1 findAll:&error];
  
  STAssertNil(error, @"%@", error);
  STAssertEquals([results count], (NSUInteger)2, nil);
  
  NSSet *matchSet = [NSSet setWithObjects:@"asterix", @"obelix", nil];
  NSMutableSet *nameSet = [NSMutableSet new];
  for (DKEntity *entity in results) {
    [nameSet addObject:[entity objectForKey:@"name"]];
  }
  
  STAssertTrue([matchSet isEqualToSet:nameSet], nil);
  
  [e0 delete];
  [e1 delete];
}

@end

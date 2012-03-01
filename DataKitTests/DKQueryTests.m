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

- (void)testGreaterLesserThanQuery {
  NSString *entityName = @"QueryGreaterLesser";
  
  DKEntity *e0 = [DKEntity entityWithName:entityName];
  [e0 setObject:[NSNumber numberWithDouble:1.5] forKey:@"a"];
  [e0 setObject:[NSNumber numberWithDouble:9.3] forKey:@"b"];
  [e0 save];
  
  DKEntity *e1 = [DKEntity entityWithName:entityName];
  [e1 setObject:[NSNumber numberWithDouble:4.3] forKey:@"a"];
  [e1 setObject:[NSNumber numberWithDouble:7.0] forKey:@"b"];
  [e1 save];
  
  // Query gt/lt
  DKQuery *q = [DKQuery queryWithEntityName:entityName];
  [q whereKey:@"a" greaterThan:[NSNumber numberWithDouble:1.0]];
  [q whereKey:@"a" lessThan:[NSNumber numberWithDouble:4.3]];
  
  NSError *error = nil;
  NSArray *results = [q findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  DKEntity *r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:@"a"], [NSNumber numberWithDouble:1.5], nil);
  STAssertEqualObjects([r0 objectForKey:@"b"], [NSNumber numberWithDouble:9.3], nil);
  
  // Query gt/lte
  DKQuery *q2 = [DKQuery queryWithEntityName:entityName];
  [q2 whereKey:@"a" greaterThan:[NSNumber numberWithDouble:1.0]];
  [q2 whereKey:@"a" lessThanOrEqualTo:[NSNumber numberWithDouble:4.3]];
  
  error = nil;
  results = [q2 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)2, nil);
  
  DKEntity *r1 = [results objectAtIndex:0];
  DKEntity *r2 = [results objectAtIndex:1];
  
  STAssertEqualObjects([r1 objectForKey:@"a"], [NSNumber numberWithDouble:1.5], nil);
  STAssertEqualObjects([r1 objectForKey:@"b"], [NSNumber numberWithDouble:9.3], nil);
  
  STAssertEqualObjects([r2 objectForKey:@"a"], [NSNumber numberWithDouble:4.3], nil);
  STAssertEqualObjects([r2 objectForKey:@"b"], [NSNumber numberWithDouble:7.0], nil);
  
  // Compound
  DKQuery *q3 = [DKQuery queryWithEntityName:entityName];
  [q3 whereKey:@"a" greaterThan:[NSNumber numberWithDouble:1.0]];
  [q3 whereKey:@"b" lessThanOrEqualTo:[NSNumber numberWithDouble:7.0]];
  
  error = nil;
  results = [q3 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  DKEntity *r3 = [results lastObject];
  
  STAssertEqualObjects([r3 objectForKey:@"a"], [NSNumber numberWithDouble:4.3], nil);
  STAssertEqualObjects([r3 objectForKey:@"b"], [NSNumber numberWithDouble:7.0], nil);
  
  [e0 delete];
  [e1 delete];
}

@end

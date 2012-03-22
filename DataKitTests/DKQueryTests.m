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
#import "DKManager.h"
#import "DKMapReduce.h"
#import "DKTests.h"

@implementation DKQueryTests

- (void)setUp {
  [DKManager setAPIEndpoint:kDKEndpoint];
  [DKManager setAPISecret:kDKSecret];
}

- (void)testEqualNotEqualToQuery {
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
  STAssertEqualsWithAccuracy(createdAt, now, 2.0, nil);
  STAssertEqualsWithAccuracy(updatedAt, now, 2.0, nil);
  STAssertEqualObjects([result objectForKey:@"name"], @"obelix", nil);
  
  // Fetch matching not 'obelix'
  DKQuery *q1 = [DKQuery queryWithEntityName:@"QueryEql"];
  [q1 whereKey:@"name" notEqualTo:@"obelix"];
  
  error = nil;
  results = [q1 findAll:&error];
  
  STAssertNil(error, @"%@", error);
  STAssertEquals([results count], (NSUInteger)1, nil);
  
  result = [results lastObject];
  now = [[NSDate date] timeIntervalSince1970];
  createdAt = result.createdAt.timeIntervalSince1970;
  updatedAt = result.updatedAt.timeIntervalSince1970;
  
  STAssertNotNil(result.entityId, nil);
  STAssertEqualsWithAccuracy(createdAt, now, 2.0, nil);
  STAssertEqualsWithAccuracy(updatedAt, now, 2.0, nil);
  STAssertEqualObjects([result objectForKey:@"name"], @"asterix", nil);
  
  // Fetch all
  DKQuery *q2 = [DKQuery queryWithEntityName:@"QueryEql"];

  error = nil;
  results = [q2 findAll:&error];
  
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

- (void)testOrQuery {
  NSString *entityName = @"QueryOr";
  
  DKEntity *e0 = [DKEntity entityWithName:entityName];
  [e0 setObject:[NSNumber numberWithDouble:1.0] forKey:@"a"];
  [e0 setObject:[NSNumber numberWithDouble:2.0] forKey:@"b"];
  [e0 setObject:[NSNumber numberWithDouble:1.0] forKey:@"c"];
  [e0 save];
  
  DKEntity *e1 = [DKEntity entityWithName:entityName];
  [e1 setObject:[NSNumber numberWithDouble:2.0] forKey:@"a"];
  [e1 setObject:[NSNumber numberWithDouble:1.0] forKey:@"b"];
  [e1 setObject:[NSNumber numberWithDouble:1.0] forKey:@"c"];
  [e1 save];
  
  DKEntity *e2 = [DKEntity entityWithName:entityName];
  [e2 setObject:[NSNumber numberWithDouble:2.0] forKey:@"a"];
  [e2 setObject:[NSNumber numberWithDouble:2.0] forKey:@"b"];
  [e2 setObject:[NSNumber numberWithDouble:1.0] forKey:@"c"];
  [e2 save];
  
  DKQuery *q = [DKQuery queryWithEntityName:entityName];
  [[q or] whereKey:@"a" equalTo:[NSNumber numberWithDouble:1.0]];
  [[q or] whereKey:@"b" equalTo:[NSNumber numberWithDouble:1.0]];
  
  NSError *error = nil;
  NSArray *results = [q findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)2, nil);
  
  DKEntity *r0 = [results objectAtIndex:0];
  DKEntity *r1 = [results objectAtIndex:1];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], [NSNumber numberWithDouble:1.0], nil);
  STAssertEqualObjects([r0 objectForKey:@"b"], [NSNumber numberWithDouble:2.0], nil);
  STAssertEqualObjects([r0 objectForKey:@"c"], [NSNumber numberWithDouble:1.0], nil);
  
  STAssertEqualObjects([r1 objectForKey:@"a"], [NSNumber numberWithDouble:2.0], nil);
  STAssertEqualObjects([r1 objectForKey:@"b"], [NSNumber numberWithDouble:1.0], nil);
  STAssertEqualObjects([r1 objectForKey:@"c"], [NSNumber numberWithDouble:1.0], nil);
  
  [e0 delete];
  [e1 delete];
  [e2 delete];
}

- (void)testAndQuery {
  NSString *entityName = @"QueryAnd";
  
  DKEntity *e0 = [DKEntity entityWithName:entityName];
  [e0 setObject:[NSNumber numberWithDouble:1.0] forKey:@"a"];
  [e0 setObject:[NSNumber numberWithDouble:3.0] forKey:@"b"];
  [e0 save];
  
  DKEntity *e1 = [DKEntity entityWithName:entityName];
  [e1 setObject:[NSNumber numberWithDouble:1.0] forKey:@"a"];
  [e1 setObject:[NSNumber numberWithDouble:2.0] forKey:@"b"];
  [e1 save];
  
  DKQuery *q = [DKQuery queryWithEntityName:entityName];
  [q whereKey:@"a" equalTo:[NSNumber numberWithDouble:1.0]];
  [[q and] whereKey:@"b" lessThanOrEqualTo:[NSNumber numberWithDouble:2.0]];
  
  NSError *error = nil;
  NSArray *results = [q findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  DKEntity *r0 = [results lastObject];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], [NSNumber numberWithDouble:1.0], nil);
  STAssertEqualObjects([r0 objectForKey:@"b"], [NSNumber numberWithDouble:2.0], nil);
  
  [e0 delete];
  [e1 delete];
}

- (void)testInQuery {
  NSString *entityName = @"QueryIn";
  
  DKEntity *e0 = [DKEntity entityWithName:entityName];
  [e0 setObject:@"x" forKey:@"a"];
  [e0 save];
  
  DKEntity *e1 = [DKEntity entityWithName:entityName];
  [e1 setObject:@"y" forKey:@"a"];
  [e1 save];
  
  DKEntity *e2 = [DKEntity entityWithName:entityName];
  [e2 setObject:@"z" forKey:@"a"];
  [e2 save];
  
  // Test contained-in
  DKQuery *q = [DKQuery queryWithEntityName:entityName];
  [q whereKey:@"a" containedIn:[NSArray arrayWithObjects:@"x", @"y", nil]];
  
  NSError *error = nil;
  NSArray *results = [q findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)2, nil);
  
  DKEntity *r0 = [results objectAtIndex:0];
  DKEntity *r1 = [results objectAtIndex:1];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], @"x", nil);
  STAssertEqualObjects([r1 objectForKey:@"a"], @"y", nil);
  
  // Test not-contained-in
  DKQuery *q2 = [DKQuery queryWithEntityName:entityName];
  [q2 whereKey:@"a" notContainedIn:[NSArray arrayWithObjects:@"x", @"y", nil]];
  
  error = nil;
  results = [q2 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  r0 = [results objectAtIndex:0];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], @"z", nil);
  
  [e0 delete];
  [e1 delete];
  [e2 delete];
}

- (void)testAllInQuery {
  NSString *entityName = @"QueryAllIn";
  
  DKEntity *e0 = [DKEntity entityWithName:entityName];
  [e0 setObject:[NSArray arrayWithObjects:@"x", @"y", @"z", nil] forKey:@"a"];
  [e0 save];
  
  DKEntity *e1 = [DKEntity entityWithName:entityName];
  [e1 setObject:[NSArray arrayWithObjects:@"x", @"y", nil] forKey:@"a"];
  [e1 save];
  
  // Test all-in
  DKQuery *q = [DKQuery queryWithEntityName:entityName];
  [q whereKey:@"a" containsAllIn:[NSArray arrayWithObjects:@"x", @"y", nil]];
  
  NSError *error = nil;
  NSArray *results = [q findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)2, nil);
  
  DKEntity *r0 = [results objectAtIndex:0];
  DKEntity *r1 = [results objectAtIndex:1];
  
  NSArray *m0 = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
  NSArray *m1 = [NSArray arrayWithObjects:@"x", @"y", nil];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], m0, nil);
  STAssertEqualObjects([r1 objectForKey:@"a"], m1, nil);
  
  // Test all-in (2)
  DKQuery *q2 = [DKQuery queryWithEntityName:entityName];
  [q2 whereKey:@"a" containsAllIn:[NSArray arrayWithObjects:@"x", @"y", @"z", nil]];
  
  error = nil;
  results = [q2 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  r0 = [results objectAtIndex:0];
  m0 = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], m0, nil);
  
  [e0 delete];
  [e1 delete];
}

- (void)testExistsQuery {
  NSString *entityName = @"QueryExists";
  
  DKEntity *e0 = [DKEntity entityWithName:entityName];
  [e0 setObject:@"y" forKey:@"a"];
  [e0 setObject:@"x" forKey:@"b"];
  [e0 setObject:@"x" forKey:@"c"];
  [e0 save];
  
  DKEntity *e1 = [DKEntity entityWithName:entityName];
  [e1 setObject:@"x" forKey:@"a"];
  [e1 setObject:@"x" forKey:@"d"];
  [e1 setObject:@"x" forKey:@"e"];
  [e1 save];
  
  // Test exists
  DKQuery *q = [DKQuery queryWithEntityName:entityName];
  [q whereKeyExists:@"b"];
  
  NSError *error = nil;
  NSArray *results = [q findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  DKEntity *r0 = [results lastObject];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], @"y", nil);
  
  // Test exists
  DKQuery *q2 = [DKQuery queryWithEntityName:entityName];
  [q2 whereKeyDoesNotExist:@"b"];
  
  error = nil;
  results = [q2 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  r0 = [results lastObject];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], @"x", nil);
  
  [e0 delete];
  [e1 delete];
}

- (void)testAscDescLimitSkipQuery {
  NSString *entityName = @"QueryAscDescLimitSkip";
  
  DKEntity *e0 = [DKEntity entityWithName:entityName];
  [e0 setObject:[NSNumber numberWithInteger:0] forKey:@"a"];
  [e0 save];
  
  DKEntity *e1 = [DKEntity entityWithName:entityName];
  [e1 setObject:[NSNumber numberWithInteger:1] forKey:@"a"];
  [e1 save];
  
  DKEntity *e2 = [DKEntity entityWithName:entityName];
  [e2 setObject:[NSNumber numberWithInteger:2] forKey:@"a"];
  [e2 save];
  
  // Test asc
  DKQuery *q = [DKQuery queryWithEntityName:entityName];
  [q orderAscendingByKey:@"a"];
  
  NSError *error = nil;
  NSArray *results = [q findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)3, nil);
  
  DKEntity *r0 = [results objectAtIndex:0];
  DKEntity *r1 = [results objectAtIndex:1];
  DKEntity *r2 = [results objectAtIndex:2];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], [NSNumber numberWithInteger:0], nil);
  STAssertEqualObjects([r1 objectForKey:@"a"], [NSNumber numberWithInteger:1], nil);
  STAssertEqualObjects([r2 objectForKey:@"a"], [NSNumber numberWithInteger:2], nil);
  
  // Test desc
  DKQuery *q2 = [DKQuery queryWithEntityName:entityName];
  [q2 orderDescendingByKey:@"a"];
  
  error = nil;
  results = [q2 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)3, nil);
  
  r0 = [results objectAtIndex:0];
  r1 = [results objectAtIndex:1];
  r2 = [results objectAtIndex:2];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], [NSNumber numberWithInteger:2], nil);
  STAssertEqualObjects([r1 objectForKey:@"a"], [NSNumber numberWithInteger:1], nil);
  STAssertEqualObjects([r2 objectForKey:@"a"], [NSNumber numberWithInteger:0], nil);
  
  // Test limit
  DKQuery *q3 = [DKQuery queryWithEntityName:entityName];
  [q3 orderDescendingByKey:@"a"];
  [q3 setLimit:2];
  
  error = nil;
  results = [q3 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)2, nil);
  
  r0 = [results objectAtIndex:0];
  r1 = [results objectAtIndex:1];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], [NSNumber numberWithInteger:2], nil);
  STAssertEqualObjects([r1 objectForKey:@"a"], [NSNumber numberWithInteger:1], nil);
  
  // Test skip
  DKQuery *q4 = [DKQuery queryWithEntityName:entityName];
  [q4 orderDescendingByKey:@"a"];
  [q4 setSkip:2];
  
  error = nil;
  results = [q4 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  r0 = [results objectAtIndex:0];
  
  STAssertEqualObjects([r0 objectForKey:@"a"], [NSNumber numberWithInteger:0], nil);
  
  [e0 delete];
  [e1 delete];
  [e2 delete];
}

- (void)testRegexSafeString {
  DKQuery *q = [DKQuery queryWithEntityName:@"SafeRegexTest"];
  NSString *unsafeString = @"[some\\^$words.|in?*+(between)";
  NSString *expectedString = @"\\[some\\\\\\^\\$words\\.\\|in\\?\\*\\+\\(between\\)";
  NSString *safeString = [q makeRegexSafeString:unsafeString];
  
  STAssertEqualObjects(safeString, expectedString, @"%@", safeString);
}

- (void)testRegexQuery {
  NSString *entityName = @"QueryRegex";
  
  DKEntity *e0 = [DKEntity entityWithName:entityName];
  [e0 setObject:@"some words\nwith a newline\ninbetween" forKey:@"a"];
  [e0 setObject:@"0" forKey:@"b"];
  [e0 save];
  
  DKEntity *e1 = [DKEntity entityWithName:entityName];
  [e1 setObject:@"another\nrandom regex\nstring" forKey:@"a"];
  [e1 setObject:@"1" forKey:@"b"];
  [e1 save];
  
  // Test standard regex
  DKQuery *q = [DKQuery queryWithEntityName:entityName];
  [q whereKey:@"a" matchesRegex:@"\\s+words"];
  
  NSError *error = nil;
  NSArray *results = [q findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  DKEntity *r0 = [results lastObject];
  
  STAssertEqualObjects([r0 objectForKey:@"b"], @"0", nil);
  
  // Test multiline regex
  DKQuery *q2 = [DKQuery queryWithEntityName:entityName];
  [q2 whereKey:@"a" matchesRegex:@"regex$" options:DKRegexOptionMultiline];
  
  error = nil;
  results = [q2 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  r0 = [results lastObject];
  
  STAssertEqualObjects([r0 objectForKey:@"b"], @"1", nil);
  
  // Test multiline regex fail
  DKQuery *q3 = [DKQuery queryWithEntityName:entityName];
  [q3 whereKey:@"a" matchesRegex:@"regex$" options:0];
  
  error = nil;
  results = [q3 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)0, nil);
  
  // Test dotall regex
  DKQuery *q4 = [DKQuery queryWithEntityName:entityName];
  [q4 whereKey:@"a" matchesRegex:@"regex.*string" options:DKRegexOptionDotall];
  
  error = nil;
  results = [q4 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  r0 = [results lastObject];
  
  STAssertEqualObjects([r0 objectForKey:@"b"], @"1", nil);
  
  // Test dotall regex fail
  DKQuery *q5 = [DKQuery queryWithEntityName:entityName];
  [q5 whereKey:@"a" matchesRegex:@"regex.*string" options:0];
  
  error = nil;
  results = [q5 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)0, nil);
  
  // Test contains string (simple regex)
  DKQuery *q6 = [DKQuery queryWithEntityName:entityName];
  [q6 whereKey:@"a" containsString:@"newline\nin"];
  
  error = nil;
  results = [q6 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  r0 = [results lastObject];
  
  STAssertEqualObjects([r0 objectForKey:@"b"], @"0", nil);
  
  // Test prefix
  DKQuery *q7 = [DKQuery queryWithEntityName:entityName];
  [q7 whereKey:@"a" hasPrefix:@"some"];
  
  error = nil;
  results = [q7 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  r0 = [results lastObject];
  
  STAssertEqualObjects([r0 objectForKey:@"b"], @"0", nil);
  
  // Test suffix
  DKQuery *q8 = [DKQuery queryWithEntityName:entityName];
  [q8 whereKey:@"a" hasSuffix:@"ing"];
  
  error = nil;
  results = [q8 findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  
  r0 = [results lastObject];
  
  STAssertEqualObjects([r0 objectForKey:@"b"], @"1", nil);
  
  [e0 delete];
  [e1 delete];
}

- (void)testFindOneCountAndById {
  NSString *en = @"FindOneCountAndById";
  
  DKEntity *e = [DKEntity entityWithName:en];
  [e setObject:@"x" forKey:@"a"];
  [e setObject:@"y" forKey:@"b"];
  [e save];
  
  DKEntity *e2 = [DKEntity entityWithName:en];
  [e2 setObject:@"x" forKey:@"a"];
  [e2 save];
  
  // Verify find all returns 2 objects
  DKQuery *q = [DKQuery queryWithEntityName:en];
  [q whereKey:@"a" equalTo:@"x"];
  
  NSArray *results = [q findAll];
  
  STAssertEquals(results.count, (NSUInteger)2, nil);
  
  // Find one
  DKQuery *q2 = [DKQuery queryWithEntityName:en];
  [q2 whereKey:@"a" equalTo:@"x"];
  
  NSError *error = nil;
  DKEntity *er = [q2 findOne:&error];
  
  NSString *y = [er objectForKey:@"b"];
  
  STAssertNil(error, error.localizedDescription);
  STAssertNotNil(er, nil);
  STAssertEqualObjects(y, @"y", nil);
  
  // Test count
  DKQuery *q3 = [DKQuery queryWithEntityName:en];
  [q3 whereKey:@"a" equalTo:@"x"];
  
  error = nil;
  NSUInteger count = [q3 countAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(count, (NSUInteger)2, nil);
  
  // Test find by id
  DKQuery *q4 = [DKQuery queryWithEntityName:en];
  [q4 whereEntityIdMatches:e2.entityId];
  
  error = nil;
  DKEntity *er2 = [q4 findOne:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEqualObjects(e2.entityId, er2.entityId, nil);
  
  [e delete];
  [e2 delete];
}

- (void)testFieldIncludeExclude {
  NSString *name = @"FieldInclExcl";
  
  DKEntity *e = [DKEntity entityWithName:name];
  [e setObject:@"a" forKey:@"x"];
  [e setObject:@"b" forKey:@"y"];
  [e setObject:@"c" forKey:@"z"];
  
  NSError *error = nil;
  BOOL success = [e save:&error];
  
  STAssertTrue(success, nil);
  STAssertNil(error, error.localizedDescription);
  
  // Test exclude
  DKQuery *q = [DKQuery queryWithEntityName:name];
  [q whereEntityIdMatches:e.entityId];
  [q excludeKeys:[NSArray arrayWithObjects:@"x", @"y", nil]];
  
  error = nil;
  DKEntity *e2 = [q findOne:&error];
  
  NSLog(@"entity => %@", e2);
  
  STAssertNil(error, error.localizedDescription);
  STAssertNotNil(e2, nil);
  
  STAssertNil([e2 objectForKey:@"x"], nil);
  STAssertNil([e2 objectForKey:@"y"], nil);
  STAssertEqualObjects([e2 objectForKey:@"z"], @"c", nil);
  
  // Test include
  [q includeKeys:[NSArray arrayWithObjects:@"x", @"y", nil]];
  
  error = nil;
  DKEntity *e3 = [q findOne:&error];
  
  NSLog(@"entity => %@", e3);
  
  STAssertNil(error, error.localizedDescription);
  STAssertNotNil(e3, nil);
  
  STAssertEqualObjects([e3 objectForKey:@"x"], @"a", nil);
  STAssertEqualObjects([e3 objectForKey:@"y"], @"b", nil);
  STAssertNil([e3 objectForKey:@"z"], nil);
  
  [e delete];
}

- (void)testQueryOnNonExistentCollection {
  DKQuery *q = [DKQuery queryWithEntityName:@"NonExistentCollection"];
  [q whereKeyExists:@"i"];
  
  NSError *error = nil;
  NSArray *results = [q findAll:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)0, @"not nil: %@", results);
}

@end

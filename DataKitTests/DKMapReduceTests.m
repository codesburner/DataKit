//
//  DKMapReduceTests.m
//  DataKit
//
//  Created by Erik Aigner on 12.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKMapReduceTests.h"

#import "DataKit.h"

@implementation DKMapReduceTests

- (void)testEmbeddedFieldCount {
  NSString *entityName = @"EmbeddedFieldMapReduce";
  NSString *key = @"k";
  NSString *key2 = @"k2";
  
  NSArray *l0 = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
  NSArray *l1 = [NSArray arrayWithObjects:@"x", nil];
  NSArray *l2 = [NSArray arrayWithObjects:@"c", @"d", nil];
  NSArray *l3 = [NSArray arrayWithObjects:@"j", @"k", @"l", @"m", nil];
  
  DKEntity *e = [DKEntity entityWithName:entityName];
  [e setObject:l0 forKey:key];
  [e setObject:l1 forKey:key2];
  [e save];
  
  DKEntity *e2 = [DKEntity entityWithName:entityName];
  [e2 setObject:l2 forKey:key];
  [e2 setObject:l3 forKey:key2];
  [e2 save];
  
  DKMapReduce *mapReduce = [DKMapReduce new];
  [mapReduce map:@"function () { emit(this._id, {k: this.k.length, k2: this.k2.length}); }"];
  
  DKQuery *query = [DKQuery queryWithEntityName:entityName];
  
  id result = [query performMapReduce:mapReduce];
  NSUInteger numTested = 0;
  
  for (NSDictionary *dict in result) {
    NSString *oid = [dict objectForKey:@"_id"];
    NSDictionary *value = [dict objectForKey:@"value"];
    NSUInteger kc = [[value objectForKey:key] integerValue];
    NSUInteger k2c = [[value objectForKey:key2] integerValue];
    
    if ([oid isEqualToString:e.entityId]) {
      STAssertEquals(kc, l0.count, nil);
      STAssertEquals(k2c, l1.count, nil);
      numTested++;
    }
    else if ([oid isEqualToString:e2.entityId]) {
      STAssertEquals(kc, l2.count, nil);
      STAssertEquals(k2c, l3.count, nil);
      numTested++;
    }
  }
  
  STAssertEquals(numTested, (NSUInteger)2, nil);
  
  [e delete];
  [e2 delete];
}

- (void)testEmbeddedFieldCountTemplate {
  NSString *entityName = @"EmbeddedFieldMapReduceTemplate";
  NSString *key = @"k";
  NSString *key2 = @"k2";
  
  NSArray *l0 = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
  NSArray *l1 = [NSArray arrayWithObjects:@"x", nil];
  NSArray *l2 = [NSArray arrayWithObjects:@"c", @"d", nil];
  NSArray *l3 = [NSArray arrayWithObjects:@"j", @"k", @"l", @"m", nil];
  
  DKEntity *e = [DKEntity entityWithName:entityName];
  [e setObject:l0 forKey:key];
  [e setObject:l1 forKey:key2];
  [e setObject:@"otherValue" forKey:@"someKey"];
  [e save];
  
  DKEntity *e2 = [DKEntity entityWithName:entityName];
  [e2 setObject:l2 forKey:key];
  [e2 setObject:l3 forKey:key2];
  [e2 setObject:@"otherValue2" forKey:@"someKey"];
  [e2 save];
  
  DKMapReduce *mapReduce = [DKMapReduce countForKeys:[NSArray arrayWithObjects:key, key2, nil]];
  DKQuery *query = [DKQuery queryWithEntityName:entityName];
  
  id result = [query performMapReduce:mapReduce];
  
  NSUInteger numTested = 0;
  for (NSDictionary *dict in result) {
    NSString *oid = [dict objectForKey:@"_id"];
    NSNumber *keyCount = [dict objectForKey:key];
    NSNumber *keyCount2 = [dict objectForKey:key2];
    NSString *otherValue = [dict objectForKey:@"someKey"];
    
    if ([oid isEqualToString:e.entityId]) {
      STAssertEqualObjects(keyCount, [NSNumber numberWithInt:l0.count], nil);
      STAssertEqualObjects(keyCount2, [NSNumber numberWithInt:l1.count], nil);
      STAssertEqualObjects(otherValue, @"otherValue", nil);
      numTested++;
    }
    else if ([oid isEqualToString:e2.entityId]) {
      STAssertEqualObjects(keyCount, [NSNumber numberWithInt:l2.count], nil);
      STAssertEqualObjects(keyCount2, [NSNumber numberWithInt:l3.count], nil);
      STAssertEqualObjects(otherValue, @"otherValue2", nil);
      numTested++;
    }
  }
  
  STAssertEquals(numTested, (NSUInteger)2, nil);
  
  [e delete];
  [e2 delete];
}

@end

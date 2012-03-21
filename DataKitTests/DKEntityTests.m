//
//  DKEntityTests.m
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKEntityTests.h"

#import "DataKit.h"
#import "DKEntity-Private.h"
#import "NSData+DataKit.h"
#import "DKTests.h"

@implementation DKEntityTests

- (void)setUp {
  [DKManager setAPIEndpoint:kDKEndpoint];
  [DKManager setAPISecret:kDKSecret];
}

- (void)testObjectInSerial {
  NSString *entityName = @"User";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  // Insert
  DKEntity *object = [DKEntity entityWithName:entityName];
  [object setObject:@"Erik" forKey:@"name"];
  [object setObject:@"Aigner" forKey:@"surname"];
  
  NSError *error = nil;
  BOOL success = [object save:&error];
  if (!success) {
    NSLog(@"error: %@", error);
  }
  STAssertNil(error, @"first insert should not return error, did return %@", error);
  STAssertTrue(success, @"update should have been successful (return YES)");
  
  NSUInteger mapCount = object.resultMap.count;
  STAssertEquals(mapCount, (NSUInteger)5, @"result map should have 5 elements, has %i", mapCount);
  
  NSString *oid = [object objectForKey:@"_id"];
  NSString *name = [object objectForKey:@"name"];
  NSString *surname = [object objectForKey:@"surname"];
  
  STAssertTrue(oid.length > 0, @"result map should have field '_id'");
  STAssertEqualObjects(name, @"Erik", @"result map should have name field set to 'Erik', is '%@'", name);
  STAssertEqualObjects(surname, @"Aigner", @"result map should have surname field set to 'Aigner', is '%@'", surname);
  
  NSTimeInterval createdAt = object.createdAt.timeIntervalSince1970;
  NSTimeInterval updatedAt = object.updatedAt.timeIntervalSince1970;
  NSTimeInterval createdNow = [[NSDate date] timeIntervalSince1970];
  
  STAssertEqualsWithAccuracy(createdAt, createdNow, 1.0, nil);
  STAssertEqualsWithAccuracy(updatedAt, createdNow, 1.0, nil);
  
  // Update
  [object setObject:@"Stefan" forKey:@"name"];
  [object setObject:@"More" forKey:@"more"];
  
  error = nil;
  success = [object save:&error];
  STAssertNil(error, @"update should not return error, did return %@", error);
  STAssertTrue(success, @"update should have been successful (return YES)");
  
  mapCount = object.resultMap.count;
  STAssertEquals(mapCount, (NSUInteger)6, @"result map should have 6 elements, has %i", mapCount);
  
  NSString *oid2 = [object objectForKey:@"_id"];
  name = [object objectForKey:@"name"];
  surname = [object objectForKey:@"surname"];
  NSString *more = [object objectForKey:@"more"];
  
  STAssertTrue(oid2.length > 0, @"result map should have field '_id'");
  STAssertEqualObjects(oid2, oid, @"object id 1 and 2 should be equal");
  STAssertEqualObjects(name, @"Stefan", @"result map should have name field set to 'Stefan', is '%@'", name);
  STAssertEqualObjects(surname, @"Aigner", @"result map should have surname field set to 'Aigner', is '%@'", surname);
  STAssertEqualObjects(more, @"More", @"result map should have more field set to 'More', is '%@'", surname);
  
  createdAt = object.createdAt.timeIntervalSince1970;
  updatedAt = object.updatedAt.timeIntervalSince1970;
  NSTimeInterval updatedNow = [[NSDate date] timeIntervalSince1970];
  
  STAssertEqualsWithAccuracy(createdAt, createdNow, 1.0, nil);
  STAssertEqualsWithAccuracy(updatedAt, updatedNow, 1.0, nil);
  
  // Remove
  [object removeObjectForKey:@"more"];
  
  error = nil;
  success = [object save:&error];
  STAssertNil(error, @"update (unset) should not return error, did return %@", error);
  STAssertTrue(success, @"update (unset) should have been successful (return YES)");
  
  mapCount = object.resultMap.count;
  STAssertEquals(mapCount, (NSUInteger)5, @"result map should have 5 elements, has %i", mapCount);
  
  more = [object objectForKey:@"more"];
  STAssertNil(more, @"more field should have been deleted");
  
  createdAt = object.createdAt.timeIntervalSince1970;
  updatedAt = object.updatedAt.timeIntervalSince1970;
  updatedNow = [[NSDate date] timeIntervalSince1970];
  
  STAssertEqualsWithAccuracy(createdAt, createdNow, 1.0, nil);
  STAssertEqualsWithAccuracy(updatedAt, updatedNow, 1.0, nil);
  
  // Refresh
  [object setObject:@"RefreshMeAway" forKey:@"refresh"];
  
  NSString *refreshField = [object objectForKey:@"refresh"];
  STAssertNotNil(refreshField, @"refresh field should not be nil");
  
  error = nil;
  success = [object refresh:&error];
  STAssertNil(error, @"refresh should not return error, did return %@", error);
  STAssertTrue(success, @"refresh should have been successful (return YES)");
  
  mapCount = object.resultMap.count;
  STAssertEquals(mapCount, (NSUInteger)5, @"result map should have 5 elements, has %i", mapCount);
  
  refreshField = [object objectForKey:@"refresh"];
  STAssertNil(refreshField, @"refresh field should have been cleared");
  
  // Public ID
  error = nil;
  NSURL *publicURL = [object generatePublicURLForFields:[NSArray arrayWithObject:@"name"]
                                                  error:&error];
  STAssertNil(error, @"public id generation returned error %@", error);
  STAssertNotNil(publicURL, @"generated URL invalid '%@'", publicURL);
  
  NSURLRequest *req = [NSURLRequest requestWithURL:publicURL];
  NSData *pubData = [NSURLConnection sendSynchronousRequest:req returningResponse:NULL error:NULL];
  NSString *pubName = [[NSString alloc] initWithData:pubData encoding:NSUTF8StringEncoding];
  
  STAssertEqualObjects(pubName, @"Stefan", @"public URL should return 'Stefan', did return '%@'", pubName);
  
  // Delete
  error = nil;
  success = [object delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
}

- (void)testSequenceNumbers {
  NSString *entityName = @"Sequence";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  DKEntity *e = [DKEntity entityWithName:entityName];
  [e setObject:@"x" forKey:@"a"];
  [e save];
  
  DKEntity *e2 = [DKEntity entityWithName:entityName];
  [e2 setObject:@"x" forKey:@"a"];
  [e2 save];
  
  DKEntity *e3 = [DKEntity entityWithName:entityName];
  [e3 setObject:@"x" forKey:@"a"];
  [e3 save];
  
  STAssertTrue(e.sequenceNumber >= 0, nil);
  STAssertEquals(e2.sequenceNumber, e.sequenceNumber + 1, nil);
  STAssertEquals(e3.sequenceNumber, e2.sequenceNumber + 1, nil);
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
}

- (void)testRemoveWithoutPriorSave {
  NSString *entityName = @"RemoveWithoutPriorSave";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  DKEntity *e = [DKEntity entityWithName:entityName];
  [e setObject:@"a" forKey:@"x"];
  [e setObject:@"b" forKey:@"y"];
  [e removeObjectForKey:@"x"];
  
  NSError *error = nil;
  BOOL success = [e save:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  
  STAssertEqualObjects([e objectForKey:@"y"], @"b", nil);
  STAssertNil([e objectForKey:@"x"], nil);
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
}

- (void)testObjectKeyIncrement {
  NSString *entityName = @"IncrementValue";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  DKEntity *object = [DKEntity entityWithName:entityName];
  [object setObject:@"TestValue" forKey:@"key"];
  [object setObject:[NSNumber numberWithInteger:3] forKey:@"amount"];
  
  NSError *error = nil;
  BOOL success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  STAssertEquals([[object objectForKey:@"amount"] integerValue], (NSInteger)3, nil);
  
  [object incrementKey:@"amount" byAmount:[NSNumber numberWithInteger:2]];
  
  error = nil;
  success = [object save:&error];
  
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  STAssertEquals([[object objectForKey:@"amount"] integerValue], (NSInteger)5, nil);
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  // Test increment without prior save
  DKEntity *e = [DKEntity entityWithName:entityName];
  [e setObject:[NSNumber numberWithInt:6] forKey:@"count"];
  [e incrementKey:@"count" byAmount:[NSNumber numberWithInt:2]];
  
  error = nil;
  success = [e save:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  
  NSNumber *count = [e objectForKey:@"count"];
  NSNumber *comp = [NSNumber numberWithInt:8];
  
  STAssertEqualObjects(count, comp, nil);
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
}

- (void)testObjectPush {
  NSString *entityName = @"PushValue";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  DKEntity *object = [DKEntity entityWithName:entityName];
  [object setObject:[NSArray arrayWithObject:@"stefan"] forKey:@"nameList"];
  
  NSError *error = nil;
  BOOL success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [object pushObject:@"erik" forKey:@"nameList"];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  NSArray *list = [object objectForKey:@"nameList"];
  NSArray *comp = [NSArray arrayWithObjects:@"stefan", @"erik", nil];
  STAssertEqualObjects(list, comp, nil);
  
  [object pushAllObjects:[NSArray arrayWithObjects:@"anna", @"john", nil] forKey:@"nameList"];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  list = [object objectForKey:@"nameList"];
  comp = [NSArray arrayWithObjects:@"stefan", @"erik", @"anna", @"john", nil];
  STAssertEqualObjects(list, comp, nil);
  
  [object delete];
  
  // Test push without prior insert
  DKEntity *e = [DKEntity entityWithName:entityName];
  [e setObject:[NSArray arrayWithObjects:@"j", @"k", nil] forKey:@"values"];
  [e pushObject:@"l" forKey:@"values"];
  
  error = nil;
  success = [e save:&error];
  
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  
  list = [e objectForKey:@"values"];
  comp = [NSArray arrayWithObjects:@"j", @"k", @"l", nil];
  
  STAssertEqualObjects(list, comp, nil);
  
  [e delete];
  
  // Test push all without prior insert
  DKEntity *e2 = [DKEntity entityWithName:entityName];
  [e2 setObject:[NSArray arrayWithObjects:@"o", @"p", nil] forKey:@"values"];
  [e2 pushAllObjects:[NSArray arrayWithObjects:@"q", @"r", nil] forKey:@"values"];
  
  error = nil;
  success = [e2 save:&error];
  
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  
  list = [e2 objectForKey:@"values"];
  comp = [NSArray arrayWithObjects:@"o", @"p", @"q", @"r", nil];
  
  STAssertEqualObjects(list, comp, nil);
  
  [e2 delete];
}

- (void)testObjectAddToSet {
  NSString *entityName = @"AddToSetValues";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  DKEntity *object = [DKEntity entityWithName:entityName];
  [object setObject:[NSArray arrayWithObject:@"stefan"] forKey:@"names"];
  
  NSError *error = nil;
  BOOL success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [object addObjectToSet:@"erik" forKey:@"names"];
  [object addAllObjectsToSet:[NSArray arrayWithObjects:@"anna", @"stefan", @"jakob", nil] forKey:@"names"];
  [object addObjectToSet:@"mark" forKey:@"otherNames"];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  NSArray *list = [object objectForKey:@"names"];
  NSArray *comp = [NSArray arrayWithObjects:@"stefan", @"erik", @"anna", @"jakob", nil];
  STAssertEqualObjects(list, comp, nil);
  
  list = [object objectForKey:@"otherNames"];
  comp = [NSArray arrayWithObjects:@"mark", nil];
  STAssertEqualObjects(list, comp, nil);
  
  [object delete];
  
  // Test add to set without prior insert
  DKEntity *e = [DKEntity entityWithName:entityName];
  [e setObject:[NSArray arrayWithObjects:@"a", @"b", @"c", nil] forKey:@"values"];
  [e addAllObjectsToSet:[NSArray arrayWithObjects:@"b", @"d", nil] forKey:@"values"];
  
  error = nil;
  success = [e save:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  
  list = [e objectForKey:@"values"];
  comp = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", nil];
  
  STAssertEqualObjects(list, comp, nil);
  
  [e delete];
}

- (void)testObjectPop {
  NSString *entityName = @"PopValues";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  NSMutableArray *names = [NSMutableArray arrayWithObjects:@"stefan", @"erik", @"markus", nil];
  DKEntity *object = [DKEntity entityWithName:entityName];
  [object setObject:names forKey:@"names"];
  
  NSError *error = nil;
  BOOL success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [object popFirstObjectForKey:@"names"];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [names removeObjectAtIndex:0];
  
  NSArray *list = [object objectForKey:@"names"];
  STAssertEqualObjects(list, names, nil);
  
  [object popLastObjectForKey:@"names"];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [names removeLastObject];
  
  list = [object objectForKey:@"names"];
  STAssertEqualObjects(list, names, nil);
  
  [object delete];
  
  // Test pop without prior insert
  DKEntity *e = [DKEntity entityWithName:entityName];
  [e setObject:[NSArray arrayWithObjects:@"a", @"b", @"c", nil] forKey:@"values"];
  [e popFirstObjectForKey:@"values"];
  
  error = nil;
  success = [e save:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  
  list = [e objectForKey:@"values"];
  NSArray *comp = [NSArray arrayWithObjects:@"b", @"c", nil];
  
  STAssertEqualObjects(list, comp, nil);
  
  [e delete];
}

- (void)testObjectPull {
  NSString *entityName = @"PullValues";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  NSString *key = @"values";
  NSMutableArray *values = [NSMutableArray arrayWithObjects:@"a", @"b", @"b", @"c", @"d", @"d", nil];
  
  DKEntity *object = [DKEntity entityWithName:entityName];
  [object setObject:values forKey:key];
  
  NSError *error = nil;
  BOOL success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [object pullObject:@"x" forKey:key];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  NSArray *list = [object objectForKey:@"values"];
  STAssertEqualObjects(values, list, nil);
  
  [object pullObject:@"b" forKey:key];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [values removeObject:@"b"];
  
  list = [object objectForKey:key];
  STAssertEqualObjects(values, list, nil);
  
  [object pullAllObjects:[NSArray arrayWithObjects:@"c", @"d", nil] forKey:@"values"];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [values removeObject:@"c"];
  [values removeObject:@"d"];
  
  list = [object objectForKey:key];
  STAssertEqualObjects(values, list, nil);
  
  [object delete];
  
  // Test object pull without prior insert
  DKEntity *e = [DKEntity entityWithName:entityName];
  [e setObject:[NSArray arrayWithObjects:@"X", @"Y", @"Z", nil] forKey:@"values"];
  [e pullObject:@"Y" forKey:key];
  
  STAssertTrue(e.pullAllMap.count > 0, nil);
  
  error = nil;
  success = [e save:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  
  list = [e objectForKey:key];
  NSArray *comp = [NSArray arrayWithObjects:@"X", @"Z", nil];
  
  STAssertEqualObjects(comp, list, @"list: %@", list);
  
  [e delete];
}

- (void)testEnsureIndex {
  NSString *entityName = @"EnsureIndexes";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  DKEntity *e = [DKEntity entityWithName:entityName];
  [e setObject:@"erik" forKey:@"names"];
  
  NSError *error = nil;
  BOOL success = [e save:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  
  // Test unique index
  error = nil;
  success = [e ensureIndexForKey:@"names" unique:YES dropDuplicates:YES error:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  
  DKEntity *e2 = [DKEntity entityWithName:entityName];
  [e2 setObject:@"stefan" forKey:@"names"];
  
  error = nil;
  success = [e2 save:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  
  [e2 setObject:@"erik" forKey:@"names"];
  
  error = nil;
  success = [e2 save:&error];
  
  STAssertNotNil(error, error.localizedDescription);
  STAssertFalse(success, nil);
  
  [e delete];
  [e2 delete];
}

- (void)testEntityDestroy {
  NSString *entityName = @"DestroyMe";
  
  [DKEntity destroyAllEntitiesForName:entityName error:NULL];
  
  DKEntity *entity = [DKEntity entityWithName:entityName];
  [entity setObject:@"a" forKey:@"b"];
  [entity save];
  
  DKQuery *query = [DKQuery queryWithEntityName:entityName];
  
  NSUInteger count = [query countAll];
  
  STAssertTrue(count > 0, nil);
  
  NSError *error = nil;
  BOOL success = [DKEntity destroyAllEntitiesForName:entityName error:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  
  count = [query countAll];
  
  STAssertEquals(count, (NSUInteger)0, nil);
}

@end

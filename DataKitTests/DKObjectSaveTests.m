//
//  DKObjectSaveTests.m
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKObjectSaveTests.h"

#import "DataKit.h"
#import "DKEntity-Private.h"
#import "NSData+DataKit.h"

@implementation DKObjectSaveTests

- (void)setUp {
  [DKManager setAPIEndpoint:@"http://localhost:3000"];
  [DKManager setAPISecret:@"c821a09ebf01e090a46b6bbe8b21bcb36eb5b432265a51a76739c20472908989"];
}

- (void)testObjectInSerial {
  // Insert
  DKEntity *object = [DKEntity entityWithName:@"User"];
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
  STAssertEquals(mapCount, (NSUInteger)4, @"result map should have 4 elements, has %i", mapCount);
  
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
  STAssertEquals(mapCount, (NSUInteger)5, @"result map should have 5 elements, has %i", mapCount);
  
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
  STAssertEquals(mapCount, (NSUInteger)4, @"result map should have 4 elements, has %i", mapCount);
  
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
  STAssertEquals(mapCount, (NSUInteger)4, @"result map should have 4 elements, has %i", mapCount);
  
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

- (void)testObjectKeyIncrement {
  // Insert
  DKEntity *object = [DKEntity entityWithName:@"Value"];
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
  
  [object delete];
}

- (void)testObjectPush {
  DKEntity *object = [DKEntity entityWithName:@"PushValue"];
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
}

- (void)testObjectAddToSet {
  DKEntity *object = [DKEntity entityWithName:@"AddToSetValues"];
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
}

- (void)testObjectPop {
  NSMutableArray *names = [NSMutableArray arrayWithObjects:@"stefan", @"erik", @"markus", nil];
  DKEntity *object = [DKEntity entityWithName:@"PopValues"];
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
}

- (void)testObjectPull {
  NSMutableArray *values = [NSMutableArray arrayWithObjects:@"a", @"b", @"b", @"c", @"d", @"d", nil];
  DKEntity *object = [DKEntity entityWithName:@"PullValues"];
  [object setObject:values forKey:@"values"];
  
  NSError *error = nil;
  BOOL success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [object pullObject:@"x" forKey:@"values"];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  NSArray *list = [object objectForKey:@"values"];
  STAssertEqualObjects(values, list, nil);
  
  [object pullObject:@"b" forKey:@"values"];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [values removeObject:@"b"];
  
  list = [object objectForKey:@"values"];
  STAssertEqualObjects(values, list, nil);
  
  [object pullAllObjects:[NSArray arrayWithObjects:@"c", @"d", nil] forKey:@"values"];
  
  error = nil;
  success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  [values removeObject:@"c"];
  [values removeObject:@"d"];
  
  list = [object objectForKey:@"values"];
  STAssertEqualObjects(values, list, nil);
  
  [object delete];
}

@end

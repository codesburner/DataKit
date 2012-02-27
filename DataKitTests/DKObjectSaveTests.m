//
//  DKObjectSaveTests.m
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKObjectSaveTests.h"

#import "DataKit.h"
#import "DKObject-Private.h"
#import "NSData+Hex.h"
#import "NSData+Base64.h"

@implementation DKObjectSaveTests

- (void)setUp {
  [DKManager setAPIEndpoint:@"http://localhost:3000"];
  [DKManager setAPISecret:@"c821a09ebf01e090a46b6bbe8b21bcb36eb5b432265a51a76739c20472908989"];
}

- (void)testPublicIDGeneration {
  NSString *oid = @"4F4AA5A86886D57C1A000001";
  DKObject *obj = [DKObject objectWithEntityName:@"Test"];
  obj.resultMap = [NSDictionary dictionaryWithObject:oid forKey:@"_id"];
  
  NSString *pid = [obj publicId];
  
  STAssertTrue(pid.length > 0, @"public ID must not be empty (%@)", pid);
  
  NSData *data = [NSData dataFromBase64String:pid];
  NSString *oid2 = [data hexString];
  
  STAssertEqualObjects(oid, oid2, @"decoded oid must match original oid");
}

- (void)testObjectSaveUpdateRefreshDelete {
  // Insert
  DKObject *object = [DKObject objectWithEntityName:@"User"];
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
  STAssertEquals(mapCount, (NSUInteger)3, @"result map should have 3 elements, has %i", mapCount);
  
  NSString *oid = [object objectForKey:@"_id"];
  NSString *name = [object objectForKey:@"name"];
  NSString *surname = [object objectForKey:@"surname"];
  
  STAssertTrue(oid.length > 0, @"result map should have field '_id'");
  STAssertEqualObjects(name, @"Erik", @"result map should have name field set to 'Erik', is '%@'", name);
  STAssertEqualObjects(surname, @"Aigner", @"result map should have surname field set to 'Aigner', is '%@'", surname);
  
  // Update
  [object setObject:@"Stefan" forKey:@"name"];
  [object setObject:@"More" forKey:@"more"];
  
  error = nil;
  success = [object save:&error];
  STAssertNil(error, @"update should not return error, did return %@", error);
  STAssertTrue(success, @"update should have been successful (return YES)");
  
  mapCount = object.resultMap.count;
  STAssertEquals(mapCount, (NSUInteger)4, @"result map should have 4 elements, has %i", mapCount);
  
  NSString *oid2 = [object objectForKey:@"_id"];
  name = [object objectForKey:@"name"];
  surname = [object objectForKey:@"surname"];
  NSString *more = [object objectForKey:@"more"];
  
  STAssertTrue(oid2.length > 0, @"result map should have field '_id'");
  STAssertEqualObjects(oid2, oid, @"object id 1 and 2 should be equal");
  STAssertEqualObjects(name, @"Stefan", @"result map should have name field set to 'Stefan', is '%@'", name);
  STAssertEqualObjects(surname, @"Aigner", @"result map should have surname field set to 'Aigner', is '%@'", surname);
  STAssertEqualObjects(more, @"More", @"result map should have more field set to 'More', is '%@'", surname);
  
  // Unset
  [object removeObjectForKey:@"more"];
  
  error = nil;
  success = [object save:&error];
  STAssertNil(error, @"update (unset) should not return error, did return %@", error);
  STAssertTrue(success, @"update (unset) should have been successful (return YES)");
  
  mapCount = object.resultMap.count;
  STAssertEquals(mapCount, (NSUInteger)3, @"result map should have 3 elements, has %i", mapCount);
  
  more = [object objectForKey:@"more"];
  STAssertNil(more, @"more field should have been deleted");
  
  // Refresh
  [object setObject:@"RefreshMeAway" forKey:@"refresh"];
  
  NSString *refreshField = [object objectForKey:@"refresh"];
  STAssertNotNil(refreshField, @"refresh field should not be nil");
  
  error = nil;
  success = [object refresh:&error];
  STAssertNil(error, @"refresh should not return error, did return %@", error);
  STAssertTrue(success, @"refresh should have been successful (return YES)");
  
  mapCount = object.resultMap.count;
  STAssertEquals(mapCount, (NSUInteger)3, @"result map should have 3 elements, has %i", mapCount);
  
  refreshField = [object objectForKey:@"refresh"];
  STAssertNil(refreshField, @"refresh field should have been cleared");
  
  // Delete
  error = nil;
  success = [object delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
}

@end

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
#import "NSData+DataKit.h"

@implementation DKObjectSaveTests

- (void)setUp {
  [DKManager setAPIEndpoint:@"http://localhost:3000"];
  [DKManager setAPISecret:@"c821a09ebf01e090a46b6bbe8b21bcb36eb5b432265a51a76739c20472908989"];
}

- (void)testObjectInSerial {
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
  
  // Remove
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
  DKObject *object = [DKObject objectWithEntityName:@"Value"];
  [object setObject:@"TestValue" forKey:@"key"];
  [object setObject:[NSNumber numberWithInteger:3] forKey:@"amount"];
  
  NSError *error = nil;
  BOOL success = [object save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  STAssertEquals([[object objectForKey:@"amount"] integerValue], (NSInteger)3, nil);
  
  [object incrementKey:@"amount" byAmount:[NSNumber numberWithInteger:2]];
  
  error = nil;
  success = [object save:&error];
  
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  STAssertEquals([[object objectForKey:@"amount"] integerValue], (NSInteger)5, nil);
  
  [object delete];
}

@end

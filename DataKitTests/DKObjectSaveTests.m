//
//  DKObjectSaveTests.m
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKObjectSaveTests.h"

#import "DataKit.h"

@implementation DKObjectSaveTests

- (void)setUp {
  [DKManager setAPIEndpoint:@"http://localhost:3000"];
}

- (void)testObjectSave {
  // Test insert
  DKObject *object = [DKObject objectWithEntityName:@"User"];
  [object setObject:@"Erik" forKey:@"name"];
  [object setObject:@"Aigner" forKey:@"surname"];
  
  NSError *error = nil;
  BOOL success = [object save:&error];
  if (!success) {
    NSLog(@"error: %@", error);
  }
  STAssertNil(error, @"error should be nil");
  STAssertTrue(success, @"save should succeed");
  
  NSString *oid = [object objectForKey:@"_id"];
  NSString *name = [object objectForKey:@"name"];
  NSString *surname = [object objectForKey:@"surname"];
  
  STAssertTrue(oid.length > 0, nil);
  STAssertEqualObjects(name, @"Erik", nil);
  STAssertEqualObjects(surname, @"Aigner", nil);
  
  // Test update
  [object setObject:@"Stefan" forKey:@"name"];

  error = nil;
  success = [object save:&error];
  if (!success) {
    NSLog(@"error: %@", error);
  }
  STAssertNil(error, nil);
  STAssertTrue(success, nil);
  
  oid = [object objectForKey:@"_id"];
  name = [object objectForKey:@"name"];
  surname = [object objectForKey:@"surname"];
  
  STAssertTrue(oid.length > 0, nil);
  STAssertEqualObjects(name, @"Stefan", nil);
  STAssertEqualObjects(surname, @"Aigner", nil);
}

@end

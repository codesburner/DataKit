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
}

@end

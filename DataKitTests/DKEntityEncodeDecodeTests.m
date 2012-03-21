//
//  DKEntityEncodeDecodeTests.m
//  DataKit
//
//  Created by Erik Aigner on 04.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKEntityEncodeDecodeTests.h"

#import "DKEntity.h"
#import "DKQuery.h"
#import "DKManager.h"
#import "DKTests.h"

@implementation DKEntityEncodeDecodeTests

- (void)setUp {
  [DKManager setAPIEndpoint:kDKEndpoint];
  [DKManager setAPISecret:kDKSecret];
}

- (void)testDataStore {
  NSString *entityName = @"DataEntity";
  DKEntity *e = [DKEntity entityWithName:entityName];
  
  NSString *dataString = @"this utf8 string is represented as NSData";
  NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  
  [e setObject:data forKey:@"stringData"];
  [e save];
  
  DKQuery *q = [DKQuery queryWithEntityName:entityName];

  DKEntity *qe = [[q findAll] lastObject];
  
  NSData *dataOut = [qe objectForKey:@"stringData"];
  
  STAssertTrue([dataOut isKindOfClass:[NSData class]], nil);
  
  NSString *stringOut = [[NSString alloc] initWithData:dataOut encoding:NSUTF8StringEncoding];
  
  STAssertEqualObjects(dataString, stringOut, nil);
  
  [e delete];
}
@end

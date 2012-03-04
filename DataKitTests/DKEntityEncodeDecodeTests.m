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

@implementation DKEntityEncodeDecodeTests

- (void)setUp {
  [DKManager setAPIEndpoint:@"http://localhost:3000"];
  [DKManager setAPISecret:@"c821a09ebf01e090a46b6bbe8b21bcb36eb5b432265a51a76739c20472908989"];
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

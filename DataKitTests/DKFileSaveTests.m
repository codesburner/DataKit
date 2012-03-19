//
//  DKFileSaveTests.m
//  DataKit
//
//  Created by Erik Aigner on 18.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKFileSaveTests.h"

#import "DataKit.h"

@implementation DKFileSaveTests

- (void)setUp {
  [DKManager setAPIEndpoint:@"http://localhost:3000"];
  [DKManager setAPISecret:@"c821a09ebf01e090a46b6bbe8b21bcb36eb5b432265a51a76739c20472908989"];
}

- (NSData *)generateRandomDataWithLength:(NSUInteger)numBytes {
  NSMutableData *data = [NSMutableData new];
  [data appendData:[@"DSTART!" dataUsingEncoding:NSUTF8StringEncoding]];
  for (int i=0; i<numBytes; i++) {
    UInt8 c = (UInt8)(rand() % 255);
    CFDataAppendBytes((__bridge CFMutableDataRef)data, &c, 1);
  }
  [data appendData:[@"DEND!" dataUsingEncoding:NSUTF8StringEncoding]];
  return [NSData dataWithData:data];
}

- (void)testRandomData {
  NSInteger len = 1024;
  NSData *data = [self generateRandomDataWithLength:len];
  NSData *data2 = [self generateRandomDataWithLength:len];
  
  STAssertFalse([data isEqualToData:data2], nil);
}

- (void)testSave {
  NSString *fileName = @"someFile";
  NSData *data = [self generateRandomDataWithLength:1024*1024];
  
  [DKFile deleteFile:fileName error:NULL];
  
  DKFile *file = [DKFile fileWithData:data name:fileName];
  
  NSError *error = nil;
  BOOL success = [file save:&error];
  
  STAssertTrue(success, nil);
  STAssertNil(error, error.localizedDescription);
}

@end

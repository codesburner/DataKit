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

- (void)testFileIntegrity {
  NSString *fileName = @"someFile";
  NSData *data = [self generateRandomDataWithLength:1024*1024];
  
  [DKFile deleteFile:fileName error:NULL];
  
  NSError *error = nil;
  BOOL exists = [DKFile fileExists:fileName error:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertFalse(exists, nil);
  
  DKFile *file = [DKFile fileWithData:data name:fileName];
  
  error = nil;
  BOOL success = [file save:&error];
  
  STAssertTrue(success, nil);
  STAssertNil(error, error.localizedDescription);
  
  error = nil;
  exists = [DKFile fileExists:fileName error:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(exists, nil);
  
  NSURL *ep = [DKManager endpointForMethod:@"stream"];
  NSString *absoluteString = [ep.absoluteString stringByAppendingPathComponent:fileName];
  
  NSData *data2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:absoluteString]];
  
  STAssertTrue([data isEqualToData:data2], nil);
}

- (void)testAsyncSave {
  NSString *fileName = @"asyncFile";
  NSData *data = [self generateRandomDataWithLength:1024*100];
  
  [DKFile deleteFile:fileName error:NULL];
  
  DKFile *file = [DKFile fileWithData:data name:fileName];
  
  NSMutableArray *progress = [NSMutableArray new];
  
  __block BOOL asyncSuccess = NO;
  __block NSError *asyncError = nil;
  __block BOOL done = NO;
  
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  
  STAssertNotNil(runLoop, nil);
  
  [file saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
    asyncSuccess = success;
    asyncError = error;
    done = YES;
  } progressBlock:^(NSUInteger bytes, NSUInteger totalBytes) {
    [progress addObject:[NSNumber numberWithInt:bytes]];
  }];
  
  while (!done && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
  }
  
  STAssertNil(asyncError, asyncError.localizedDescription);
  STAssertTrue(asyncSuccess, nil);
  STAssertTrue(progress.count > 0, nil);
}

@end

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
  NSData *startData = [@"DSTART!" dataUsingEncoding:NSUTF8StringEncoding];
  NSData *endData = [@"DEND!" dataUsingEncoding:NSUTF8StringEncoding];
  NSUInteger plus = (startData.length + endData.length);
  numBytes = MAX(numBytes, plus) - plus;
  [data appendData:startData];
  for (int i=0; i<numBytes; i++) {
    UInt8 c = (UInt8)(rand() % 255);
    CFDataAppendBytes((__bridge CFMutableDataRef)data, &c, 1);
  }
  [data appendData:endData];
  return [NSData dataWithData:data];
}

- (void)testRandomData {
  NSInteger len = 1024;
  NSData *data = [self generateRandomDataWithLength:len];
  NSData *data2 = [self generateRandomDataWithLength:len];
  
  STAssertFalse([data isEqualToData:data2], nil);
}

- (void)testFileIntegrityAndLoad {
  NSString *fileName = @"someFile";
  NSData *data = [self generateRandomDataWithLength:1024*1024];
  
  // Delete old file
  [DKFile deleteFile:fileName error:NULL];
  
  // Check exists (NO)
  NSError *error = nil;
  BOOL exists = [DKFile fileExists:fileName error:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertFalse(exists, nil);
  
  // Save
  DKFile *file = [[DKFile alloc] initWithData:data name:fileName];
  
  error = nil;
  BOOL success = [file save:&error];
  
  STAssertTrue(success, nil);
  STAssertNil(error, error.localizedDescription);
  
  // Check exists (YES)
  error = nil;
  exists = [DKFile fileExists:fileName error:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(exists, nil);
  
  // Load sync
  error = nil;
  DKFile *file2 = [DKFile fileWithName:fileName];
  NSData *data2 = [file2 loadData:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue([data isEqualToData:data2], nil);
  
  // Load async
  DKFile *file3 = [DKFile fileWithName:fileName];
  
  NSMutableArray *progress = [NSMutableArray new];
  
  __block BOOL asyncSuccess = NO;
  __block NSData *asyncData = nil;
  __block NSError *asyncError = nil;
  __block BOOL done = NO;
  
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  
  STAssertNotNil(runLoop, nil);
  
  [file3 loadDataInBackgroundWithBlock:^(BOOL success, NSData *data, NSError *error) {
    asyncSuccess = success;
    asyncData = data;
    asyncError = error;
    done = YES;
  } progressBlock:^(NSUInteger bytes, NSUInteger totalBytes) {
    [progress addObject:[NSNumber numberWithInt:bytes]];
    NSLog(@"LOAD PROGRESS: %i/%i", bytes, totalBytes);
  }];
  
  while (!done && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
  
  STAssertTrue(asyncSuccess, nil);
  STAssertNil(asyncError, asyncError.localizedDescription);
  STAssertNotNil(asyncData, nil);
  STAssertTrue(asyncData.length > 0, nil);
  STAssertTrue([data isEqualToData:asyncData], nil);
  STAssertTrue(progress.count > 0, nil);
}

- (void)testAsyncSave {
  NSString *fileName = @"asyncFile";
  NSData *data = [self generateRandomDataWithLength:1024*100];
  
  [DKFile deleteFile:fileName error:NULL];
  
  DKFile *file = [[DKFile alloc] initWithData:data name:fileName];
  
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
    NSLog(@"SAVE PROGRESS: %i/%i", bytes, totalBytes);
  }];
  
  while (!done && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
  
  STAssertNil(asyncError, asyncError.localizedDescription);
  STAssertTrue(asyncSuccess, nil);
  STAssertTrue(progress.count > 0, nil);
}

- (void)testAsyncSaveAndAbort {
  NSString *fileName = @"asyncFileAbort";
  NSData *data = [self generateRandomDataWithLength:1024*100];
  
  // Delete old file
  [DKFile deleteFile:fileName error:NULL];
  
  // Save file and abort
  DKFile *file = [[DKFile alloc] initWithData:data name:fileName];
  
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
    NSLog(@"DONE!");
  } progressBlock:^(NSUInteger bytes, NSUInteger totalBytes) {
    [progress addObject:[NSNumber numberWithInt:bytes]];
    NSLog(@"SAVE ABORT PROGRESS: %i/%i", bytes, totalBytes);
    [file abort];
  }];
  
  while (!done && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
  
  STAssertNil(asyncError, asyncError.localizedDescription);
  STAssertFalse(asyncSuccess, nil);
  STAssertTrue(progress.count == 1, nil);
  
  // Check if file exists
  NSError *error = nil;
  BOOL exists = [DKFile fileExists:fileName error:&error];
  
  STAssertFalse(exists, nil);
  STAssertNil(error, error.localizedDescription);
}

- (void)testFileNameAssign {
  NSData *data = [self generateRandomDataWithLength:1024];
  DKFile *file = [[DKFile alloc] initWithData:data name:nil];
  
  STAssertNil(file.name, nil);
  
  NSError *error = nil;
  BOOL success = [file save:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  STAssertTrue(file.name.length > 0, file.name);
  
  [DKFile deleteFile:file.name error:NULL];
}

@end

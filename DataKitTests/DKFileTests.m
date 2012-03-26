//
//  DKFileSaveTests.m
//  DataKit
//
//  Created by Erik Aigner on 18.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKFileTests.h"

#import "DataKit.h"
#import "DKTests.h"

@implementation DKFileTests

- (void)setUp {
  [DKManager setAPIEndpoint:kDKEndpoint];
  [DKManager setAPISecret:kDKSecret];
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
  DKFile *file = [DKFile fileWithName:fileName data:data];
  
  STAssertTrue(file.isVolatile, nil);
  STAssertEqualObjects(data, file.data, nil);
  STAssertEqualObjects(fileName, file.name, nil);
  
  error = nil;
  BOOL success = [file save:&error];
  
  STAssertTrue(success, nil);
  STAssertNil(error, error.localizedDescription);
  STAssertFalse(file.isVolatile, nil);
  STAssertEqualObjects(data, file.data, nil);
  STAssertEqualObjects(fileName, file.name, nil);
  
  // Save again, produce error
  error = nil;
  success = [file save:&error];
  
  STAssertNotNil(error, error.localizedDescription);
  STAssertFalse(success, nil);
  
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
  
  DKFile *file = [DKFile fileWithName:fileName data:data];
  
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

- (void)testPublicFileURL {
  NSData *data = [self generateRandomDataWithLength:1024*100];
  
  DKFile *file = [DKFile fileWithData:data];
  
  STAssertTrue(file.isVolatile, nil);
  STAssertNil(file.name, nil);
  STAssertEqualObjects(file.data, data, nil);
  
  // Save file
  NSError *error = nil;
  BOOL success = [file save:&error];
  
  STAssertTrue(success, nil);
  STAssertNil(error, error.localizedDescription);
  
  // Generate public URL
  error = nil;
  NSURL *url = [file generatePublicURL:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue([url isKindOfClass:[NSURL class]], nil);
  
  // Fetch file from public URL and compare data
  NSData *data2 = [NSData dataWithContentsOfURL:url];
  
  STAssertEqualObjects(data, data2, nil);
  
  // Delete file
  error = nil;
  success = [file delete];
  
  STAssertTrue(success, nil);
  STAssertNil(error, error.localizedDescription);
}

- (void)testAsyncSaveAndAbort {
  NSString *fileName = @"asyncFileAbort";
  NSData *data = [self generateRandomDataWithLength:1024*100];
  
  // Delete old file
  [DKFile deleteFile:fileName error:NULL];
  
  // Save file and abort
  DKFile *file = [DKFile fileWithName:fileName data:data];
  
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
  DKFile *file = [DKFile fileWithData:data];
  
  STAssertNil(file.name, nil);
  
  NSError *error = nil;
  BOOL success = [file save:&error];
  
  STAssertNil(error, error.localizedDescription);
  STAssertTrue(success, nil);
  STAssertTrue(file.name.length > 0, file.name);
  
  [DKFile deleteFile:file.name error:NULL];
}

@end

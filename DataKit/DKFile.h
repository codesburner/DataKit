//
//  DKFile.h
//  DataKit
//
//  Created by Erik Aigner on 13.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^DKFileSaveResultBlock)(BOOL success, NSError *error);
typedef void (^DKFileLoadResultBlock)(NSData *data, NSError *error);
typedef void (^DKFileDeleteResultBlock)(BOOL success, NSError *error);
typedef void (^DKFileExistsResultBlock)(BOOL exists, NSError *error);

/**
 Block to track download and upload progress
 
 @param bytes Bytes received or written
 @param totalBytes Total expected bytes
 */
typedef void (^DKFileProgressBlock)(NSUInteger bytes, NSUInteger totalBytes);

/**
 Represents a block of binary data. You can set file objects on keys in <DKEntity> instances.
 */
@interface DKFile : NSObject
@property (nonatomic, assign, readonly) BOOL isVolatile;
@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSString *name;

/** @name Creating Files */

+ (DKFile *)fileWithData:(NSData *)data name:(NSString *)name;

- (id)initWithData:(NSData *)data name:(NSString *)name;

/** @name Checking for Existence */

+ (BOOL)fileExists:(NSString *)fileName;
+ (BOOL)fileExists:(NSString *)fileName error:(NSError **)error;
+ (void)fileExists:(NSString *)fileName inBackgroundWithBlock:(DKFileExistsResultBlock)block;

/** @name Deleting Files */

+ (BOOL)deleteFile:(NSString *)fileName error:(NSError **)error;
+ (BOOL)deleteFiles:(NSArray *)fileNames error:(NSError **)error;

- (BOOL)delete;
- (BOOL)delete:(NSError **)error;
- (void)deleteInBackgroundWithBlock:(DKFileDeleteResultBlock)block;

/** @name Saving Files */

- (BOOL)save;
- (BOOL)save:(NSError **)error;
- (void)saveInBackgroundWithBlock:(DKFileSaveResultBlock)block;
- (void)saveInBackgroundWithBlock:(DKFileSaveResultBlock)block progressBlock:(DKFileProgressBlock)progressBlock;

/** @name Loading Data */

- (NSData *)loadData;
- (NSData *)loadData:(NSError **)error;
- (void)loadDataInBackgroundWithBlock:(DKFileLoadResultBlock)block;
- (void)loadDataInBackgroundWithBlock:(DKFileLoadResultBlock)block progressBlock:(DKFileProgressBlock)progressBlock;

/** @name Aborting */

- (void)abort;

@end

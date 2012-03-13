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
typedef void (^DKFileProgressBlock)(double progress);

/**
 Represents a block of binary data. DKFile should be used for files greater 10MB. You can set file objects on keys in <DKEntity> instances.
 */
@interface DKFile : NSObject
@property (nonatomic, assign, readonly) BOOL isDirty;
@property (nonatomic, assign, readonly) BOOL hasData;
@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSString *name;

/** @name Creating Files */

+ (DKFile *)fileWithData:(NSData *)data;
+ (DKFile *)fileWithData:(NSData *)data name:(NSString *)name;

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

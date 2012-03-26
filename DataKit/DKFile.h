//
//  DKFile.h
//  DataKit
//
//  Created by Erik Aigner on 13.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Represents a block of binary data. You should use this class for larger data objects (>10MB).
 */
@interface DKFile : NSObject

/**
 If `YES` the file is not stored on the server, `NO` otherwise.
 */
@property (nonatomic, assign, readonly) BOOL isVolatile;

/**
 The file name (must be unique)
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 The file data
 */
@property (nonatomic, strong, readonly) NSData *data;

/** @name Creating and Initializing Files */

/**
 Creates a new file with the given data.
 
 The server will asign a random name for the file on save.
 @param data The file data
 @return The initialized file
 */
+ (DKFile *)fileWithData:(NSData *)data;

/**
 Creates a new file with the given name.
 
 You can then load the data using one of the load methods.
 @param name The filename
 @return The empty initialized file
 */
+ (DKFile *)fileWithName:(NSString *)name;

/**
 Creates a new file with the given name and data
 @param name The filename
 @param data The file data
 @return The initialized file
 */
+ (DKFile *)fileWithName:(NSString *)name data:(NSData *)data;

/**
 Initializes a new file with the given data and name.
 
 The file name must be unique, otherwise save will return an error.
 @param name The file name, if `nil` the server will assign a random name.
 @param data The file data
 @return The initialized file
 */
- (id)initWithName:(NSString *)name data:(NSData *)data;

/** @name Checking Existence */

/**
 Checks if a file with the specified name exists.
 @param fileName The file name to check
 @return `YES` if the file exists, `NO` if it doesn't
 */
+ (BOOL)fileExists:(NSString *)fileName;

/**
 Checks if a file with the specified name exists.
 @param fileName The file name to check
 @param error The error object set on error
 @return `YES` if the file exists, `NO` if it doesn't
 */
+ (BOOL)fileExists:(NSString *)fileName error:(NSError **)error;

/**
 Checks if a file with the specified name exists in the background
 @param fileName The file name to check
 @param block The result callback
 */
+ (void)fileExists:(NSString *)fileName inBackgroundWithBlock:(void (^)(BOOL exists, NSError *error))block;

/** @name Deleting Files */

/**
 Deletes the specified file
 @param fileName The file name
 @param error The error object set on error
 @return `YES` if the file was deleted, `NO` if not
 */
+ (BOOL)deleteFile:(NSString *)fileName error:(NSError **)error;

/**
 Deletes the specified files
 @param fileNames The file names
 @param error The error object set on error
 @return `YES` if the files were deleted, `NO` if not
 */
+ (BOOL)deleteFiles:(NSArray *)fileNames error:(NSError **)error;

/**
 Deletes the current file
 @return `YES` if the file was deleted, `NO` if not
 */
- (BOOL)delete;

/**
 Deletes the current file
 @param error The error object set on error
 @return `YES` if the file was deleted, `NO` if not
 */
- (BOOL)delete:(NSError **)error;

/**
 Deletes the current file in the background
 @param block The result callback
 */
- (void)deleteInBackgroundWithBlock:(void (^)(BOOL success, NSError *error))block;

/** @name Saving Files */

/**
 Saves the current file
 @return `YES` if the file was saved, otherwise `NO`.
 @exception NSInternalInconsistencyException Raised if data is not set
 */
- (BOOL)save;

/**
 Saves the current file
 @param error The error object set on error
 @return `YES` if the file was saved, otherwise `NO`.
 @exception NSInternalInconsistencyException Raised if data is not set
 */
- (BOOL)save:(NSError **)error;

/**
 Saves the current file in the background
 @param block The result block
 @exception NSInternalInconsistencyException Raised if data is not set
 */
- (void)saveInBackgroundWithBlock:(void (^)(BOOL success, NSError *error))block;

/**
 Saves the current file in the background and tracks upload progress
 @param block The result callback
 @param progressBlock The progress callback for tracking upload progress
 @exception NSInternalInconsistencyException Raised if data is not set
 */
- (void)saveInBackgroundWithBlock:(void (^)(BOOL success, NSError *error))block progressBlock:(void (^)(NSUInteger bytes, NSUInteger totalBytes))progressBlock;

/** @name Loading Data */

/**
 Loads data for the specified filename
 @return The file data
 @exception NSInternalInconsistencyException Raised if name is not set
 */
- (NSData *)loadData;

/**
 Loads data for the specified filename
 @param error The error object set on error
 @return The file data
 @exception NSInternalInconsistencyException Raised if name is not set
 */
- (NSData *)loadData:(NSError **)error;

/**
 Loads data for the specified filename in the background
 @param block The result callback block
 @exception NSInternalInconsistencyException Raised if name is not set
 */
- (void)loadDataInBackgroundWithBlock:(void (^)(BOOL success, NSData *data, NSError *error))block;

/**
 Loads data for the specified filename in the background
 @param block The result callback block
 @param progressBlock The download progress callback block
 @exception NSInternalInconsistencyException Raised if name is not set
 */
- (void)loadDataInBackgroundWithBlock:(void (^)(BOOL success, NSData *data, NSError *error))block progressBlock:(void (^)(NSUInteger bytes, NSUInteger totalBytes))progressBlock;

/** @name Aborting */

/**
 Aborts the current asynchronous save or load
 
 The callback blocks will return `NO` on the `success` flag
 */
- (void)abort;

/** @name Public URLs */

/**
 Generates a public URL to access the file directly
 @param error The error object set on error
 @return The public URL for the file data
 */
- (NSURL *)generatePublicURL:(NSError **)error;

@end

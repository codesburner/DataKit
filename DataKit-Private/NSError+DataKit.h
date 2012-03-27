//
//  NSError+DataKit.h
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (DataKit)

+ (void)writeToError:(NSError **)error code:(NSInteger)code description:(NSString *)desc original:(NSError *)originalError;

@end

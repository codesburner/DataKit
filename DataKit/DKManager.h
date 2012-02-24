//
//  DKManager.h
//  DataKit
//
//  Created by Erik Aigner on 24.02.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKManager : NSObject

+ (void)setAPIEndpoint:(NSString *)absoluteString;
+ (NSString *)APIEndpoint;

@end

//
//  NSDateFormatter+ThreadSafe.h
//  ClearStyle
//
//  Created by LIANGJUN JIANG on 12/8/12.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (ThreadSafe)
+ (NSDateFormatter *)dateReader;
+ (NSDateFormatter *)dateWriter;

@end

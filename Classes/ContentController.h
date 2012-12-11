/*
     File: ContentController.h 
 Abstract: The generic content controller superclass. Subclasses are created for supporting differing devices. 
  Version: 1.4 
  
 
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
 */

#import <Foundation/Foundation.h>

@interface ContentController : NSObject
{
    NSArray *contentList;
}

@property (nonatomic, retain) NSArray *contentList;

- (UIView *)view;

@end

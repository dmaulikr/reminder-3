/*
     File: MyViewController.m
 Abstract: A controller for a single page of content. For this application, pages simply display text on a colored background. The colors are retrieved from a static color list.
  Version: 1.4
 
 
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import "HomeContentViewController.h"

static NSArray *__pageControlColorList = nil;

@implementation HomeContentViewController

@synthesize pageNumberLabel, numberImage, numberTitle;

// Creates the color list the first time this method is invoked. Returns one color object from the list.
+ (UIColor *)pageControlColorWithIndex:(NSUInteger)index {
    if (__pageControlColorList == nil) {
        __pageControlColorList = [[NSArray alloc] initWithObjects:[UIColor clearColor], [UIColor clearColor], [UIColor clearColor],
                                  [UIColor clearColor], nil];
    }
	
    // Mod the index by the list length to ensure access remains in bounds.
    return [__pageControlColorList objectAtIndex:index % [__pageControlColorList count]];
}

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithPageNumber:(int)page {
    if (self = [super initWithNibName:@"MyView" bundle:nil]) {
        pageNumber = page;
    }
    return self;
}

- (void)dealloc {
//    [pageNumberLabel release];
//    [super dealloc];
}

// Set the label and background color when the view has finished loading.
- (void)viewDidLoad {
    pageNumberLabel.text = [NSString stringWithFormat:@"Page %d", pageNumber + 1];
    self.view.backgroundColor = [HomeContentViewController pageControlColorWithIndex:pageNumber];
}

@end

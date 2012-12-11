/*
     File: MyViewController.h
 Abstract: A controller for a single page of content. For this application, pages simply display text on a colored background. The colors are retrieved from a static color list.
  Version: 1.4
 
 
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import <UIKit/UIKit.h>


@interface HomeContentViewController : UIViewController {
    UILabel *pageNumberLabel;
    int pageNumber;
    UIImageView *numberImage;
    UILabel *numberTitle;
}

@property (nonatomic, retain) IBOutlet UILabel *pageNumberLabel;
@property (nonatomic, retain) IBOutlet UILabel *numberTitle;
@property (nonatomic, retain) IBOutlet UIImageView *numberImage;


- (id)initWithPageNumber:(int)page;

@end

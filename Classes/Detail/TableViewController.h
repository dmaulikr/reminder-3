
/*
     File: TableViewController.h
 Abstract: Table view controller to manage display of quotations from various plays.
 The controller supports opening and closing of sections. To do this it maintains information about each section using an array of SectionInfo objects.
 
  Version: 2.0
 
 Copyright (C) 2011 LJApps. All Rights Reserved.
 
 */

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "SectionHeaderView.h"

@class QuoteCell;

@interface TableViewController : UITableViewController <MFMailComposeViewControllerDelegate, SectionHeaderViewDelegate> 

@property (nonatomic, strong) NSArray* plays;
@property (nonatomic, weak) IBOutlet QuoteCell *quoteCell;

@end


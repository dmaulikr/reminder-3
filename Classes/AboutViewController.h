/*
     File: RecipeDetailViewController.h
 Abstract: Table view controller to manage an editable table view that displays information about a recipe.
 The table view uses different cell types for different row types.
 
  Version: 1.4
 
 
 
 Copyright (C) 2010 LJApps. All Rights Reserved.
 
 */

@interface AboutViewController : UITableViewController {
    @private
    
        NSArray *credits;
        NSArray *authors;
        UIView *tableHeaderView;
        UIButton *photoButton;
        UITextField *nameTextField;
        UITextField *overviewTextField;
        UITextField *versionTextField;
}
            
@property (nonatomic, retain) NSArray *credits;
@property (nonatomic, retain) NSArray *authors;
@property (nonatomic, retain) NSArray *instructions;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UIButton *photoButton;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *overviewTextField;
@property (nonatomic, retain) IBOutlet UITextField *versionTextField;

@end

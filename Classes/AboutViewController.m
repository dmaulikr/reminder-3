/*
     File: RecipeDetailViewController.m 
 Abstract: Table view controller to manage an editable table view that displays information about a recipe.
 The table view uses different cell types for different row types.
  
  Version: 1.4 
  
 
  
 Copyright (C) 2010 LJApps. All Rights Reserved. 
  
 */

#import "AboutViewController.h"

@implementation AboutViewController

@synthesize credits;
@synthesize authors, instructions;
@synthesize tableHeaderView;
@synthesize photoButton;
@synthesize nameTextField, overviewTextField, versionTextField;

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
        
        
    }
    
    return self;
}

- (void)viewDidLoad {
    // Create and set the table header view.
    if (tableHeaderView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"DetailHeaderView" owner:self options:nil];
        self.tableView.tableHeaderView = tableHeaderView;
    }
    
    [SSThemeManager customizeTableView:self.tableView];
    
    self.title = NSLocalizedString(@"About", @"About");
    
    self.nameTextField.text = @"Reminder +";
    self.overviewTextField.text = @"A better reminder app";
    self.versionTextField.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *developer = @{@"name":@"Liangjun Jiang, Mi Zhang", @"title":@"Developer"};
    NSDictionary *creative= @{@"name":@"Leah Wang", @"title":@"Creative"};
    self.authors = @[developer, creative];
    self.credits = @[@"Custome Alert", @"Other Stuffs",@"Other Stuff2",@"Other Stuffs"];
    self.instructions = @[@"How to use it"];
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
	
}


- (void)viewDidUnload {
    self.tableHeaderView = nil;
	self.photoButton = nil;
	self.nameTextField = nil;
	self.overviewTextField = nil;
	self.versionTextField = nil;
	[super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



#pragma mark -
#pragma mark UITableView Delegate/Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    // Return a title or nil as appropriate for the section.
    switch (section) {
        case 0:
            title = @"Authors";
            break;
        case 1:
            title = @"Credits";
            break;
        case 2:
            title = @"Instruction";
            break;
            
        default:
            break;
    }
    return title;;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    /*
     The number of rows depends on the section.
     In the case of ingredients, if editing, add a row in editing mode to present an "Add Ingredient" cell.
	 */
    switch (section) {
        case 0:
            return self.authors.count;
            break;
        case 1:
            return self.credits.count;
            break;
        case 2:
            return self.instructions.count;
		default:
            break;
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
     // For the Ingredients section, if necessary create a new cell and configure it with an additional label for the amount.  Give the cell a different identifier from that used for cells in other sections so that it can be dequeued separately.
    if (indexPath.section == 0) {
		
        static NSString *authorCellIdentifier = @"IngredientsCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:authorCellIdentifier];
        
        if (cell == nil) {
             // Create a cell to display an ingredient.
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:authorCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = self.authors[indexPath.row][@"name"];
        cell.detailTextLabel.text = self.authors[indexPath.row][@"title"];
        
    } else {
         // If necessary create a new cell and configure it appropriately for the section.  Give the cell a different identifier from that used for cells in the Ingredients section so that it can be dequeued separately.
        static NSString *MyIdentifier = @"GenericCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        NSString *text = nil;
        
        switch (indexPath.section) {
            case 1: 
                text = self.credits[indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 2: // instructions
                text = self.instructions[indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            default:
                break;
        }
        
        cell.textLabel.text = text;
    }
    return cell;
}


#pragma mark - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end

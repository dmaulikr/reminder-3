//
//  PlaceCategoryViewController.m
//  Reminder
//
//  Created by LIANGJUN JIANG on 12/4/12.
//
//

#import "PlaceCategoryViewController.h"

@interface PlaceCategoryViewController ()
@property (nonatomic, strong) NSArray *placeCategory;
@property (nonatomic, strong) NSString *selectedCategory;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@end

@implementation PlaceCategoryViewController
@synthesize placeCategory;
@synthesize cancelBlock = cancelBlock_, saveBlock = saveBlock_;
@synthesize selectedCategory;
@synthesize lastIndexPath;

- (void)onDone:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    saveBlock_(self,self.selectedCategory);
}

- (void)onCancel:(id)sender
{
    cancelBlock_(self,nil);
}

#pragma mark - View Cycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = YES;
    
    // Right
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // left
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
 
    // last Indexpath
    lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    // we init the place category in this way
    [self setCategoryValues];
    
    //    self.tableView.sectionIndexMinimumDisplayRowCount=10;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (NSString *)atomicElementForIndexPath:(NSIndexPath *)indexPath {
//	return [[[PeriodicElements sharedPeriodicElements] elementsWithInitialLetter:[[[PeriodicElements sharedPeriodicElements] elementNameIndexArray] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
//}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.placeCategory.count;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
////	// returns the array of section titles. There is one entry for each unique character that an element begins with
////	// [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
////	return [[PeriodicElements sharedPeriodicElements] elementNameIndexArray];
//}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//	return index;
//}


//- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
//	// the section represents the initial letter of the element
//	// return that letter
//	NSString *initialLetter = [[[PeriodicElements sharedPeriodicElements] elementNameIndexArray] objectAtIndex:section];
//	
//	// get the array of elements that begin with that letter
//	NSArray *elementsWithInitialLetter = [[PeriodicElements sharedPeriodicElements] elementsWithInitialLetter:initialLetter];
//	
//	// return the count
//	return [elementsWithInitialLetter count];
//}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	// this table has multiple sections. One for each unique character that an element begins with
//	// [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
//	// return the letter that represents the requested section
//	// this is actually a delegate method, but we forward the request to the datasource in the view controller
//	
//	return [[[PeriodicElements sharedPeriodicElements] elementNameIndexArray] objectAtIndex:section];
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell...
    cell.textLabel.text = self.placeCategory[indexPath.row];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell* newCell = [tableView cellForRowAtIndexPath:indexPath];
    int newRow = [indexPath row];
    int oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
    
    if(newRow != oldRow)
    {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell* oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        lastIndexPath = indexPath;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.selectedCategory = self.placeCategory[indexPath.row];
    }
    
}


#pragma mark - categories
- (void)setCategoryValues
{
    self.placeCategory = @[
    @"accounting",
    @"airport",
    @"amusement_park",
    @"aquarium",
    @"art_gallery",
    @"atm",
    @"bakery",
    @"bank",
    @"bar",
    @"beauty_salon",
    @"bicycle_store",
    @"book_store",
    @"bowling_alley",
    @"bus_station",
    @"cafe",
    @"campground",
    @"car_dealer",
    @"car_rental",
    @"car_repair",
    @"car_wash",
    @"casino",
    @"cemetery",
    @"church",
    @"city_hall",
    @"clothing_store",
    @"convenience_store",
    @"courthouse",
    @"dentist",
    @"department_store",
    @"doctor",
    @"electrician",
    @"electronics_store",
    @"embassy",
    @"establishment",
    @"finance",
    @"fire_station",
    @"florist",
    @"food",
    @"funeral_home",
    @"furniture_store",
    @"gas_station",
    @"general_contractor",
    @"geocode",
    @"grocery_or_supermarket",
    @"gym",
    @"hair_care",
    @"hardware_store",
    @"health",
    @"hindu_temple",
    @"home_goods_store",
    @"hospital",
    @"insurance_agency",
    @"jewelry_store",
    @"laundry",
    @"lawyer",
    @"library",
    @"liquor_store",
    @"local_government_office",
    @"locksmith",
    @"lodging",
    @"meal_delivery",
    @"meal_takeaway",
    @"mosque",
    @"movie_rental",
    @"movie_theater",
    @"moving_company",
    @"museum",
    @"night_club",
    @"painter",
    @"park",
    @"parking",
    @"pet_store",
    @"pharmacy",
    @"physiotherapist",
    @"place_of_worship",
    @"plumber",
    @"police",
    @"post_office",
    @"real_estate_agency",
    @"restaurant",
    @"roofing_contractor",
    @"rv_park",
    @"school",
    @"shoe_store",
    @"shopping_mall",
    @"spa",
    @"stadium",
    @"storage",
    @"store",
    @"subway_station",
    @"synagogue",
    @"taxi_stand",
    @"train_station",
    @"travel_agency",
    @"university",
    @"veterinary_care",
    @"zoo"
    ];
}
@end

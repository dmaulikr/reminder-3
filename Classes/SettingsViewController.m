//
//  SettingsViewController.m
//  Reminder
//
//  Created by LIANGJUN JIANG on 11/17/12.
//
//

#import "SettingsViewController.h"
#import "SwitchTableCell.h"

#define GENERAL_SECTION 0
#define REPEAT_SECTION 1
#define ALERT_SECTION 2
#define REGION_SECTION 3
#define ABOUT_SECTION 4

#define TITLE @"title"
#define VALUE @"placeholder"



@interface SettingsViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) NSMutableDictionary *contentList;
@property (nonatomic, strong) NSMutableArray *repeatPickerViewArray;
@end

@implementation SettingsViewController
@synthesize contentList;
@synthesize repeatPickerViewArray;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

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

    self.title = NSLocalizedString(@"Settings", @"Settings");
    
    [SSThemeManager customizeTableView:self.tableView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    
    self.contentList = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:plistPath]
                                                                 options:NSPropertyListMutableContainers
                                                                  format:NULL
                                                                   error:NULL];
//    self.repeatPickerViewArray = @[@"CA",@"FL",@"TX",@"NJ"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.contentList allKeys] objectAtIndex:section];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.contentList allKeys] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *key = [[self.contentList allKeys] objectAtIndex:section];
    return [[self.contentList objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    static NSString *GeneralCellIdentifier = @"GeneralCell";
    static NSString *RepeatCellIdentifier = @"RepeatCell";
    static NSString *AlertCellIdentifier = @"AlertCell";
    static NSString *RegionCellIdentifier = @"RegionCell";
    static NSString *AboutCellIdentifier = @"AboutCell";
    UITableViewCell *cell = nil;
    NSString *key = [[self.contentList allKeys] objectAtIndex:section];
    NSString *title = [[[self.contentList objectForKey:key] objectAtIndex:row] objectForKey:TITLE];
    NSNumber *switchState = 0;
    if (section != ABOUT_SECTION) {
        switchState = [[[self.contentList objectForKey:key] objectAtIndex:row] objectForKey:VALUE];
    }
    switch (section) {
        case GENERAL_SECTION:
        {
            SwitchTableCell *generalCell = (SwitchTableCell*)[tableView dequeueReusableCellWithIdentifier:GeneralCellIdentifier];
            if (generalCell == nil) {
                generalCell = [[SwitchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GeneralCellIdentifier];
                
            }
            generalCell.textLabel.text = title;
            generalCell.onOffSwitch.on = [switchState boolValue];
            [generalCell.onOffSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            generalCell.onOffSwitch.tag = section*100+row;
            cell = generalCell;
            break;
        }
            
        case REPEAT_SECTION:
        {
            SwitchTableCell *repeatCell = (SwitchTableCell*)[tableView dequeueReusableCellWithIdentifier:RepeatCellIdentifier];
            if (repeatCell == nil) {
                repeatCell = [[SwitchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RepeatCellIdentifier];
                
            }
            repeatCell.textLabel.text = title;
            repeatCell.onOffSwitch.on = [switchState boolValue];
            [repeatCell.onOffSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            repeatCell.onOffSwitch.tag = section*100+row;
            cell = repeatCell;
            break;
        }
        case ALERT_SECTION:
        {
            SwitchTableCell *alertCell = (SwitchTableCell*)[tableView dequeueReusableCellWithIdentifier:AlertCellIdentifier];
            if (alertCell == nil) {
                alertCell = [[SwitchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlertCellIdentifier];
            
            }
            alertCell.textLabel.text = title;
            alertCell.onOffSwitch.on = [switchState boolValue];
            [alertCell.onOffSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            alertCell.onOffSwitch.tag = section*100+row;
            cell = alertCell;
            break;
        }
            
        case REGION_SECTION:
        {
            SwitchTableCell *regionCell = (SwitchTableCell*)[tableView dequeueReusableCellWithIdentifier:RegionCellIdentifier];
            if (regionCell == nil) {
                regionCell = [[SwitchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RegionCellIdentifier];
                
            }
            regionCell.textLabel.text = title;
            regionCell.onOffSwitch.on = [switchState boolValue];
            [regionCell.onOffSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            regionCell.onOffSwitch.tag = section*100+row;
            cell = regionCell;
            break;
        }
        case ABOUT_SECTION:
        {
            UITableViewCell *aboutCell = [tableView dequeueReusableCellWithIdentifier:AboutCellIdentifier];
            if (aboutCell == nil) {
                aboutCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AboutCellIdentifier];
                aboutCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            aboutCell.textLabel.text = title;
            cell = aboutCell;
            break;
        }
        default:
        {
            static NSString *DefaultCellIdentifier = @"DefaultCell";
            UITableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
            if (defaultCell == nil) {
                defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCellIdentifier];
            }
            defaultCell.textLabel.text = title;
            cell = defaultCell;
            break;
            
            break;
        }
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section != ABOUT_SECTION) {
        NSLog(@"Choose About");
    } else
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - OnOffSwitch method
- (void)onSwitch:(id)sender
{
    UISwitch *settingSwitch = (UISwitch *)sender;
    NSUInteger section = settingSwitch.tag / 100;
    NSUInteger row = settingSwitch.tag % 100;
    
    NSNumber *value = [NSNumber numberWithBool:settingSwitch.on];
    
    // we now use the section/row info to update the contentList
    NSString *key = [[self.contentList allKeys] objectAtIndex:section];
    NSMutableDictionary *keyValueDictionary = [[self.contentList objectForKey:key] objectAtIndex:row];
    [keyValueDictionary setObject:value forKey:VALUE];
}

@end

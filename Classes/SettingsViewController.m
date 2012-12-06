//
//  SettingsViewController.m
//  Reminder
//
//  Created by LIANGJUN JIANG on 11/17/12.
//
//

#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "SwitchTableCell.h"
#import  <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SSTheme.h"

#define REGION_SECTION 0
#define ABOUT_SECTION 1

#define TITLE @"title"
#define kDESC @"desc"


#define kFont [UIFont boldSystemFontOfSize:14.0];

@interface SettingsViewController ()<UITextFieldDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSMutableDictionary *contentList;
@property (nonatomic, strong) NSString *defaultHeb;
@property (nonatomic, assign) BOOL onOff;
@property (nonatomic, retain, readonly) UISlider *sliderCtl;
@end

@implementation SettingsViewController
@synthesize contentList;
@synthesize defaultHeb, onOff;
@synthesize sliderCtl;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Settings", @"Settings");
    
    [SSThemeManager customizeTableView:self.tableView];
 
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"SimpleSettings" ofType:@"plist"];
    self.contentList = [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"USER_GEOFENCING"]) {
        [defaults setDouble:self.sliderCtl.value forKey:@"GEOFENCING_RADIUS"];
        [defaults synchronize];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == REGION_SECTION)? 60.0 :44.0;
    
}


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
    
    static NSString *RegionCellIdentifier = @"RegionCell";
    static NSString *AboutCellIdentifier = @"AboutCell";
    UITableViewCell *cell = nil;
    NSString *key = [[self.contentList allKeys] objectAtIndex:section];
    NSString *title = [[[self.contentList objectForKey:key] objectAtIndex:row] objectForKey:TITLE];
    
    if (section == REGION_SECTION) {
        NSString *desc = [[[self.contentList objectForKey:key] objectAtIndex:row] objectForKey:kDESC];
        
        if  (row !=2){
            SwitchTableCell *regionCell = (SwitchTableCell*)[tableView dequeueReusableCellWithIdentifier:RegionCellIdentifier];
            if (regionCell == nil) {
                regionCell = [[SwitchTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RegionCellIdentifier];
                
            }
            regionCell.textLabel.text = title;
            if (onOff && row == 0) {
                regionCell.detailTextLabel.text = defaultHeb;
            } else {
                regionCell.detailTextLabel.text = desc;
            }
            regionCell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            regionCell.detailTextLabel.numberOfLines = 2;
            regionCell.onOffSwitch.on = onOff;
            regionCell.onOffSwitch.tag = 100 + row;
            [regionCell.onOffSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            cell = regionCell;
        } else {
            static NSString *kDisplayCell_ID = @"DisplayCellID";
            cell = [self.tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kDisplayCell_ID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else
            {
                // the cell is being recycled, remove old embedded controls
                UIView *viewToRemove = nil;
                viewToRemove = [cell.contentView viewWithTag:110];
                if (viewToRemove)
                    [viewToRemove removeFromSuperview];
            }
            
            cell.textLabel.text = title;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            double radius = [defaults doubleForKey:@"GEOFENCING_RADIUS"];
            
            if ((radius - 0) < 10.0) {
                radius = 1000;
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f mile", radius*0.00062] ;
//            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            UIControl *control = self.sliderCtl;
            control.enabled = onOff;
            [cell.contentView addSubview:control];
            
        }
    } else {
        UITableViewCell *aboutCell = [tableView dequeueReusableCellWithIdentifier:AboutCellIdentifier];
        if (aboutCell == nil) {
            aboutCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AboutCellIdentifier];
            aboutCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        aboutCell.textLabel.text = title;
        cell = aboutCell;
    }
    
    cell.textLabel.font = kFont;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == ABOUT_SECTION) {
        if (indexPath.row == 0) {
            AboutViewController *about = [[AboutViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:about animated:YES];
        } else {
            [self displayComposerSheet];
        }
    }
}

#pragma mark - OnOffSwitch method
- (void)onSwitch:(id)sender
{
    UISwitch *settingSwitch = (UISwitch *)sender;
    NSUInteger tagNumber = settingSwitch.tag;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (tagNumber == 100) {
        if (settingSwitch.on) {
            
            // we have to wait until the user has set a specific heb
            // in this case, delegete could be a better approach
            [defaults setBool:YES forKey:@"USE_DEFAULT_LOCATION"];
            [defaults synchronize];
        } else {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.detailTextLabel.text = @"";
            [defaults setBool:NO forKey:@"USE_DEFAULT_LOCATION"];
            [defaults synchronize];
            
        }
    } else if (tagNumber == 101) {
        if  (settingSwitch.on){
            [defaults setBool:YES forKey:@"USE_GEOFENCING"];
            self.sliderCtl.enabled = YES;
        }
        else
        {
            [defaults setBool:NO forKey:@"USER_GEOFENCING"];
            self.sliderCtl.enabled = NO;
        }
        
    }
    
    
}


#pragma mark - mail delegate
-(void)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Reminder+ Feedback"];
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@"2010.longhorn@gmail.com"];
    
    [picker setToRecipients:toRecipients];
    // Fill out the email body text
    NSString *emailBody = @"Thank you for your feedback!";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:nil];
    
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
//    message.hidden = NO;
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
//            message.text = @"Result: canceled";
            break;
        case MFMailComposeResultSaved:
//            message.text = @"Result: saved";
            break;
        case MFMailComposeResultSent:
//            message.text = @"Result: sent";
            break;
        case MFMailComposeResultFailed:
//            message.text = @"Result: failed";
            break;
        default:
//            message.text = @"Result: not sent";
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISlider
- (void)sliderAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    [slider setValue:((int)((slider.value + 25) / 50) * 50) animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f mile",slider.value * 0.00062];
    
}

#define kSliderHeight			7.0
- (UISlider *)sliderCtl
{
    if (sliderCtl == nil)
    {
        CGRect frame = CGRectMake(174.0, 12.0, 120.0, kSliderHeight);
        sliderCtl = [[UISlider alloc] initWithFrame:frame];
        [sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        sliderCtl.backgroundColor = [UIColor clearColor];
        
        sliderCtl.minimumValue = 50.0;
        sliderCtl.maximumValue = 2000.0;
        sliderCtl.continuous = YES;
    
        sliderCtl.value = 1000.0;
        
		// Add an accessibility label that describes the slider.
		[sliderCtl setAccessibilityLabel:NSLocalizedString(@"StandardSlider", @"")];
		
		sliderCtl.tag = 110;	// tag this view for later so we can remove it from recycled table cells
    }
    return sliderCtl;
}

@end

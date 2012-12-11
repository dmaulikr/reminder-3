//
//  SettingsViewController.m
//  Reminder
//
//  Created by LIANGJUN JIANG on 11/17/12.
//
//

#import "SettingsViewController.h"
#import "AboutViewController.h"
#import  <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CustomAlertView.h"
#import "ScrollingViewController.h"
#import "HomeViewController.h"

#define kFont [UIFont boldSystemFontOfSize:14.0];

@interface SettingsViewController ()<MFMailComposeViewControllerDelegate>
@property (nonatomic, retain, readonly) UISlider *sliderCtl;
@end

@implementation SettingsViewController

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

}

- (void)viewDidDisappear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"REMINDER_INADVANCE"]) {
        [defaults setInteger:self.sliderCtl.value forKey:@"REMINDER_INADVANCE"];
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
    return (indexPath.section == 0)? 60.0 :44.0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    return [[self.contentList allKeys] objectAtIndex:section];
    NSString *aboutTitle = [NSString stringWithFormat:@"Version: %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    return (section == 0)?@"Setting":aboutTitle;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
//    return [[self.contentList allKeys] count];
    return 2;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
//        case 1:
//            return 1;
//            break;
        case 1:
            return 3;
            break;
            
        default:
            break;
    }
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    static NSString *AboutCellIdentifier = @"AboutCell";
    static NSString *kDisplayCell_ID = @"DisplayCellID";
    UITableViewCell *cell = nil;
    
    if (section == 0) {
        UITableViewCell* temp = [self.tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
        if (temp == nil)
        {
            temp = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kDisplayCell_ID];
            temp.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            // the cell is being recycled, remove old embedded controls
            UIView *viewToRemove = nil;
            viewToRemove = [cell.contentView viewWithTag:110];
            if (viewToRemove)
                [viewToRemove removeFromSuperview];
        }
        
        temp.textLabel.text = @"In Advance notifcation";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int16_t inAdvanceMinute = [defaults integerForKey:@"REMINDER_INADVANCE"];
      
        if (inAdvanceMinute<=0) {
            inAdvanceMinute = 5;
        }
        temp.detailTextLabel.text = [NSString stringWithFormat:@"%d minutes", inAdvanceMinute];
        self.sliderCtl.value = inAdvanceMinute;
        [temp.contentView addSubview:self.sliderCtl];
        cell = temp;
    } else if (section == 1 || section ==2)
    {
        UITableViewCell *aboutCell = [tableView dequeueReusableCellWithIdentifier:AboutCellIdentifier];
        if (aboutCell == nil) {
            aboutCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AboutCellIdentifier];
            aboutCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        NSString *title = @"";
//        if (section == 1) {
//            title = @"Instruction";
//            
//        } else
            if (section == 1) {
            switch (row) {
                case 0:
                    title = @"About Us";
                    break;
                case 1:
                    title = @"Contact Us";
                    break;
                case 2:
                    title = @"Privacy Policy";
                    break;
                default:
                    break;
            }
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
//    if (indexPath.section == 1) {
//        HomeViewController *instructionViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
//        [self.navigationController pushViewController:instructionViewController animated:YES];
//        
//    } else
    
        if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            AboutViewController *about = [[AboutViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:about animated:YES];
        } else if (indexPath.row ==1) {
            [self displayComposerSheet];
        } else {
            [[[CustomAlertView alloc] initWithTitle:@"Privacy Policy"
                                                message:@"This app doesn't collect any user information."
                                               delegate:self
                                      cancelButtonTitle:@"Okay"
                                      otherButtonTitles:nil] show];
            
            
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
    [slider setValue:((int)((slider.value + 2.5) / 5) * 5) animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f minutues",slider.value];
    
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
        
        sliderCtl.minimumValue = 5.0;
        sliderCtl.maximumValue = 60.0;
        sliderCtl.continuous = YES;
    
		// Add an accessibility label that describes the slider.
		[sliderCtl setAccessibilityLabel:NSLocalizedString(@"StandardSlider", @"")];
		
		sliderCtl.tag = 110;	// tag this view for later so we can remove it from recycled table cells
    }
    return sliderCtl;
}

@end

//
//  VaFeedbackViewController.m
//  VaTouch
//
//  Created by Liangjun Jiang on 11/15/12.
//  Copyright (c) 2012 LJ Apps All rights reserved.
//

#import "VaFeedbackViewController.h"

static NSString *kTitleKey = @"sectionTitleKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";

#define kTextFieldWidth	195.0
#define kTextHeight		34.0

@interface CustomTableViewCell : UITableViewCell
@property (nonatomic, strong) UITextField *textField;
- (void)setContentForTableCellLabel:(NSString *)title andTextField:(NSString *)placeHolder andKeyBoardType:(NSNumber *)keyboardType;
@end

@implementation CustomTableViewCell
@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.backgroundColor = [UIColor clearColor];
        CGRect frame = CGRectMake(100, 5.0, kTextFieldWidth, kTextHeight);
        textField = [[UITextField alloc] initWithFrame:frame];
        textField.borderStyle = UITextBorderStyleNone;
        textField.textColor = [UIColor blackColor];
        textField.font = [UIFont systemFontOfSize:13.0];
        textField.textAlignment = NSTextAlignmentLeft;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.enabled = YES;
        textField.backgroundColor = [UIColor clearColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
        
        self.accessoryView = textField;
        
    }
    
    return self;
}

- (void)setContentForTableCellLabel:(NSString *)title andTextField:(NSString *)textFieldText andKeyBoardType:(NSNumber *)keyboardType
{
    
    self.textLabel.text = title;
    self.textField.text = textFieldText;
    self.textField.keyboardType = [keyboardType intValue];
    
}

@end;


@interface VaFeedbackViewController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>
{
    NSUInteger selected;  // this is for keeping track of the selected cell. since tableviewcell has a delegate method for it
                          // this might not be necessary.
}

@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *feedbackCategoryArray;
//@property (nonatomic, strong) FeedbackDc *feedback;

// definitely there is no point to create the following two. UItableview datasource delegate will give better performance.
// I have to create those in NIB by request.So I made those.
@property (nonatomic, weak) IBOutlet UIView *footerContainerView;
//@property (nonatomic, weak) IBOutlet VaUIButton *submitButton;


- (IBAction)onSubmit:(id)sender;
@end

@implementation VaFeedbackViewController
@synthesize footerContainerView;
@synthesize dataSourceArray, dataArray, feedbackCategoryArray;//, feedback;

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

//    [VaThemeManager customizeTableView:self.tableView];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    self.title = NSLocalizedString(@"Feedback", @"Feedback");
    
//    feedback = [[FeedbackDc alloc] init];
    
    // Let's make some information about the user's device, iOS, and app version
    // watchout: if the build info in project is not changed to meaning build for every relase build, the second will be meaningless (will be always 1) as the date of 11/15/2012
    NSString *appVersion = [NSString stringWithFormat:@"%@(%@)" , [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    NSString *userDevice = [NSString stringWithFormat:@"%@(%@), %@(%@)",[UIDevice currentDevice].name, [UIDevice currentDevice].model,[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
    
//    NSString *appInfo = [NSString stringWithFormat:@"Version: %@, Device: %@",appVersion, userDevice];
    
    self.feedbackCategoryArray = @[NSLocalizedString(@"Suggestion",@""),NSLocalizedString(@"Complaint",@""),NSLocalizedString(@"Problem",@""),NSLocalizedString(@"Other",@"")];
  
    NSString *user = @"";
    NSString *email = @"";
    
    // most likely, user name & email won't be changed, let's set them right now.
//    feedback.name = user; 
//    feedback.email = email;
//    feedback.comments = @"";
    
    self.dataSourceArray = @[
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             NSLocalizedString(@"Name",@""), kTitleKey,
                             user, kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeNamePhonePad], kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
                             NSLocalizedString(@"Phone",@""), kTitleKey,
                             @"", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypePhonePad], kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
                             NSLocalizedString(@"Email",@""), kTitleKey,
                             email, kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeEmailAddress], kViewKey,
                             nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             NSLocalizedString(@"Category",@""), kTitleKey,
                             @"", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeDefault], kViewKey,
							 nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             NSLocalizedString(@"Comments",@""), kTitleKey,
                             @"", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeDefault], kViewKey,
							 nil]];
    
    self.dataArray = [NSMutableArray arrayWithCapacity:[self.dataSourceArray count]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"We'd like to hear from you! Thank you for your time to complete the form. We welcome all of your comments and suggestions",@"");
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSourceArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return footerContainerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.dataSourceArray count] -1)
        return 100.0;
    else
        return 44.0;
    
}



- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *TextViewCellIdentifier = @"TextViewCell";
    UITableViewCell *tableViewCell = nil;
    
    if (indexPath.row != [self.dataSourceArray count] -1) {
        CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
        cell.textField.delegate = self;
        cell.textField.tag = indexPath.row + 10;
        // Configure the cell...
        NSDictionary *infoDict = self.dataSourceArray[indexPath.row];
        [cell setContentForTableCellLabel:infoDict[kTitleKey] andTextField:infoDict[kSourceKey] andKeyBoardType:infoDict[kViewKey]];
        tableViewCell = cell;
    } else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TextViewCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextViewCellIdentifier];
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
        cell.textLabel.text = self.dataSourceArray[indexPath.row][kTitleKey];
        
        UITextView *commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(100, 5.0, kTextFieldWidth, 80.0)];
        commentTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        // We also don't want to set the returnkey of keyboard "Done" for the TextView
        // because the user might just want to change to new line
        commentTextView.returnKeyType = UIReturnKeyDefault; 
        commentTextView.font = [UIFont systemFontOfSize:14.0f];
        commentTextView.delegate = self;
        commentTextView.backgroundColor = [UIColor clearColor];
        commentTextView.tag = indexPath.row + 10;
        cell.accessoryView = commentTextView;
        
        return cell;
    }
    
    return tableViewCell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we row this to top
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark  - IBAction Method

- (IBAction)onSubmit:(id)sender
{
    self.navigationItem.rightBarButtonItem = nil;
    
    // I don't want to collect those content from UITextField & UITextView Until right now
    // Since it will be another process of iterating the cells, and decide it is textfield or textview
    // Even though the user doesn't fill up with anything, the user email, name and device info will still be sent out
//    if (feedback.comments.length > 0) {
//        // we send the info to server
//        NSLog(@"feedback will be sent out: %@",feedback);
//    } else {
//        CustomAlertView *error = [[CustomAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"") message:NSLocalizedString(@"Comment can't be blank", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", @"") otherButtonTitles:nil, nil];
//        [error show];
//        
//    }
    
    
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSDictionary *contentDictionary = nil;
    NSString *key = nil;
    // just don't want to iterate to rewrite those key titles again
    NSInteger index = textField.tag / 10;
    
    contentDictionary = self.dataSourceArray[index];
    key = contentDictionary[kTitleKey];  // we only care the section title
    [self.dataArray addObject:@{key:textField.text}];
    
    //Crap, I still need to iterate those
//    switch (index) {
//        case 0:
//            feedback.name = textField.text;
//            break;
//        case 1:
//            feedback.phone = textField.text;
//            break;
//        case 2:
//            feedback.email = textField.text;
//            break;
//        case 3:
//            feedback.category = textField.text;
//            break;
//        default:
//            break;
//    }
    
  	[textField resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
     
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // create a "done" item as the right barButtonItem so user can dismiss the keyboard
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem = doneItem;
    selected = textField.tag - 10;
    
    if (textField.tag == 13)  // this is for feedback category
    {
        UIPickerView *categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        categoryPicker.showsSelectionIndicator = YES;	// note this is default to NO
        
        // this view controller is the data source and delegate
        categoryPicker.delegate = self;
        categoryPicker.dataSource = self;
        
        textField.inputView = categoryPicker;
        
        // this animiation was from Apple Sample Code: DateCell
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [categoryPicker sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		categoryPicker.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
        
        [UIView animateWithDuration:0.3 animations:^{
            categoryPicker.frame = pickerRect;
        }];
 
    }
    
}

#pragma mark - UITextView Delegate method
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    selected = textView.tag-10;
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

#pragma mark - private method

- (void)onDone:(id)sender
{
    // we resign the textfield
    // Apple creates a numberpad (also decimal number pad) without "Done" which has a good reason.
    // It's not necessary to have to comply with it. But it's better to do so. The common practice in Apple's app is..
    // make the RightBarButtonItem dismiss the numberkeypad.
    
    
    UITableViewCell *activeCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selected inSection:0]];
    if ([activeCell.accessoryView isKindOfClass:[UITextField class]])
    {
        UITextField *textField = (UITextField*)activeCell.accessoryView;
        if (textField.tag == 11) // for phone
        {
//            feedback.phone = textField.text;
        } else if (textField.tag == 13) // for category
        {
//            feedback.category = textField.text;
        }
        
        [textField resignFirstResponder];
    } else if ([activeCell.accessoryView isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView *)activeCell.accessoryView;
//        feedback.comments = textView.text;
        [textView resignFirstResponder];
    } else  // rest should be just textfield
    {
        [(UITextField *)activeCell.accessoryView resignFirstResponder];
    }
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // since we have only one textfield having a picker, so we hardcode where it is.
    NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    CustomTableViewCell *cell = (CustomTableViewCell *)[self.tableView cellForRowAtIndexPath:pickerIndexPath];
    // we need to update the UI
    cell.textField.text = self.feedbackCategoryArray[row];
}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.feedbackCategoryArray objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 280.0;
 	return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.feedbackCategoryArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

@end

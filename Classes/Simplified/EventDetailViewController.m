//
//  VaFeedbackViewController.m
//  VaTouch
//
//  Created by Liangjun Jiang on 11/15/12.
//  Copyright (c) 2012 LJ Apps All rights reserved.
//

#import "EventDetailViewController.h"
#import "Event.h"

static NSString *kTitleKey = @"sectionTitleKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";

#define kTextFieldWidth	195.0
#define kTextHeight		34.0

//#define kSliderHeight			7.0
//#define kProgressIndicatorSize	40.0
//
//#define kUIProgressBarWidth		160.0
//#define kUIProgressBarHeight	24.0
//
//#define kViewTag				1		// for tagging our embedded controls for removal at cell recycle time


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


@interface EventDetailViewController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>
{
    NSUInteger selected;  // this is for keeping track of the selected cell. since tableviewcell has a delegate method for it
                          // this might not be necessary.
}

@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
//@property (nonatomic, retain, readonly) UIActivityIndicatorView *progressInd;
@property (nonatomic, strong) NSDictionary *howDataDictionary;
@end

@implementation EventDetailViewController

@synthesize dataSourceArray, dataArray;
@synthesize howDataDictionary;
@synthesize event;
@synthesize cancelBlock, saveBlock;
//@synthesize progressInd;

- (void)onDone:(id)sender
{
//    NSArray *visibelCells = [self.tableView visibleCells];
//    [visibelCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        CustomTableViewCell *customCell = (CustomTableViewCell *)obj;
//        switch (customCell.textField.tag) {
//            case 10:
//                event.name = customCell.textField.text;
//                break;
//            case 11:
//                event.when = customCell.textField.text;
//                break;
//            case 12:
//                event.where = customCell.textField.text;
//                break;
//                
//            default:
//                break;
//        }
//    }];
    
    saveBlock(self,event);
}

- (void)onCancel:(id)sender
{
    cancelBlock(self,nil);
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

    
    // Right
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // left
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.clearsSelectionOnViewWillAppear = NO;
 
    self.title = NSLocalizedString(@"Detail", @"Detail");
    
    self.dataSourceArray = @[
                           [NSDictionary dictionaryWithObjectsAndKeys:
                             NSLocalizedString(@"What",@""), kTitleKey,
                             @"", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeDefault], kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
                             NSLocalizedString(@"Where",@""), kTitleKey,
                             @"", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeDefault], kViewKey,
                             nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             NSLocalizedString(@"When",@""), kTitleKey,
                             @"", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeDefault], kViewKey,
							 nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             NSLocalizedString(@"How",@""), kTitleKey,
                             @"", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeDefault], kViewKey,
							 nil]];
    
    self.dataArray = [NSMutableArray arrayWithCapacity:[self.dataSourceArray count]];
    
    // Set up the how, such as entering/leaving, alert frequency
//    NSArray *repeatOptions = @[@"None",@"Every Day",@"Every Week",@"Every 2 Weeks",@"Every Month", @"Every Year"];
    
    NSArray *locationOptions = @[@"Both", @"Arriving", @"Leaving"];
    
    NSArray *priorityOptions = @[@"None", @"Low", @"Med",@"High"];
    
    NSArray *inAdvanceOptions = @[@"5 Mins", @"15 Mins",@"30 Mins",@"1 Hour", @"2 Hour",@"1 Day"];
    
    howDataDictionary = @{@"location":locationOptions, @"inAdvance":inAdvanceOptions, @"priority":priorityOptions};
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4; //[self.dataSourceArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0)
//        return 100.0;
//    else
    return 66.0;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
//    static NSString *TextViewCellIdentifier = @"TextViewCell";
    UITableViewCell *tableViewCell = nil;
    
//    if (indexPath.row != 0) {
        CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
//        cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
        cell.textField.delegate = self;
        cell.textField.tag = indexPath.row + 10;
        // Configure the cell...
//        NSDictionary *infoDict = self.dataSourceArray[indexPath.row];
//        [cell setContentForTableCellLabel:infoDict[kTitleKey] andTextField:infoDict[kSourceKey] andKeyBoardType:infoDict[kViewKey]];
    
        NSString *title = @"";
        NSString *content = @"";
    switch (indexPath.row) {
        case 0:
        {
            title = @"What";
            content = event.name;
            break;
        }
        case 1:
        {
            title = @"Where";
            content = event.where;
            break;
        }
        case 2:
        {
            title = @"When";
            content = event.when;
            break;
        }
        case 3:
        {
            title = @"How";
            content = [NSString stringWithFormat:@"%@, %@, %@", event.priority, event.geoFencingPreference, event.inAdvance];//event.how;
            break;
        }
        default:
            break;
    }
    
    cell.textLabel.text = title;
    cell.textField.text = content;
    
        tableViewCell = cell;
//    }
//    else
//    {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TextViewCellIdentifier];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextViewCellIdentifier];
//        }
//        cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
//        cell.textLabel.text = self.dataSourceArray[indexPath.row][kTitleKey];
//        
//        UITextView *commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(100, 5.0, kTextFieldWidth, 80.0)];
//        commentTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
//        // We also don't want to set the returnkey of keyboard "Done" for the TextView
//        // because the user might just want to change to new line
//        commentTextView.returnKeyType = UIReturnKeyDefault; 
//        commentTextView.font = [UIFont systemFontOfSize:14.0f];
//        commentTextView.delegate = self;
//        commentTextView.backgroundColor = [UIColor clearColor];
////        commentTextView.tag = indexPath.row + 10;
//        cell.accessoryView = commentTextView;
//        
//        return cell;
//    }
    
    return tableViewCell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we row this to top
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case 10:
            event.name = textField.text;
            break;
        case 11:
            event.where = textField.text;
            break;
        case 12:
            event.when = textField.text;
            break;
        case 13:
            event.how = textField.text;
            break;
        default:
            break;
    }
    
    
  	[textField resignFirstResponder];
  	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    selected = textField.tag - 10;
    
    if (textField.tag == 12) //for date
    {
        UIDatePicker *datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
        
        textField.inputView = datePickerView;
        
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [datePickerView sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		datePickerView.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
        
        [UIView animateWithDuration:0.3 animations:^{
            datePickerView.frame = pickerRect;
        }];
    } else if (textField.tag == 13) {
        UIPickerView *categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        categoryPicker.showsSelectionIndicator = YES;	// note this is default to NO
        categoryPicker.tag = 101;
        
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

        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        descLabel.text = @"    Priority | Geo-Fencing | Alert Before";
        textField.inputAccessoryView = descLabel;
    } else {
        textField.keyboardType = UIKeyboardTypeDefault;
        
    }
    
}

#pragma mark - UITextView Delegate method
//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    selected = textView.tag-10;
//}
//
//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    [textView resignFirstResponder];
//}

#pragma mark - private method

//- (void)onDone:(id)sender
//{
//    // we resign the textfield
//    
//    UITableViewCell *activeCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selected inSection:0]];
//    if ([activeCell.accessoryView isKindOfClass:[UITextField class]])
//    {
//        UITextField *textField = (UITextField*)activeCell.accessoryView;
//        if (textField.tag == 11) // for where
//        {
//        } else if (textField.tag == 13) // for how
//        {
//        }
//        
//        [textField resignFirstResponder];
//    }
//    
////    else if ([activeCell.accessoryView isKindOfClass:[UITextView class]])
////    {
////        UITextView *textView = (UITextView *)activeCell.accessoryView;
////        [textView resignFirstResponder];
////    } else  // rest should be just textfield
////    {
////        [(UITextField *)activeCell.accessoryView resignFirstResponder];
////    }
//}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // since we have only one textfield having a picker, so we hardcode where it is.
    NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    CustomTableViewCell *cell = (CustomTableViewCell *)[self.tableView cellForRowAtIndexPath:pickerIndexPath];
    // we need to update the UI
//    cell.textField.text = self.eventInfoArray[row];
    NSString *key = [howDataDictionary allKeys][component];
    NSString *selected = ((NSArray *)howDataDictionary[key])[row];
    
    switch (component) {
        case 0:
            event.priority = selected;
            break;
        case 1:
            event.inAdvance = selected;
            break;
        case 2:
            event.geoFencingPreference = selected;
            break;
        default:
            break;
    }
    
}


#pragma mark UIPickerViewDataSource

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],  NSForegroundColorAttributeName:[UIColor redColor]};
    
    NSString *returnStr = @"";
    if (pickerView.tag == 101) {
        NSString *key = [howDataDictionary allKeys][component];
        returnStr = ((NSArray *)howDataDictionary[key])[row];
    }
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:returnStr attributes:attributes];
    return string;
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnStr = @"";
    if (pickerView.tag == 101) {
        NSString *key = [howDataDictionary allKeys][component];
        return ((NSArray *)howDataDictionary[key])[row];
    }
	return returnStr;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 0.0;
    if  (pickerView.tag == 101){
        switch (component) {
            case 0:
                componentWidth = 80.0;
                break;
            case 1:
                componentWidth = 80.0;
                break;
            case 2:
                componentWidth = 130.0;
                break;
//            case 3:
//                componentWidth = 70.0;
//                break;
            default:
                break;
        }
        
        
    }
    return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSString *key = [howDataDictionary allKeys][component];
    
    return ((NSArray *)howDataDictionary[key]).count;
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return (pickerView.tag == 101)?3:1;
}

#pragma mark - Progress Ind
//- (UIActivityIndicatorView *)progressInd
//{
//    if (progressInd == nil)
//    {
//        CGRect frame = CGRectMake(265.0, 12.0, kProgressIndicatorSize, kProgressIndicatorSize);
//        
//        progressInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        progressInd.frame = frame;
//        [progressInd startAnimating];
//        progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//        [progressInd sizeToFit];
//		
//		progressInd.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
//    }
//    return progressInd;
//}

@end

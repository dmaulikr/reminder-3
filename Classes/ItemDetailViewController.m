//
//  CustomerInfoViewController.m
//  TempProject
//
//  Created by Liangjun Jiang on 10/26/12.
//  Copyright (c) 2012 Liangjun Jiang. All rights reserved.
//

//typedef enum {
//    UIKeyboardTypeDefault,                // Default type for the current input method.
//    UIKeyboardTypeASCIICapable,           // Displays a keyboard which can enter ASCII characters, non-ASCII keyboards remain active
//    UIKeyboardTypeNumbersAndPunctuation,  // Numbers and assorted punctuation.
//    UIKeyboardTypeURL,                    // A type optimized for URL entry (shows . / .com prominently).
//    UIKeyboardTypeNumberPad,              // A number pad (0-9). Suitable for PIN entry.
//    UIKeyboardTypePhonePad,               // A phone pad (1-9, *, 0, #, with letters under the numbers).
//    UIKeyboardTypeNamePhonePad,           // A type optimized for entering a person's name or phone number.
//    UIKeyboardTypeEmailAddress,           // A type optimized for multiple email address entry (shows space @ . prominently).
//    
//    UIKeyboardTypeAlphabet = UIKeyboardTypeASCIICapable, // Deprecated
//    
//} UIKeyboardType;

#import "ItemDetailViewController.h"
#import "CustomTextField.h"
#import "TextFieldTableCell.h"
#import <QuartzCore/QuartzCore.h>
//#import "SSTheme.h"

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";

@interface ItemDetailViewController ()<UITextFieldDelegate> //, HPGrowingTextViewDelegate>
@property (nonatomic, retain) NSArray *dataSourceArray;
@property (nonatomic, assign) NSUInteger selectedCellIndex;
@property (nonatomic, assign) BOOL isEditing;

@end

@implementation ItemDetailViewController
@synthesize selectedCellIndex, isEditing;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
//    [SSThemeManager customizeTableView:self.tableView];
    // let's make something like
    isEditing = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //    NSString *question = @"What is the weather in San Francisco?";
    NSString *question = @"Remind to use coupon when entering Walmart at 5 pm, tomorrow.";
    
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    tagger.string = question;
    
    // I need a better algorithm for this
    __block NSMutableArray *tagArrays = [NSMutableArray array];
    [tagger enumerateTagsInRange:NSMakeRange(0, [question length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        NSString *token = [question substringWithRange:tokenRange];
        NSDictionary *dict = @{@"tag":tag, @"token":token};
        [tagArrays addObject:dict];
    }];
    
    NSLog(@"tag array: %@",tagArrays);
    // I know this is stupid
    __block NSUInteger conjunctionIndex = 0;
    __block NSUInteger particleIndex = 0;
    __block NSUInteger prepositionIndex = 0;
    [tagArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary *)obj;
        if ([dict[@"tag"] isEqualToString:@"Particle"]) {
            particleIndex = idx;
        }
        if ([dict[@"tag"] isEqualToString:@"Conjunction"]) {
            conjunctionIndex = idx;
        }
        if ([dict[@"tag"] isEqualToString:@"Preposition"]) {
            prepositionIndex = idx;
        }
        
    }];
//    NSLog(@"par:%d, con:%d,  prep: %d",particleIndex, conjunctionIndex, prepositionIndex);
//
//
    __block NSMutableString *whatString = [NSMutableString string];

    if  (conjunctionIndex - (particleIndex+1) > 0)
    {
        NSRange whatRange = NSMakeRange(particleIndex+1, conjunctionIndex-(particleIndex+ 1));
        NSArray *whatArray = [tagArrays objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:whatRange]];
        
        if (whatArray.count>0) {
            [whatArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [whatString appendString:[NSString stringWithFormat:@"%@ ",((NSDictionary *)obj)[@"token"]]];
            }];
        }
        NSLog(@"what :%@",whatString);
    }
    
    __block NSMutableString *whereString = [NSMutableString string];
    if (prepositionIndex-(conjunctionIndex+1) > 0) {
        NSRange whereRange = NSMakeRange(conjunctionIndex+1, prepositionIndex-(conjunctionIndex+ 1));
        NSArray *whereArray = [tagArrays objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:whereRange]];
        if (whereArray.count>0) {
            [whereArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [whereString appendString:[NSString stringWithFormat:@"%@ ",((NSDictionary *)obj)[@"token"]]];
            }];
        }
        NSLog(@"where :%@",whereString);
    }
    
    __block NSMutableString *whenString = [NSMutableString string];
    if (tagArrays.count-(prepositionIndex+1) > 0) {
        NSRange whenRange = NSMakeRange(prepositionIndex+1, tagArrays.count-(prepositionIndex+ 1));
        NSArray *whenArray = [tagArrays objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:whenRange]];
        if (whenArray.count>0) {
            [whenArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [whenString appendString:[NSString stringWithFormat:@"%@ ",((NSDictionary *)obj)[@"token"]]];
            }];
        }
        NSLog(@"when :%@",whenString);
    }
    
//    __block NSMutableString *howString = [NSMutableString string];

    
//    NSLog(@"what: %@, when: %@, where :%@",what, when, where);
    self.dataSourceArray = [NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Summary", kSectionTitleKey,
                             question, kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeDefault], kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
                             @"When", kSectionTitleKey,
                             whenString, kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeNamePhonePad], kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
                             @"Where", kSectionTitleKey,
                             whereString, kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypePhonePad], kViewKey,
							 nil],
						    
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"What", kSectionTitleKey,
                             whatString, kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeDefault], kViewKey,
							 nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"How", kSectionTitleKey,
                             @"", kSourceKey,
                             [NSNumber numberWithInt:UIKeyboardTypeDefault], kViewKey,
                             nil],
                         	nil];
	
	self.title = NSLocalizedString(@"Event Detail", @"Event Detail");
	
	// we aren't editing any fields yet, it will be in edit when the user touches an edit field
	self.editing = NO;
    
    

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    selectedCellIndex = 0;
    
    isEditing = editing;
    [self.tableView reloadData];
    
    // we now need to save those data
    if (!editing) {
        isEditing = editing;
        [self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onCheckButton:(id)sender
{
    
    NSLog(@"we save the user info");
    
}

#pragma mark - Table view data source

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 60.0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44)];
//    UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [checkButton addTarget:self action:@selector(onCheckButton:) forControlEvents:UIControlEventTouchUpInside];
//    [checkButton setTitle:@"DELETE" forState:UIControlStateNormal];
////    [checkButton setBackgroundImage:[UIImage imageNamed:@"checkmark.png"] forState:UIControlStateNormal];
//    checkButton.frame = CGRectMake(60.0, 5.0, 200, 30);
//    
////    UILabel *buttonInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 5.0, 250.0, 30)];
////    buttonInfoLabel.backgroundColor = [UIColor clearColor];
////    buttonInfoLabel.text = @"Delete";
////    [footerView addSubview:buttonInfoLabel];
//    [footerView addSubview:checkButton];
//    footerView.backgroundColor = [UIColor clearColor];
//    return footerView;
//    
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.dataSourceArray[section][kSectionTitleKey];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataSourceArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return [self.dataSourceArray count];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    static NSString *kCellTextField_ID = @"CellTextField_ID";
    
    TextFieldTableCell *cell = (TextFieldTableCell*) [tableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
    
    if (cell == nil)
    {
        cell = [[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:kCellTextField_ID] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textField.delegate = self;
    cell.textField.tag = 100 + row;
    NSString *descTitle = self.dataSourceArray[section][kSourceKey];
    NSNumber *keyboardType = self.dataSourceArray[section][kViewKey];
//    [cell setContentForTableCellLabel:title andTextField:placeholder andKeyBoardType:keyboardType andEnabled:isEditing];
//    cell.textLabel.text = descTitle;
    cell.textField.text = descTitle;
    cell.detailTextLabel.text = (section == 0)? @"Life": @"";
    cell.textField.keyboardType =[keyboardType intValue];
    cell.textField.enabled = isEditing;
    if (isEditing) {
        cell.textField.layer.cornerRadius = 4.0f;
        cell.textField.layer.masksToBounds = YES;
        cell.textField.layer.borderColor = [[UIColor redColor]CGColor];
        cell.textField.layer.borderWidth = 1.0f;
    }
    return cell;
}

#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   
    // we row this to top
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, 40)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.tintColor = [UIColor darkGrayColor];
    
    UIBarButtonItem *prevItem = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleDone target:self action:@selector(onPrev:)];
    
    UIBarButtonItem *spaceItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    spaceItem1.width = 10.0;
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(onNext:)];
    
    UIBarButtonItem *spaceItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    spaceItem2.width = 130.0;
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    
    NSArray *itemsArray =@[prevItem, spaceItem1, nextItem, spaceItem2, doneItem];
    keyboardToolbar.items = itemsArray;
    
    textField.inputAccessoryView = keyboardToolbar;

    // TODO: CAN I DO BETTER THAN THIS?
    selectedCellIndex = textField.tag;
    return YES;
}

#pragma mark - UITextField Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}


#pragma mark - IBAction Methods

- (void)onPrev:(id)sender
{
    NSArray *visiableCells = [self.tableView visibleCells];
    [visiableCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TextFieldTableCell *cell = (TextFieldTableCell *)obj;
        if (cell.textField.tag == selectedCellIndex) {
            [cell.textField resignFirstResponder];
        } else if (cell.textField.tag == selectedCellIndex - 1){
            [cell.textField becomeFirstResponder];
            *stop = YES;
        }
        
    }];
}

- (void)onNext:(id)sender
{
    NSArray *visiableCells = [self.tableView visibleCells];
    [visiableCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TextFieldTableCell *cell = (TextFieldTableCell *)obj;
        if (cell.textField.tag == selectedCellIndex) {
            [cell.textField resignFirstResponder];
        } else if (cell.textField.tag == selectedCellIndex + 1){
            [cell.textField becomeFirstResponder];
            *stop = YES;
        }
     
    }];
}

- (void)onDone:(id)sender
{
    NSArray *visiableCells = [self.tableView visibleCells];
    [visiableCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TextFieldTableCell *cell = (TextFieldTableCell *)obj;
        if (cell.textField.tag == selectedCellIndex) {
            [cell.textField resignFirstResponder];
        }
        
    }];
    
}

@end


/*
     File: QuoteCell.h
 Abstract: Table view cell to display information about a news item.
 The cell is configured in QuoteCell.xib.
 
  Version: 2.0
 
 
 
 */

@class HighlightingTextView;
@class Quotation;


@interface QuoteCell : UITableViewCell 

@property (nonatomic, weak) IBOutlet UILabel *characterLabel;
@property (nonatomic, weak) IBOutlet UILabel *actAndSceneLabel;
@property (nonatomic, weak) IBOutlet HighlightingTextView *quotationTextView;

@property (nonatomic, strong) Quotation *quotation;

@end

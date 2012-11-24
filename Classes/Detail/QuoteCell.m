
/*
     File: QuoteCell.m
 Abstract: Table view cell to display information about a news item.
 The cell is configured in QuoteCell.xib.
 
  Version: 2.0
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "QuoteCell.h"
#import "Quotation.h"
#import "HighlightingTextView.h"

@implementation QuoteCell

@synthesize characterLabel, quotationTextView, actAndSceneLabel, quotation;


- (void)setQuotation:(Quotation *)newQuotation {
 
    if (quotation != newQuotation) {
        quotation = newQuotation;
        
        characterLabel.text = quotation.character;
        actAndSceneLabel.text = [NSString stringWithFormat:@"Act %d, Scene %d", quotation.act, quotation.scene];
        quotationTextView.text = quotation.quotation;
    }
}



@end


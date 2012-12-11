//
//  ScrollingViewController.h
//  Scrolling
//
//  Created by David Janes on 09-09-25.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollingViewController : UIViewController
<UIScrollViewDelegate>
{
	IBOutlet UIScrollView* scrollView;
	IBOutlet UIPageControl* pageControl;
	
    BOOL pageControlIsChangingPage;
}
@property (nonatomic, retain) UIView *scrollView;
@property (nonatomic, retain) UIPageControl* pageControl;

/* for pageControl */
- (IBAction)changePage:(id)sender;

/* internal */
- (void)setupPage;

@end


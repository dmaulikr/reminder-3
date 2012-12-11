//
//  ScrollingViewController.m
//  Scrolling
//
//  Created by David Janes on 09-09-25.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ScrollingViewController.h"

@implementation ScrollingViewController
@synthesize scrollView;
@synthesize pageControl;

#pragma mark -
#pragma mark UIView boilerplate
- (void)viewDidLoad 
{
    self.title = NSLocalizedString(@"Guide", @"Guide");
	[self setupPage];
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark The Guts
- (void)setupPage
{
	scrollView.delegate = self;

	[self.scrollView setBackgroundColor:[UIColor blackColor]];
	[scrollView setCanCancelContentTouches:NO];
	
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView.clipsToBounds = YES;
	scrollView.scrollEnabled = YES;
	scrollView.pagingEnabled = YES;
	
	NSUInteger nimages = 0;
	CGFloat cx = 0;
	for (; ; nimages++) {
		NSString *imageName = [NSString stringWithFormat:@"instruction%d.png", (nimages + 1)];
		UIImage *image = [UIImage imageNamed:imageName];
		if (image == nil) {
			break;
		}
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		CGRect rect = imageView.frame;
		rect.size.height = image.size.height;
		rect.size.width = image.size.width;
		rect.origin.x = ((scrollView.frame.size.width - image.size.width) / 2) + cx;
		rect.origin.y = ((scrollView.frame.size.height - image.size.height) / 2);

		imageView.frame = rect;

		[scrollView addSubview:imageView];
	
		cx += scrollView.frame.size.width;
	}
	
	self.pageControl.numberOfPages = nimages;
	[scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage) {
        return;
    }

	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
    pageControlIsChangingPage = NO;
}

#pragma mark -
#pragma mark PageControl stuff
- (IBAction)changePage:(id)sender 
{
	/*
	 *	Change the scroll view
	 */
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
	
    [scrollView scrollRectToVisible:frame animated:YES];

	/*
	 *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 */
    pageControlIsChangingPage = YES;
}

@end

#import "PageBookmarkCellController.h"

@implementation PageBookmarkCellController

@synthesize cell;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[cell release];
	[super dealloc];
}

@end

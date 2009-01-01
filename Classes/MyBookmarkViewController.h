#import <UIKit/UIKit.h>

@interface MyBookmarkViewController : UITableViewController {
	UITableView *myBookmarkView;
	NSMutableArray *myBookmarks;
	NSIndexPath *selectedRow;
	NSInteger offset;
}

@property (nonatomic, retain) UITableView *myBookmarkView;
@property (retain) NSMutableArray *myBookmarks;
@property (nonatomic, retain) NSIndexPath *selectedRow;

- (void)addMyBookmark:(id)entry;

@end

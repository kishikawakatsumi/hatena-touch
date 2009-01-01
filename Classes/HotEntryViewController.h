#import <UIKit/UIKit.h>

@interface HotEntryViewController : UITableViewController {
	UITableView *hotEntryView;
	NSMutableArray *hotEntries;
	NSMutableArray *featuredEntries;
	NSIndexPath *selectedRow;
}

@property (nonatomic, retain) UITableView *hotEntryView;
@property (retain) NSMutableArray *hotEntries;
@property (retain) NSMutableArray *featuredEntries;
@property (nonatomic, retain) NSIndexPath *selectedRow;

- (void)addHotEntry:(id)entry;
- (void)addFeaturedEntry:(id)entry;

@end

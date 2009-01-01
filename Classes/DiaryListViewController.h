#import <UIKit/UIKit.h>


@interface DiaryListViewController : UITableViewController <UIActionSheetDelegate> {
	UITableView *diaryListView;
	NSMutableArray *diaryList;
	NSInteger page;
	NSDateFormatter *dateFormatter1;
	NSDateFormatter *dateFormatter2;
	
	BOOL draft;
	BOOL forceReload;
}

@property (nonatomic, retain) UITableView *diaryListView;
@property (retain) NSMutableArray *diaryList;
@property (nonatomic, getter=isDraft) BOOL draft;
@property (nonatomic) BOOL forceReload;

- (void)addDiaryList:(id)entry;

@end

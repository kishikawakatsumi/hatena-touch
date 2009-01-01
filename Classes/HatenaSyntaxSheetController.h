#import <UIKit/UIKit.h>


@interface HatenaSyntaxSheetController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *syntaxSheetView;
	IBOutlet UIBarButtonItem *hideButton;
	NSArray *hatenaSyntaxNameList1;
	NSArray *hatenaSyntaxNameList2;
	NSArray *hatenaSyntaxNameList3;
	NSArray *hatenaSyntaxList1;
	NSArray *hatenaSyntaxList2;
	NSArray *hatenaSyntaxList3;
}

@property (nonatomic, retain) UITableView *syntaxSheetView;
@property (nonatomic, retain) UIBarButtonItem *hideButton;
@property (nonatomic, retain) NSArray *hatenaSyntaxNameList1;
@property (nonatomic, retain) NSArray *hatenaSyntaxNameList2;
@property (nonatomic, retain) NSArray *hatenaSyntaxNameList3;
@property (nonatomic, retain) NSArray *hatenaSyntaxList1;
@property (nonatomic, retain) NSArray *hatenaSyntaxList2;
@property (nonatomic, retain) NSArray *hatenaSyntaxList3;

- (IBAction)hideSyntaxSheet:(id)sender;

@end

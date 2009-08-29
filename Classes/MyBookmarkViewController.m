#import "MyBookmarkViewController.h"
#import "HatenaXMLParser.h"
#import "MyBookmarkCell.h"
#import "HatenaTouchAppDelegate.h"
#import "WebViewController.h"
#import "HatenaAtomPub.h"
#import "MyBookmarkNextCell.h"
#import "Debug.h"

#define FEED_OFFSET 20

@implementation MyBookmarkViewController

@synthesize myBookmarkView;
@synthesize myBookmarks;
@synthesize selectedRow;

- (void)dealloc {
	[selectedRow release];
	[myBookmarks release];
	[myBookmarkView setDelegate:nil];
	[myBookmarkView release];
	[super dealloc];
}

- (void)loadEntriesWithData:(NSData *)data entryTag:(NSString *)entryTag
					 target:(id)object callBack:(SEL)method {
	HatenaXMLParser *parser = [HatenaXMLParser alloc];
	[parser parseXMLOfData:data entryTag:entryTag target:object callBack:method parseError:nil];
	[parser release];
}

- (void)_loadMyBookmarks {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
	NSData *data = [atomPub requestMyBookmarkFeed:offset];
	[atomPub release];
	
	[self loadEntriesWithData:data entryTag:@"entry" target:self callBack:@selector(addMyBookmark:)];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[pool release];
}

- (void)loadMyBookmarks {
	[NSThread detachNewThreadSelector:@selector(_loadMyBookmarks) toTarget:self withObject:nil];
}

- (void)addMyBookmark:(id)entry {
	if (!myBookmarks) {
		myBookmarks = [[NSMutableArray alloc] initWithCapacity:20];
	}
	[myBookmarks addObject:entry];
	[myBookmarkView reloadData];
}

- (void)refleshIfNeeded {
	if (!myBookmarks) {
		[self loadMyBookmarks];
		[myBookmarkView reloadData];
	}
}

- (void)loadNext {
	offset += FEED_OFFSET;
	[self loadMyBookmarks];
}

- (BOOL)deleteEntry:(NSDictionary *)entry {
	BOOL success = NO;
	
	HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
	success = [atomPub requestDeleteMyBookmark:[entry objectForKey:@"service.edit"]];
	
	[atomPub release];
	
	return success;
}

#pragma mark <UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger count = [myBookmarks count];
	if (count == 0) {
		return 0;
	} else {
		return count + 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	if (indexPath.row == [myBookmarks count]) {
		MyBookmarkNextCell *cell = (MyBookmarkNextCell *)[tableView dequeueReusableCellWithIdentifier:@"MyBookmarkNextCell"];
		if (cell == nil) {
			cell = [[[MyBookmarkNextCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 70.0f) reuseIdentifier:@"MyBookmarkNextCell"] autorelease];
		}

		return cell;
	} else {
		MyBookmarkCell *cell = (MyBookmarkCell *)[tableView dequeueReusableCellWithIdentifier:@"MyBookmarkCell"];
		if (cell == nil) {
			cell = [[[MyBookmarkCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 70.0f) reuseIdentifier:@"MyBookmarkCell"] autorelease];
		}
		
		NSDictionary *entry = [myBookmarks objectAtIndex:indexPath.row];
		[cell setTitleText:[entry objectForKey:@"title"]];
		[cell setLinkText:[entry objectForKey:@"related"]];
		[cell setNumberText:[NSString stringWithFormat:@"%d", indexPath.row +1]];

		return cell;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	HatenaTouchAppDelegate *hatenaTouchApp = [HatenaTouchAppDelegate sharedHatenaTouchApp];
	return [NSString stringWithFormat:NSLocalizedString(@"BookmarkOf", nil), [hatenaTouchApp.userSettings userName]];
}

#pragma mark <UITableViewDelegate> Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [myBookmarks count]) {
		[self loadNext];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else {
		selectedRow = indexPath;
		WebViewController *controller = [[HatenaTouchAppDelegate sharedHatenaTouchApp] sharedWebViewController];
		NSDictionary *entry = [myBookmarks objectAtIndex:indexPath.row];
		
		controller.title = [entry objectForKey:@"title"];
		controller.pageURL = [entry objectForKey:@"related"];
		[[self navigationController] pushViewController:controller animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSDictionary *entry = [myBookmarks objectAtIndex:indexPath.row];
		if ([self deleteEntry:entry]) {
			[myBookmarks removeObjectAtIndex:indexPath.row];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		}
	}
}

#pragma mark <UIViewController> Methods

- (void)loadView {
	[myBookmarkView release];
	myBookmarkView = nil;
	myBookmarkView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
	[myBookmarkView setRowHeight:70.0f];
	[myBookmarkView setDelegate:self];
	[myBookmarkView setDataSource:self];
	[self setView:myBookmarkView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = NSLocalizedString(@"MyBookmark", nil);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self refleshIfNeeded];
}

- (void)didReceiveMemoryWarning {
	LOG_CURRENT_METHOD;
	[super didReceiveMemoryWarning];
}

@end

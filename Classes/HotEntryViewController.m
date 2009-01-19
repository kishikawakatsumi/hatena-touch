#import "HotEntryViewController.h"
#import "XMLParser.h"
#import "EntryCell.h"
#import "WebViewController.h"
#import "HatenaTouchAppDelegate.h"
#import "NSString+XMLExtensions.h"
#import "Reachability.h"
#import "Debug.h"

@implementation HotEntryViewController

@synthesize hotEntryView;
@synthesize hotEntries;
@synthesize featuredEntries;
@synthesize selectedRow;

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		;
	}
	return self;
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[selectedRow release];
	[featuredEntries release];
	[hotEntries release];
	[hotEntryView setDelegate:nil];
	[hotEntryView release];
	[super dealloc];
}

- (void)loadEntriesWithURL:(NSString *)url entryTag:(NSString *)entryTag 
					target:(id)object callBack:(SEL)method {
	XMLParser *parser = [XMLParser alloc];
	[parser parseXMLAtURL:[NSURL URLWithString:url] entryTag:entryTag target:object callBack:method parseError:nil];
	[parser release];
}

- (void)loadHotEntries {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSString *url = @"http://b.hatena.ne.jp/hotentry.rss";
	[self loadEntriesWithURL:url entryTag:@"item" target:self callBack:@selector(addHotEntry:)];
	[url release];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[pool release];
}

- (void)loadFeaturedEntries {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSString *url = @"http://b.hatena.ne.jp/entrylist?sort=hot&threshold=&mode=rss";
	[self loadEntriesWithURL:url entryTag:@"item" target:self callBack:@selector(addFeaturedEntry:)];
	[url release];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[pool release];
}

- (void)_loadEntries {
	[self loadHotEntries];
	[self loadFeaturedEntries];
}

- (void)loadEntries {
	LOG(@"Hot Entries: refresh data.");
	[NSThread detachNewThreadSelector:@selector(_loadEntries) toTarget:self withObject:nil];
}

- (void)addHotEntry:(id)entry {
	if (!hotEntries) {
		hotEntries = [[NSMutableArray alloc] initWithCapacity:20];
	}
	[hotEntries addObject:entry];
	[hotEntryView reloadData];
}

- (void)addFeaturedEntry:(id)entry {
	if (!featuredEntries) {
		featuredEntries = [[NSMutableArray alloc] initWithCapacity:20];
	}
	[featuredEntries addObject:entry];
	[hotEntryView reloadData];
}

- (void)refleshIfNeeded {
	if ([[Reachability sharedReachability] remoteHostStatus] == NotReachable) {
		NSBundle *bundle = [NSBundle mainBundle];
		NSDictionary *infoDictionary = [bundle localizedInfoDictionary];
		NSString *appName = [[infoDictionary count] ? infoDictionary : [bundle infoDictionary] objectForKey:@"CFBundleDisplayName"];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appName message:NSLocalizedString(@"NotReachable", nil)
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		return;
	}
	
	if (!hotEntries || !featuredEntries) {
		[hotEntries removeAllObjects];
		[featuredEntries removeAllObjects];
		[self loadEntries];
	}
	[hotEntryView reloadData];
}

- (NSDictionary *)whichEntry:(NSIndexPath *)indexPath {
	NSDictionary *entry = nil;
	if (indexPath.section == 0) {
		entry = [hotEntries objectAtIndex:indexPath.row];
	} else {
		entry = [featuredEntries objectAtIndex:indexPath.row];
	}
	return entry;
}

#pragma mark <UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [hotEntries count];
	} else {
		return [featuredEntries count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"EntryCell";
	EntryCell *cell = (EntryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[EntryCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 80.0f) reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSDictionary *entry = [self whichEntry:indexPath];
	
	NSMutableDictionary *listOfRead = [[HatenaTouchAppDelegate sharedHatenaTouchApp] listOfRead];
	if ([listOfRead objectForKey:[entry objectForKey:@"link"]]) {
		[cell.titleLabel setTextColor:[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f]];
	}else {
		[cell.titleLabel setTextColor:[UIColor colorWithRed:0.0f green:0.2f blue:1.0f alpha:1.0f]];
	}

	[cell.titleLabel setText:[NSString decodeXMLCharactersIn:[entry objectForKey:@"title"]]];
	[cell.descriptionLabel setText:[NSString decodeXMLCharactersIn:[entry objectForKey:@"description"]]];
	[cell.numberLabel setText:[NSString stringWithFormat:@"%d", indexPath.row + 1]];
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return NSLocalizedString(@"RecentEntry", nil);
	} else {
		return NSLocalizedString(@"FeaturedEntry", nil);
	}
}

#pragma mark <UITableViewDelegate> Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selectedRow = indexPath;
	
	WebViewController *controller = [[HatenaTouchAppDelegate sharedHatenaTouchApp] sharedWebViewController];
	
	NSDictionary *entry = [self whichEntry:indexPath];
	controller.title = [entry objectForKey:@"title"];
	controller.pageURL = [NSString decodeXMLCharactersIn:[entry objectForKey:@"link"]];
	
	NSMutableDictionary *listOfRead = [[HatenaTouchAppDelegate sharedHatenaTouchApp] listOfRead];
	[listOfRead setObject:[entry objectForKey:@"title"] forKey:[entry objectForKey:@"link"]];
	
	[[self navigationController] pushViewController:controller animated:YES];
}

#pragma mark <UIViewController> Methods

- (void)loadView {
	[hotEntryView release];
	hotEntryView = nil;
	hotEntryView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
	[hotEntryView setRowHeight:80.0f];
	[hotEntryView setDelegate:self];
	[hotEntryView setDataSource:self];
	[self setView:hotEntryView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = NSLocalizedString(@"HotEntry", nil);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self refleshIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	LOG_CURRENT_METHOD;
	[super didReceiveMemoryWarning];
}

@end

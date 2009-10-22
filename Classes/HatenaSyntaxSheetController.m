#import "HatenaSyntaxSheetController.h"
#import "DiaryViewController.h"
#import "Debug.h"

@implementation HatenaSyntaxSheetController

@synthesize syntaxSheetView;
@synthesize hideButton;
@synthesize hatenaSyntaxNameList1;
@synthesize hatenaSyntaxNameList2;
@synthesize hatenaSyntaxNameList3;
@synthesize hatenaSyntaxList1;
@synthesize hatenaSyntaxList2;
@synthesize hatenaSyntaxList3;

- (IBAction)hideSyntaxSheet:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [hatenaSyntaxList1 count];
	} else if (section == 1) {
		return [hatenaSyntaxList2 count];
	} else {
		return [hatenaSyntaxList3 count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return [NSString stringWithUTF8String:"入力支援記法"];
	} else if (section == 1) {
		return [NSString stringWithUTF8String:"自動リンク"];
	} else {
		return [NSString stringWithUTF8String:"はてな内自動リンク"];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"HatenaSyntaxCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
	}

	if (indexPath.section == 0) {
		cell.text = [hatenaSyntaxNameList1 objectAtIndex:indexPath.row];
	} else if (indexPath.section == 1) {
		cell.text = [hatenaSyntaxNameList2 objectAtIndex:indexPath.row];
	} else {
		cell.text = [hatenaSyntaxNameList3 objectAtIndex:indexPath.row];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *viewControllers = [(UINavigationController *)[self parentViewController] viewControllers];
	DiaryViewController *controller = [viewControllers objectAtIndex:[viewControllers count] -1];
    LOG(@"%@", controller);
	NSString *syntax;
	if (indexPath.section == 0) {
		syntax = [hatenaSyntaxList1 objectAtIndex:indexPath.row];
	} else if (indexPath.section == 1) {
		syntax = [hatenaSyntaxList2 objectAtIndex:indexPath.row];
	} else {
		syntax = [hatenaSyntaxList3 objectAtIndex:indexPath.row];
	}
	[controller insertSyntaxText:syntax];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[syntaxSheetView setDelegate:nil];
	[syntaxSheetView release];
	[hideButton release];
	[hatenaSyntaxNameList1 release];
	[hatenaSyntaxNameList2 release];
	[hatenaSyntaxNameList3 release];
	[hatenaSyntaxList1 release];
	[hatenaSyntaxList2 release];
	[hatenaSyntaxList3 release];
	[super dealloc];
}

- (NSString *)$:(const char *)nullTerminatedCString {
	return [NSString stringWithUTF8String:nullTerminatedCString];
}

- (void)viewDidLoad {
	self.hatenaSyntaxList1 = [NSArray
							  arrayWithObjects:[self $:"*～～"],						  
							  [self $:"*t*～～"], 
							  [self $:"*name*～～"],
							  [self $:"*[～～]～～"], 
							  [self $:"**～～"], 
							  [self $:"***～～"],
							  [self $:"-～～"], 
							  [self $:"--～～"],
							  [self $:"+～～"],
							  [self $:"++～～"], 
							  [self $:":～～:～～"], 
							  [self $:"|*～～ |*～～|"],
							  [self $:"|～～|～～|"],
							  [self $:">> ～～ <<"],
							  [self $:">| ～～ |<"], 
							  [self $:">|| ～～ ||<"], 
							  [self $:">|aa| ～～ ||<"], 
							  [self $:"(( ～～ ))"],
							  [self $:"===="],
							  [self $:"====="],
							  [self $:">< ～～ ><"],
							  [self $:"[tex:～～]"], 
							  [self $:"[uke:～～]"], nil];
	self.hatenaSyntaxNameList1 =  [NSArray
								   arrayWithObjects:[self $:"見出し記法"], 
								   [self $:"時刻付き見出し記法"],
								   [self $:"name属性付き見出し記法"],
								   [self $:"カテゴリー記法"],
								   [self $:"小見出し記法"],
								   [self $:"小々見出し記法"], 
								   [self $:"リスト記法(-)"],
								   [self $:"リスト記法(--)"], 
								   [self $:"リスト記法(+)"], 
								   [self $:"リスト記法(++)"],
								   [self $:"定義リスト記法"],
								   [self $:"表組み記法(Title)"],
								   [self $:"表組み記法"],
								   [self $:"引用記法"], 
								   [self $:"pre記法"], 
								   [self $:"スーパーpre記法"],
								   [self $:"aa記法"],
								   [self $:"脚注記法"], 
								   [self $:"続きを読む記法"], 
								   [self $:"スーパー続きを読む記法"], 
								   [self $:"pタグ停止記法"],
								   [self $:"tex記法"],
								   [self $:"ウクレレ記法"], nil];
	
	self.hatenaSyntaxList2 = [NSArray arrayWithObjects:
							  [self $:"http://～～"],
							  [self $:"[http://～～:title]"],
							  [self $:"[http://～～:image]"], 
							  [self $:"[http://～～:bookmark]"], 
							  [self $:"[http://～～:barcode]"], 
							  [self $:"[http://～～:sound]"], 
							  [self $:"[http://～～:movie]"],
							  [self $:"mailto:～～"], 
							  [self $:"***～～"], 
							  [self $:"[google:～～]"],
							  [self $:"[google:image:～～]"], 
							  [self $:"[google:news:～～]"],  
							  [self $:"[amazon:～～]"], 
							  [self $:"[wikipedia:～～]"], 
							  [self $:"[] はてな記法 []"], nil];
	self.hatenaSyntaxNameList2 = [NSArray arrayWithObjects:
								  [self $:"http記法"], 
								  [self $:"http記法(title)"],
								  [self $:"http記法(image)"],
								  [self $:"http記法(bookmark)"],
								  [self $:"http記法(barcode)"],
								  [self $:"http記法(sound)"],
								  [self $:"http記法(movie)"],
								  [self $:"mailto記法"],
								  [self $:"niconico記法"], 
								  [self $:"google記法"],
								  [self $:"google記法(image)"],
								  [self $:"google記法(news)"], 
								  [self $:"amazon記法"],
								  [self $:"wikipedia記法"],
								  [self $:"自動リンク停止記法"], nil];

	self.hatenaSyntaxList3 = [NSArray arrayWithObjects:
						 [self $:"id:～～"], 
						 [self $:"id:～～:archive"], 
						 [self $:"id:～～:about"], 
						 [self $:"id:～～:image"], 
						 [self $:"id:～～:detail"], 
						 [self $:"question:～～:title"],
						 [self $:"question:～～:detail"],
						 [self $:"question:～～:image"], 
						 [self $:"[search:～～]"], 
						 [self $:"[search:keyword:～～]"], 
						 [self $:"[search:question:～～]"], 
						 [self $:"[search:asin:～～]"], 
						 [self $:"[search:web:～～]"], 
						 [self $:"a:id:～～"], 
						 [self $:"b:id:～～(:～～)"],
						 [self $:"[b:keyword:～～]"], 
						 [self $:"d:id:～～"], 
						 [self $:"[d:keyword:～～]"],
						 [self $:"f:id:～～:～～:image"],
						 [self $:"f:id:～～(:favorite)"], 
						 [self $:"g:～～"], 
						 [self $:"g:～～:id:～～"], 
						 [self $:"[g:～～:keyword:～～]"], 
						 [self $:"[h:keyword:～～]"], 
						 [self $:"[h:id:～～]"], 
						 [self $:"idea:～～(:title)"], 
						 [self $:"r:id:～～"],
						 [self $:"graph:id:～～"],
						 [self $:"[graph:id:～～:～～(:image)]"], 
						 [self $:"isbn:～～"], 
						 [self $:"asin:～～"], 
						 [self $:"[rakuten:～～]"], 
						 [self $:"jan:～～"], 
						 [self $:"ean:～～"], nil];
	self.hatenaSyntaxNameList3 = [NSArray arrayWithObjects:
								  [self $:"id記法"],
								  [self $:"id記法(archive)"],
								  [self $:"id記法(about)"],
								  [self $:"id記法(image)"],
								  [self $:"id記法(detail)"],
								  [self $:"question記法(title)"],
								  [self $:"question記法(image)"],
								  [self $:"question記法(image)"],
								  [self $:"search記法"],
								  [self $:"search記法(keyword)"],
								  [self $:"search記法(question)"], 
								  [self $:"search記法(asin)"],
								  [self $:"search記法(web)"],
								  [self $:"antenna記法"],
								  [self $:"bookmark記法"],
								  [self $:"bookmark記法(keyword)"],
								  [self $:"diary記法"],
								  [self $:"diary記法(keyword)"],
								  [self $:"fotolife記法"],
								  [self $:"fotolife記法(favorite)"],
								  [self $:"group記法"],
								  [self $:"group記法(id)"],
								  [self $:"group記法(keyword)"],
								  [self $:"haiku記法"],
								  [self $:"haiku記法(id)"],
								  [self $:"idea記法"],
								  [self $:"rss記法"],
								  [self $:"graph記法"],
								  [self $:"graph記法(image)"],
								  [self $:"isbn/asin記法(isbn)"],
								  [self $:"isbn/asin記法(asin)"],
								  [self $:"rakuten記法"],
								  [self $:"jan/ean記法(jan)"],
								  [self $:"jan/ean記法(ean)"], nil];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


@end


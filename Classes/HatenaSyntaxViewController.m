//
//  HatenaSyntaxViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/21.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "HatenaSyntaxViewController.h"
#import "HatenaSyntaxCell.h"
#import "UserSettings.h"

@implementation HatenaSyntaxViewController

- (NSString *)$:(const char *)nullTerminatedCString {
	return [NSString stringWithUTF8String:nullTerminatedCString];
}

- (id)init {
    if (self = [super init]) {
        hatenaSyntaxList1 = [[NSArray alloc] initWithObjects:
                             [self $:"*～～"],						  
                             [self $:"*t*～～"], 
                             [self $:"*name*～～"],
                             [self $:"*[～～]～～"], 
                             [self $:"**～～"], 
                             [self $:"***～～"],
                             [self $:"-～～\n--～～\n--～～"], 
                             [self $:"+～～\n++～～\n++～～"],
                             [self $:":～～:～～"], 
                             [self $:"|*～～ |*～～|"],
                             [self $:"|～～|～～|"],
                             [self $:">>\n～～\n<<"],
                             [self $:">|\n～～\n|<"], 
                             [self $:">||\n～～\n||<"], 
                             [self $:">|aa|\n～～\n||<"], 
                             [self $:"(( ～～ ))"],
                             [self $:"===="],
                             [self $:"====="],
                             [self $:"><\n～～\n><"],
                             [self $:"[tex:～～]"], 
                             [self $:"[uke:～～]"], nil];
        hatenaSyntaxSampleList1 = [[NSArray alloc] initWithObjects:
                                   [self $:"*見出しです"],						  
                                   [self $:"*t*お昼に書きます"], 
                                   [self $:"*name*～～"],
                                   [self $:"*[日記]～～"], 
                                   [self $:"**小見出しです"], 
                                   [self $:"***小々見出しです"],
                                   [self $:"-好きな食べ物"], 
                                   [self $:"+ごはんの種類"],
                                   [self $:":京都府:京都市"], 
                                   [self $:"|*名前|*色|*個数|"],
                                   [self $:"|りんご|赤|1|"],
                                   [self $:">> ここは引用文です。 <<"],
                                   [self $:">| 整形済みテキストです。 |<"], 
                                   [self $:">|| #!/usr/bin/perl -w ||<"], 
                                   [self $:">|aa| （　´∀｀） ||<"], 
                                   [self $:"しなもん((はてなのマスコット犬))は..."],
                                   [self $:"===="],
                                   [self $:"====="],
                                   [self $:">< ～～ ><"],
                                   [self $:"[tex:e^{i\\pi} = -1]"], 
                                   [self $:"[uke:C Dm G G7 C]"], nil];
        hatenaSyntaxNameList1 = [[NSArray alloc] initWithObjects:
                                 [self $:"見出し記法"], 
                                 [self $:"時刻付き見出し記法"],
                                 [self $:"name属性付き見出し記法"],
                                 [self $:"カテゴリー記法"],
                                 [self $:"小見出し記法"],
                                 [self $:"小々見出し記法"], 
                                 [self $:"リスト記法 (-)"], 
                                 [self $:"リスト記法 (+)"], 
                                 [self $:"定義リスト記法"],
                                 [self $:"表組み記法 (Title)"],
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
        
        hatenaSyntaxList2 = [[NSArray alloc] initWithObjects:
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
                             [self $:"twitter:〜〜:title"], 
                             [self $:"twitter:〜〜:tweet"], 
                             [self $:"twitter:〜〜:detail"], 
                             [self $:"twitter:〜〜:tree"], 
                             [self $:"[twitter:@hatenadiary]"], 
                             [self $:"[] はてな記法 []"], nil];
        hatenaSyntaxSampleList2 = [[NSArray alloc] initWithObjects:
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
                                   [self $:"twitter:ツイートID:〜〜"], 
                                   [self $:"twitter:ツイートID:title"], 
                                   [self $:"twitter:ツイートID:tweet"], 
                                   [self $:"twitter:ツイートID:detail"], 
                                   [self $:"twitter:ツイートID:tree"], 
                                   [self $:"[twitter:@hatenadiary]"], 
                                   [self $:"[] はてな記法 []"], nil];
        hatenaSyntaxNameList2 = [[NSArray alloc] initWithObjects:
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
                                 [self $:"twitter記法"], 
                                 [self $:"twitter記法"], 
                                 [self $:"twitter記法"], 
                                 [self $:"twitter記法"], 
                                 [self $:"twitter記法"], 
                                 [self $:"twitter記法"], 
                                 [self $:"自動リンク停止記法"], nil];
        
        hatenaSyntaxList3 = [[NSArray alloc] initWithObjects:
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
                             [self $:"ean:～～"],
                             [self $:"ugomemo:～～"], nil];
        hatenaSyntaxSampleList3 = [[NSArray alloc] initWithObjects:
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
                                   [self $:"ean:～～"], 
                                   [self $:"ugomemo:～～"], nil];
        hatenaSyntaxNameList3 = [[NSArray alloc] initWithObjects:
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
                                 [self $:"jan/ean記法(ean)"],
                                 [self $:"ugomemo記法"], nil];
    }
    
    return self;
}

- (void)dealloc {
    [hatenaSyntaxNameList1 release];
    [hatenaSyntaxNameList2 release];
    [hatenaSyntaxNameList3 release];
    [hatenaSyntaxList1 release];
    [hatenaSyntaxList2 release];
    [hatenaSyntaxList3 release];
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = contentView;
    [contentView release];
    
    listView = [[UITableView alloc] initWithFrame:contentView.frame];
    listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    listView.delegate = self;
    listView.dataSource = self;
    [contentView addSubview:listView];
    [listView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Hatena Syntax", nil);
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss:)];
    [self.navigationItem setRightBarButtonItem:closeButton animated:NO];
    [closeButton release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [listView flashScrollIndicators];
    [listView deselectRowAtIndexPath:[listView indexPathForSelectedRow] animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    UserSettings *settings = [UserSettings sharedInstance];
    return settings.shouldAutoRotation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark -

- (void)dismiss:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    HatenaSyntaxCell *cell = (HatenaSyntaxCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (HatenaSyntaxCell *)[[[HatenaSyntaxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSUInteger row = indexPath.row;
    
	if (indexPath.section == 0) {
		cell.title = [hatenaSyntaxNameList1 objectAtIndex:row];
		cell.syntax = [hatenaSyntaxList1 objectAtIndex:row];
		cell.sample = [hatenaSyntaxSampleList1 objectAtIndex:row];
	} else if (indexPath.section == 1) {
		cell.title = [hatenaSyntaxNameList2 objectAtIndex:row];
		cell.syntax = [hatenaSyntaxList2 objectAtIndex:row];
		cell.sample = [hatenaSyntaxSampleList2 objectAtIndex:row];
	} else {
		cell.title = [hatenaSyntaxNameList3 objectAtIndex:row];
		cell.syntax = [hatenaSyntaxList3 objectAtIndex:row];
		cell.sample = [hatenaSyntaxSampleList3 objectAtIndex:row];
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return [self $:"入力支援記法"];
	} else if (section == 1) {
		return [self $:"自動リンク"];
	} else {
		return [self $:"はてな内自動リンク"];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    NSString *syntax;
	if (section == 0) {
		syntax = [hatenaSyntaxList1 objectAtIndex:row];
	} else if (section == 1) {
		syntax = [hatenaSyntaxList2 objectAtIndex:row];
	} else {
		syntax = [hatenaSyntaxList3 objectAtIndex:row];
	}
    
    if ([self.delegate respondsToSelector:@selector(hatenaSyntaxViewController:didSelectSyntax:)]) {
        [self.delegate hatenaSyntaxViewController:self didSelectSyntax:syntax];
    }
    
    [self dismiss:nil];
}

@end

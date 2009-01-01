#import "AddBookmarkViewController.h"
#import "HatenaAtomPub.h"
#import "Debug.h"

@implementation AddBookmarkViewController

@synthesize urlLabel;
@synthesize titleLabel;
@synthesize commentField;
@synthesize okButton;
@synthesize cancelButton;
@synthesize urlString;
@synthesize titleString;

- (IBAction)addBookmark:(id)sender {
	if ([commentField isEditing]) {
		[commentField resignFirstResponder];
	}
	
	UIView *waitingView = [HatenaAtomPub waitingView];
	[self.view addSubview:waitingView];

	HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
	BOOL success = [atomPub requestAddNewBookmark:urlString :commentField.text];
	[atomPub release];
	
	if (success) {
		[self dismissModalViewControllerAnimated:YES];
	}
	[[[self.view subviews] objectAtIndex:[[self.view subviews] count] - 1] removeFromSuperview];
}

- (IBAction)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self addBookmark:nil];
	return YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[urlLabel setText:urlString];
	[titleLabel setText:titleString];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[urlLabel release];
	[titleLabel release];
	[commentField setDelegate:nil];
	[commentField release];
	[okButton release];
	[cancelButton release];
	[urlString release];
	[titleString release];
	[super dealloc];
}

@end

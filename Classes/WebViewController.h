#import <UIKit/UIKit.h>
#import "HttpClient.h"

@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIBarButtonItem *backButton;
	IBOutlet UIBarButtonItem *forwardButton;
	
	NSString *pageURL;
	NSString *lastPageURL;
	BOOL loadFinishedSuccesefully;
	
	NSDictionary *pageInfo;
	BOOL isInfoMenuPresent;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIBarButtonItem *backButton;
@property (nonatomic, retain) UIBarButtonItem *forwardButton;
@property (nonatomic, retain) NSString *pageURL;
@property (nonatomic, retain) NSString *lastPageURL;

- (IBAction)actionButtonPushed:(id)sender;

@end

#import <UIKit/UIKit.h>
#import "UserSettings.h"
#import "WebViewController.h"

@interface HatenaTouchAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navigationController;
	UserSettings *userSettings;
	NSString *dataFilePath;
	WebViewController *sharedWebViewController;
	UIImagePickerController *sharedPickerController;
	NSMutableDictionary *listOfRead;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UserSettings *userSettings;
@property (nonatomic, retain) NSString *dataFilePath;
@property (retain, readonly) WebViewController *sharedWebViewController;
@property (retain, readonly) UIImagePickerController *sharedPickerController;
@property (nonatomic, retain) NSMutableDictionary *listOfRead;

+ (HatenaTouchAppDelegate *)sharedHatenaTouchApp;
- (void)saveUserSettings;

@end


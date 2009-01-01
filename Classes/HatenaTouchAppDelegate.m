#import "HatenaTouchAppDelegate.h"
#import "RootViewController.h"
#import "Debug.h"

@implementation HatenaTouchAppDelegate

static HatenaTouchAppDelegate *hatenaTouchApp = NULL;

@synthesize window;
@synthesize navigationController;
@synthesize userSettings;
@synthesize dataFilePath;
@synthesize sharedWebViewController;
@synthesize sharedPickerController;
@synthesize listOfRead;

- (id)init {
	LOG_CURRENT_METHOD;
	if (!hatenaTouchApp) {
		hatenaTouchApp = [super init];
		sharedWebViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
		sharedWebViewController.view.autoresizesSubviews = YES;
		sharedWebViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		sharedPickerController = [[UIImagePickerController alloc] init];
		listOfRead = [[NSMutableDictionary alloc] init];
	}
	return hatenaTouchApp;
}

+ (HatenaTouchAppDelegate *)sharedHatenaTouchApp {
	if (!hatenaTouchApp) {
		hatenaTouchApp = [[HatenaTouchAppDelegate alloc] init];
	}
	return hatenaTouchApp;
}

- (NSString *)documentDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	return documentDirectory;
}

- (void)loadUserSettings {
	LOG_CURRENT_METHOD;
	self.dataFilePath = [[self documentDirectory] stringByAppendingPathComponent:@"UserSettings.dat"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:dataFilePath]) {
		NSMutableData *theData  = [NSMutableData dataWithContentsOfFile:dataFilePath];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
		self.userSettings = [decoder decodeObjectForKey:@"userSettings"];
		
		[decoder finishDecoding];
		[decoder release];
		
		if (userSettings.version != CURRENT_VERSION) {
			LOG(@"migrate settings.");
			UserSettings *newSettings = [[UserSettings alloc] init];
			newSettings.version = CURRENT_VERSION;
			newSettings.userName = userSettings.userName;
			newSettings.password = userSettings.password;
			newSettings.imageSize = UserSettingsImageSizeMedium;
			newSettings.useMobileProxy = NO;
			self.userSettings = newSettings;
		}
	} else {
		self.userSettings = [[UserSettings alloc] init];
	}	
}

- (void)saveUserSettings {
	LOG_CURRENT_METHOD;
	NSMutableData *theData = [NSMutableData data];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
	[encoder encodeObject:userSettings forKey:@"userSettings"];
	[encoder finishEncoding];
	[theData writeToFile:dataFilePath atomically:YES];
	[encoder release];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	LOG_CURRENT_METHOD;
	[self loadUserSettings];
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	LOG_CURRENT_METHOD;
	[self saveUserSettings];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[listOfRead release];
	[sharedWebViewController release];
	[dataFilePath release];
	[userSettings release];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

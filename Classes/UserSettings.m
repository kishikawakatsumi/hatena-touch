#import "UserSettings.h"

static UserSettings *sharedInstance;

@implementation UserSettings

@synthesize version;
@synthesize userName;
@synthesize password;
@synthesize imageSize;
@synthesize useMobileProxy;
@synthesize shouldAutoRotation;

+ (UserSettings *)sharedInstance {
    if (!sharedInstance) {
        [UserSettings loadSettings];
    }
    return sharedInstance;
}

+ (void)loadSettings {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"UserSettings.dat"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSMutableData *data  = [NSMutableData dataWithContentsOfFile:path];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        sharedInstance = [[decoder decodeObjectForKey:@"userSettings"] retain];
        
        [decoder finishDecoding];
        [decoder release];
        
        if (sharedInstance.version != CURRENT_VERSION) {
            UserSettings *newSettings = [[UserSettings alloc] init];
            newSettings.version = CURRENT_VERSION;
            newSettings.userName = sharedInstance.userName;
            newSettings.password = sharedInstance.password;
            newSettings.imageSize = sharedInstance.imageSize;
            newSettings.useMobileProxy = sharedInstance.useMobileProxy;
            newSettings.shouldAutoRotation = YES;
            [sharedInstance release];
            sharedInstance = newSettings;
        }
    } else {
        sharedInstance = [[UserSettings alloc] init];
    }	
}

+ (void)saveSettings {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"UserSettings.dat"];
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [encoder encodeObject:[UserSettings sharedInstance] forKey:@"userSettings"];
    [encoder finishEncoding];
    
    [data writeToFile:path atomically:YES];
    [encoder release];
}

- (id)init {
    self = [super init];
    if (self) {
        version = CURRENT_VERSION;
        userName = [[NSString alloc] init];
        password = [[NSString alloc] init];
        imageSize = UserSettingsImageSizeMedium;
        useMobileProxy = NO;
        shouldAutoRotation = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    version = [coder decodeIntForKey:@"version"];
    userName = [[coder decodeObjectForKey:@"userName"] retain];
    password = [[coder decodeObjectForKey:@"password"] retain];
    imageSize = [coder decodeIntForKey:@"imageSize"];
    useMobileProxy = [coder decodeBoolForKey:@"useMobileProxy"];
    shouldAutoRotation = [coder decodeBoolForKey:@"shouldAutoRotation"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:version forKey:@"version"];
    [encoder encodeObject:userName forKey:@"userName"];
    [encoder encodeObject:password forKey:@"password"];
    [encoder encodeInt:imageSize forKey:@"imageSize"];
    [encoder encodeBool:useMobileProxy forKey:@"useMobileProxy"];
    [encoder encodeBool:shouldAutoRotation forKey:@"shouldAutoRotation"];
}

- (void)dealloc {
    [userName release];
    [password release];
    [super dealloc];
}

@end

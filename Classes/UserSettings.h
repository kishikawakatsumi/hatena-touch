#import <UIKit/UIKit.h>

#define CURRENT_VERSION 121

typedef enum {
    UserSettingsImageSizeSmall = 0,
    UserSettingsImageSizeMedium = 1,
    UserSettingsImageSizeLarge = 2,
    UserSettingsImageSizeExtraLarge = 3,
} UserSettingsImageSize;

@interface UserSettings : NSObject <NSCoding> {
	NSInteger version;
	NSString *userName;
	NSString *password;
	UserSettingsImageSize imageSize;
	BOOL useMobileProxy;
	BOOL shouldAutoRotation;
}

@property (nonatomic) NSInteger version;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;
@property (nonatomic) UserSettingsImageSize imageSize;
@property (nonatomic) BOOL useMobileProxy;
@property (nonatomic) BOOL shouldAutoRotation;

@end

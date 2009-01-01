#import <UIKit/UIKit.h>


@interface Diary : NSObject {
	NSString *titleText;
	NSString *diaryText;
}

@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *diaryText;

- (id)initWithTitle:(NSString *)title text:(NSString *)text;
+ (id)diaryWithTitle:(NSString *)title text:(NSString *)text;

@end

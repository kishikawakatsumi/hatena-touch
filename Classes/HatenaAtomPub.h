#import <UIKit/UIKit.h>
#import "Diary.h"

@interface HatenaAtomPub : NSObject {
	NSDate *now;
	NSDateFormatter *dateFormatter;
	NSString *formattedDate;
}

+ (UIView *)waitingView;

- (NSData *)requestBlogCollectionWhetherDraft:(BOOL)draft pageNumber:(NSInteger)page;
- (NSData *)requestBlogEntryWithURI:(NSString *)editURI;

- (NSString *)requestPostNewEntry:(Diary *)entry;
- (NSString *)requestPostNewDraft:(Diary *)entry;
- (NSString *)requestPostNewEntryFromDraft:(Diary *)entry editURI:(NSString *)editURI;
- (BOOL)requestEditEntry:(Diary *)entry editURI:(NSString *)editURI;
- (BOOL)requestDeleteEntry:(NSString *)editURI;

- (NSDictionary *)requestPostNewImage:(UIImage *)image title:(NSString *)title;

- (BOOL)requestAddNewBookmark:(NSString *)urlString:(NSString *)comment;
- (NSData *)requestMyBookmarkFeed;
- (NSData *)requestMyBookmarkFeed:(NSInteger)offset;
- (BOOL)requestDeleteMyBookmark:(NSString *)editURI;

@end

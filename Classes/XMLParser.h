#import <UIKit/UIKit.h>

@interface XMLParser : NSObject {
	NSString *entryTag;
	NSMutableArray *items;
	NSMutableDictionary *item;
	NSString *currentNodeName;
	NSMutableString *currentNodeContent;
	id target;
	SEL callBack;
}

- (NSArray *)items;

- (id)parseXMLAtURL:(NSURL *)url entryTag:(NSString *)entry parseError:(NSError **)error;
- (id)parseXMLAtURL:(NSURL *)url entryTag:(NSString *)entry
			 target:(id)object callBack:(SEL)method parseError:(NSError **)error;
- (id)parseXMLOfData:(NSData *)data entryTag:(NSString *)entry parseError:(NSError **)error;
- (id)parseXMLOfData:(NSData *)data entryTag:(NSString *)entry
			  target:(id)object callBack:(SEL)method parseError:(NSError **)error;

@end

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@interface FeedParser : NSObject {
    NSURLRequest *request;
	NSURLConnection *conn;
    xmlParserCtxtPtr parserContext;
    
    BOOL isChannel;
	BOOL isItem;
    NSMutableDictionary *channel;
    NSMutableDictionary *currentItem;
    NSMutableString *currentCharacters;
	
	id callBackObject;
	SEL callBack;
	SEL completeSelector;
}

+ (void)parseWithRequest:(NSURLRequest *)aRequest callBackObject:(id)target callBack:(SEL)selector completeSelector:(SEL)comleteSel;

@end

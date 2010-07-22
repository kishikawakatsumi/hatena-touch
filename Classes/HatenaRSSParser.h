//
//  RSSParser.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

struct _xmlSAX2Attributes {
    const xmlChar* localname;
    const xmlChar* prefix;
    const xmlChar* uri;
    const xmlChar* value;
    const xmlChar* end;
};
typedef struct _xmlSAX2Attributes xmlSAX2Attributes;

@interface HatenaRSSParser : NSObject {
    NSString *identifier;
    
    BOOL isChannel;
	BOOL isItem;
    NSMutableDictionary *channel;
    NSMutableDictionary *currentItem;
    NSMutableString *currentCharacters;
    xmlParserCtxtPtr xmlParserContext;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLConnection *connection;

- (id)initWithURL:(NSURL *)URL;
- (void)parse;

@end

@protocol HatenaRSSParserDelegate<NSObject>

- (void)parser:(HatenaRSSParser *)parser addEntry:(id)entry;
- (void)parserFinished:(HatenaRSSParser *)parser;
- (void)parser:(HatenaRSSParser *)parser encounteredError:(NSError *)error;

@end

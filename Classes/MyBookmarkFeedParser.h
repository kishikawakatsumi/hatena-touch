//
//  MyBookmarkFeedParser.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
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

@interface MyBookmarkFeedParser : NSObject {
	BOOL isEntry;
    NSMutableDictionary *bookmarks;
    NSMutableDictionary *currentEntry;
    NSMutableString *currentCharacters;
    xmlParserCtxtPtr xmlParserContext;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, readonly) NSMutableDictionary *bookmarks;

- (void)parse;

@end

@protocol MyBookmarkFeedParserDelegate<NSObject>

- (void)parser:(MyBookmarkFeedParser *)parser addEntry:(id)entry;
- (void)parserFinished:(MyBookmarkFeedParser *)parser;
- (void)parser:(MyBookmarkFeedParser *)parser encounteredError:(NSError *)error;

@end

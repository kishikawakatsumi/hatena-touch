//
//  FotolifeResponseParser.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/18.
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

@interface HatenaAtomPubResponseParser : NSObject {
    NSMutableDictionary *entry;
    NSMutableString *currentCharacters;
    xmlParserCtxtPtr xmlParserContext;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSMutableDictionary *entry;;

- (void)parseWithData:(NSData *)data;

@end

@protocol FotolifeResponseParserDelegate<NSObject>

- (void)parserFinished:(HatenaAtomPubResponseParser *)parser;
- (void)parser:(HatenaAtomPubResponseParser *)parser encounteredError:(NSError *)error;

@end

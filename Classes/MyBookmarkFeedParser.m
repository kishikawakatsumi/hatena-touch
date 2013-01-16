//
//  MyBookmarkFeedParser.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "MyBookmarkFeedParser.h"

@interface MyBookmarkFeedParser(LibXMLParserMethods)

- (void)elementFound:(const xmlChar *)localname prefix:(const xmlChar *)prefix 
                 uri:(const xmlChar *)URI namespaceCount:(int)namespaceCount
          namespaces:(const xmlChar **)namespaces attributeCount:(int)attributeCount 
defaultAttributeCount:(int)defaultAttributeCount attributes:(xmlSAX2Attributes *)attributes;
- (void)endElement:(const xmlChar *)localname prefix:(const xmlChar *)prefix uri:(const xmlChar *)URI;
- (void)charactersFound:(const xmlChar *)characters length:(int)length;
- (void)parsingError:(const char *)msg, ...;
- (void)endDocument;

@end

static xmlSAXHandler SAXHandlerStruct;

@implementation MyBookmarkFeedParser

@synthesize delegate;
@synthesize request;
@synthesize connection;
@synthesize bookmarks;

- (void)commonInit {
    bookmarks = [[NSMutableDictionary alloc] init];
    [bookmarks setObject:[NSMutableArray array] forKey:@"entries"];
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    self.request = nil;
    
    [self.connection cancel];
    self.connection = nil;
    
	[bookmarks release];
    [currentCharacters release];
    
    xmlFreeParserCtxt(xmlParserContext);
    xmlParserContext = NULL;
    
    [super dealloc];
}

- (void)parse {
    xmlParserContext = xmlCreatePushParserCtxt(&SAXHandlerStruct, self, NULL, 0, NULL);
    
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    [self.connection start];
}

#pragma mark Parsing Function Callback Methods

static const char *kEntryElementName = "entry";
static NSUInteger kEntryElementNameLength = 6;

static const char *kTitleElementName = "title";
static NSUInteger kTitleElementNameLength = 6;
static const char *kLinkElementName = "link";
static NSUInteger kLinkElementNameLength = 5;

- (void)elementFound:(const xmlChar *)localname prefix:(const xmlChar *)prefix 
                 uri:(const xmlChar *)URI namespaceCount:(int)namespaceCount
          namespaces:(const xmlChar **)namespaces attributeCount:(int)attributeCount 
defaultAttributeCount:(int)defaultAttributeCount attributes:(xmlSAX2Attributes *)attributes {    
    if (strncmp((char *)localname, kEntryElementName, kEntryElementNameLength) == 0) {
        isEntry = YES;
        
        currentEntry = [NSMutableDictionary dictionary];
        [[bookmarks objectForKey:@"entries"] addObject:currentEntry];
        return;
    }
    
    if (strncmp((char *)localname, kTitleElementName, kTitleElementNameLength) == 0) {
        [currentCharacters release], currentCharacters = nil;
        currentCharacters = [[NSMutableString string] retain];
    }
    
    if (strncmp((char *)localname, kLinkElementName, kLinkElementNameLength) == 0) {        
        NSMutableDictionary *dict = nil;
        if (isEntry) {
            dict = currentEntry;
        } else {
            dict = bookmarks;
        }
        
        int href = 0;
        int rel = 0;
        for (int i = 0; i < attributeCount; i++) {
            if (strncmp((char *)attributes[i].localname, "href", 5) == 0) {
                href = i;
            }
            if (strncmp((char *)attributes[i].localname, "rel", 4) == 0) {
                rel = i;
            }
        }
        
        int valueLength = (int) (attributes[rel].end - attributes[rel].value);
        NSString *relValue = [[[NSString alloc] initWithBytes:attributes[rel].value length:valueLength encoding:NSUTF8StringEncoding] autorelease];
        if ([relValue isEqualToString:@"related"]) {
            valueLength = (int) (attributes[href].end - attributes[href].value);
            [dict setObject:[[[NSString alloc] initWithBytes:attributes[href].value length:valueLength encoding:NSUTF8StringEncoding] autorelease] forKey:@"link"];
        } else if ([relValue isEqualToString:@"service.edit"]) {
            valueLength = (int) (attributes[href].end - attributes[href].value);
            [dict setObject:[[[NSString alloc] initWithBytes:attributes[href].value length:valueLength encoding:NSUTF8StringEncoding] autorelease] forKey:@"edit"];
        }
    }
}

- (void)endElement:(const xmlChar *)localname prefix:(const xmlChar *)prefix uri:(const xmlChar *)URI {
    if (strncmp((char *)localname, kEntryElementName, kEntryElementNameLength) == 0) {
        if ([self.delegate respondsToSelector:@selector(parser:addEntry:)]) {
            [self.delegate parser:self addEntry:currentEntry];
        }
        
        isEntry = NO;
        currentEntry = nil;
        
        return;
    }
    
    if (strncmp((char *)localname, kTitleElementName, kTitleElementNameLength) == 0) {
        NSString *key = [NSString stringWithCString:(char *)localname encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *dict = nil;
        if (isEntry) {
            dict = currentEntry;
        } else {
            dict = bookmarks;
        }
        
        [dict setObject:currentCharacters forKey:key];
        [currentCharacters release], currentCharacters = nil;
    }
}

- (void)charactersFound:(const xmlChar *)characters length:(int)length {
    if (currentCharacters) {
        NSString *string = [[NSString alloc] initWithBytes:characters length:length encoding:NSUTF8StringEncoding];
        [currentCharacters appendString:string];
        [string release];
    }
}

- (void)parsingError:(const char *)msg, ... {
    NSString *format = [[NSString alloc] initWithBytes:msg length:strlen(msg) encoding:NSUTF8StringEncoding];
    
    CFStringRef resultString = NULL;
    va_list argList;
    va_start(argList, msg);
    resultString = CFStringCreateWithFormatAndArguments(NULL, NULL, (CFStringRef)format, argList);
    va_end(argList);
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:(NSString*)resultString forKey:@"error_message"];
    NSError *error = [NSError errorWithDomain:@"ParsingDomain" code:101 userInfo:userInfo];
    
    [(NSString*)resultString release];
    [format release];
    
    if ([self.delegate respondsToSelector:@selector(parser:encounteredError:)]) {
        [self.delegate parser:self encounteredError:error];
    }
}

- (void)endDocument {
    if ([self.delegate respondsToSelector:@selector(parserFinished:)]) {
        [self.delegate parserFinished:self];
    }
}

#pragma mark NSURLConnection Delegate methods

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection 
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(parser:encounteredError:)]) {
        [self.delegate parser:self encounteredError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    xmlParseChunk(xmlParserContext, (const char *)[data bytes], [data length], 0);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    xmlParseChunk(xmlParserContext, NULL, 0, 1);
}

@end

#pragma mark SAX Parsing Callbacks

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                            const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces,
                            int nb_attributes, int nb_defaulted, const xmlChar **attributes) {
    [((MyBookmarkFeedParser *)ctx) elementFound:localname prefix:prefix uri:URI 
                                 namespaceCount:nb_namespaces namespaces:namespaces
                                 attributeCount:nb_attributes defaultAttributeCount:nb_defaulted
                                     attributes:(xmlSAX2Attributes *)attributes];
}

static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                          const xmlChar *URI) {    
    [((MyBookmarkFeedParser *)ctx) endElement:localname prefix:prefix uri:URI];
}

static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len) {
    [((MyBookmarkFeedParser *)ctx) charactersFound:ch length:len];
}

static void errorEncounteredSAX(void *ctx, const char *msg, ...) {
    va_list argList;
    va_start(argList, msg);
    [((MyBookmarkFeedParser *)ctx) parsingError:msg, argList];
}

static void endDocumentSAX(void *ctx) {
    [((MyBookmarkFeedParser *)ctx) endDocument];
}

static xmlSAXHandler SAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    endDocumentSAX,             /* endDocument */
    NULL,                       /* startElement*/
    NULL,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    NULL,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             // initialized? not sure what it means just do it
    NULL,                       // private
    startElementSAX,            /* startElementNs */
    endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};

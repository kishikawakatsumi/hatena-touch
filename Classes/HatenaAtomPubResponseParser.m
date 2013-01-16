//
//  FotolifeResponseParser.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/18.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "HatenaAtomPubResponseParser.h"

@interface HatenaAtomPubResponseParser(LibXMLParserMethods)

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

@implementation HatenaAtomPubResponseParser

@synthesize delegate;
@synthesize entry;

- (void)commonInit {
    entry = [[NSMutableDictionary alloc] init];
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
    
	[entry release];
    [currentCharacters release];
    
    xmlFreeParserCtxt(xmlParserContext);
    xmlParserContext = NULL;
    
    [super dealloc];
}

- (void)parseWithData:(NSData *)data {
    xmlParserContext = xmlCreatePushParserCtxt(&SAXHandlerStruct, self, NULL, 0, NULL);
    xmlParseChunk(xmlParserContext, (const char *)[data bytes], [data length], 0);
    xmlParseChunk(xmlParserContext, NULL, 0, 1);
}

#pragma mark Parsing Function Callback Methods

static const char *kTitleElementName = "title";
static NSUInteger kTitleElementNameLength = 6;
static const char *kHatenaSyntaxElementName = "syntax";
static NSUInteger kHatenaSyntaxElementNameLength = 7;

- (void)elementFound:(const xmlChar *)localname prefix:(const xmlChar *)prefix 
                 uri:(const xmlChar *)URI namespaceCount:(int)namespaceCount
          namespaces:(const xmlChar **)namespaces attributeCount:(int)attributeCount 
defaultAttributeCount:(int)defaultAttributeCount attributes:(xmlSAX2Attributes *)attributes {
    if (strncmp((char *)localname, kTitleElementName, kTitleElementNameLength) == 0 ||
        strncmp((char *)localname, kHatenaSyntaxElementName, kHatenaSyntaxElementNameLength) == 0) {
        [currentCharacters release], currentCharacters = nil;
        currentCharacters = [[NSMutableString string] retain];
    }
}

- (void)endElement:(const xmlChar *)localname prefix:(const xmlChar *)prefix uri:(const xmlChar *)URI {
    if (strncmp((char *)localname, kTitleElementName, kTitleElementNameLength) == 0 ||
        strncmp((char *)localname, kHatenaSyntaxElementName, kHatenaSyntaxElementNameLength) == 0) {
        NSString *key = [NSString stringWithCString:(char *)localname encoding:NSUTF8StringEncoding];
        
        [entry setObject:currentCharacters forKey:key];
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

@end

#pragma mark SAX Parsing Callbacks

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                            const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces,
                            int nb_attributes, int nb_defaulted, const xmlChar **attributes) {
    [((HatenaAtomPubResponseParser *)ctx) elementFound:localname prefix:prefix uri:URI 
                                   namespaceCount:nb_namespaces namespaces:namespaces
                                   attributeCount:nb_attributes defaultAttributeCount:nb_defaulted
                                       attributes:(xmlSAX2Attributes *)attributes];
}

static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                          const xmlChar *URI) {    
    [((HatenaAtomPubResponseParser *)ctx) endElement:localname prefix:prefix uri:URI];
}

static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len) {
    [((HatenaAtomPubResponseParser *)ctx) charactersFound:ch length:len];
}

static void errorEncounteredSAX(void *ctx, const char *msg, ...) {
    va_list argList;
    va_start(argList, msg);
    [((HatenaAtomPubResponseParser *)ctx) parsingError:msg, argList];
}

static void endDocumentSAX(void *ctx) {
    [((HatenaAtomPubResponseParser *)ctx) endDocument];
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

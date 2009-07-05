#import "FeedParser.h"

@interface FeedParser (private)
- (void)startElementLocalName:(const xmlChar*)localname 
        prefix:(const xmlChar*)prefix 
        URI:(const xmlChar*)URI 
        nb_namespaces:(int)nb_namespaces 
        namespaces:(const xmlChar**)namespaces 
        nb_attributes:(int)nb_attributes 
        nb_defaulted:(int)nb_defaulted 
        attributes:(const xmlChar**)attributes;
- (void)endElementLocalName:(const xmlChar*)localname 
        prefix:(const xmlChar*)prefix URI:(const xmlChar *)URI;
- (void)charactersFound:(const xmlChar*)ch 
        len:(int)len;
- (void)start;
@end

static void startElementHandler(
        void *ctx, 
        const xmlChar *localname, 
        const xmlChar *prefix, 
        const xmlChar *URI, 
        int nb_namespaces, 
        const xmlChar **namespaces, 
        int nb_attributes, 
        int nb_defaulted, 
        const xmlChar **attributes) {
    [(FeedParser *)ctx 
            startElementLocalName:localname 
            prefix:prefix URI:URI 
            nb_namespaces:nb_namespaces 
            namespaces:namespaces 
            nb_attributes:nb_attributes 
            nb_defaulted:nb_defaulted 
            attributes:attributes];
}

static void	endElementHandler(
        void *ctx, 
        const xmlChar *localname, 
        const xmlChar *prefix, 
        const xmlChar *URI) {
    [(FeedParser *)ctx 
            endElementLocalName:localname 
            prefix:prefix 
            URI:URI];
}

static void	charactersFoundHandler(
        void *ctx, 
        const xmlChar *ch, 
        int len) {
    [(FeedParser *)ctx 
            charactersFound:ch len:len];
}

static xmlSAXHandler _saxHandlerStruct = {
    NULL,            /* internalSubset */
    NULL,            /* isStandalone   */
    NULL,            /* hasInternalSubset */
    NULL,            /* hasExternalSubset */
    NULL,            /* resolveEntity */
    NULL,            /* getEntity */
    NULL,            /* entityDecl */
    NULL,            /* notationDecl */
    NULL,            /* attributeDecl */
    NULL,            /* elementDecl */
    NULL,            /* unparsedEntityDecl */
    NULL,            /* setDocumentLocator */
    NULL,            /* startDocument */
    NULL,            /* endDocument */
    NULL,            /* startElement*/
    NULL,            /* endElement */
    NULL,            /* reference */
    charactersFoundHandler, /* characters */
    NULL,            /* ignorableWhitespace */
    NULL,            /* processingInstruction */
    NULL,            /* comment */
    NULL,            /* warning */
    NULL,            /* error */
    NULL,            /* fatalError //: unused error() get all the errors */
    NULL,            /* getParameterEntity */
    NULL,            /* cdataBlock */
    NULL,            /* externalSubset */
    XML_SAX2_MAGIC,  /* initialized */
    NULL,            /* private */
    startElementHandler,    /* startElementNs */
    endElementHandler,      /* endElementNs */
    NULL,            /* serror */
};

@implementation FeedParser

- (id)initWithRequest:(NSURLRequest*)aRequest {
    if (![super init]) {
        return nil;
    }
    
    request = [aRequest retain];
    channel = [[NSMutableDictionary dictionary] retain];
    [channel setObject:[NSMutableArray array] forKey:@"items"];
    currentItem = nil;
    
    return self;
}

+ (void)parseWithRequest:(NSURLRequest *)aRequest callBackObject:(id)target callBack:(SEL)selector {
	FeedParser *parser = [[FeedParser alloc] initWithRequest:aRequest];
	parser->callBackObject = [target retain];
	parser->callBack = selector;
	[parser start];
}

- (void)dealloc {
    [request release], request = nil;
	[conn cancel];
    [conn release], conn = nil;
	[channel release], channel = nil;
    [currentCharacters release], currentCharacters = nil;
	[callBackObject release], callBackObject = nil;
    
	[super dealloc];
}

- (void)start {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	parserContext = xmlCreatePushParserCtxt(&_saxHandlerStruct, self, NULL, 0, NULL);
	[NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -- NSURLConnection delegate --

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    xmlParseChunk(parserContext, (const char *)[data bytes], [data length], 0);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    xmlParseChunk(parserContext, NULL, 0, 1);
	
    if (parserContext) {
        xmlFreeParserCtxt(parserContext), parserContext = NULL;
    }
    conn = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (parserContext) {
        xmlFreeParserCtxt(parserContext), parserContext = NULL;
    }
    conn = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -- libxml handler --

- (void)startElementLocalName:(const xmlChar*)localname 
        prefix:(const xmlChar*)prefix 
        URI:(const xmlChar*)URI 
        nb_namespaces:(int)nb_namespaces 
        namespaces:(const xmlChar**)namespaces 
        nb_attributes:(int)nb_attributes 
        nb_defaulted:(int)nb_defaulted 
        attributes:(const xmlChar**)attributes {
    // channel
    if (strncmp((char*)localname, "channel", sizeof("channel")) == 0) {
        isChannel = YES;
        return;
    }
    
    // item
    if (strncmp((char*)localname, "item", sizeof("item")) == 0) {
        isItem = YES;
        
        currentItem = [NSMutableDictionary dictionary];
        [[channel objectForKey:@"items"] addObject:currentItem];
        return;
    }
    
    // title, link, description
    if (strncmp((char*)localname, "title", sizeof("title")) == 0 || 
        strncmp((char*)localname, "link", sizeof("link")) == 0 || 
        strncmp((char*)localname, "description", sizeof("description")) == 0) {
        [currentCharacters release], currentCharacters = nil;
        currentCharacters = [[NSMutableString string] retain];
    }
}

- (void)endElementLocalName:(const xmlChar*)localname 
        prefix:(const xmlChar*)prefix URI:(const xmlChar*)URI {
    // channel
    if (strncmp((char*)localname, "channel", sizeof("channel")) == 0) {
        isChannel = NO;        
        return;
    }
    
    // item
    if (strncmp((char*)localname, "item", sizeof("item")) == 0) {
		[callBackObject performSelectorOnMainThread:callBack withObject:currentItem waitUntilDone:NO];
		
        isItem = NO;
        currentItem = nil;
        
        return;
    }
    
    // title, link, description
    if (strncmp((char*)localname, "title", sizeof("title")) == 0 || 
        strncmp((char*)localname, "link", sizeof("link")) == 0 || 
        strncmp((char*)localname, "description", sizeof("description")) == 0) {
        NSString *key = [NSString stringWithCString:(char *)localname encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *dict = nil;
        if (isItem) {
            dict = currentItem;
        } else if (isChannel) {
            dict = channel;
        }
        
        [dict setObject:currentCharacters forKey:key];
        [currentCharacters release], currentCharacters = nil;
    }
}

- (void)charactersFound:(const xmlChar*)ch 
        len:(int)len {
    if (currentCharacters) {
        NSString *string = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
        [currentCharacters appendString:string];
        [string release];
    }
}

@end

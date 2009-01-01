#import "XMLParser.h"

@implementation XMLParser

- (NSArray *)items {
	return items;
}

- (id)parseXMLAtURL:(NSURL *)url entryTag:(NSString *)entry parseError:(NSError **)error {
	[items release];
	items = [[NSMutableArray alloc] init];
	return [self parseXMLAtURL:url entryTag:entry target:nil callBack:nil parseError:error];
}

- (id)parseXMLAtURL:(NSURL *)url entryTag:(NSString *)entry
			 target:(id)object callBack:(SEL)method parseError:(NSError **)error {
	entryTag = entry;
	target = object;
	callBack = method;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	
	[parser parse];
	if ([parser parserError] && error) {
		*error = [parser parserError];
	}
	[parser release];
	
	return self;
}

- (id)parseXMLOfData:(NSData *)data entryTag:(NSString *)entry parseError:(NSError **)error {
	[items release];
	items = [[NSMutableArray alloc] init];
	return [self parseXMLOfData:data entryTag:entry target:nil callBack:nil parseError:error];
}

- (id)parseXMLOfData:(NSData *)data entryTag:(NSString *)entry target:(id)object 
			callBack:(SEL)method parseError:(NSError **)error {
	entryTag = entry;
	target = object;
	callBack = method;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:self];
	
	[parser parse];
	if ([parser parserError] && error) {
		*error = [parser parserError];
	}
	[parser release];
	
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:entryTag]) {
		item = [[NSMutableDictionary alloc] initWithCapacity:10];
	} else {
		currentNodeName = [elementName retain];
		currentNodeContent = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:entryTag]) {
		if (!target || !callBack) {
			[items addObject:item];
		} else if ([target respondsToSelector:callBack]) {
			[target performSelectorOnMainThread:callBack withObject:item waitUntilDone:NO];
		}
		[item release];
		item = nil;
	} else if ([elementName isEqualToString:currentNodeName]) {
		[item setValue:currentNodeContent forKey:elementName];

		[currentNodeContent release];
		currentNodeContent = nil;
		
		[currentNodeName release];
		currentNodeName = nil;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {   
	if (!string) {
		return;
	}
	[currentNodeContent appendString:string];
}

- (void)dealloc {
	[items release];
	[entryTag release];
	[super dealloc];
}

@end

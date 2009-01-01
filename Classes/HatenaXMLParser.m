#import "HatenaXMLParser.h"

@implementation HatenaXMLParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:entryTag]) {
		item = [[NSMutableDictionary alloc] initWithCapacity:10];
	} else if ([elementName isEqualToString:@"link"]) {
		[item setObject:[attributeDict objectForKey:@"href"] forKey:[attributeDict objectForKey:@"rel"]];
	} else {
		currentNodeName = [elementName retain];
		currentNodeContent = [[NSMutableString alloc] init];
	}
}

@end

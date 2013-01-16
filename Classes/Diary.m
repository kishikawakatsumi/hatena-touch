#import "Diary.h"

@implementation Diary

@synthesize titleText;
@synthesize diaryText;

- (id)init {
    self = [super init];
	if (self) {
		titleText = [[NSString alloc] init];
		diaryText = [[NSString alloc] init];
	}
	return self;
}

- (id)initWithTitle:(NSString *)title text:(NSString *)text {
    self = [super init];
	if (self) {
		titleText = [title retain];
		diaryText = [text retain];
	}
	return self;
}

+ (id)diaryWithTitle:(NSString *)title text:(NSString *)text {
	return [[[Diary alloc] initWithTitle:title text:text] autorelease];
}

- (id)initWithCoder:(NSCoder *)coder {
	titleText = [[coder decodeObjectForKey:@"titleText"] retain];
	diaryText = [[coder decodeObjectForKey:@"diaryText"] retain];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:titleText forKey:@"titleText"];
	[encoder encodeObject:diaryText forKey:@"diaryText"];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"title = %@, text = %@", titleText, diaryText];
}

- (void)dealloc {
	[titleText release];
	[diaryText release];
	[super dealloc];
}

@end

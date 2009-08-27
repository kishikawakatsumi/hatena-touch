//
//  main.m
//  HatenaTouch
//
//  Created by 岸川 克己 on 08/09/06.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//


// Valgrind を使って iPhone アプリのメモリデバッグをする - 某開発者の雑記帳
// http://d.hatena.ne.jp/tmurakam/20090123/1232680212
#import <UIKit/UIKit.h>
#import <unistd.h>

#ifndef ENABLE_VALGRIND
#define ENABLE_VALGRIND 1
#endif

#define VALGRIND_PATH   "/usr/local/bin/valgrind"
int main(int argc, char *argv[])
{
#if ENABLE_VALGRIND
  // check if in the simulator
  NSString *model = [[UIDevice currentDevice] model];
  if ([model isEqualToString:@"iPhone Simulator"]) {
    
    // execute myself with valgrind
    if (argc < 2 || strcmp(argv[1], "--valgrind") != 0) {
      execl(VALGRIND_PATH, VALGRIND_PATH, "--leak-check=full", argv[0], "--valgrind", NULL);
    }
  }
#endif
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  int retVal = UIApplicationMain(argc, argv, nil, nil);
  [pool release];
  return retVal;
}


// xcode original template
/*
#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, nil);
	[pool release];
	return retVal;
}
*/
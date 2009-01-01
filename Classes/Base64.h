
/*
      _______                          .__ .__   .__   .__                 
      \      \    ____   __ __ _______ |__||  |  |  |  |__|  ____    ____  
      /   |   \ _/ __ \ |  |  \\_  __ \|  ||  |  |  |  |  | /  _ \  /    \ 
     /    |    \\  ___/ |  |  / |  | \/|  ||  |__|  |__|  |(  <_> )|   |  \
     \____|__  / \___  >|____/  |__|   |__||____/|____/|__| \____/ |___|  /
    =========\/======\/=================================================\/==
  v0.01 19/OCT/2007 © Copyright 2007-2007 Scott D. Yelich SOME RIGHTS RESERVED


  LICENSE:  Creative Commons Attribution 3.0 License.
  SEE:      http://creativecommons.org/licenses/by/3.0/


  Fri Oct 19 23:57:59 EST 2007, v0.01 sdy
  Wed Nov 21 21:17:29 EST 2007, v0.02 sdy

  This is Base64.h, part of Base64.

  See Base64.cpp for implementation details.

*/

#ifndef BASE64_H
#define BASE64_H

//  C++

#include <string>

class Base64
{

  public:

   Base64();
  ~Base64();

  std::string decode(std::string const & s);
  std::string encode(std::string const & s, int split=0);
  std::string scrub(std::string const & s, std::string const & goodchars);
  std::string scrub(std::string const & s);
  bool isBase64Char(char const c);
  int base64Char(char const c);

  private:

  std::string baseChars;

};

#endif

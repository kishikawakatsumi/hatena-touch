
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

*/

//  PACKAGE

#include "Base64.h"


Base64::Base64() :
  baseChars("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
{
}

Base64::~Base64()
{
}

bool
Base64::isBase64Char (char const c)
{
  return (base64Char(c) != std::string::npos);
}

int
Base64::base64Char (char const c)
{
  return baseChars.find_first_of(c);
}

std::string 
Base64::scrub(std::string const & s)
{
  return scrub(s, baseChars);
}

std::string 
Base64::scrub(std::string const & so, std::string const & goodchars)
{
  int loc = 0;
  int nloc = 0;
  std::string s;
  bool process = true;
  while (process) {
    nloc = so.find_first_not_of(goodchars, loc);
    if (nloc != std::string::npos) {
      s.append(so.substr(loc, nloc-loc));
      loc = nloc+1;
    } else {
      process = false;
    }
  }
  s.append(so.substr(loc, so.size()-loc));
  return s;
}

std::string 
Base64::encode(std::string const & so, int split)
{
  std::string s;
  std::string r;
  std::string p;
  if (so.size()<1) {
    return r;
  }
  s = so;
  int c = s.size()%3;
  //  pad to make length a multiple of 3
  if (c>0) {
    for (; c<3; c++) { 
      p.append("=");
      s.append("=");
    }
  }
  int n;
  int n1, n2, n3, n4;
  //  go over over length of the string, by 3
  for (c=0; c<s.size(); c+=3) {
    if (0<c && 0<split && ((c/3)*4)%split == 0) {
      r.append("\n");
    }
    //  convert 3 8-bit values into 1 24-bit value
    n = (s[c]<<16) + (s[c+1]<<8) + (s[c+2]);
    //  split 1 24-bit value into 4 6-bit values
    n1 = (n >> 18) & 63;
    n2 = (n >> 12) & 63;
    n3 = (n >>  6) & 63;
    n4 = (n >>  0) & 63;
    //  add each of the 6-bit chars to string via lookup
    r += baseChars[n1];
    r += baseChars[n2];
    r += baseChars[n3];
    r += baseChars[n4];
  }
  if (c>0) {
    r = r.substr(0, r.size()-p.size()).append(p);
  }
  return r;
}

std::string 
Base64::decode(std::string const & so)
{
  std::string s;
  std::string r;
  std::string p;
  if (so.size()<1){
    return r;
  }
  s = so;
  //  replace padding with 'A' for 0 valued bits...
  if (!s.substr(s.size()-1, 1).compare("=")) {
    p.append("A");
  }
  if (!s.substr(s.size()-2, 1).compare("=")) {
    p.append("A");
  }
  s = scrub(s);
  if (p.size()>0){
    s.append(p);
  }
  int n;
  //  go over over length of the string, by 4
  for (int c=0; c<s.size(); c+=4) {
    //  each of the 4 char represents 6-bits of the 1 24-bit value
    n = (base64Char(s[c  ])<<18) +
        (base64Char(s[c+1])<<12) +
        (base64Char(s[c+2])<< 6) +
        (base64Char(s[c+3])<< 0);
    //  split the 1 24-bit value into 3 8-bit values and append as chars
    r += char((n>>16)&255);
    r += char((n>> 8)&255);
    r += char((n>> 0)&255);
  }
  r = r.substr(0, r.size()-p.size());
  return r;
}

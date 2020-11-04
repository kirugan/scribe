//
// Created by Kirill on 11/4/2020.
//

#ifndef SCRIBE_SRC_UTILS_H_
#define SCRIBE_SRC_UTILS_H_

#include <string_view>

namespace scribe {
  using namespace std;

  inline void str_split(vector<string>& tokens, const string& str, const string_view delim) {
    // todo(kirugan) optimize algorithm
    size_t start = 0, pos = 0;
    for (const char c: str) {
      const auto char_is_delimeter = delim.find(c) != string::npos;
      if (char_is_delimeter) {
        auto ss = str.substr(start, pos - start);
        if (!ss.empty()) {
          tokens.push_back(ss);
        }
        start = pos + 1;
      }
      pos++;
    }

    if (start < pos) {
      auto ss = str.substr(start, pos-start);
      if (!ss.empty()) {
        tokens.push_back(ss);
      }
    }
  }
}

#endif //SCRIBE_SRC_UTILS_H_

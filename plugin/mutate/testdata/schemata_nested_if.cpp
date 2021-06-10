/// @copyright Boost License 1.0, http://boost.org/LICENSE_1_0.txt
/// @date 2021
/// @author Joakim Brännström (joakim.brannstrom@gmx.com)

#include <string>

#define FMT_CONSTEXPR inline

template <typename Char, typename Handler>
FMT_CONSTEXPR void handle_cstring_type_spec(Char spec, Handler&& handler) {
    if (spec == 0 || spec == 's')
        handler.on_string();
    else if (spec == 'p')
        handler.on_pointer();
    else
        handler.on_error("invalid type specifier");
}

void fn() {}

int assert_counter;
#define JSON_ASSERT(x)                                                                             \
    {                                                                                              \
        if (!(x))                                                                                  \
            ++assert_counter;                                                                      \
    }

class Foo {
    void deep_nest(std::string s) {
        JSON_ASSERT(s.empty());

        if (!s.empty() && s.back()) {
            for (auto it = s.begin(); it != s.end(); ++it) {
                if (*it) {
                    s.end();
                    break;
                }
            }
        }
    }
};

int main(int argc, char** argv) {
    int x = 0;
    x = 42;
    x = 42;
    x = 42;
    x = 42;

    std::string a{"123"};
    std::string b{"bcd"};

    if (argc == 1)
        fn();
    else if (a == b)
        fn();
    else
        fn();

    return x;
}

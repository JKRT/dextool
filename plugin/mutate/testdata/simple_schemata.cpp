/// @copyright Boost License 1.0, http://boost.org/LICENSE_1_0.txt
/// @date 2020
/// @author Joakim Brännström (joakim.brannstrom@gmx.com)

int main(int argc, char** argv) { return 0; }

int test_composed(int x) { return (x + 3) > 3; }

enum Enum1 { gEnum1, gEnum2 };

enum class Enum2 { lEnum1, lEnum2, lEnum3 };

class OpPartialOverload {
public:
    OpPartialOverload() = default;

    // AOR
    OpPartialOverload operator+(const OpPartialOverload&) { return *this; }
};

void arith_op_on_partial_object() {
    OpPartialOverload a, b, res;
    res = a + b;
}

Enum2 test_enum_value(Enum2 x) {
    if (x == Enum2::lEnum1)
        return Enum2::lEnum2;
    if (x == Enum2::lEnum2)
        return Enum2::lEnum1;
    x = Enum2::lEnum3;
    return x;
}

int test_ror(unsigned int x) {
    if (x > 10u)
        return -10;
    if (x < 10)
        return 10;
    return x;
}

int test_switch(int x) {
    switch (x) {
    case 0:
        return 2;
    case 1: {
        return 3;
    }
    // fallthrough had a bug wherein dcr crashed
    case 2:
    case 3:
    default:
        x = 42;
        break;
    }

    return x;
}

int test_unary_op(int x) {
    if (!x)
        x = 42;
    if (!x)
        x = 42;
    if (!x)
        x = 42;
    x = !x;
    return x;
}

int test_binary_op(int x) {
    x = x + 2;
    x = x - 3;
    x = x & 4;
    x = x | 5;
    x = x && true;
    x = x || false;

    return x;
}

int test_complex_binary_op(int x, int left, int width, int y, int top, int height) {
    return x >= left && x < left + width && y <= top && y > top - height;
}

int test_assign_op(int x) {
    x += 2;
    x -= 1;
    x &= 3;
    x |= 4;
    return x;
}

int test_const(int x, const int y) {
    int w = 42;
    const int a = 84 + 4;
    return w + a;
}

int test_sdl1(int x) {
    x = test_unary_op(x);
    test_assign_op(x);
    return 42;
}

void test_sdl2(int x) {
    x = test_unary_op(x);
    if (x == 42)
        return;
    test_assign_op(x);
}

bool test_bool_return_fn(int x) { return x > 42; }

#define MY_MACRO(x) x > x
void myMacroFun() {
    int x;
    MY_MACRO(x);
}

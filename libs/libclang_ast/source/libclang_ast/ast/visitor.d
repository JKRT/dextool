/**
Copyright: Copyright (c) 2016-2021, Joakim Brännström. All rights reserved.
License: MPL-2
Author: Joakim Brännström (joakim.brannstrom@gmx.com)

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.
*/
module libclang_ast.ast.visitor;

version (unittest) {
    import std.algorithm : map, splitter;
    import std.array : array;
    import std.string : strip;
    import unit_threaded : shouldEqual;
}

/// Inject incr/decr that is called by the accept function when visiting the AST.
mixin template generateIndentIncrDecr() {
    uint indent;

    override void incr() @safe scope {
        ++indent;
    }

    override void decr() @safe scope {
        --indent;
    }
}

@("Should be an instane of a Visitor")
unittest {
    import libclang_ast.ast.base_visitor;

    class V2 : Visitor {
    }

    auto v = new V2;
}

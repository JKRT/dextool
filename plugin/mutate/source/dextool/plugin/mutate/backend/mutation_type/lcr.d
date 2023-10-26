/**
Copyright: Copyright (c) 2018, Joakim Brännström. All rights reserved.
License: MPL-2
Author: Joakim Brännström (joakim.brannstrom@gmx.com)

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.
*/
module dextool.plugin.mutate.backend.mutation_type.lcr;

import std.typecons : Tuple;

import dextool.plugin.mutate.backend.type;

import dextool.plugin.mutate.backend.analyze.ast;

auto lcrMutations(Kind operator) {
    alias Rval = Tuple!(Mutation.Kind[], "op", Mutation.Kind[], "expr",
            Mutation.Kind[], "lhs", Mutation.Kind[], "rhs");
    Rval rval;

    switch (operator) with (Mutation.Kind) {
    case Kind.OpAnd:
        rval = Rval([lcrOr], [lcrTrue, lcrFalse], null, null);
        break;
    case Kind.OpOr:
        rval = Rval([lcrAnd], [lcrTrue, lcrFalse], null, null);
        break;
        // TODO: add assign
    case Kind.OpAndBitwise:
        rval = Rval([lcrbOr], null, null, null);
        break;
    case Kind.OpOrBitwise:
        // TODO: add back [lcrbLhs], [lcrbRhs] mutants but have to consider the functions this type of function:
        // bool fun(int* x, int* y) { return y != x; }
        rval = Rval([lcrbAnd], null, null, null);
        break;
    case Kind.OpAssignAndBitwise:
        rval = Rval([lcrbOrAssign], null, null, null);
        break;
    case Kind.OpAssignOrBitwise:
        rval = Rval([lcrbAndAssign], null, null, null);
        break;
    default:
    }

    return rval;
}

immutable Mutation.Kind[] lcrMutationsAll;

shared static this() {
    with (Mutation.Kind) {
        lcrMutationsAll = [
            lcrAnd, lcrOr, lcrLhs, lcrRhs, lcrTrue, lcrFalse, lcrbAnd, lcrbOr,
            lcrbLhs, lcrbRhs
        ];
    }
}

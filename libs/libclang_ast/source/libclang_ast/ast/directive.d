/**
Copyright: Copyright (c) 2016, Joakim Brännström. All rights reserved.
License: MPL-2
Author: Joakim Brännström (joakim.brannstrom@gmx.com)

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.

DO NOT EDIT. THIS FILE IS GENERATED.
See the generator script source/devtool/generator_clang_ast_nodes.d
*/
module libclang_ast.ast.directive;
import libclang_ast.ast.node : Node;

abstract class Directive : Node {
    import clang.Cursor : Cursor;
    import libclang_ast.ast : Visitor;

    private Cursor cursor_;

    // trusted on the assumption that the node is scope allocated and all access to cursor is via a scoped ref.
    this(scope Cursor cursor) @trusted {
        this.cursor_ = cursor;
    }

    Cursor cursor() return const @safe {
        return Cursor(cursor_.cx);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor_, v);
    }
}

final class OmpParallelDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpForDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpSectionsDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpSectionDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpSingleDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpParallelForDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpParallelSectionsDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTaskDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpMasterDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpCriticalDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTaskyieldDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpBarrierDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTaskwaitDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpFlushDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpOrderedDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpAtomicDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpForSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpParallelForSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTeamsDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTaskgroupDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpCancellationPointDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpCancelDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetDataDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTaskLoopDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTaskLoopSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpDistributeDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetEnterDataDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetExitDataDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetParallelDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetParallelForDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetUpdateDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpDistributeParallelForDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpDistributeParallelForSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpDistributeSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetParallelForSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTeamsDistributeDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTeamsDistributeSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTeamsDistributeParallelForSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTeamsDistributeParallelForDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetTeamsDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetTeamsDistributeDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetTeamsDistributeParallelForDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetTeamsDistributeParallelForSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

final class OmpTargetTeamsDistributeSimdDirective : Directive {
    import clang.Cursor : Cursor;

    this(scope Cursor cursor) @safe {
        super(cursor);
    }

    override void accept(scope Visitor v) @safe const scope {
        static import libclang_ast.ast;

        libclang_ast.ast.accept(cursor, v);
    }
}

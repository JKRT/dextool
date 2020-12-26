/**
Copyright: Copyright (c) 2020, Joakim Brännström. All rights reserved.
License: MPL-2
Author: Joakim Brännström (joakim.brannstrom@gmx.com)

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.
*/
module dextool.plugin.mutate.backend.test_mutant.schemata;

import logger = std.experimental.logger;
import std.algorithm : sort, map;
import std.array : empty;
import std.conv : to;
import std.datetime : Duration;
import std.exception : collectException;
import std.typecons : Tuple;

import proc : DrainElement;
import sumtype;

import my.fsm : Fsm, next, act, get, TypeDataMap;
static import my.fsm;

import dextool.plugin.mutate.backend.database : MutationStatusId, Database, spinSql;
import dextool.plugin.mutate.backend.interface_ : FilesysIO, Blob;
import dextool.plugin.mutate.backend.test_mutant.common;
import dextool.plugin.mutate.backend.test_mutant.test_cmd_runner : TestRunner;
import dextool.plugin.mutate.backend.type : Mutation, TestCase, Checksum;
import dextool.plugin.mutate.type : TestCaseAnalyzeBuiltin, ShellCommand;

@safe:

struct SchemataTestDriver {
    private {
        /// True as long as the schemata driver is running.
        bool isRunning_ = true;

        FilesysIO fio;

        Database* db;

        /// Runs the test commands.
        TestRunner* runner;

        /// Result of testing the mutants.
        MutationTestResult[] result_;

        /// Time it took to compile the schemata.
        Duration compileTime;
    }

    static struct None {
    }

    static struct InitializeData {
        MutationStatusId[] mutants;
    }

    static struct Initialize {
    }

    static struct Done {
    }

    static struct NextMutantData {
        /// Mutants to test.
        InjectIdResult mutants;
    }

    static struct NextMutant {
        bool done;
        InjectIdResult.InjectId inject;
    }

    static struct TestMutantData {
        /// If the user has configured that the test cases should be analyzed.
        bool hasTestCaseOutputAnalyzer;
    }

    static struct TestMutant {
        InjectIdResult.InjectId inject;

        MutationTestResult result;
        bool hasTestOutput;
        // if there are mutants status id's related to a file but the mutants
        // have been removed.
        bool mutantIdError;
    }

    static struct TestCaseAnalyzeData {
        TestCaseAnalyzer* testCaseAnalyzer;
        DrainElement[] output;
    }

    static struct TestCaseAnalyze {
        MutationTestResult result;
        bool unstableTests;
    }

    static struct StoreResult {
        MutationTestResult result;
    }

    alias Fsm = my.fsm.Fsm!(None, Initialize, Done, NextMutant, TestMutant,
            TestCaseAnalyze, StoreResult);
    alias LocalStateDataT = Tuple!(TestMutantData, TestCaseAnalyzeData,
            NextMutantData, InitializeData);

    private {
        Fsm fsm;
        TypeDataMap!(LocalStateDataT, TestMutant, TestCaseAnalyze, NextMutant, Initialize) local;
    }

    this(FilesysIO fio, TestRunner* runner, Database* db,
            TestCaseAnalyzer* testCaseAnalyzer, MutationStatusId[] mutants, Duration compileTime) {
        this.fio = fio;
        this.runner = runner;
        this.db = db;
        this.local.get!Initialize.mutants = mutants;
        this.local.get!TestCaseAnalyze.testCaseAnalyzer = testCaseAnalyzer;
        this.local.get!TestMutant.hasTestCaseOutputAnalyzer = !testCaseAnalyzer.empty;
        this.compileTime = compileTime;
    }

    static void execute_(ref SchemataTestDriver self) @trusted {
        self.fsm.next!((None a) => fsm(Initialize.init),
                (Initialize a) => fsm(NextMutant.init), (NextMutant a) {
            if (a.done)
                return fsm(Done.init);
            return fsm(TestMutant(a.inject));
        }, (TestMutant a) {
            if (a.mutantIdError)
                return fsm(NextMutant.init);
            if (a.result.status == Mutation.Status.killed
                && self.local.get!TestMutant.hasTestCaseOutputAnalyzer && a.hasTestOutput) {
                return fsm(TestCaseAnalyze(a.result));
            }
            return fsm(StoreResult(a.result));
        }, (TestCaseAnalyze a) {
            if (a.unstableTests)
                return fsm(NextMutant.init);
            return fsm(StoreResult(a.result));
        }, (StoreResult a) => fsm(NextMutant.init), (Done a) => fsm(a));

        debug logger.trace("state: ", self.fsm.logNext);
        self.fsm.act!(self);
    }

nothrow:

    MutationTestResult[] result() {
        return result_;
    }

    void execute() {
        try {
            execute_(this);
        } catch (Exception e) {
            logger.warning(e.msg).collectException;
        }
    }

    bool isRunning() {
        return isRunning_;
    }

    void opCall(None data) {
    }

    void opCall(Initialize data) {
        scope (exit)
            local.get!Initialize.mutants = null;

        InjectIdBuilder builder;
        foreach (mutant; local.get!Initialize.mutants) {
            auto cs = spinSql!(() { return db.getChecksum(mutant); });
            if (!cs.isNull) {
                builder.put(mutant, cs.get);
            }
        }
        debug logger.trace(builder).collectException;

        local.get!NextMutant.mutants = builder.finalize;
    }

    void opCall(Done data) {
        isRunning_ = false;
    }

    void opCall(ref NextMutant data) {
        data.done = local.get!NextMutant.mutants.empty;

        if (!data.done) {
            data.inject = local.get!NextMutant.mutants.front;
            local.get!NextMutant.mutants.popFront;
        }
    }

    void opCall(ref TestMutant data) {
        import std.datetime.stopwatch : StopWatch, AutoStart;
        import dextool.plugin.mutate.backend.analyze.pass_schemata : schemataMutantEnvKey,
            checksumToId;
        import dextool.plugin.mutate.backend.generate_mutant : makeMutationText;

        auto sw = StopWatch(AutoStart.yes);

        data.result.id = data.inject.statusId;

        auto id = spinSql!(() { return db.getMutationId(data.inject.statusId); });
        if (id.isNull) {
            data.mutantIdError = true;
            return;
        }
        auto entry_ = spinSql!(() { return db.getMutation(id.get); });
        if (entry_.isNull) {
            data.mutantIdError = true;
            return;
        }
        auto entry = entry_.get;

        try {
            const file = fio.toAbsoluteRoot(entry.file);
            auto original = fio.makeInput(file);
            auto txt = makeMutationText(original, entry.mp.offset,
                    entry.mp.mutations[0].kind, entry.lang);
            debug logger.trace(entry);
            logger.infof("%s from '%s' to '%s' in %s:%s:%s", data.inject.injectId,
                    txt.original, txt.mutation, file, entry.sloc.line, entry.sloc.column);
        } catch (Exception e) {
            logger.info(e.msg).collectException;
        }

        runner.env[schemataMutantEnvKey] = data.inject.injectId.to!string;
        scope (exit)
            runner.env.remove(schemataMutantEnvKey);

        auto res = runTester(*runner);
        data.result.profile = MutantTimeProfile(compileTime, sw.peek);
        // the first tested mutant also get the compile time of the schema.
        compileTime = Duration.zero;

        data.result.mutId = id;
        data.result.status = res.status;
        data.result.exitStatus = res.exitStatus;
        data.hasTestOutput = !res.output.empty;
        local.get!TestCaseAnalyze.output = res.output;

        logger.infof("%s %s:%s (%s)", data.inject.injectId, data.result.status,
                data.result.exitStatus.get, data.result.profile).collectException;
    }

    void opCall(ref TestCaseAnalyze data) {
        try {
            auto analyze = local.get!TestCaseAnalyze.testCaseAnalyzer.analyze(
                    local.get!TestCaseAnalyze.output);
            local.get!TestCaseAnalyze.output = null;

            analyze.match!((TestCaseAnalyzer.Success a) {
                data.result.testCases = a.failed;
            }, (TestCaseAnalyzer.Unstable a) {
                logger.warningf("Unstable test cases found: [%-(%s, %)]", a.unstable);
                logger.info(
                    "As configured the result is ignored which will force the mutant to be re-tested");
                data.unstableTests = true;
            }, (TestCaseAnalyzer.Failed a) {
                logger.warning("The parser that analyze the output from test case(s) failed");
            });

            logger.infof(!data.result.testCases.empty, `%s killed by [%-(%s, %)]`,
                    data.result.mutId, data.result.testCases.sort.map!"a.name").collectException;
        } catch (Exception e) {
            logger.warning(e.msg).collectException;
        }
    }

    void opCall(StoreResult data) {
        result_ ~= data.result;
    }
}

/** Generate schemata injection IDs (32bit) from mutant checksums (128bit).
 *
 * There is a possibility that an injection ID result in a collision because
 * they are only 32 bit. If that happens the mutant is discarded as unfeasable
 * to use for schemata.
 *
 * TODO: if this is changed to being order dependent then it can handle all
 * mutants. But I can't see how that can be done easily both because of how the
 * schemas are generated and how the database is setup.
 */
struct InjectIdBuilder {
    import my.set;

    private {
        alias InjectId = InjectIdResult.InjectId;

        InjectId[uint] result;
        Set!uint collisions;
    }

    void put(MutationStatusId id, Checksum cs) @safe pure nothrow {
        import dextool.plugin.mutate.backend.analyze.pass_schemata : checksumToId;

        const injectId = checksumToId(cs);
        debug logger.tracef("%s %s %s", id, cs, injectId).collectException;

        if (injectId in collisions) {
        } else if (injectId in result) {
            collisions.add(injectId);
            result.remove(injectId);
        } else {
            result[injectId] = InjectId(id, injectId);
        }
    }

    InjectIdResult finalize() @safe pure nothrow {
        import std.array : array;

        return InjectIdResult(result.byValue.array);
    }
}

struct InjectIdResult {
    alias InjectId = Tuple!(MutationStatusId, "statusId", uint, "injectId");
    InjectId[] ids;

    InjectId front() @safe pure nothrow {
        assert(!empty, "Can't get front of an empty range");
        return ids[0];
    }

    void popFront() @safe pure nothrow {
        assert(!empty, "Can't pop front of an empty range");
        ids = ids[1 .. $];
    }

    bool empty() @safe pure nothrow const @nogc {
        return ids.empty;
    }
}

@("shall detect a collision and make sure it is never part of the result")
unittest {
    InjectIdBuilder builder;
    builder.put(MutationStatusId(1), Checksum(1, 2));
    builder.put(MutationStatusId(2), Checksum(3, 4));
    builder.put(MutationStatusId(3), Checksum(1, 2));
    auto r = builder.finalize;

    assert(r.front.statusId == MutationStatusId(2));
    r.popFront;
    assert(r.empty);
}

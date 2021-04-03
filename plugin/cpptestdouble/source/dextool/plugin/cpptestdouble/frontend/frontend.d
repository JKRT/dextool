/**
Date: 2015-2017, Joakim Brännström
License: MPL-2, Mozilla Public License 2.0
Author: Joakim Brännström (joakim.brannstrom@gmx.com)

This file contains the frontend for generating a C++ test double.

Responsible for:
 - Receiving the call from the main to start working.
 - User interaction.
    - Error reporting in a way that the user understand the error.
    - Writing files to the filesystem.
    - Parsing arguments and other interaction information from the user.
    - Configuration file handling.
 - Provide user data to the backend via the interface the backend own.
*/
module dextool.plugin.cpptestdouble.frontend.frontend;

import std.algorithm : map;
import std.array : array, empty;
import std.typecons : Nullable, Yes;

import logger = std.experimental.logger;

import cpptooling.type : CustomHeader, MainFileName, MainName, MainNs;

import dextool.compilation_db : CompileCommandDB, Compiler;
import dextool.type : AbsolutePath, DextoolVersion, ExitStatusType, Path;
import dextool.io : WriteStrategy;

import dextool.plugin.cpptestdouble.backend : Controller, Parameters, Products, Transform;
import dextool.plugin.cpptestdouble.frontend.raw_args : Config_YesNo, RawConfiguration, XmlConfig;

struct FileData {
    AbsolutePath filename;
    string data;
    WriteStrategy strategy;
}

/** Test double generation of C++ code.
 *
 * TODO Describe the options.
 * TODO implement --in=...
 */
class CppTestDoubleVariant : Controller, Parameters, Products {
    import std.string : toLower;
    import std.regex : regex, Regex;
    import std.typecons : Flag;
    import dsrcgen.cpp;
    import my.filter : ReFilter;
    import dextool.compilation_db : CompileCommandFilter;
    import cpptooling.type : StubPrefix, MainInterface;
    import dextool.utility;
    import cpptooling.testdouble.header_filter : TestDoubleIncludes, LocationType;

    private {
        StubPrefix prefix;

        CustomHeader custom_hdr;

        MainName main_name;
        MainNs main_ns;
        MainInterface main_if;
        Flag!"FreeFunction" do_free_funcs;
        Flag!"Gmock" gmock;
        Flag!"GtestPODPrettyPrint" gtestPP;
        Flag!"PreInclude" pre_incl;
        Flag!"PostInclude" post_incl;

        string system_compiler;

        Nullable!XmlConfig xmlConfig;
        CompileCommandFilter compiler_flag_filter;

        string[] exclude;
        string[] include;
        ReFilter fileFilter;

        /// Data produced by the generatore intented to be written to specified file.
        FileData[] file_data;

        TestDoubleIncludes td_includes;
    }

    static auto makeVariant(ref RawConfiguration args) {
        // dfmt off
        auto variant = new CppTestDoubleVariant(regex(args.stripInclude))
            .argPrefix(args.prefix)
            .argMainName(args.mainName)
            .argGenFreeFunction(args.doFreeFuncs)
            .argGmock(args.gmock)
            .argGtestPODPrettyPrint(args.gtestPODPrettyPrint)
            .argPreInclude(args.generatePreInclude)
            .argPostInclude(args.genPostInclude)
            .argForceTestDoubleIncludes(args.testDoubleInclude)
            .argFileExclude(args.fileExclude)
            .argFileInclude(args.fileInclude)
            .argCustomHeader(args.header, args.headerFile)
            .argXmlConfig(args.xmlConfig)
            .systemCompiler(args.systemCompiler);
        // dfmt on

        return variant;
    }

    /** Design of c'tor.
     *
     * The c'tor has as paramters all the required configuration data.
     * Assignment of members are used for optional configuration.
     *
     * Follows the design pattern "correct by construction".
     *
     * TODO document the parameters.
     */
    this(Regex!char strip_incl) {
        this.td_includes = TestDoubleIncludes(strip_incl);
    }

    auto argFileExclude(string[] a) {
        this.exclude = a;
        fileFilter = ReFilter(include, exclude);
        return this;
    }

    auto argFileInclude(string[] a) {
        this.include = a;
        fileFilter = ReFilter(include, exclude);
        return this;
    }

    auto argPrefix(string s) {
        this.prefix = StubPrefix(s);
        return this;
    }

    auto argMainName(string s) {
        this.main_name = MainName(s);
        this.main_ns = MainNs(s);
        this.main_if = MainInterface("I_" ~ s);
        return this;
    }

    /// Force the includes to be those supplied by the user.
    auto argForceTestDoubleIncludes(string[] a) {
        if (a.length != 0) {
            td_includes.forceIncludes(a);
        }
        return this;
    }

    auto argCustomHeader(string header, string header_file) {
        if (header.length != 0) {
            this.custom_hdr = CustomHeader(header);
        } else if (header_file.length != 0) {
            import std.file : readText;

            string content = readText(header_file);
            this.custom_hdr = CustomHeader(content);
        }

        return this;
    }

    auto argGenFreeFunction(bool a) {
        this.do_free_funcs = cast(Flag!"FreeFunction") a;
        return this;
    }

    auto argGmock(bool a) {
        this.gmock = cast(Flag!"Gmock") a;
        return this;
    }

    auto argGtestPODPrettyPrint(Config_YesNo a) {
        this.gtestPP = cast(Flag!"GtestPODPrettyPrint")(cast(bool) a);
        return this;
    }

    auto argPreInclude(bool a) {
        this.pre_incl = cast(Flag!"PreInclude") a;
        return this;
    }

    auto argPostInclude(bool a) {
        this.post_incl = cast(Flag!"PostInclude") a;
        return this;
    }

    /** Ensure that the relevant information from the xml file is extracted.
     *
     * May overwrite information from the command line.
     * TODO or should the command line have priority over the xml file?
     */
    auto argXmlConfig(Nullable!XmlConfig conf) {
        import dextool.compilation_db : defaultCompilerFlagFilter;

        if (conf.isNull) {
            compiler_flag_filter = CompileCommandFilter(defaultCompilerFlagFilter, 0);
            return this;
        }

        xmlConfig = conf;
        compiler_flag_filter = CompileCommandFilter(conf.get.filterClangFlags,
                conf.get.skipCompilerArgs);

        return this;
    }

    auto systemCompiler(string a) {
        this.system_compiler = a;
        return this;
    }

    ref CompileCommandFilter getCompileCommandFilter() {
        return compiler_flag_filter;
    }

    /// Data produced by the generatore intented to be written to specified file.
    ref FileData[] getProducedFiles() {
        return file_data;
    }

    void putFile(AbsolutePath fname, string data) {
        file_data ~= FileData(fname, data);
    }

    /// Signal that a file has finished analyzing.
    void processIncludes() {
        td_includes.process();
    }

    /// Signal that all files have been analyzed.
    void finalizeIncludes() {
        td_includes.finalize();
    }

    // -- Controller --

    bool doFile(in string filename, in string info) {
        return fileFilter.match(filename, (string s, string type) {
            logger.tracef("matcher --file-%s removed %s. Skipping", s, type);
        });
    }

    bool doGoogleMock() {
        return gmock;
    }

    bool doGoogleTestPODPrettyPrint() {
        return gtestPP;
    }

    bool doPreIncludes() {
        return pre_incl;
    }

    bool doIncludeOfPreIncludes() {
        return pre_incl;
    }

    bool doPostIncludes() {
        return post_incl;
    }

    bool doIncludeOfPostIncludes() {
        return post_incl;
    }

    bool doFreeFunction() {
        return do_free_funcs;
    }

    // -- Parameters --

    Path[] getIncludes() {
        return td_includes.includes.map!(a => Path(a)).array();
    }

    MainName getMainName() {
        return main_name;
    }

    MainNs getMainNs() {
        return main_ns;
    }

    MainInterface getMainInterface() {
        return main_if;
    }

    StubPrefix getArtifactPrefix() {
        return prefix;
    }

    DextoolVersion getToolVersion() {
        import dextool.utility : dextoolVersion;

        return dextoolVersion;
    }

    CustomHeader getCustomHeader() {
        return custom_hdr;
    }

    Compiler getSystemCompiler() const {
        return Compiler(system_compiler);
    }

    Compiler getMissingFileCompiler() const {
        if (system_compiler.empty)
            return Compiler("/usr/bin/c++");
        return getSystemCompiler();
    }

    // -- Products --

    void putFile(AbsolutePath fname, CppHModule hdr_data) {
        file_data ~= FileData(fname, hdr_data.render());
    }

    void putFile(AbsolutePath fname, CppHModule data, WriteStrategy strategy) {
        file_data ~= FileData(fname, data.render(), strategy);
    }

    void putFile(AbsolutePath fname, CppModule impl_data) {
        file_data ~= FileData(fname, impl_data.render());
    }

    void putLocation(Path fname, LocationType type) {
        td_includes.put(fname, type);
    }
}

class FrontendTransform : Transform {
    import std.path : buildPath;
    import cpptooling.type : StubPrefix;

    static const hdrExt = ".hpp";
    static const implExt = ".cpp";
    static const xmlExt = ".xml";

    StubPrefix prefix;

    Path output_dir;
    MainFileName main_fname;

    this(MainFileName main_fname, Path output_dir) {
        this.main_fname = main_fname;
        this.output_dir = output_dir;
    }

    AbsolutePath createHeaderFile(string name) {
        return AbsolutePath(Path(buildPath(output_dir, main_fname ~ name ~ hdrExt)));
    }

    AbsolutePath createImplFile(string name) {
        return AbsolutePath(Path(buildPath(output_dir, main_fname ~ name ~ implExt)));
    }

    AbsolutePath createXmlFile(string name) {
        return AbsolutePath(Path(buildPath(output_dir, main_fname ~ name ~ xmlExt)));
    }
}

ExitStatusType genCpp(CppTestDoubleVariant variant, FrontendTransform transform,
        string[] userCflags, CompileCommandDB compile_db, Path[] inFiles) {
    import dextool.clang : reduceMissingFiles;
    import dextool.compilation_db : limitOrAllRange, parse, prependFlags,
        addCompiler, replaceCompiler, addSystemIncludes, fileRange;
    import dextool.plugin.cpptestdouble.backend : Backend;
    import dextool.io : writeFileData;
    import dextool.utility : prependDefaultFlags, PreferLang;

    auto generator = Backend(variant, variant, variant, transform);

    auto compDbRange() {
        if (compile_db.empty) {
            return fileRange(inFiles, variant.getMissingFileCompiler);
        }
        return compile_db.fileRange;
    }

    auto fixedDb = compDbRange.parse(variant.getCompileCommandFilter)
        .addCompiler(variant.getMissingFileCompiler).replaceCompiler(
                variant.getSystemCompiler).addSystemIncludes.prependFlags(
                prependDefaultFlags(userCflags, PreferLang.cpp)).array;

    auto limitRange = limitOrAllRange(fixedDb, inFiles.map!(a => cast(string) a).array)
        .reduceMissingFiles(fixedDb);

    if (!compile_db.empty && !limitRange.isMissingFilesEmpty) {
        foreach (a; limitRange.missingFiles) {
            logger.error("Unable to find any compiler flags for .", a);
        }
        return ExitStatusType.Errors;
    }

    foreach (pdata; limitRange.range) {
        if (generator.analyzeFile(pdata.cmd.absoluteFile,
                pdata.flags.completeFlags) == ExitStatusType.Errors) {
            return ExitStatusType.Errors;
        }

        variant.processIncludes;
    }

    variant.finalizeIncludes;

    // All files analyzed, process and generate artifacts.
    generator.process();

    return writeFileData(variant.file_data);
}

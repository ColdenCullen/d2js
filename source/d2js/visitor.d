module d2js.visitor;

import std.d.ast;
import std.array, std.algorithm;

class JSVisitor : ASTVisitor
{
    // Add default overlaod set.
    alias visit = ASTVisitor.visit;
    // To write the resulting code to
    Appender!string result;

    override void visit( const ModuleDeclaration mod )
    {
        import std.stdio;
        writeln( "Parsing module: ", mod.moduleName.identifiers.map!( id => cast(string)id.text ).joiner( "." ) );
    }

    // Handle function declarations
    override void visit( const FunctionDeclaration func )
    {
        string funcName = func.name.text;
        bool isMain = funcName == "main";

        // Emit main function directly into text.
        if( !isMain )
        {
            assert( !func.parameters.hasVarargs, "var args currently unsupported." );
            auto paramStr = func.parameters.parameters
                            .map!( par => cast(string)par.name.text )
                            .joiner( ", " )
                            .array();

            result ~= "function "~funcName~"(";
            result ~= paramStr;
            result ~= ") // -> "~"RETURN TYPE HERE\n{\n";
        }

        visit( func.functionBody );

        if( !isMain )
        {
            result ~= "}\n";
        }
    }

    /// Save the code.
    void saveResults( string filePath )
    {
        import std.file;
        filePath.write( result.data );
    }
}

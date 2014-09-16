module d2js.visitor;
import d2js.helpers;

import std.d.ast, std.d.lexer;
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
        writeln( "Parsing module: ", mod.moduleName.identifiers.listToString!( id => cast(string)id.text )( "." ) );
    }

    // Handle tokens
    override void visit( const Token tok )
    {
        result ~= tok.text;
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
                            .listToString!( par => cast(string)par.name.text );

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

    // Handle function calls
    override void visit( const FunctionCallExpression call )
    {
        assert( !call.templateArguments, "Template args not supported." );

        visit( call.unaryExpression );
        result ~= "( ";
        foreach( arg; call.arguments.argumentList.items )
        {
            visit( arg );
        }
        result ~= " )";
    }

    /// Save the code.
    void saveResults( string filePath )
    {
        import std.file;
        filePath.write( result.data );
    }
}

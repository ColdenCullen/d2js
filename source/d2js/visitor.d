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

    // Handle module declarations.
    override void visit( const ModuleDeclaration mod )
    {
        import std.stdio;
        writeln( "Parsing module: ", mod.moduleName.identifiers.listToString!( id => cast(string)id.text )( "." ) );
    }

    // Handle imports
    override void visit( const ImportDeclaration imp )
    {
        //TODO
    }

    // Handle tokens
    override void visit( const Token tok )
    {
        result ~= tok.text;
    }

    // Handle identifiers
    override void visit( const IdentifierChain identifierChain )
    {
        foreach( i, ident; identifierChain.identifiers )
        {
            if( i > 0 ) result ~= ".";
            visit( ident );
        }
    }

    // Handle function declarations
    override void visit( const FunctionDeclaration func )
    {
        bool isMain = func.name.text == "main";

        // Emit main function directly into text.
        if( !isMain )
        {
            assert( !func.parameters.hasVarargs, "var args currently unsupported." );
            auto paramStr = func.parameters.parameters
                            .listToString!( par => cast(string)par.name.text );

            result ~= "function ";
            visit( func.name );
            result ~= "(";
            result ~= paramStr;
            result ~= ") // -> ";
            visit( func.returnType );
            result ~= "\n{\n";
        }

        //visit( func.functionBody );

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
        result ~= "(";
        foreach( arg; call.arguments.argumentList.items )
        {
            visit( arg );
        }
        result ~= ")";
        //TODO Remove
        result ~= ";\n";
    }

    /// Save the code.
    void saveResults( string filePath )
    {
        import std.file;
        result ~= "function writeln() { console.log( arguments ); }";
        filePath.write( result.data );
    }
}

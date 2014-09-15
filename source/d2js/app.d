module d2js.app;
import d2js.visitor;

import std.stdio;

int main( string[] args )
{
    import std.getopt;

    args.getopt(
        config.bundling,
    );

    if( args.length == 1 )
    {
        writeln( "No file given." );
        return 1;
    }

    foreach( fileName; args[ 1..$ ] )
    {
        compileFile( fileName );
    }

    return 0;
}

void compileFile( string fileName )
{
    import std.d.lexer, std.d.parser;
    import std.file, std.path;

    auto fileContents = cast(ubyte[])fileName.read();
    auto config = LexerConfig(
        fileName,
        StringBehavior.source,
    );
    auto cache = StringCache( StringCache.defaultBucketCount );

    auto tokens = fileContents.getTokensForParser( config, &cache );
    auto mod = tokens.parseModule( fileName );

    auto visitor = new JSVisitor();
    visitor.visit( mod );
    visitor.saveResults( fileName.setExtension( ".js" ) );
}

var traceur = require( 'traceur' ),
    fs      = require( 'fs' ),
    path    = require( 'path' );

var dSources = './source';

// Returns: result file name
function compileD( sourceFile )
{

}

// Returns compiled code
function compileJs( sourceFile )
{
    var src = "class MyClass { log() { console.log( 'Testing!' ); } } var c = new MyClass(); c.log();";
    var options = {
    };

    return traceur.compile( src, options );
}

// Executes the new code.
function executeJs( source )
{
    console.log( "Compiled:\n" + source );
    eval( source );
}

fs.readdir( dSources, function( err, files ) {
    if( err ) throw err;

    for( var fileIdx in files )
    {
        var file = path.join( dSources, files[ fileIdx ] );

        console.log( "Compiling: ", file );

        var jsFileName = compileD( file );
        var compiledJs = compileJs( jsFileName );
        executeJs( compiledJs );

        /*fs.unlink( jsFileName, function( err ) {
            if( err ) throw err;
        } );*/
    }
} );

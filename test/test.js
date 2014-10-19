var traceur = require( 'traceur' ),
    fs      = require( 'fs' ),
    path    = require( 'path' ),
    proc    = require( 'child_process' );

var dSources = './source';

// Arguments
var args = {
    // Delete JS files after test
    deleteJs: false,
    // Test output of dmd execution against js execution
    testDmd: false
};

process.argv.forEach( function( val, index ) {
    // Ignore node
    if( index === 0 ) return;

    if( val === "--delete-js" || val == "-d" )
        args.deleteJs = true;

    else if( val === "--test-dmd" || val === "-t" )
        args.testDmd = true;
} );

// Returns compiled code
function compileEs6( source )
{
    if( source === "")
        return "";

    var options = {
    };

    return traceur.compile( source, options );
}

function compile( file )
{
    // Compile D to js
    console.log( path.join( "..", "d2js" ) + " " + file );
    proc.exec( path.join( "..", "d2js" ) + " " + file, function( err, stdout, stderr ) {
        if( err ) throw err;

        // Get the path to the JS file
        var jsFile = path.join( path.dirname( file ), path.basename( file, ".d" ) ) + ".js";

        // Read the JS file
        fs.readFile( jsFile, function( err, data ) {
            if( err ) throw err;

            // Compile ES6, and evaluate
            eval( compileEs6( data.toString() ) );

            // Delete the js file
            if( args.deleteJs )
                fs.unlink( jsFile );
        } );
    } );
}

fs.readdir( dSources, function( err, files ) {
    if( err ) throw err;

    for( var fileIdx in files )
    {
        // The path to the file
        var file = path.join( dSources, files[ fileIdx ] );

        // Ignore generate js.
        if( path.extname( file ) !== ".d" )
            continue;

        compile( file );
    }
} );

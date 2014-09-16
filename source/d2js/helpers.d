module d2js.helpers;
import std.algorithm, std.array;

auto listToString( alias func, T )( T[] list, string sep = ", " )
{
    return list.map!func().joiner( sep ).array();
}

package cpp.asys;

extern class Path
{
    @:native('::hx::asys::filesystem::Path::isAbsolute')
    static function isAbsolute(path:String):Bool;

    @:native('::hx::asys::filesystem::Path::parent')
    static function parent(path:String):String;
}
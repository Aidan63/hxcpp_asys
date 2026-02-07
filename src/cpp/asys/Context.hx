package cpp.asys;

@:cpp.ManagedType({ namespace : [ "hx", "asys" ], flags : [ StandardNaming ] })
@:buildXml("<include name='${HXCPP}/src/hx/libs/asys/libuv/Build.xml'/>")
extern class Context {
    final process : CurrentProcess;

    static function boot() : Context;
    static function get() : Context;
}
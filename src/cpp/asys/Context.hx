package cpp.asys;

@:native('::hx::asys::Context')
@:buildXml("<include name='${HXCPP}/src/hx/libs/asys/libuv/Build.xml'/>")
extern class Context {
    // final process : CurrentProcess;

    @:native('::hx::asys::Context_obj::create')
    static function create() : Context;

    // function close() : Void;

    // function loop() : Bool;
}
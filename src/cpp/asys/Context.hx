package cpp.asys;

@:native('::hx::asys::Context')
@:buildXml("<include name='${HXCPP}/src/hx/libs/asys/libuv/Build.xml'/>")
extern class Context {
    @:native('::hx::asys::Context_obj::create')
    static function create() : Context;

    overload function enqueue(func : Any) : Void;
    
    overload function enqueue(func : Any, intervalMs : Int) : Any;

    function cancel(handler : Any) : Void;

    function loop() : Void;
}
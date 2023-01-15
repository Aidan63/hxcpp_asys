package cpp.asys;

import haxe.io.BytesData;
import asys.native.system.AsysError;

extern class Net
{
    @:native('::hx::asys::net::resolve')
    static function resolve(ctx : Context, host : String, cbSuccess : Array<cpp.EnumBase>->Void, cbFailure : AsysError->Void) : Void;

    @:native('::hx::asys::net::ipName')
    static overload function ipName(ip : Int) : String;

    @:native('::hx::asys::net::ipName')
    static overload function ipName(ip : BytesData) : String;
}
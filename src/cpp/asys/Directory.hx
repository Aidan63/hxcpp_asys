package cpp.asys;

import asys.native.system.AsysError;

@:native('::hx::asys::filesystem::FileAccessMode')
private extern class FileAccessMode {
    //
}

@:native('::hx::asys::filesystem::Directory')
extern class Directory {
    function next(batch : Int, cbSuccess : Array<String>->Void, cbFailure : AsysError->Void) : Void;
    function close(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::open')
    static function open(ctx : Context, path : String, onSuccess : Directory->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::create')
    static function create(ctx : Context, path : String, permissions : Int, recursive : Bool, onSuccess : Void->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::move')
    static function move(ctx : Context, oldPath : String, newPath : String, onSuccess : Void->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::check')
    static function check(ctx : Context, path : String, accessMode : FileAccessMode, onSuccess : Bool->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::deleteFile')
    static function deleteFile(ctx : Context, path : String, onSuccess : Void->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::deleteDirectory')
    static function deleteDirectory(ctx : Context, path : String, onSuccess : Void->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::isFile')
    static function isFile(ctx : Context, path : String, onSuccess : Bool->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::isDirectory')
    static function isDirectory(ctx : Context, path : String, onSuccess : Bool->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::isLink')
    static function isLink(ctx : Context, path : String, onSuccess : Bool->Void, onFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::setLinkOwner')
    static function setLinkOwner(ctx : Context, path : String, user : Int, group : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::link')
    static function link(ctx : Context, target : String, path : String, type : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::linkInfo')
    static function linkInfo(ctx : Context, path : String, cbSuccess : NativeInfo->Void, cbFailure : AsysError->Void) : Void;

    @:native('::hx::asys::filesystem::Directory_obj::readLink')
    static function readLink(ctx : Context, path : String, cbSuccess : String->Void, cbFailure : AsysError->Void) : Void;
}
package cpp.asys;

import cpp.asys.AsysError;

@:native('::hx::asys::filesystem::FileAccessMode')
private extern class FileAccessMode {
    //
}

@:cpp.ManagedType({ namespace : [ "hx", "asys", "filesystem" ], flags : [ StandardNaming ] })
extern class Directory {
    final path : String;

    function next(batch : Int, cbSuccess : Array<String>->Void, cbFailure : AsysError->Void) : Void;
    function close(cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;

    static function open(ctx : Context, path : String, onSuccess : Directory->Void, onFailure : AsysError->Void) : Void;
    static function create(ctx : Context, path : String, permissions : Int, onSuccess : Void->Void, onFailure : AsysError->Void) : Void;
    static function rename(ctx : Context, oldPath : String, newPath : String, onSuccess : Void->Void, onFailure : AsysError->Void) : Void;
    static function check(ctx : Context, path : String, accessMode : FileAccessMode, onSuccess : Bool->Void, onFailure : AsysError->Void) : Void;
    static function deleteFile(ctx : Context, path : String, onSuccess : Void->Void, onFailure : AsysError->Void) : Void;
    static function deleteDirectory(ctx : Context, path : String, onSuccess : Void->Void, onFailure : AsysError->Void) : Void;
    static function isFile(ctx : Context, path : String, onSuccess : Bool->Void, onFailure : AsysError->Void) : Void;
    static function isDirectory(ctx : Context, path : String, onSuccess : Bool->Void, onFailure : AsysError->Void) : Void;
    static function isLink(ctx : Context, path : String, onSuccess : Bool->Void, onFailure : AsysError->Void) : Void;
    static function setLinkOwner(ctx : Context, path : String, user : Int, group : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
    static function link(ctx : Context, target : String, path : String, type : Int, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
    static function linkInfo(ctx : Context, path : String, cbSuccess : NativeInfo->Void, cbFailure : AsysError->Void) : Void;
    static function readLink(ctx : Context, path : String, cbSuccess : String->Void, cbFailure : AsysError->Void) : Void;
    static function copyFile(ctx : Context, source : String, destination : String, overwrite : Bool, cbSuccess : Void->Void, cbFailure : AsysError->Void) : Void;
    static function realPath(ctx : Context, path : String, cbSuccess : String->Void, cbFailure : AsysError->Void) : Void;
}
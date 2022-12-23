package asys.native.filesystem;

import sys.thread.Thread;

class FileSystem {
    static public function openFile<T>(path:String, flag:FileOpenFlag<T>, callback:Callback<T>) {
        cpp.asys.File.open(
            @:privateAccess Thread.current().events.context,
            path,
            cast flag,
            file -> callback.success(cast @:privateAccess new File(path, file)),
            msg -> callback.fail(new FsException(msg, path)));
    }
}
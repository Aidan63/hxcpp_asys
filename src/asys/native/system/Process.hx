package asys.native.system;

import sys.thread.Thread;
import haxe.NoData;
import haxe.io.Bytes;
import asys.native.filesystem.Callback;
import haxe.exceptions.NotImplementedException;

class Process {
    public final pid:Int;

    function new(pid) {
        this.pid = pid;
    }

    static public function execute(command:String, ?options:ProcessOptions, callback:Callback<{?stdout:Bytes, ?stderr:Bytes, exitCode:Int}>) {
		throw new NotImplementedException();
	}

    static public function open(command:String, ?options:ProcessOptions, callback:Callback<ChildProcess>) {
		cpp.asys.Process.open(
            @:privateAccess Thread.current().events.context,
            command,
            options,
            proc -> callback.success(@:privateAccess new ChildProcess(proc)),
            msg -> callback.fail(new IoException(msg)));
	}

    public function sendSignal(signal:Signal, callback:Callback<NoData>) {
		throw new NotImplementedException();
	}
}
package asys.native.system;

import haxe.exceptions.ArgumentException;
import haxe.ds.ReadOnlyArray;
import sys.thread.Thread;
import haxe.NoData;
import haxe.io.Bytes;
import haxe.Callback;
import haxe.exceptions.NotImplementedException;

class Process {
    /**
		Current process handle.
		Can be used to communicate with the parent process and for self-signalling.
	**/
	static public var current(get,never):CurrentProcess;
	static function get_current():CurrentProcess return @:privateAccess new CurrentProcess(Thread.current().context().process);

    public final pid:Int;

    /**
		Initial IO streams opened for this process.
		The first three indices always are:
		- 0 - stdin
		- 1 - stdout
		- 2 - stderr
		Indices from 3 and higher contain handlers for streams created as configured
		by the corresponding indices in `options.stdio` field of `options` argument
		for `asys.native.system.Process.open` call.
		@see asys.native.system.ProcessOptions.stdio
	**/
	public var stdio(get,never):ReadOnlyArray<Stream>;
	function get_stdio():ReadOnlyArray<Stream> throw new NotImplementedException();

    function new(pid) {
        this.pid = pid;
    }

    static public function execute(command:String, ?options:ProcessOptions, callback:Callback<{?stdout:Bytes, ?stderr:Bytes, exitCode:Int}>) {
		throw new NotImplementedException();
	}

    static public function open(command:String, ?options:ProcessOptions, callback:Callback<ChildProcess>) {
        if (callback == null) {
            throw new ArgumentException("callback", "callback was null");
        }

        if (command == null) {
            callback.fail(new ArgumentException("command", "command was null"));

            return;
        }

		cpp.asys.Process.open(
            @:privateAccess Thread.current().context(),
            command,
            toSensibleOptions(options),
            proc -> callback.success(@:privateAccess new ChildProcess(proc)),
            msg -> callback.fail(new IoException(msg)));
	}

    public function sendSignal(signal:Signal, callback:Callback<NoData>) {
		throw new NotImplementedException();
	}

    private static function toSensibleOptions(input:ProcessOptions) {
        if (input == null) {
            return null;
        }

        return {
            args : input.args,
            cwd : input.cwd,
            env : input.env,
            user : input.user,
            group : input.group,
            detached : input.detached,
            stdio : {
                stdin : makeStdin(input.stdio),
                stdout : makeStdout(input.stdio),
                stderr : makeStderr(input.stdio),
                extra : makeExtra(input.stdio)
            }
        }
    }

    static function makeExtra(arg:Null<Array<StdioConfig>>) {
        if (arg == null || arg.length < 4) {
            return [];
        }

        return [ for (i in 3...arg.length - 1) arg[i] ];
    }

    static function makeStderr(arg:Null<Array<StdioConfig>>) {
        if (arg == null || arg.length < 3 || arg[2] == null) {
            return StdioConfig.PipeWrite;
        }

        return arg[2];
    }

    static function makeStdout(arg:Null<Array<StdioConfig>>) {
        if (arg == null || arg.length < 2 || arg[1] == null) {
            return StdioConfig.PipeWrite;
        }

        return arg[1];
    }

    static function makeStdin(arg:Null<Array<StdioConfig>>) {
        if (arg == null || arg.length < 1 || arg[0] == null) {
            return StdioConfig.PipeRead;
        }

        return arg[0];
    }
}
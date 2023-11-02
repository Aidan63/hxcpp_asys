package asys.native.system;

import sys.thread.Thread;
import haxe.NoData;
import haxe.io.Bytes;
import asys.native.filesystem.Callback;
import haxe.exceptions.NotImplementedException;

class Process {
    /**
		Current process handle.
		Can be used to communicate with the parent process and for self-signalling.
	**/
	static public var current(get,never):CurrentProcess;
	static function get_current():CurrentProcess return @:privateAccess new CurrentProcess(cpp.asys.Process.current());

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
        if (arg == null || arg.length < 3) {
            return StdioConfig.PipeWrite;
        }

        return arg[2];
    }

    static function makeStdout(arg:Null<Array<StdioConfig>>) {
        if (arg == null || arg.length < 2) {
            return StdioConfig.PipeWrite;
        }

        return arg[1];
    }

    static function makeStdin(arg:Null<Array<StdioConfig>>) {
        if (arg == null || arg.length < 1) {
            return StdioConfig.PipeWrite;
        }

        return arg[0];
    }

    static function mapStdioConfig(arg:StdioConfig) {
        return switch arg {
            case PipeRead:
                //
            case PipeWrite:
                //
            case PipeReadWrite:
                //
            case Inherit:
                //
            case Ignore:
                //
            case File(path, flags):
                //
            case OpenedFile(file):
                //
        }
    }
}
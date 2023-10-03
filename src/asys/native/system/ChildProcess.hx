package asys.native.system;

import haxe.NoData;
import haxe.exceptions.NotImplementedException;
import asys.native.net.Callback;

/**
	Additional API for child processes spawned by the current process.
	@see asys.native.system.Process.open
**/
class ChildProcess extends Process {
	final native : cpp.Pointer<cpp.asys.ChildProcess>;

    function new(native:cpp.Pointer<cpp.asys.ChildProcess>) {
		super(native.ptr.pid());

        this.native = native;
    }

	/**
		A stream used by the process as standard input.
	**/
	public var stdin(get,never):IWritable;
	function get_stdin():IWritable throw new NotImplementedException();

	/**
		A stream used by the process as standard output.
	**/
	public var stdout(get,never):IReadable;
	function get_stdout():IReadable throw new NotImplementedException();

	/**
		A stream used by the process as standard error output.
	**/
	public var stderr(get,never):IReadable;
	function get_stderr():IReadable throw new NotImplementedException();

	/**
		Wait the process to shutdown and get the exit code.
		If the process is already dead at the moment of this call, then `callback`
		may be invoked with the exit code immediately.
	**/
	public function exitCode(callback:Callback<Int>) {
		native.ptr.exitCode(
			callback.success,
			msg -> callback.fail(new IoException(msg)));
	}

	/**
		Close the process handle and release associated resources.
		TODO: should this method wait for the process to finish?
	**/
	public function close(callback:Callback<NoData>) {
		native.ptr.close(
			() -> {
				callback.success(null);

				native.destroy();
			},
			msg -> callback.fail(new IoException(msg)));
	}
}
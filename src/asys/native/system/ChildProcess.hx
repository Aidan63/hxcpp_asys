package asys.native.system;

import cpp.asys.Writable;
import cpp.asys.Readable;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.ds.ReadOnlyArray;
import haxe.NoData;
import haxe.Callback;

private class ReadableWrapper implements IReadable {
	final native : Readable;

	public function new(native) {
		this.native = native;
	}

	public function read(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int, Exception>) {
		native.read(
			buffer.getData(),
			offset,
			length,
			callback.success,
			msg -> callback.fail(new IoException(msg)));
	}

	public function close(callback:Callback<NoData, Exception>) {
		callback.success(null);
	}
}

private class WritableWrapper implements IWritable {
	final native : Writable;

	public function new(native) {
		this.native = native;
	}

	public function write(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int, Exception>) {
		native.write(
			buffer.getData(),
			offset,
			length,
			callback.success, 
			msg -> callback.fail(new IoException(msg)));
	}

	public function flush(callback:Callback<NoData>) {
		native.flush(
			() -> callback.success(null),
			msg -> callback.fail(new IoException(msg)));
	}

	public function close(callback:Callback<NoData>) {
		callback.success(null);
	}
}

/**
	Additional API for child processes spawned by the current process.
	@see asys.native.system.Process.open
**/
class ChildProcess extends Process {
	final native : cpp.asys.ChildProcess;

	final stdinReader : WritableWrapper;

	final stdoutReader : ReadableWrapper;

	final stderrReader : ReadableWrapper;

    function new(native:cpp.asys.ChildProcess) {
		super(native.pid());

        this.native  = native;
		stdinReader  = new WritableWrapper(this.native.stdio_in);
		stdoutReader = new ReadableWrapper(this.native.stdio_out);
		stderrReader = new ReadableWrapper(this.native.stdio_err);
    }

	/**
		A stream used by the process as standard input.
	**/
	public var stdin(get,never):IWritable;
	function get_stdin():IWritable return stdinReader;

	/**
		A stream used by the process as standard output.
	**/
	public var stdout(get,never):IReadable;
	function get_stdout():IReadable return stdoutReader;

	/**
		A stream used by the process as standard error output.
	**/
	public var stderr(get,never):IReadable;
	function get_stderr():IReadable return stderrReader;

	override function sendSignal(signal:Signal, callback:Callback<NoData>) {
		native.sendSignal(
			cast signal,
			() -> callback.success(null),
			msg -> callback.fail(new IoException(msg)));
	}

	/**
		Wait the process to shutdown and get the exit code.
		If the process is already dead at the moment of this call, then `callback`
		may be invoked with the exit code immediately.
	**/
	public function exitCode(callback:Callback<Int>) {
		native.exitCode(
			callback.success,
			msg -> callback.fail(new IoException(msg)));
	}

	/**
		Close the process handle and release associated resources.
		TODO: should this method wait for the process to finish?
	**/
	public function close(callback:Callback<NoData>) {
		native.close(
			() -> callback.success(null),
			msg -> callback.fail(new IoException(msg)));
	}

	override function get_stdio():ReadOnlyArray<Stream> {
		return [
			Write(stdin),
			Read(stdout),
			Read(stderr)
		];
	}
}
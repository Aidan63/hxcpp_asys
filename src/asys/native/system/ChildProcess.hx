package asys.native.system;

import cpp.asys.Writable;
import cpp.asys.Readable;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.ds.ReadOnlyArray;
import haxe.NoData;
import haxe.Callback;
import haxe.coro.schedulers.Scheduler;
import haxe.exceptions.ArgumentException;

using hxcoro.util.Convenience;

private class Reader implements IReadable {
	final native : Readable;

	public function new(native:Readable) {
		this.native = native;
	}

	@:coroutine public function read(buffer:Bytes, offset:Int, length:Int):Int {
		if (offset < 0) {
			throw new ArgumentException("offset", "offset was less than zero");
		}

		if (offset > buffer.length) {
			throw new ArgumentException("offset", "offset was greater than the buffer length");
		}

		if (length < 0) {
			throw new ArgumentException("length", "length was less than zero");
		}

		if (offset + length > buffer.length) {
			throw new Exception("invalid buffer range");
		}

		return
			hxcoro.Coro.suspend(cont -> {
				native.read(
					buffer.getData(),
					offset,
					length,
					cont.succeedAsync,
					msg -> cont.context.get(Scheduler).schedule(0,() -> cont.resume(0, new IoException(msg))));
			});
	}

	@:coroutine public function close() {
		return;
	}
}

private class Writer implements IWritable {
	final native : Writable;

	public function new(native:Writable) {
		this.native = native;
	}

	@:coroutine public function write(buffer:Bytes, offset:Int, length:Int):Int {
		if (buffer == null) {
			throw new ArgumentException("buffer", "buffer was null");
		}

		if (offset < 0) {
			throw new ArgumentException("offset", "offset was less than zero");
		}

		if (offset > buffer.length) {
			throw new ArgumentException("offset", "offset was greater than the buffer length");
		}

		if (length < 0) {
			throw new ArgumentException("length", "length was less than zero");
		}

		if (offset + length > buffer.length) {
			throw new Exception("invalid buffer range");
		}

		return
			hxcoro.Coro.suspend(cont -> {
				native.write(
					buffer.getData(),
					offset,
					length,
					cont.succeedAsync,
					msg -> cont.context.get(Scheduler).schedule(0,() -> cont.resume(0, new IoException(msg))));
			});
	}

	@:coroutine public function flush() {
		hxcoro.Coro.suspend(cont -> {
			native.flush(
				() -> cont.succeedAsync(null),
				msg -> cont.failAsync(new IoException(msg)));
		});
	}

	@:coroutine public function close() {
		return;
	}
}

/**
	Additional API for child processes spawned by the current process.
	@see asys.native.system.Process.open
**/
class ChildProcess extends Process {
	final native : cpp.asys.ChildProcess;

	final stdinReader : Writer;

	final stdoutReader : Reader;

	final stderrReader : Reader;

    function new(native:cpp.asys.ChildProcess) {
		super(native.pid());

        this.native  = native;
		stdinReader  = new Writer(this.native.stdio_in);
		stdoutReader = new Reader(this.native.stdio_out);
		stderrReader = new Reader(this.native.stdio_err);
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

	// override function sendSignal(signal:Signal, callback:Callback<NoData>) {
	// 	native.sendSignal(
	// 		cast signal,
	// 		() -> callback.success(null),
	// 		msg -> callback.fail(new IoException(msg)));
	// }

	// /**
	// 	Wait the process to shutdown and get the exit code.
	// 	If the process is already dead at the moment of this call, then `callback`
	// 	may be invoked with the exit code immediately.
	// **/
	// public function exitCode(callback:Callback<Int>) {
	// 	native.exitCode(
	// 		callback.success,
	// 		msg -> callback.fail(new IoException(msg)));
	// }

	// /**
	// 	Close the process handle and release associated resources.
	// 	TODO: should this method wait for the process to finish?
	// **/
	// public function close(callback:Callback<NoData>) {
	// 	native.close(
	// 		() -> callback.success(null),
	// 		msg -> callback.fail(new IoException(msg)));
	// }

	override function get_stdio():ReadOnlyArray<Stream> {
		return [
			Write(stdin),
			Read(stdout),
			Read(stderr)
		];
	}
}
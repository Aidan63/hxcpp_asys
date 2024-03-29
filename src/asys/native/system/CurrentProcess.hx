package asys.native.system;

import haxe.exceptions.ArgumentException;
import haxe.Exception;
import sys.thread.Thread;
import cpp.asys.Writable;
import cpp.asys.Readable;
import haxe.io.Bytes;
import haxe.ds.ReadOnlyArray;
import haxe.NoData;
import haxe.Callback;

private class Reader implements IReadable {
	final native : Readable;

	public function new(native:Readable) {
		this.native = native;
	}

	public function read(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>) {
		native.read(
			buffer.getData(),
			offset,
			length,
			callback.success,
			error -> callback.fail(new IoException(error.toIoErrorType())));
	}

	public function close(callback:Callback<NoData>) {
		native.close(
			() -> callback.success(null),
			error -> callback.fail(new IoException(error.toIoErrorType())));
	}
}

private class Writer implements IWritable {
	final native : Writable;

	public function new(native:Writable) {
		this.native = native;
	}

	public function write(buffer:Bytes, offset:Int, length:Int, callback:Callback<Int>) {
		if (callback == null) {
			throw new ArgumentException("callback", "Callback was null.");
		}

		if (buffer == null) {
			callback.fail(new ArgumentException("buffer", "Buffer was null."));

			return;
		}

		if (offset < 0) {
			callback.fail(new ArgumentException("offset", "Buffer offset less than zero."));

			return;
		}

		if (length < 0) {
			callback.fail(new ArgumentException("length", "Buffer length less than zero."));

			return;
		}

		if (offset > buffer.length) {
			callback.fail(new ArgumentException("offset", "Buffer offset greater than the buffer length."));

			return;
		}

		if (offset + length > buffer.length) {
			callback.fail(new ArgumentException("length", "Buffer range exceeds the maximum buffer length."));

			return;
		}

		native.write(
			buffer.getData(),
			offset,
			length,
			callback.success,
			error -> callback.fail(new IoException(error.toIoErrorType())));
	}

	public function flush(callback:Callback<NoData>) {
		native.flush(
			() -> callback.success(null),
			error -> callback.fail(new IoException(error.toIoErrorType())));
	}

	public function close(callback:Callback<NoData>) {
		native.close(
			() -> callback.success(null),
			error -> callback.fail(new IoException(error.toIoErrorType())));
	}
}

/**
	Additional API for the current process.
	@see asys.native.system.Process.current
**/
class CurrentProcess extends Process {
	final native : cpp.asys.CurrentProcess;

	function new(_native : cpp.asys.CurrentProcess) {
		super(_native.pid());
		
		native = _native;
	}

	/**
		A stream used by the process as standard input.
	**/
	public var stdin(get,never):IReadable;
	function get_stdin():IReadable return new Reader(@:privateAccess Thread.current().context().process.stdio_in);

	/**
		A stream used by the process as standard output.
	**/
	public var stdout(get,never):IWritable;
	function get_stdout():IWritable return new Writer(@:privateAccess Thread.current().context().process.stdio_out);

	/**
		A stream used by the process as standard error output.
	**/
	public var stderr(get,never):IWritable;
	function get_stderr():IWritable return new Writer(@:privateAccess Thread.current().context().process.stdio_err);

	/**
		Set the action taken by the process on receipt of a `signal`.
		Possible `action` values:
		- `Ignore` - ignore the signal;
		- `Default` - restore default action;
		- `Handle(handler:() -> Void)` - execute `handler` on `signal` receipt.
		Actions for `Kill` and `Stop` signals cannot be changed.
	**/
	public function setSignalAction(signal:Signal, action:SignalAction):Void {
		if (signal == null) {
			throw new ArgumentException("signal", "signal was null");
		}

		if (action == null) {
			throw new ArgumentException("action", "action was null");
		}

		native.setSignalAction(cast signal, cast action);
	}

	override function sendSignal(signal:Signal, callback:Callback<NoData>) {
		if (signal == null) {
			throw new ArgumentException("signal", "signal was null");
		}

		if (callback == null) {
			throw new ArgumentException("callback", "callback was null");
		}

		native.sendSignal(
			cast signal,
			() -> callback.success(null),
			msg -> callback.fail(new IoException(msg)));
	}

	override function get_stdio():ReadOnlyArray<Stream> {
		return [
			Read(stdin),
			Write(stdout),
			Write(stderr)
		];
	}
}
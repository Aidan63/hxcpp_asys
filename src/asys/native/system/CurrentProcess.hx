package asys.native.system;

import haxe.exceptions.ArgumentException;
import haxe.Exception;
import cpp.asys.Writable;
import cpp.asys.Readable;
import haxe.io.Bytes;
import haxe.ds.ReadOnlyArray;
import haxe.coro.schedulers.Scheduler;

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
	Additional API for the current process.
	@see asys.native.system.Process.current
**/
class CurrentProcess extends Process {
	final native : cpp.asys.CurrentProcess;

	function new(_native : cpp.asys.CurrentProcess) {
		super(_native.pid());
		
		native = _native;
		stdin  = new Reader(cpp.asys.Context.get().process.stdio_in);
		stdout = new Writer(cpp.asys.Context.get().process.stdio_out);
		stderr = new Writer(cpp.asys.Context.get().process.stdio_err);
	}

	/**
		A stream used by the process as standard input.
	**/
	public var stdin(default,null):IReadable;

	/**
		A stream used by the process as standard output.
	**/
	public var stdout(default,null):IWritable;

	/**
		A stream used by the process as standard error output.
	**/
	public var stderr(default,null):IWritable;

	// /**
	// 	Set the action taken by the process on receipt of a `signal`.
	// 	Possible `action` values:
	// 	- `Ignore` - ignore the signal;
	// 	- `Default` - restore default action;
	// 	- `Handle(handler:() -> Void)` - execute `handler` on `signal` receipt.
	// 	Actions for `Kill` and `Stop` signals cannot be changed.
	// **/
	// public function setSignalAction(signal:Signal, action:SignalAction):Void {
	// 	if (signal == null) {
	// 		throw new ArgumentException("signal", "signal was null");
	// 	}

	// 	if (action == null) {
	// 		throw new ArgumentException("action", "action was null");
	// 	}

	// 	native.setSignalAction(cast signal, cast action);
	// }

	// override function sendSignal(signal:Signal, callback:Callback<NoData>) {
	// 	if (signal == null) {
	// 		throw new ArgumentException("signal", "signal was null");
	// 	}

	// 	if (callback == null) {
	// 		throw new ArgumentException("callback", "callback was null");
	// 	}

	// 	native.sendSignal(
	// 		cast signal,
	// 		() -> callback.success(null),
	// 		msg -> callback.fail(new IoException(msg)));
	// }

	override function get_stdio():ReadOnlyArray<Stream> {
		return [
			Read(stdin),
			Write(stdout),
			Write(stderr)
		];
	}
}
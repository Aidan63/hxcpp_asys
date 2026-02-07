package asys.native.system;

import haxe.exceptions.ArgumentException;
import haxe.Exception;
import cpp.asys.Writable;
import cpp.asys.Readable;
import haxe.io.Bytes;
import haxe.ds.ReadOnlyArray;

using hxcoro.util.Convenience;

private class Reader implements IReadable {
	public function new() {}

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
				cont.context
					.get(Asys)
					.ctx
					.process
					.stdio_in
					.read(
						buffer.getData(),
						offset,
						length,
						cont.succeedAsync,
						msg -> cont.context.scheduleFunction(0, () -> cont.resume(0, new IoException(msg))));
			});
	}

	@:coroutine public function close() {
		return;
	}
}

private class Writer implements IWritable {
	final selector : (cpp.asys.CurrentProcess)->Writable;

	public function new(selector:(cpp.asys.CurrentProcess)->Writable) {
		this.selector = selector;
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
				selector(cont.context.get(Asys).ctx.process).write(
					buffer.getData(),
					offset,
					length,
					cont.succeedAsync,
					msg -> cont.context.scheduleFunction(0, () -> cont.resume(0, new IoException(msg))));
			});
	}

	@:coroutine public function flush() {
		hxcoro.Coro.suspend(cont -> {
			selector(cont.context.get(Asys).ctx.process).flush(
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
	function new() {
		super(0);
		
		stdin  = new Reader();
		stdout = new Writer(ctx -> ctx.stdio_out);
		stderr = new Writer(ctx -> ctx.stdio_err);
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
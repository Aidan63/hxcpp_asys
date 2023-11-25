package asys.native.system;

import haxe.ds.ReadOnlyArray;
import cpp.asys.Writable.WritableWrapper;
import cpp.asys.Readable.ReadableWrapper;
import haxe.NoData;
import haxe.exceptions.NotImplementedException;

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
	function get_stdin():IReadable return new ReadableWrapper(native.stdio_in);

	/**
		A stream used by the process as standard output.
	**/
	public var stdout(get,never):IWritable;
	function get_stdout():IWritable return new WritableWrapper(native.stdio_out);

	/**
		A stream used by the process as standard error output.
	**/
	public var stderr(get,never):IWritable;
	function get_stderr():IWritable return new WritableWrapper(native.stdio_err);

	/**
		Set the action taken by the process on receipt of a `signal`.
		Possible `action` values:
		- `Ignore` - ignore the signal;
		- `Default` - restore default action;
		- `Handle(handler:() -> Void)` - execute `handler` on `signal` receipt.
		Actions for `Kill` and `Stop` signals cannot be changed.
	**/
	public function setSignalAction(signal:Signal, action:SignalAction):Void {
		native.setSignalAction(cast signal, cast action);
	}

	override function sendSignal(signal:Signal, callback:asys.native.filesystem.Callback<NoData>) {
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
package asys.native;

import haxe.NoData;
import haxe.Callback;
import haxe.io.Bytes;

/**
	An interface to write bytes into an out-going stream of bytes.
**/
interface IWritable {
	/**
		Write up to `length` bytes from `buffer` (starting from buffer `offset`),
		then invoke `callback` with the amount of bytes written.
	**/
	@:coroutine function write(buffer:Bytes, offset:Int, length:Int):Int;

	/**
		Force all buffered data to be committed.
	**/
	@:coroutine function flush():Void;

	/**
		Close this stream.
	**/
	@:coroutine function close():Void;
}
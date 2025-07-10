package asys.native;

import haxe.NoData;
import haxe.Callback;
import haxe.io.Bytes;

/**
	An interface to read bytes from a source of bytes.
**/
interface IReadable {
	/**
		Read up to `length` bytes and write them into `buffer` starting from `offset`
		position in `buffer`, then invoke `callback` with the amount of bytes read.
	**/
	@:coroutine function read(buffer:Bytes, offset:Int, length:Int):Int;

	/**
		Close this stream.
	**/
	@:coroutine function close():Void;
}
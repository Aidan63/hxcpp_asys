package haxe;

typedef CallbackHandler<R, E=Exception> = (result:R, error:Null<E>) -> Void;

/**
	A callback.
	All callbacks in the standard library are functions which accept
	two arguments: an error (`haxe.Exception`) and a result (`T`).
	Non-null `error` means an operation failed to finish successfully.
	In case of failure the value of the second argument has no meaning and should
	not be used.
	The underlying function type is declared in `haxe.CallbackHandler`.
**/
abstract Callback<R, E=Exception>(CallbackHandler<R, E>) from CallbackHandler<R, E> {
	/**
		This method may be used instead of allocating an anonymous function to ignore
		the outcome of an operation.
	**/
	static public function ignore<E,R>(result:R, ?e:Null<E>):Void {}

	/**
		Create a callback, which ignores the result of an operation.
		TODO: type inference does not work for arguments of `fn` if `fromNoResult` is
		used through an implicit cast. Submit compiler issue.
	**/
	// @:from static public inline function ignoreResult<E,R>(fn:(error:Null<E>) -> Void):Callback<E,R> {
	// 	return (e:Null<E>, r:Null<R>) -> fn(e);
	// }

	/**
		Report a failure.
	**/
	public function fail(error:E):Void {
		this(@:nullSafety(Off) (null:R), error);
	}

	/**
		Emit the result of a successful operation.
	**/
	public inline function success(result:R):Void {
		this(result, null);
	}
}
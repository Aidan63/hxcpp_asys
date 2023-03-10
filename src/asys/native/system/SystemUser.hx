package asys.native.system;

private typedef NativeUser = Int;

/**
	Represents an OS user account.
**/
abstract SystemUser(NativeUser) from NativeUser to NativeUser {

	public inline function toString():String {
		return '$this';
	}
}
package asys.native;

/**
	An interface to read and write bytes.
	If a class has to implement both `IReadable` and `IWritable` it is strongly
	recommended to implement `IDuplex` instead.
**/
interface IDuplex extends IReadable extends IWritable {}
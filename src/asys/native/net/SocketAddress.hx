package asys.native.net;

enum SocketAddress {
	/**
		A network address.
		`host` can be either a host name or IPv4 or IPv6 address.
	**/
	Net(host:String, port:Int);
	/**
		An address in the file system for Inter-Process Communications.
	*/
	Ipc(path:String);
}
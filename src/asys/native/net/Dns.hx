package asys.native.net;

import haxe.exceptions.ArgumentException;
import sys.thread.Thread;
import haxe.Exception;
import haxe.Callback;
import haxe.io.Bytes;

using Lambda;

/**
	Methods related to Domain Name System.
**/
class Dns {
	/**
		Lookup the given `host` name.
	**/
	static public function resolve(host:String, callback:Callback<Array<Ip>>) {
		if (callback == null) {
			throw new ArgumentException("callback", "argument was null");
		}

		if (host == null) {
			callback.fail(new ArgumentException("host", "argument was null"));

			return;
		}

		cpp.asys.Net.resolve(
            @:privateAccess Thread.current().context(),
            host,
            ips -> callback.success(ips.map(convertIp)),
            msg -> callback.fail(new IoException(msg.toIoErrorType())));
	}

	/**
		Find host names associated with the given IP address.
	**/
	static public function reverse(ip:Ip, callback:Callback<Array<String>>) {
		if (callback == null) {
			throw new ArgumentException("callback", "argument was null");
		}

		switch ip {
			case null:
				callback.fail(new ArgumentException("ip", "argument was null"));
			case Ipv4(raw):
				cpp.asys.Net.reverse(
					@:privateAccess Thread.current().context(),
					raw,
					host -> callback.success([ host ]),
					msg -> callback.fail(new IoException(msg.toIoErrorType())));
			case Ipv6(raw):
				cpp.asys.Net.reverse(
					@:privateAccess Thread.current().context(),
					raw.getData(),
					host -> callback.success([ host ]),
					msg -> callback.fail(new IoException(msg.toIoErrorType())));
		}
	}

	static function convertIp(ip:cpp.EnumBase):Ip {
		return switch ip.getIndex() {
			case 0:
				Ip.Ipv4(ip.getParamI(0));
			case 1:
				Ip.Ipv6(Bytes.ofData(ip.getParamI(0)));
			default:
				throw new Exception('Unexpected enum index');
		}
	}
}
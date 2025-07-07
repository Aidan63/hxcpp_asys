package asys.native.net;

import haxe.exceptions.ArgumentException;
import sys.thread.Thread;
import haxe.Exception;
import haxe.Callback;
import haxe.io.Bytes;

using Lambda;
using hxcoro.util.Convenience;

/**
	Methods related to Domain Name System.
**/
class Dns {
	/**
		Lookup the given `host` name.
	**/
	@:coroutine static public function resolve(host:String):Array<Ip> {
		if (host == null) {
			throw new ArgumentException("host", "argument was null");
		}

		final ips = hxcoro.Coro.suspend(cont -> {
			cpp.asys.Net.resolve(
				cpp.asys.Context.get(),
				host,
				ips -> cont.succeedAsync(ips),
				msg -> cont.failAsync(new IoException(msg.toIoErrorType())));
		});

		return ips.map(convertIp);
	}

	/**
		Find host names associated with the given IP address.
	**/
	@:coroutine static public function reverse(ip:Ip):Array<String> {
		switch ip {
			case null:
				throw new ArgumentException("ip", "argument was null");
			case Ipv4(raw):
				return
					hxcoro.Coro.suspend(cont -> {
						cpp.asys.Net.reverse(
							cpp.asys.Context.get(),
							raw,
							host -> cont.succeedAsync([ host ]),
							msg -> cont.failAsync(new IoException(msg.toIoErrorType())));
					});
			case Ipv6(raw):
				return
					hxcoro.Coro.suspend(cont -> {
						cpp.asys.Net.reverse(
							cpp.asys.Context.get(),
							raw.getData(),
							host -> cont.succeedAsync([ host ]),
							msg -> cont.failAsync(new IoException(msg.toIoErrorType())));
					});
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
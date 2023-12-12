package asys.native.net;

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
		cpp.asys.Net.resolve(
            @:privateAccess Thread.current().events.context,
            host,
            ips -> callback.success(ips.map(convertIp)),
            msg -> callback.fail(new Exception('')));
	}

	/**
		Find host names associated with the given IP address.
	**/
	static public function reverse(ip:Ip, callback:Callback<Array<String>>) {
		switch ip {
			case Ipv4(raw):
				cpp.asys.Net.reverse(
					@:privateAccess Thread.current().events.context,
					raw,
					host -> callback.success([ host ]),
					msg -> callback.fail(new Exception('')));
			case Ipv6(raw):
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
package asys.native.net;

import haxe.Exception;
import haxe.io.Bytes;

using Lambda;

/**
	Represents a resolved IP address.
**/
@:using(asys.native.net.Ip.IpTools)
enum Ip {
	/**
		32-bit IPv4 address. As an example, the IP address `127.0.0.1` is
		represented as `Ipv4(0x7F000001)`.
	**/
	Ipv4(raw:Int);

	/**
		128-bit IPv6 address.
	**/
	Ipv6(raw:Bytes);
}

class IpTools {
	/**
		String representation of `ip`.
		Examples:
		- IPv4: "192.168.0.1"
		- IPv6: "::ffff:c0a8:1"
	**/
	static public function toString(ip:Ip):String {
		return switch ip {
			case Ipv4(raw):
				cpp.asys.Net.ipName(raw);
			case Ipv6(raw):
				cpp.asys.Net.ipName(raw.getData());
		}
	}

	/**
		String representation of `ip`.
		Examples:
		- IPv4: "192.168.0.1"
		- IPv6: "0000:0000:0000:0000:0000:ffff:c0a8:1"
	**/
	static public function toFullString(ip:Ip):String {
		return switch ip {
			case Ipv4(raw):
				cpp.asys.Net.ipName(raw);
			case Ipv6(raw):
				cpp.asys.Net.ipName(raw.getData());
		}
	}

	/**
		Parse a string representation of an IP address.
		Throws an exception if provided string does not represent a valid IP address.
	**/
	static public function parseIp(ip:String):Ip {
		return switch cpp.asys.Net.parse(ip) {
			case null:
				throw new Exception('Unable to parse address');
			case parsed:
				switch parsed.getIndex() {
					case 0:
						Ip.Ipv4(parsed.getParamI(0));
					case 1:
						Ip.Ipv6(Bytes.ofData(parsed.getParamI(0)));
					case _:
						throw new Exception('Unable to parse address');
				}
		}
	}

	/**
		Check if `str` contains a valid IPv6 or IPv4 address.
	**/
	static public function isIp(str:String):Bool {
		return cpp.asys.Net.parse(str) != null;
	}

	/**
		Check if `str` contains a valid IPv4 address.
	**/
	static public function isIpv4(str:String):Bool {
		return switch cpp.asys.Net.parse(str) {
			case null:
				false;
			case parsed:
				parsed.getIndex() == 0;
		}
	}

	/**
		Check if `str` contains a valid IPv6 address.
	**/
	static public function isIpv6(str:String):Bool {
		return switch cpp.asys.Net.parse(str) {
			case null:
				false;
			case parsed:
				parsed.getIndex() == 1;
		}
	}

	/**
		Convert any IP address to IPv6 format.
	**/
	static public function toIpv6(ip:Ip):Ip {
		return switch ip {
			case Ipv4(_):
				final name = ip.toFullString();
				final str  = '2002::$name';

				if (IpTools.isIpv6(str)) {
					return IpTools.parseIp(str);
				} else {
					throw new Exception('Unable to convert from ipv4 address to ipv6');
				}
			case Ipv6(_):
				ip;
		}
	}

	/**
		Check if `a` and `b` contain the same IP address.
	**/
	static public function equals(a:Ip, b:Ip):Bool {
		return switch a {
			case Ipv4(v4a):
				switch b {
					case Ipv4(v4b):
						v4a == v4b;
					case Ipv6(_):
						equals(a.toIpv6(), b);
				}
			case Ipv6(v6a):
				switch b {
					case Ipv4(_):
						equals(a.toIpv6(), b);
					case Ipv6(v6b):
						v6a.compare(v6b) == 0;
				}
		}
	}
}
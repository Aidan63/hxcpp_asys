package net;

import haxe.exceptions.ArgumentException;
import haxe.io.Bytes;
import utest.Assert;
import asys.native.net.Dns;
import utest.Async;
import utest.Test;

class DnsTests extends Test {
    function test_resolve_ip(async:Async) {
        Dns.resolve("localhost", (result, error) -> {
            if (Assert.isNull(error)) {
                if (Assert.notNull(result)) {
                    for (ip in result) {
                        switch ip {
                            case Ipv4(raw):
                                Assert.equals(new sys.net.Host("localhost").ip, raw);
                            case Ipv6(raw):
                                Assert.equals(0, Bytes.ofData([ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ]).compare(raw));
                        }
                    }

                    Assert.isTrue(result.length > 0);
                }
            }

            async.done();
        });
    }

    function test_resolve_null_string(async:Async) {
        Dns.resolve(null, (result, error) -> {
            if (Assert.notNull(error) && Assert.isOfType(error, ArgumentException)) {
                Assert.equals("host", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_resolve_null_callback() {
        Assert.raises(() -> Dns.resolve("localhost", null), ArgumentException);
    }

    function test_reverse_ipv4(async:Async) {
        final src = new sys.net.Host("localhost");

        Dns.reverse(Ipv4(src.ip), (result, error) -> {
            Assert.contains(src.reverse(), result);

            async.done();
        });
    }

    function test_reverse_ipv6(async:Async) {
        final src  = new sys.net.Host("localhost");
        final ipv6 = Bytes.ofData([ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ]);

        Dns.reverse(Ipv6(ipv6), (result, error) -> {
            Assert.contains(src.reverse(), result);

            async.done();
        });
    }

    function test_reverse_null_ip(async:Async) {
        Dns.reverse(null, (result, error) -> {
            if (Assert.notNull(error) && Assert.isOfType(error, ArgumentException)) {
                Assert.equals("ip", (cast error : ArgumentException).argument);
            }

            async.done();
        });
    }

    function test_reverse_null_callback() {
        Assert.raises(() -> Dns.reverse(Ipv4(0), null), ArgumentException);
    }
}
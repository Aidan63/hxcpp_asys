package net;

import haxe.io.Bytes;
import haxe.exceptions.ArgumentException;
import asys.native.net.Ip;
import utest.Test;
import utest.Assert;

class IpTests extends Test {
    function test_ipv4_to_string() {
        Assert.equals("127.0.0.1", Ipv4(0x7F000001).toString());
    }

    function test_ipv6_to_string() {
        Assert.equals("::1", Ipv6(Bytes.ofData([ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ])).toString());
    }

    function test_null_to_string() {
        Assert.raises(() -> IpTools.toString(null), ArgumentException);
    }

    function test_ipv4_to_full_string() {
        Assert.equals("127.0.0.1", Ipv4(0x7F000001).toFullString());
    }

    function test_ipv6_to_full_string() {
        Assert.equals("0000:0000:0000:0000:0000:0000:0000:0001", Ipv6(Bytes.ofData([ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ])).toFullString());
    }

    function test_null_to_full_string() {
        Assert.raises(() -> IpTools.toFullString(null), ArgumentException);
    }

    function test_parse_ipv4() {
        switch IpTools.parseIp("127.0.0.1") {
            case Ipv4(raw):
                Assert.equals(raw, 0x7F000001);
            case Ipv6(_):
                Assert.fail("Expected Ipv4");
        }
    }

    function test_parse_short_ipv6() {
        switch IpTools.parseIp("::1") {
            case Ipv4(_):
                Assert.fail("Expected Ipv6");
            case Ipv6(raw):
                Assert.equals(0, Bytes.ofData([ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ]).compare(raw));
        }
    }

    function test_parse_full_ipv6() {
        switch IpTools.parseIp("0000:0000:0000:0000:0000:0000:0000:0001") {
            case Ipv4(_):
                Assert.fail("Expected Ipv6");
            case Ipv6(raw):
                Assert.equals(0, Bytes.ofData([ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ]).compare(raw));
        }
    }

    function test_parse_non_ip() {
        Assert.raises(() -> IpTools.parseIp("not an ip"));
    }

    function test_parse_empty_string() {
        Assert.raises(() -> IpTools.parseIp(""));
    }

    function test_parse_null() {
        Assert.raises(() -> IpTools.parseIp(null), ArgumentException);
    }

    function test_isIp_ipv4() {
        Assert.isTrue(IpTools.isIp("127.0.0.1"));
        Assert.isTrue(IpTools.isIp("127.255.255.255"));
        Assert.isFalse(IpTools.isIp("255.255.255*000"));
        Assert.isFalse(IpTools.isIp("255.255.255.256"));
        Assert.isFalse(IpTools.isIp("2555.0.0.0"));
        Assert.isFalse(IpTools.isIp("255"));
    }

    function test_isIp_ipv6() {
        Assert.isTrue(IpTools.isIp("::1"));
        Assert.isFalse(IpTools.isIp(":::1"));
        Assert.isFalse(IpTools.isIp("abcde::1"));
        Assert.isFalse(IpTools.isIp("fe80:0:0:0:2acf:daff:fedd:342a:5678"));
        Assert.isFalse(IpTools.isIp("fe80:0:0:0:2acf:daff:abcd:1.2.3.4"));
        Assert.isFalse(IpTools.isIp("fe80:0:0:2acf:daff:1.2.3.4.5"));
        Assert.isFalse(IpTools.isIp("ffff:ffff:ffff:ffff:ffff:ffff:255.255.255.255.255"));
    }

    function test_isIp_full_ipv6() {
        Assert.isTrue(IpTools.isIp("0000:0000:0000:0000:0000:0000:0000:0001"));
    }

    function test_isIp_non_ip() {
        Assert.isFalse(IpTools.isIp("not an ip"));
    }

    function test_isIp_empty_string() {
        Assert.isFalse(IpTools.isIp(""));
    }

    function test_isIp_null() {
        Assert.raises(() -> IpTools.isIp(null), ArgumentException);
    }

    function test_isIpv4_ipv4() {
        Assert.isTrue(IpTools.isIpv4("127.0.0.1"));
    }

    function test_isIpv4_ipv6() {
        Assert.isFalse(IpTools.isIpv4("::1"));
    }

    function test_isIpv4_full_ipv6() {
        Assert.isFalse(IpTools.isIpv4("0000:0000:0000:0000:0000:0000:0000:0001"));
    }

    function test_isIpv4_non_ip() {
        Assert.isFalse(IpTools.isIpv4("not an ip"));
    }

    function test_isIpv4_empty_string() {
        Assert.isFalse(IpTools.isIpv4(""));
    }

    function test_isIpv4_null() {
        Assert.raises(() -> IpTools.isIpv4(null), ArgumentException);
    }

    function test_isIpv6_ipv4() {
        Assert.isFalse(IpTools.isIpv6("127.0.0.1"));
    }

    function test_isIpv6_ipv6() {
        Assert.isTrue(IpTools.isIpv6("::1"));
    }

    function test_isIpv6_full_ipv6() {
        Assert.isTrue(IpTools.isIpv6("0000:0000:0000:0000:0000:0000:0000:0001"));
    }

    function test_isIpv6_non_ip() {
        Assert.isFalse(IpTools.isIpv6("not an ip"));
    }

    function test_isIpv6_empty_string() {
        Assert.isFalse(IpTools.isIpv6(""));
    }

    function test_isIpv6_null() {
        Assert.raises(() -> IpTools.isIpv6(null), ArgumentException);
    }
}
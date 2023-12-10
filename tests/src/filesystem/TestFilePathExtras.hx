package filesystem;

import utest.Assert;
import utest.Test;
import cpp.asys.FilePathExtras;

class TestFilePathExtras extends Test {
    function test_hasRootName() {
        Assert.isTrue(FilePathExtras.hasRootName("C:"));
        Assert.isTrue(FilePathExtras.hasRootName("C:/"));
        Assert.isTrue(FilePathExtras.hasRootName("C:foo"));
        Assert.isFalse(FilePathExtras.hasRootName("foo"));
        Assert.isFalse(FilePathExtras.hasRootName("/foo"));
        Assert.isFalse(FilePathExtras.hasRootName(".."));
        Assert.isFalse(FilePathExtras.hasRootName("."));
        Assert.isFalse(FilePathExtras.hasRootName("    "));
        Assert.isFalse(FilePathExtras.hasRootName(null));
    }

    function test_getRootName() {
        Assert.equals("C:", FilePathExtras.getRootName("C:"));
        Assert.equals("C:", FilePathExtras.getRootName("C:/"));
        Assert.equals("C:", FilePathExtras.getRootName("C:foo"));
        Assert.equals("", FilePathExtras.getRootName("foo"));
        Assert.equals("", FilePathExtras.getRootName("/foo"));
        Assert.equals("", FilePathExtras.getRootName(".."));
        Assert.equals("", FilePathExtras.getRootName("."));
        Assert.equals("", FilePathExtras.getRootName("    "));
        Assert.equals("", FilePathExtras.getRootName(null));
    }

    function test_hasRootDirectory() {
        Assert.isFalse(FilePathExtras.hasRootDirectory("C:"));
        Assert.isTrue(FilePathExtras.hasRootDirectory("C:/"));
        Assert.isTrue(FilePathExtras.hasRootDirectory("C:/foo"));
        Assert.isTrue(FilePathExtras.hasRootDirectory("C:///"));
        Assert.isTrue(FilePathExtras.hasRootDirectory("C:///foo"));
        Assert.isFalse(FilePathExtras.hasRootDirectory("C:foo"));
        Assert.isFalse(FilePathExtras.hasRootDirectory("foo"));
        Assert.isTrue(FilePathExtras.hasRootDirectory("/foo"));
        Assert.isTrue(FilePathExtras.hasRootDirectory("///foo"));
        Assert.isTrue(FilePathExtras.hasRootDirectory("/"));
        Assert.isTrue(FilePathExtras.hasRootDirectory("///"));
        Assert.isFalse(FilePathExtras.hasRootDirectory(".."));
        Assert.isFalse(FilePathExtras.hasRootDirectory("."));
        Assert.isFalse(FilePathExtras.hasRootDirectory("    "));
        Assert.isFalse(FilePathExtras.hasRootDirectory(null));
    }

    function test_getRootDirectory() {
        Assert.equals("", FilePathExtras.getRootDirectory("C:"));
        Assert.equals("/", FilePathExtras.getRootDirectory("C:/"));
        Assert.equals("/", FilePathExtras.getRootDirectory("C:/foo"));
        Assert.equals("///", FilePathExtras.getRootDirectory("C:///"));
        Assert.equals("///", FilePathExtras.getRootDirectory("C:///foo"));
        Assert.equals("", FilePathExtras.getRootDirectory("C:foo"));
        Assert.equals("", FilePathExtras.getRootDirectory("foo"));
        Assert.equals("/", FilePathExtras.getRootDirectory("/foo"));
        Assert.equals("///", FilePathExtras.getRootDirectory("///foo"));
        Assert.equals("", FilePathExtras.getRootDirectory(".."));
        Assert.equals("", FilePathExtras.getRootDirectory("."));
        Assert.equals("", FilePathExtras.getRootDirectory("    "));
        Assert.equals("", FilePathExtras.getRootDirectory(null));
    }

    function test_getRootPath() {
        Assert.equals("C:", FilePathExtras.getRootPath("C:"));
        Assert.equals("C:/", FilePathExtras.getRootPath("C:/"));
        Assert.equals("C:/", FilePathExtras.getRootPath("C:/foo"));
        Assert.equals("C:///", FilePathExtras.getRootPath("C:///"));
        Assert.equals("C:///", FilePathExtras.getRootPath("C:///foo"));
        Assert.equals("C:", FilePathExtras.getRootPath("C:foo"));
        Assert.equals("", FilePathExtras.getRootPath("foo"));
        Assert.equals("/", FilePathExtras.getRootPath("/foo"));
        Assert.equals("///", FilePathExtras.getRootPath("///foo"));
        Assert.equals("", FilePathExtras.getRootPath(".."));
        Assert.equals("", FilePathExtras.getRootPath("."));
        Assert.equals("", FilePathExtras.getRootPath("    "));
        Assert.equals("", FilePathExtras.getRootPath(null));
    }

    function test_hasRelativePath() {
        Assert.isTrue(FilePathExtras.hasRelativePath("foo/bar"));
        Assert.isTrue(FilePathExtras.hasRelativePath("/foo/bar"));
        Assert.isTrue(FilePathExtras.hasRelativePath("/  foo"));
        Assert.isTrue(FilePathExtras.hasRelativePath("   foo"));
        Assert.isTrue(FilePathExtras.hasRelativePath("   foo"));
        Assert.isTrue(FilePathExtras.hasRelativePath("C:foo"));
        Assert.isTrue(FilePathExtras.hasRelativePath("C:/foo"));
        Assert.isTrue(FilePathExtras.hasRelativePath("  C:foo"));
        Assert.isTrue(FilePathExtras.hasRelativePath("  C:/foo"));
        Assert.isTrue(FilePathExtras.hasRelativePath("   "));
        Assert.isTrue(FilePathExtras.hasRelativePath("  C:  foo"));
        Assert.isTrue(FilePathExtras.hasRelativePath("  C:/  foo"));
        Assert.isTrue(FilePathExtras.hasRelativePath("/   "));
        Assert.isTrue(FilePathExtras.hasRelativePath("////   "));
        Assert.isTrue(FilePathExtras.hasRelativePath("   /   "));
        Assert.isTrue(FilePathExtras.hasRelativePath("   ////   "));
        Assert.isTrue(FilePathExtras.hasRelativePath("C:   "));
        Assert.isTrue(FilePathExtras.hasRelativePath("C:/   "));
        Assert.isTrue(FilePathExtras.hasRelativePath("   C:   "));
        Assert.isTrue(FilePathExtras.hasRelativePath("   C:/   "));
        Assert.isTrue(FilePathExtras.hasRelativePath("   /"));
        Assert.isTrue(FilePathExtras.hasRelativePath("   ////"));
        Assert.isTrue(FilePathExtras.hasRelativePath("   C:"));
        Assert.isTrue(FilePathExtras.hasRelativePath("   C:/"));
        
        Assert.isFalse(FilePathExtras.hasRelativePath(null));
        Assert.isFalse(FilePathExtras.hasRelativePath(""));
        Assert.isFalse(FilePathExtras.hasRelativePath("/"));
        Assert.isFalse(FilePathExtras.hasRelativePath("////"));
        Assert.isFalse(FilePathExtras.hasRelativePath("/"));
        Assert.isFalse(FilePathExtras.hasRelativePath("C:"));
        Assert.isFalse(FilePathExtras.hasRelativePath("C:/"));
        Assert.isFalse(FilePathExtras.hasRelativePath("C:////"));
    }

    function test_getRelativePath() {
        Assert.equals("foo/bar", FilePathExtras.getRelativePath("foo/bar"));
        Assert.equals("foo/bar", FilePathExtras.getRelativePath("/foo/bar"));
        Assert.equals("  foo", FilePathExtras.getRelativePath("/  foo"));
        Assert.equals("   foo", FilePathExtras.getRelativePath("   foo"));
        Assert.equals("   foo", FilePathExtras.getRelativePath("   foo"));
        Assert.equals("foo", FilePathExtras.getRelativePath("C:foo"));
        Assert.equals("foo", FilePathExtras.getRelativePath("C:/foo"));
        Assert.equals("  C:foo", FilePathExtras.getRelativePath("  C:foo"));
        Assert.equals("  C:/foo", FilePathExtras.getRelativePath("  C:/foo"));
        Assert.equals("   ", FilePathExtras.getRelativePath("   "));
        Assert.equals("  C:  foo", FilePathExtras.getRelativePath("  C:  foo"));
        Assert.equals("  C:/  foo", FilePathExtras.getRelativePath("  C:/  foo"));
        Assert.equals("   ", FilePathExtras.getRelativePath("/   "));
        Assert.equals("   ", FilePathExtras.getRelativePath("////   "));
        Assert.equals("   /   ", FilePathExtras.getRelativePath("   /   "));
        Assert.equals("   ////   ", FilePathExtras.getRelativePath("   ////   "));
        Assert.equals("   ", FilePathExtras.getRelativePath("C:   "));
        Assert.equals("   ", FilePathExtras.getRelativePath("C:/   "));
        Assert.equals("   C:   ", FilePathExtras.getRelativePath("   C:   "));
        Assert.equals("   C:/   ", FilePathExtras.getRelativePath("   C:/   "));
        Assert.equals("   /", FilePathExtras.getRelativePath("   /"));
        Assert.equals("   ////", FilePathExtras.getRelativePath("   ////"));
        Assert.equals("   C:", FilePathExtras.getRelativePath("   C:"));
        Assert.equals("   C:/", FilePathExtras.getRelativePath("   C:/"));
        
        Assert.equals("", FilePathExtras.getRelativePath(null));
        Assert.equals("", FilePathExtras.getRelativePath(""));
        Assert.equals("", FilePathExtras.getRelativePath("/"));
        Assert.equals("", FilePathExtras.getRelativePath("////"));
        Assert.equals("", FilePathExtras.getRelativePath("/"));
        Assert.equals("", FilePathExtras.getRelativePath("C:"));
        Assert.equals("", FilePathExtras.getRelativePath("C:/"));
        Assert.equals("", FilePathExtras.getRelativePath("C:////"));
    }

    function test_empty() {
        Assert.isTrue(FilePathExtras.empty(null));
        Assert.isTrue(FilePathExtras.empty(""));
        Assert.isTrue(FilePathExtras.empty("     "));
        Assert.isTrue(FilePathExtras.empty("\t"));
        Assert.isFalse(FilePathExtras.empty("no"));
        Assert.isFalse(FilePathExtras.empty("  no"));
    }
}
package filesystem;

import asys.native.filesystem.FilePath;
import utest.Test;
import haxe.io.Bytes;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;

class TestFilePath extends Test {
    // function test_create_path() {
    //     Assert.equals("path/to/file", FilePath.createPath("path", "to", "file"));
    //     Assert.equals("path/to/file", FilePath.createPath("path/", "to", "file"));
    //     Assert.equals("/to/file", FilePath.createPath("path", "/to", "file"));
    //     Assert.equals("path/file", FilePath.createPath("path", "", "file"));
    // }

    // function test_is_absolute() {
    //     Assert.isFalse(FilePath.ofString(null).isAbsolute());
    //     Assert.isTrue(FilePath.ofString(Sys.getCwd()).isAbsolute());
    //     Assert.isTrue(FilePath.ofString("/something/something").isAbsolute());
    //     Assert.isFalse(FilePath.ofString("").isAbsolute());
    //     Assert.isFalse(FilePath.ofString("./").isAbsolute());
    //     Assert.isFalse(FilePath.ofString("..").isAbsolute());
    //     Assert.isTrue(FilePath.ofString("C:\\something").isAbsolute());
    //     Assert.isTrue(FilePath.ofString("\\").isAbsolute());
    //     Assert.isFalse(FilePath.ofString("C:something").isAbsolute());
    // }

    // function test_parent() {
    //     Assert.equals(null, FilePath.ofString(null).parent());
    //     Assert.equals(null, FilePath.ofString("file").parent());
    //     Assert.equals("/", FilePath.ofString("/file").parent());
    //     Assert.equals("./", FilePath.ofString(".").parent());
    //     Assert.equals("path/to", FilePath.ofString("path/to/file").parent());
    //     Assert.equals("path/to", FilePath.ofString("path/to/dir/").parent());
    //     Assert.equals("path/to", FilePath.ofString("path/to///dir/").parent());
    //     Assert.equals("path/to/..", FilePath.ofString("path/to/../file").parent());
    //     Assert.equals("path/to", FilePath.ofString("path/to/..").parent());
    //     Assert.equals("path/to", FilePath.ofString("path/to/.").parent());
    //     Assert.equals(null, FilePath.ofString(".hidden").parent());
    //     Assert.equals(null, FilePath.ofString(".").parent());
    //     Assert.equals(null, FilePath.ofString("").parent());
    //     Assert.equals(null, FilePath.ofString("/").parent());
    //     Assert.equals(null, FilePath.ofString("\\").parent());
    // }

    // function test_equal() {
    //     final p1 = FilePath.ofString('qwe');
	// 	final p2 = FilePath.ofString('qwe');

	// 	Assert.isTrue(p1 == p2);
    // }

    // function test_normalise() {
    //     Assert.equals("some/path", FilePath.ofString("some/path").normalize());
    //     Assert.equals("", FilePath.ofString("").normalize());
    //     Assert.equals("", FilePath.ofString(".").normalize());
    //     Assert.equals("", FilePath.ofString("./").normalize());
    //     Assert.equals("non-existent/file", FilePath.ofString("path/to/./../../non-existent/./file").normalize());
    //     Assert.equals("check/slashes", FilePath.ofString("check///slashes/").normalize());
    //     Assert.equals("", FilePath.ofString("./all/redundant/../..").normalize());
    //     Assert.equals("../..", FilePath.ofString("leaves/../non-redundant/../double-dots/../../..").normalize());
    //     Assert.equals("...", FilePath.ofString("...").normalize());
    //     Assert.equals("/absolute/path", FilePath.ofString("/absolute/path").normalize());

    //     Assert.equals("C:/absolute/../path", FilePath.ofString("C:/path").normalize());
    //     Assert.equals("C:/back/to/root/../../..", FilePath.ofString("C:/").normalize());
    //     Assert.equals("C:/absolute/excessive/dots/../../../..", FilePath.ofString("C:/").normalize());
    //     Assert.equals("C:relative/.././", FilePath.ofString("C:").normalize());
    //     Assert.equals("C:relative/../excessive/dots/../../../..", FilePath.ofString("C:../..").normalize());
    // }
}
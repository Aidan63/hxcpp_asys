package filesystem;

import asys.native.filesystem.FilePath;
import utest.Test;
import haxe.io.Bytes;
import utest.Async;
import utest.Assert;
import asys.native.IoErrorType;
import asys.native.filesystem.FileSystem;

using StringTools;

class TestFilePath extends Test {
    function test_separator() {
        Assert.equals(if (Sys.systemName() == 'Windows') '\\' else '/', FilePath.SEPARATOR);
    }

    function test_create_path() {
        Assert.equals('path${FilePath.SEPARATOR}to${FilePath.SEPARATOR}file', FilePath.createPath('path', 'to', 'file'));
        Assert.equals('path${FilePath.SEPARATOR}to${FilePath.SEPARATOR}file', FilePath.createPath('path/', 'to', 'file'));
        Assert.equals('/to${FilePath.SEPARATOR}file', FilePath.createPath('path', '/to', 'file'));
        Assert.equals('path${FilePath.SEPARATOR}file', FilePath.createPath('path', '', 'file'));
    }

    function test_is_absolute() {
        Assert.isFalse(FilePath.ofString(null).isAbsolute());
        Assert.isTrue(FilePath.ofString(Sys.getCwd()).isAbsolute());
        Assert.isTrue(FilePath.ofString('/something/something').isAbsolute());
        Assert.isFalse(FilePath.ofString('').isAbsolute());
        Assert.isFalse(FilePath.ofString('     ').isAbsolute());
        Assert.isFalse(FilePath.ofString('./').isAbsolute());
        Assert.isFalse(FilePath.ofString('..').isAbsolute());
        Assert.isTrue(FilePath.ofString('C:/something').isAbsolute());
        Assert.isTrue(FilePath.ofString('/').isAbsolute());
        Assert.isTrue(FilePath.ofString('//').isAbsolute());
        Assert.isFalse(FilePath.ofString('C:something').isAbsolute());
    }

    // function test_parent() {
    //     Assert.equals(null, FilePath.ofString(null).parent());
    //     Assert.equals(null, FilePath.ofString('file').parent());
    //     Assert.equals('/', FilePath.ofString('/file').parent());
    //     Assert.equals('./', FilePath.ofString('.').parent());
    //     Assert.equals('path/to', FilePath.ofString('path/to/file').parent());
    //     Assert.equals('path/to', FilePath.ofString('path/to/dir/').parent());
    //     Assert.equals('path/to', FilePath.ofString('path/to///dir/').parent());
    //     Assert.equals('path/to', FilePath.ofString('path/to/dir////').parent());
    //     Assert.equals('path/to/..', FilePath.ofString('path/to/../file').parent());
    //     Assert.equals('path/to', FilePath.ofString('path/to/..').parent());
    //     Assert.equals('path/to', FilePath.ofString('path/to/.').parent());
    //     Assert.equals(null, FilePath.ofString('.hidden').parent());
    //     Assert.equals(null, FilePath.ofString('.').parent());
    //     Assert.equals(null, FilePath.ofString('').parent());
    //     Assert.equals(null, FilePath.ofString('/').parent());
    //     Assert.equals(null, FilePath.ofString('//').parent());
    // }

    function test_add() {
        Assert.equals('file', FilePath.ofString("file").add(""));
        Assert.equals('file', FilePath.ofString("file").add("    "));
        Assert.equals('file', FilePath.ofString("file").add(null));

        Assert.equals('file', FilePath.ofString("").add("file"));
        Assert.equals('   ${FilePath.SEPARATOR}file', FilePath.ofString("   ").add("file"));
        Assert.equals('file', FilePath.ofString(null).add("file"));

        Assert.equals('dir${FilePath.SEPARATOR}file', FilePath.ofString("dir").add("file"));
        Assert.equals('dir${FilePath.SEPARATOR}file', FilePath.ofString("dir/").add("file"));
        Assert.equals('dir${FilePath.SEPARATOR}file', FilePath.ofString("dir/////").add("file"));
        Assert.equals('/file', FilePath.ofString("dir").add("/file"));
        Assert.equals('dir', FilePath.ofString("dir").add(""));

        Assert.equals('C:/bar', FilePath.ofString("foo").add("C:/bar"));
        Assert.equals('C:', FilePath.ofString("foo").add("C:"));
        Assert.equals('C:', FilePath.ofString("C:").add(""));
        Assert.equals('C:/bar', FilePath.ofString("C:foo").add("/bar"));
        Assert.equals('C:foo${FilePath.SEPARATOR}bar', FilePath.ofString("C:foo").add("bar"));
    }

    function test_normalise_empty_paths() {
        Assert.equals('', FilePath.ofString(null).normalize());
        Assert.equals('', FilePath.ofString('').normalize());
        Assert.equals('', FilePath.ofString('        ').normalize());
    }

    function test_normalise_multiple_separators() {
        Assert.equals('some${FilePath.SEPARATOR}dir', FilePath.ofString('some/dir').normalize());
        Assert.equals('some${FilePath.SEPARATOR}dir', FilePath.ofString('some/dir/').normalize());
        Assert.equals('some${FilePath.SEPARATOR}dir', FilePath.ofString('some${ [ for (_ in 0...3) FilePath.SEPARATOR ].join('') }dir').normalize());
        Assert.equals('some${FilePath.SEPARATOR}dir', FilePath.ofString('some/////dir').normalize());
        Assert.equals('some${FilePath.SEPARATOR}dir', FilePath.ofString('some//${ FilePath.SEPARATOR }//dir').normalize());
        Assert.equals('some${FilePath.SEPARATOR}dir', FilePath.ofString('some/dir/////').normalize());
        Assert.equals('some${FilePath.SEPARATOR}dir', FilePath.ofString('some/dir//${ FilePath.SEPARATOR }//').normalize());
    }

    function test_normalise_current_dir_indicator() {
        Assert.equals('.', FilePath.ofString('./').normalize());
        Assert.equals('dir', FilePath.ofString('./dir').normalize());
        Assert.equals('dir', FilePath.ofString('././dir').normalize());
        Assert.equals('dir', FilePath.ofString('dir/./').normalize());
        Assert.equals('dir', FilePath.ofString('dir/././').normalize());
        Assert.equals('some${FilePath.SEPARATOR}dir', FilePath.ofString('some/./dir').normalize());
        Assert.equals('dir', FilePath.ofString('./////dir').normalize());
        Assert.equals('dir', FilePath.ofString('.${ FilePath.SEPARATOR }dir').normalize());
        Assert.equals('dir', FilePath.ofString('.${ [ for (_ in 0...3) FilePath.SEPARATOR ].join('') }dir').normalize());
    }

    function test_normalise_dot_dot_parts() {
        Assert.equals('some', FilePath.ofString('some/dir/..').normalize());
        Assert.equals('some', FilePath.ofString('some/dir/../').normalize());
        Assert.equals('some${FilePath.SEPARATOR}other', FilePath.ofString('some/dir/../other').normalize());
        Assert.equals('other', FilePath.ofString('some/dir/../../other').normalize());
        Assert.equals('some', FilePath.ofString('some/dir/../other/..').normalize());
        Assert.equals('${FilePath.SEPARATOR}some', FilePath.ofString('/some/dir/../other/..').normalize());
        Assert.equals('C:${FilePath.SEPARATOR}some', FilePath.ofString('C:/some/dir/../other/..').normalize());
        Assert.equals('..', FilePath.ofString('..').normalize());
        Assert.equals('..${FilePath.SEPARATOR}..', FilePath.ofString('../..').normalize());
        Assert.equals(FilePath.SEPARATOR, FilePath.ofString('/..').normalize());
        Assert.equals('C:${FilePath.SEPARATOR}', FilePath.ofString('C:/..').normalize());
        Assert.equals('..${FilePath.SEPARATOR}..', FilePath.ofString('leaves/../non-redundant/../double-dots/../../..').normalize());
        Assert.equals('non-existent${FilePath.SEPARATOR}file', FilePath.ofString('path/to/./../../non-existent/./file').normalize());
        Assert.equals('C:', FilePath.ofString('C:relative/.././').normalize());
        Assert.equals('C:..${FilePath.SEPARATOR}..', FilePath.ofString('C:relative/../excessive/dots/../../../..').normalize());
    }
}
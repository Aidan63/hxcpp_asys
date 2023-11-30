package filesystem;

import utest.Async;
import utest.Assert;
import asys.native.filesystem.FileSystem;
import asys.native.filesystem.FileOpenFlag;
import haxe.io.Bytes;

class TestFileModifyingBuffers extends FileOpenTests {

    /**
     * After the bytes are sent to write more data is added to the buffer by peeking at the underlying array and resizing it.
     * Should any behaviour around this be defined?
     * I'm not sure if getData is suppose to return the underlying array on every target, it does on cpp atleast.
     */
    function test_expanding_buffer_after_sending(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Append, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "lorem ipsum";
            final buffer = Bytes.ofString(text);

            file.write(buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(text.length, count);

                file.close((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals(0, sys.io.File.getBytes(emptyFileName).compare(Bytes.ofString(text)));

                    async.done();
                });
            });

            buffer.getData().resize(text.length * 2);
        });
    }

    /**
     * Very similar to above, except we shrink the buffer instead of expanding!
     */
    function test_shrinking_buffer_after_sending(async:Async) {
        FileSystem.openFile(emptyFileName, FileOpenFlag.Append, (error, file) -> {
            Assert.isNull(error);
            Assert.notNull(file);

            final text   = "lorem ipsum";
            final buffer = Bytes.ofString(text);

            file.write(buffer, 0, buffer.length, (error, count) -> {
                Assert.isNull(error);
                Assert.equals(text.length, count);

                file.close((error, _) -> {
                    Assert.isNull(error);
                    Assert.equals(0, sys.io.File.getBytes(emptyFileName).compare(Bytes.ofString(text)));

                    async.done();
                });
            });

            buffer.getData().resize(text.length - 5);
        });
    }
}
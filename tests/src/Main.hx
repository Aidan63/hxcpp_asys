import filesystem.TestFile;
import filesystem.TestFileSystem;
import filesystem.TestFileOpenRead;
import filesystem.TestFileOpenWrite;
import filesystem.TestDirectoryOpen;
import filesystem.TestDirectoryList;
import filesystem.TestFileOpenAppend;
import filesystem.TestFileOpenWriteX;
import filesystem.TestFileDodgyAccess;
import filesystem.TestFileOpenReadWrite;
import filesystem.TestFileOpenWriteRead;
import filesystem.TestFileOpenOverwrite;
import filesystem.TestFileModifyingBuffers;
import filesystem.TestFileOpenOverwriteRead;
import utest.ui.Report;
import utest.Runner;

function main() {
    final runner = new Runner();
    runner.addCase(new TestFileOpenRead());
    runner.addCase(new TestFileOpenReadWrite());
    runner.addCase(new TestFileOpenAppend());
    runner.addCase(new TestFileOpenWrite());
    runner.addCase(new TestFileOpenWriteRead());
    runner.addCase(new TestFileOpenWriteX());
    runner.addCase(new TestFileOpenOverwrite());
    runner.addCase(new TestFileOpenOverwriteRead());
    runner.addCase(new TestFile());
    runner.addCase(new TestFileDodgyAccess());
    runner.addCase(new TestFileModifyingBuffers());
    runner.addCase(new TestDirectoryOpen());
    runner.addCase(new TestDirectoryList());
    runner.addCase(new TestFileSystem());

    Report.create(runner);
    
    runner.run();
}
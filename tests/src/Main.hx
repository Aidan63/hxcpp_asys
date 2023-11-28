import filesystem.TestFileOpenRead;
import filesystem.TestFileOpenWrite;
import filesystem.TestFileOpenAppend;
import filesystem.TestFileOpenWriteX;
import filesystem.TestFileOpenReadWrite;
import filesystem.TestFileOpenWriteRead;
import filesystem.TestFileOpenOverwrite;
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

    Report.create(runner);
    
    runner.run();
}
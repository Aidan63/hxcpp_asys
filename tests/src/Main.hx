import filesystem.TestFileOpenRead;
import filesystem.TestFileOpenReadWrite;
import utest.ui.Report;
import utest.Runner;

function main() {
    final runner = new Runner();
    runner.addCase(new TestFileOpenRead());
    runner.addCase(new TestFileOpenReadWrite());

    Report.create(runner);
    
    runner.run();
}
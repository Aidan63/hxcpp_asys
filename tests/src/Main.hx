import utest.ui.Report;
import utest.Runner;

function main() {
    final runner = new Runner();
    runner.addCase(new TestFileOpenRead());

    Report.create(runner);
    
    runner.run();
}
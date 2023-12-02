package filesystem;

import haxe.io.Path;
import utils.Directory;

class DirectoryTests extends FileOpenTests {
    final directoryName : String;

    public function new() {
        super();

        directoryName = "test_dir";
    }

    override function setup() {
        super.setup();

        ensureDirectoryIsEmpty(directoryName);

        sys.FileSystem.createDirectory(Path.join([ directoryName, "sub_dir" ]));

        sys.io.File.saveContent(Path.join([ directoryName, "file1.txt" ]), "");
        sys.io.File.saveContent(Path.join([ directoryName, "file2.txt" ]), "");
    }
}
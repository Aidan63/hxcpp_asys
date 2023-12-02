package utils;

import haxe.io.Path;
import sys.FileSystem;

function cleanFolder(folder:String, delete:Bool) {
    for (item in FileSystem.readDirectory(folder)) {
        final path = Path.join([ folder, item ]);

        if (FileSystem.isDirectory(path)) {
            cleanFolder(path, true);
        } else {
            FileSystem.deleteFile(path);
        }
    }

    if (delete) {
        FileSystem.deleteDirectory(folder);
    }
}

function ensureDirectoryIsEmpty(folder:String) {
    if (!FileSystem.exists(folder)) {
        FileSystem.createDirectory(folder);
    } else {
        cleanFolder(folder, false);
    }
}
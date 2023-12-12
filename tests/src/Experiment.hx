import haxe.NoData;
import asys.native.filesystem.Callback;

enum abstract AceType(Int) {
    var Allow;
    var Deny;
}

enum abstract AcePermission(Int) {
    var AppendData;
    var Delete;
    var DeleteChild;
    var Execute;
    var ReadAcl;
    var ReadAttributes;
    var ReadData;
    var ReadNamedAttributes;
    var Synchronise;
    var WriteAcl;
    var WriteAttributes;
    var WriteData;
    var WriteNamedAttributes;
    var WriteOwner;
    var AddFile;
    var AddSubdirectory;
    var ListDirectory;
}

enum abstract AceFlag(Int) {
    /**
     * Can be placed on a directory and indicates that the ACE should be added to each new directory created.
     */
    var DirectoryInherit;

    /**
     * Can be placed on a directory and indicates that the ACE should be added to each new non-directory file created.
     */
    var FileInherit;

    /**
     * Can be placed on a directory but does not apply to the directory, only to newly created files and directories as specified by the `FileInherit` and `DirectoryInherit` flags.
     */
    var InheritOnly;

    /**
     * Can be placed on a directory to indicate that the ACE should not be placed on the newly created directory which is inheritable by subdirectories of the created directory.
     */
    var NoPropagateInherit;
}

class Ace {
    public var type : AceType;

    public var permissions : Array<AcePermission>;

    public var flags : AceFlag;
}

class Acl {
    public function getEntries(callback:Callback<Array<Ace>>) {
        //
    }

    public function setEntries(entries:Array<Ace>, callback:Callback<NoData>) {
        //
    }
}

class Experiment {
    //
}

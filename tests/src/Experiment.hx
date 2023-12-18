import asys.native.filesystem.FileSystem;
import haxe.exceptions.NotImplementedException;
import asys.native.filesystem.Directory;
import asys.native.filesystem.FilePath;
import asys.native.filesystem.File;
import haxe.NoData;
import haxe.Callback;

abstract Principal(String) {
    public var name (get, never) : String;

    function get_name():String {
        throw new NotImplementedException();
    }
}

abstract SystemUser(Principal) to Principal {
    public static function current(callback:Callback<Principal>) {
        throw new NotImplementedException();
    }

    public static function find(name:String, callback:Callback<SystemUser>) {
        throw new NotImplementedException();
    }
}

abstract SystemGroup(Principal) to Principal {
    public static function find(name:String, callback:Callback<SystemGroup>) {
        throw new NotImplementedException();
    }
}

//

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
    public var principal : Principal;

    public var type : AceType;

    public var permissions : Array<AcePermission>;

    public var flags : AceFlag;
}

class Acl {
    public function getEntries(callback:Callback<Null<Array<Ace>>>) {
        //
    }

    public function setEntries(entries:Null<Array<Ace>>, callback:Callback<NoData>) {
        //
    }

    public static function fromSecurity(security:Security, callback:Callback<Acl>) {
        //
    }
}

class Security {
    public var owner (get, set) : SystemUser;

    function get_owner():SystemUser {
        throw new NotImplementedException();
    }

    function set_owner(_:SystemUser):SystemUser {
        throw new NotImplementedException();
    }

    public var group (get, set) : SystemGroup;

    function get_group():SystemGroup {
        throw new NotImplementedException();
    }

    function set_group(_:SystemGroup):SystemGroup {
        throw new NotImplementedException();
    }
}

class Experiment {
    static function main() {

        FileSystem.openFile("test.txt", Read, (error, file) -> {

            Acl.fromSecurity(cast file, (error, acl) -> {

                acl.getEntries((error, entries) -> {
                    for (ace in entries) {
                        //
                    }
                });
                
            });

        });
    }
}

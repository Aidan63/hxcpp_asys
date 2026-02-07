package cpp.asys;

@:cpp.ManagedType({ namespace : [ "hx", "asys", "system" ], flags : [ StandardNaming ] })
extern class CurrentProcess extends Process {
    final stdio_in : Readable;
    final stdio_out : Writable;
    final stdio_err : Writable;

    // function setSignalAction(signal:cpp.EnumBase, action:cpp.EnumBase):Void;
}
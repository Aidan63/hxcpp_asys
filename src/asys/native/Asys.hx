package asys.native;

import cpp.asys.Context;
import haxe.coro.context.Key;
import haxe.coro.context.IElement;

class Asys implements IElement<Asys> {
    public static final key = new Key<Asys>("Asys");

    public final ctx : Context;

    public function new() {
        ctx = Context.get();
    }

    public function getKey():Key<Asys> {
        return key;
    }
}
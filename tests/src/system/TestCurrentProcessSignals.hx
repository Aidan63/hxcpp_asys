package system;

import haxe.exceptions.ArgumentException;
import utest.Assert;
import asys.native.system.Signal;
import asys.native.system.Process;
import utest.Async;
import utest.Test;

class TestCurrentProcessSignals extends Test {
    //

    // public function test_ignoring_signal(async:Async) {
    //     Process.current.setSignalAction(Interrupt, Ignore);
    //     Process.current.sendSignal(Interrupt, (_, error) -> {
    //         Assert.isNull(error);

    //         Process.current.setSignalAction(Interrupt, Default);

    //         async.done();
    //     });
    // }

    public function test_setSignalAction_null_signal() {
        Assert.raises(() -> Process.current.setSignalAction(null, Ignore), ArgumentException);
    }

    public function test_setSignalAction_null_action() {
        Assert.raises(() -> Process.current.setSignalAction(Terminate, null), ArgumentException);
    }

    public function test_sendSignal_null_signal() {
        Assert.raises(() -> Process.current.sendSignal(null, (_, _) -> {}), ArgumentException);
    }

    public function test_sendSignal_null_callback() {
        Assert.raises(() -> Process.current.sendSignal(Terminate, null), ArgumentException);
    }
}
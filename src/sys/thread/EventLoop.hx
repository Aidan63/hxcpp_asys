package sys.thread;

import cpp.asys.Context;
import haxe.Exception;
import haxe.exceptions.NotImplementedException;

/**
 * When an event loop has an available event to execute.
 */
enum NextEventTime {
	/**
	 * There's already an event waiting to be executed
	 */
	Now;

	/**
	 * No new events are expected.
	 */
	Never;

	/**
	 * An event is expected to arrive at any time.
	 * 
	 * If `time` is specified, then the event will be ready at that time for sure.
	 */
	AnyTime(time : Null<Float>);

	/**
	 * An event is expected to be ready for execution at `time`.
	 */
	At(time : Float);
}

@:coreApi
class EventLoop
{
    final context : Context;

    public function new() {
        context = Context.create();
    }

    public function cancel(eventHandler : EventHandler) : Void {
        try {
            context.cancel(eventHandler);
        } catch (err : String) {
            throw new Exception(err);
        }
    }

    public function loop() : Void {
        context.loop();
    }

    public function progress() : NextEventTime {
        throw new NotImplementedException();
    }

    public function promise() : Void {
        throw new NotImplementedException();
    }

    public function repeat(event : Void->Void, intervalMs : Int) : EventHandler {
        try {
            return context.enqueue(event, intervalMs);
        } catch (err : String) {
            throw new Exception(err);
        }
    }

    public function run(event : Void->Void) : Void {
        try {
            context.enqueue(event);
        } catch (err : String) {
            throw new Exception(err);
        }
    }

    public function runPromised(event : Void->Void) : Void {
        throw new NotImplementedException();
    }

    public function wait(?timeout : Float) : Bool {
        throw new NotImplementedException();
    }
}

abstract EventHandler(Any) {}
scriptname RPB_TestFreezable extends Actor

;/
    Test-only: on RPB_TestFreezableGuard, a copy of a Solitude guard whose only script is this one, so the actor himself is
    this object. A real frozen guard's object stops answering (every call on him waits forever, his AI and Scenes go on);
    HoldLock makes the same thing on demand: while it runs, the object's lock is this stack's, and any other call on him
    waits for it.

    The loop must make no call at all: a Wait, or a call into anything else (a global too), gives the lock up for as long
    as that call takes, and the calls I'm testing would slip through. So it can't look at the clock or at JDB: it reads
    @abRelease[0], an array element the test sets from its own stack (reading one is no call). A pass count bounded by time
    wouldn't do either: the VM ran 2575 passes/s with the game idle and far fewer mid escort (a 45s hold took minutes).
    @aiMaxPasses only stops it if the test never releases it.
/;

function HoldLock(bool[] abRelease, int aiMaxPasses)
    int pass = 0
    while (!abRelease[0] && pass < aiMaxPasses)
        pass += 1
    endWhile
endFunction

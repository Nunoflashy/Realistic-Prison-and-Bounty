scriptname RPB_ThreadLock hidden

import RPB_Utility
import RPB_Memory

;/
    A mutual-exclusion lock between Papyrus THREADS (not an in-game lock on a door or container).

    Papyrus can switch between threads at function calls, so any multi-step change to shared
    state can interleave with another thread's (see PAPYRUS_PERFORMANCE.md and test 39). A bool
    flag can't fix that - two threads can both read it as false before either sets it - so this
    is built on JContainers' JAtomic, whose compare-exchange is one indivisible operation:
    compareExchangeInt(lock, ".locked", 1, 0) returns the PREVIOUS value and only changes it
    from 0 to 1 if it was still 0, so exactly one of any number of simultaneous callers sees 0.

    Being global functions on a hidden script there is no state and no per-script field, so any
    script can use it:

        int threadLock = RPB_ThreadLock.Get("MySystem")
        RPB_ThreadLock.Acquire(threadLock)
        ; ... change the shared state ...
        RPB_ThreadLock.Release(threadLock)

    Keep the critical section short, and do anything that triggers callbacks (Dispel(), spells,
    events) AFTER releasing.

    Acquire() waits with a randomized sleep (so waiters don't all resume in the same instant) and
    force-takes the lock (logging an error) only when it looks STUCK, so a thread that died while
    holding it can never deadlock the system. Stuck means nobody has acquired it for a while - not
    that this waiter has waited long: every acquire bumps a ticket on the lock, and a waiter only
    counts the waits during which the ticket didn't move. A long queue that keeps moving (ten
    arrests assigning cells one after another) therefore never force-takes, which would put two
    threads in the critical section at once. The lock word lives in a JContainers object that is
    saved with the game, so a save taken while it is held leaves it held; that is recovered with a
    single ~5s stall on next use.
/;

;/
    A private, retained lock object that isn't in the registry - for tests and benchmarks.
    Release it with FastMap_Release() when done. Get() is what real code wants.
/;
int function CreatePrivate() global
    int threadLock = FastMap("<string>", true)
    FastMap_SetInt(threadLock, "locked", 0)
    return threadLock
endFunction

;/
    The registry map every named lock lives in, itself created on demand. Its handle is published
    in the JContainers DB (an int, `.RPB_ThreadLockRegistry`).

    Creation is "claim, create, publish": fetchAddInt returns the PREVIOUS value atomically, so
    of any number of simultaneous first callers exactly one sees 0, and only that one creates
    the map. The others wait (bounded) for it to be published. (An earlier version tried to
    install the object with JAtomic.compareExchangeObj on a nested DB path; test 42/44 showed
    that reported success without storing anything, so every caller got a private lock and
    nothing was excluded. fetchAddInt on a single key is what the tests proved to work.)

    If a claim exists but nothing was ever published (the claiming thread died, or a stale claim
    survived from an older save) the bounded wait ends and the caller creates it itself, logging
    an error - a recovery path only.
/;
int function __GetRegistry() global
    int registry = JDB.solveInt(".RPB_ThreadLockRegistry")
    if (registry && JValue.isExists(registry))
        return registry
    endif

    int claim = JAtomic.fetchAddInt(JDB.root(), ".RPB_ThreadLockRegistryClaim", 1, 0, true)
    if (claim == 0)
        registry = FastMap("<string>", true)
        JDB.solveIntSetter(".RPB_ThreadLockRegistry", registry, true)
        return registry
    endif

    int tries = 0
    while (tries < 100)
        registry = JDB.solveInt(".RPB_ThreadLockRegistry")
        if (registry && JValue.isExists(registry))
            return registry
        endif

        Utility.WaitMenuMode(0.01)
        tries += 1
    endWhile

    Error("RPB_ThreadLock: the lock registry was claimed but never published - creating it now.")
    registry = FastMap("<string>", true)
    JDB.solveIntSetter(".RPB_ThreadLockRegistry", registry, true)
    return registry
endFunction

;/
    Returns the lock registered under @asName, creating it if this is the first request. Same
    claim/create/publish scheme as the registry itself: of any number of threads asking for a
    brand-new name at once, exactly one creates the lock and every caller ends up with that same
    handle. @asName must be path-safe: letters, digits and underscores (a '-' is not).
/;
int function Get(string asName) global
    int registry = __GetRegistry()

    int existing = FastMap_GetInt(registry, asName)
    if (existing && JValue.isExists(existing))
        return existing
    endif

    int claim = JAtomic.fetchAddInt(registry, ".claim_" + asName, 1, 0, true)
    if (claim == 0)
        int fresh = CreatePrivate()
        FastMap_SetInt(registry, asName, fresh)
        return fresh
    endif

    int tries = 0
    while (tries < 100)
        existing = FastMap_GetInt(registry, asName)
        if (existing && JValue.isExists(existing))
            return existing
        endif

        Utility.WaitMenuMode(0.01)
        tries += 1
    endWhile

    Error("RPB_ThreadLock: the lock '" + asName + "' was claimed but never published - creating it now.")
    existing = CreatePrivate()
    FastMap_SetInt(registry, asName, existing)
    return existing
endFunction

;/ Removes a registered lock and releases its object. For tests; never call it on a lock something might still hold. /;
function Forget(string asName) global
    int registry = JDB.solveInt(".RPB_ThreadLockRegistry")
    if (registry && JValue.isExists(registry))
        int existing = FastMap_GetInt(registry, asName)
        if (existing)
            FastMap_Release(existing)
        endif

        FastMap_RemoveKey(registry, asName)
        FastMap_RemoveKey(registry, "claim_" + asName)
    endif
endFunction

;/ One attempt, no waiting. True if this caller now holds the lock. /;
bool function TryAcquire(int aiLock) global
    ; onErrorReturn = 1: an invalid handle must read as "not acquired", never as a free lock
    return JAtomic.compareExchangeInt(aiLock, ".locked", 1, 0, false, 1) == 0
endFunction

;/
    Waits for the lock and takes it. Returns true if it was acquired normally, false if it had to
    be force-taken because nobody acquired it for @aiMaxTries waits in a row (~0.04s each on
    average): a previous holder never released it. Waits during which another thread did acquire
    it don't count - the queue is moving. Either way the caller holds the lock when this returns.
/;
bool function Acquire(int aiLock, int aiMaxTries = 120) global
    int tries = 0 ; every wait (stats only)
    int stalled = 0 ; waits in a row during which nobody acquired the lock
    int seenTicket = JValue.solveInt(aiLock, ".ticket")

    while (stalled < aiMaxTries)
        if (JAtomic.compareExchangeInt(aiLock, ".locked", 1, 0, false, 1) == 0)
            JAtomic.fetchAddInt(aiLock, ".ticket", 1, 0, true) ; progress, for whoever is still waiting
            if (tries > 0)
                __RecordWait(tries, stalled)
            endif
            return true
        endif

        Utility.WaitMenuMode(Utility.RandomFloat(0.02, 0.06))
        tries += 1

        int ticket = JValue.solveInt(aiLock, ".ticket")
        if (ticket != seenTicket)
            seenTicket = ticket
            stalled = 0
        else
            stalled += 1
        endif
    endWhile

    Error("RPB_ThreadLock: lock " + aiLock + " was not acquired by anyone for " + stalled + " waits - a previous holder never released it. Force-taking it.")
    ; Counted where the tests can read it (Error() is silent while they run): a force-take lets two threads into the same
    ; critical section if the holder was in fact alive, so only a lock with no progress at all may reach it
    JAtomic.fetchAddInt(JDB.root(), ".RPB_ThreadLockForceTakes", 1, 0, true)
    __RecordWait(tries, stalled)
    JAtomic.exchangeInt(aiLock, ".locked", 1)
    JAtomic.fetchAddInt(aiLock, ".ticket", 1, 0, true)
    return false
endFunction

; Diagnostics only (plain maxes, not atomic): the longest total wait and the longest no-progress stretch, in tries
function __RecordWait(int aiTries, int aiStalled) global
    if (aiTries > JDB.solveInt(".RPB_ThreadLockMaxWaitTries"))
        JDB.solveIntSetter(".RPB_ThreadLockMaxWaitTries", aiTries, true)
    endif
    if (aiStalled > JDB.solveInt(".RPB_ThreadLockMaxStallTries"))
        JDB.solveIntSetter(".RPB_ThreadLockMaxStallTries", aiStalled, true)
    endif
endFunction

; For the tests: force-takes, the longest total wait and the longest no-progress stretch, since ResetStats()
int function ForceTakeCount() global
    return JDB.solveInt(".RPB_ThreadLockForceTakes")
endFunction

int function MaxWaitTries() global
    return JDB.solveInt(".RPB_ThreadLockMaxWaitTries")
endFunction

int function MaxStallTries() global
    return JDB.solveInt(".RPB_ThreadLockMaxStallTries")
endFunction

function ResetStats() global
    JDB.solveIntSetter(".RPB_ThreadLockForceTakes", 0, true)
    JDB.solveIntSetter(".RPB_ThreadLockMaxWaitTries", 0, true)
    JDB.solveIntSetter(".RPB_ThreadLockMaxStallTries", 0, true)
endFunction

function Release(int aiLock) global
    JAtomic.exchangeInt(aiLock, ".locked", 0)
endFunction

;/
    Checks the JAtomic natives really behave like a lock on this install. If the native were
    missing, every call would silently return 0 and TryAcquire() would report "acquired" forever
    - a fake lock - so anything that depends on this should be able to check first.
/;
bool function IsWorking() global
    int scratch = CreatePrivate()

    bool firstAcquired = TryAcquire(scratch)
    bool secondAcquired = TryAcquire(scratch)
    Release(scratch)
    bool thirdAcquired = TryAcquire(scratch)

    FastMap_Release(scratch)

    return firstAcquired && !secondAcquired && thirdAcquired
endFunction

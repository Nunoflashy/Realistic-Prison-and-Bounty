scriptname RPB_ActiveMagicEffectContainer extends ReferenceAlias

;/
    Dynamic map of ActiveMagicEffect -> string key, built on fixed-size native Papyrus arrays
    ("pages") since Papyrus has no dynamic collection type, and ActiveMagicEffect cannot be
    stored in JContainers - it does NOT extend Form (confirmed against Skyrim's native Papyrus
    script headers: Form.psc and ActiveMagicEffect.psc are both separate `Hidden` scripts with
    no Extends clause, i.e. siblings under ScriptObject, not parent/child). That's a
    compile-time type constraint, not a soft limitation - JMap/JArray's Form-storage functions
    (wrapped by RPB_Memory.psc's FastMap_SetForm and used successfully elsewhere in this
    codebase for real Form types) simply reject anything that isn't a Form.

    Design: elements stay densely packed at global indices [0, Count) at all times - no gaps,
    ever. AddElement() always appends at Count; RemoveElement() moves whatever is currently the
    last live element into the freed slot (the same technique the old
    __private_moveLastElementToIndex used within a single array - this just extends it across
    page boundaries). A later page can therefore never hold a live element while an earlier
    page has a hole: removing an element always backfills from the true end of the list, so a
    trailing page that empties out just sits unallocated again - no fragmentation is possible
    by construction, nothing to "reindex" as a separate pass.

    Pages that fall entirely outside [0, Count) get freed (set to None) as soon as
    RemoveElement() makes that true, not left allocated forever - confirmed real Papyrus
    technique (an array field set to None drops to length 0 and is eligible for garbage
    collection like any other reference). This matters because this container isn't a
    singleton: every Hold's ArresteeList, every Prison's PrisonerList, every Captor list, etc.
    each get their own independent set of page fields, so an idle instance's pages shouldn't
    just sit allocated for the life of the save. See KNOWN_ISSUES.md/TROUBLESHOOTING_NOTES.md
    for the real numbers and reasoning behind PAGE_SIZE/PAGE_COUNT below.

    Iteration order is NOT stable across removals (a swap can reorder two elements) - a
    deliberate non-goal, confirmed safe against every real caller in this codebase, none of
    which depend on order, only on visiting every live element once (GetActors(), the MCM/UI
    list-pickers, BindAllPrisonersToCell(), the monitor loops).

    JContainers is only ever used for bookkeeping - a key -> global-index map (__keyToIndex) and
    its mirror, a global-index -> key map (__indexToKey); the ActiveMagicEffect payload itself
    always lives in one of the page arrays below. The mirror exists so RemoveElement()'s swap
    step can ask "which key owns the last slot?" in O(1) instead of scanning every key
    (measured at ~2.4s of pure scanning to drain 150 entries - see KNOWN_ISSUES.md). Both maps
    must always describe the same set of entries; ValidateIndexConsistency() checks exactly that.
/;

import RPB_Utility
import RPB_Memory

; =========================================================
;                          Paged storage
; =========================================================

;/
    32 pages x 32 elements = 1024 total capacity. Real documented scale (cell capacity data,
    the "Maximum Prisoners when Overcrowded" ceiling of 15) fits inside one 32-slot page with
    2x headroom, so the common case (an active container) only ever pays for page 0. Pages
    allocate lazily (only when Count first grows into them) and free themselves (see
    __FreePageIfNowUnused()) once Count shrinks back out of them - so an idle container costs
    nothing at all, and an active one costs one 32-slot page, not the 128-slot page this class
    used before this size was revisited.

    Raising the ceiling later is a mechanical change: add more __pageN fields, add the matching
    branches to __GetSlot()/__SetSlot()/__FreePageIfNowUnused() below,
    bump PAGE_COUNT to match - nothing else in this file needs to change. Papyrus has no
    array-of-arrays/jagged-array type and no dynamic field list, so a fixed, hand-declared set
    of page fields plus an if/elseif dispatch is the only way to do this at all.
/;
ActiveMagicEffect[] __page0
ActiveMagicEffect[] __page1
ActiveMagicEffect[] __page2
ActiveMagicEffect[] __page3
ActiveMagicEffect[] __page4
ActiveMagicEffect[] __page5
ActiveMagicEffect[] __page6
ActiveMagicEffect[] __page7
ActiveMagicEffect[] __page8
ActiveMagicEffect[] __page9
ActiveMagicEffect[] __page10
ActiveMagicEffect[] __page11
ActiveMagicEffect[] __page12
ActiveMagicEffect[] __page13
ActiveMagicEffect[] __page14
ActiveMagicEffect[] __page15
ActiveMagicEffect[] __page16
ActiveMagicEffect[] __page17
ActiveMagicEffect[] __page18
ActiveMagicEffect[] __page19
ActiveMagicEffect[] __page20
ActiveMagicEffect[] __page21
ActiveMagicEffect[] __page22
ActiveMagicEffect[] __page23
ActiveMagicEffect[] __page24
ActiveMagicEffect[] __page25
ActiveMagicEffect[] __page26
ActiveMagicEffect[] __page27
ActiveMagicEffect[] __page28
ActiveMagicEffect[] __page29
ActiveMagicEffect[] __page30
ActiveMagicEffect[] __page31

;/ const /; int PAGE_SIZE = 32
;/ const /; int PAGE_COUNT = 32

;/ FastMap<int> - key -> global index (pageIndex * PAGE_SIZE + slotIndex) /;
int __keyToIndex

;/ FastIntMap<string> - global index -> key, the exact mirror of __keyToIndex /;
int __indexToKey

int __count

int property Count
    int function get()
        return __count
    endFunction
endProperty

event OnInit()
    __keyToIndex = FastMap("<string>", true)
    __indexToKey = FastMap("<int>", true)
    __count = 0
endEvent

;/
    Defensive lazy-init, called first thing by every method that touches __keyToIndex.
    OnInit() alone isn't reliable for this: it's a ReferenceAlias lifecycle event that fires
    when an alias is FIRST bound - for an alias that already existed in a save from before a
    change to this script's fields, there's no guarantee it fires again, so __keyToIndex can
    still be an invalid/unset handle (0) on a real, already-populated alias. FastMap_SetInt/
    HasKey against an invalid handle are silent no-ops (no crash), which is exactly what let
    __count drift out of sync with reality before this guard existed: AddElement() kept
    incrementing __count on every call while the underlying map writes silently went nowhere.

    If __keyToIndex needed (re)allocating here, __count is reset to 0 in the same moment - not
    just for tidiness. If the handle was invalid, every prior "successful" AddElement for this
    alias was itself a no-op (nothing was ever really stored or retrievable), so a non-zero
    __count at this point is corrupted state from that same cause. Resetting both together
    heals the alias back to a genuinely empty, consistent state instead of leaving __count
    pointing past where AddElement would actually start writing once __keyToIndex works again.
/;
function __EnsureInitialized()
    if (!__keyToIndex)
        __keyToIndex = FastMap("<string>", true)
        __indexToKey = FastMap("<int>", true)
        __count = 0
    elseif (!__indexToKey)
        self.__RebuildIndexToKey()
    endif
endFunction

;/
    Second, distinct case from the one above: __keyToIndex is valid (and may hold real, live
    entries) but __indexToKey is unset. That's exactly what an alias saved before __indexToKey
    was added looks like once it loads under the new script - a new field defaults to 0 on
    existing aliases, and OnInit() doesn't re-fire. Unlike the case above, nothing here is
    corrupt: __keyToIndex and __count are trustworthy, so they're left alone and the mirror is
    simply derived from __keyToIndex in one O(n) pass. Runs at most once per alias.
/;
function __RebuildIndexToKey()
    __indexToKey = FastMap("<int>", true)

    string[] keys = FastMap_KeysAsPapyrusArray(__keyToIndex)
    int i = 0
    while (i < keys.Length)
        FastIntMap_SetString(__indexToKey, FastMap_GetInt(__keyToIndex, keys[i]), keys[i])
        i += 1
    endWhile
endFunction

; =========================================================
;                      Page dispatch helpers
; =========================================================

;/ Reads the element at @aiGlobalIndex. Returns None if its page was never allocated. /;
ActiveMagicEffect function __GetSlot(int aiGlobalIndex)
    int pageIndex = aiGlobalIndex / PAGE_SIZE
    int slotIndex = aiGlobalIndex % PAGE_SIZE

    if (pageIndex == 0)
        return __page0[slotIndex]
    elseif (pageIndex == 1)
        return __page1[slotIndex]
    elseif (pageIndex == 2)
        return __page2[slotIndex]
    elseif (pageIndex == 3)
        return __page3[slotIndex]
    elseif (pageIndex == 4)
        return __page4[slotIndex]
    elseif (pageIndex == 5)
        return __page5[slotIndex]
    elseif (pageIndex == 6)
        return __page6[slotIndex]
    elseif (pageIndex == 7)
        return __page7[slotIndex]
    elseif (pageIndex == 8)
        return __page8[slotIndex]
    elseif (pageIndex == 9)
        return __page9[slotIndex]
    elseif (pageIndex == 10)
        return __page10[slotIndex]
    elseif (pageIndex == 11)
        return __page11[slotIndex]
    elseif (pageIndex == 12)
        return __page12[slotIndex]
    elseif (pageIndex == 13)
        return __page13[slotIndex]
    elseif (pageIndex == 14)
        return __page14[slotIndex]
    elseif (pageIndex == 15)
        return __page15[slotIndex]
    elseif (pageIndex == 16)
        return __page16[slotIndex]
    elseif (pageIndex == 17)
        return __page17[slotIndex]
    elseif (pageIndex == 18)
        return __page18[slotIndex]
    elseif (pageIndex == 19)
        return __page19[slotIndex]
    elseif (pageIndex == 20)
        return __page20[slotIndex]
    elseif (pageIndex == 21)
        return __page21[slotIndex]
    elseif (pageIndex == 22)
        return __page22[slotIndex]
    elseif (pageIndex == 23)
        return __page23[slotIndex]
    elseif (pageIndex == 24)
        return __page24[slotIndex]
    elseif (pageIndex == 25)
        return __page25[slotIndex]
    elseif (pageIndex == 26)
        return __page26[slotIndex]
    elseif (pageIndex == 27)
        return __page27[slotIndex]
    elseif (pageIndex == 28)
        return __page28[slotIndex]
    elseif (pageIndex == 29)
        return __page29[slotIndex]
    elseif (pageIndex == 30)
        return __page30[slotIndex]
    elseif (pageIndex == 31)
        return __page31[slotIndex]
    endif

    return none
endFunction

;/
    Writes @apElement at @aiGlobalIndex, allocating that slot's page first if it doesn't exist.

    The allocation check is NESTED inside the branch that matched the page, on purpose. An
    earlier version did it as a separate __EnsurePageAllocated() helper whose branches read
    `if (aiPageIndex == N && !__pageN)`: once a page exists (nearly every call) that second
    condition is false, so the chain didn't stop at the matching branch - it fell through and
    evaluated every remaining branch too, ~32 comparisons at ~0.11ms each in-game (measured,
    see TROUBLESHOOTING_NOTES.md), on almost every write. Matching on the index alone lets the
    chain stop at the right page, and "already allocated" becomes a single check.
/;
function __SetSlot(int aiGlobalIndex, ActiveMagicEffect apElement)
    int pageIndex = aiGlobalIndex / PAGE_SIZE
    int slotIndex = aiGlobalIndex % PAGE_SIZE

    if (pageIndex == 0)
        if (!__page0)
            __page0 = new ActiveMagicEffect[32]
        endif
        __page0[slotIndex] = apElement
    elseif (pageIndex == 1)
        if (!__page1)
            __page1 = new ActiveMagicEffect[32]
        endif
        __page1[slotIndex] = apElement
    elseif (pageIndex == 2)
        if (!__page2)
            __page2 = new ActiveMagicEffect[32]
        endif
        __page2[slotIndex] = apElement
    elseif (pageIndex == 3)
        if (!__page3)
            __page3 = new ActiveMagicEffect[32]
        endif
        __page3[slotIndex] = apElement
    elseif (pageIndex == 4)
        if (!__page4)
            __page4 = new ActiveMagicEffect[32]
        endif
        __page4[slotIndex] = apElement
    elseif (pageIndex == 5)
        if (!__page5)
            __page5 = new ActiveMagicEffect[32]
        endif
        __page5[slotIndex] = apElement
    elseif (pageIndex == 6)
        if (!__page6)
            __page6 = new ActiveMagicEffect[32]
        endif
        __page6[slotIndex] = apElement
    elseif (pageIndex == 7)
        if (!__page7)
            __page7 = new ActiveMagicEffect[32]
        endif
        __page7[slotIndex] = apElement
    elseif (pageIndex == 8)
        if (!__page8)
            __page8 = new ActiveMagicEffect[32]
        endif
        __page8[slotIndex] = apElement
    elseif (pageIndex == 9)
        if (!__page9)
            __page9 = new ActiveMagicEffect[32]
        endif
        __page9[slotIndex] = apElement
    elseif (pageIndex == 10)
        if (!__page10)
            __page10 = new ActiveMagicEffect[32]
        endif
        __page10[slotIndex] = apElement
    elseif (pageIndex == 11)
        if (!__page11)
            __page11 = new ActiveMagicEffect[32]
        endif
        __page11[slotIndex] = apElement
    elseif (pageIndex == 12)
        if (!__page12)
            __page12 = new ActiveMagicEffect[32]
        endif
        __page12[slotIndex] = apElement
    elseif (pageIndex == 13)
        if (!__page13)
            __page13 = new ActiveMagicEffect[32]
        endif
        __page13[slotIndex] = apElement
    elseif (pageIndex == 14)
        if (!__page14)
            __page14 = new ActiveMagicEffect[32]
        endif
        __page14[slotIndex] = apElement
    elseif (pageIndex == 15)
        if (!__page15)
            __page15 = new ActiveMagicEffect[32]
        endif
        __page15[slotIndex] = apElement
    elseif (pageIndex == 16)
        if (!__page16)
            __page16 = new ActiveMagicEffect[32]
        endif
        __page16[slotIndex] = apElement
    elseif (pageIndex == 17)
        if (!__page17)
            __page17 = new ActiveMagicEffect[32]
        endif
        __page17[slotIndex] = apElement
    elseif (pageIndex == 18)
        if (!__page18)
            __page18 = new ActiveMagicEffect[32]
        endif
        __page18[slotIndex] = apElement
    elseif (pageIndex == 19)
        if (!__page19)
            __page19 = new ActiveMagicEffect[32]
        endif
        __page19[slotIndex] = apElement
    elseif (pageIndex == 20)
        if (!__page20)
            __page20 = new ActiveMagicEffect[32]
        endif
        __page20[slotIndex] = apElement
    elseif (pageIndex == 21)
        if (!__page21)
            __page21 = new ActiveMagicEffect[32]
        endif
        __page21[slotIndex] = apElement
    elseif (pageIndex == 22)
        if (!__page22)
            __page22 = new ActiveMagicEffect[32]
        endif
        __page22[slotIndex] = apElement
    elseif (pageIndex == 23)
        if (!__page23)
            __page23 = new ActiveMagicEffect[32]
        endif
        __page23[slotIndex] = apElement
    elseif (pageIndex == 24)
        if (!__page24)
            __page24 = new ActiveMagicEffect[32]
        endif
        __page24[slotIndex] = apElement
    elseif (pageIndex == 25)
        if (!__page25)
            __page25 = new ActiveMagicEffect[32]
        endif
        __page25[slotIndex] = apElement
    elseif (pageIndex == 26)
        if (!__page26)
            __page26 = new ActiveMagicEffect[32]
        endif
        __page26[slotIndex] = apElement
    elseif (pageIndex == 27)
        if (!__page27)
            __page27 = new ActiveMagicEffect[32]
        endif
        __page27[slotIndex] = apElement
    elseif (pageIndex == 28)
        if (!__page28)
            __page28 = new ActiveMagicEffect[32]
        endif
        __page28[slotIndex] = apElement
    elseif (pageIndex == 29)
        if (!__page29)
            __page29 = new ActiveMagicEffect[32]
        endif
        __page29[slotIndex] = apElement
    elseif (pageIndex == 30)
        if (!__page30)
            __page30 = new ActiveMagicEffect[32]
        endif
        __page30[slotIndex] = apElement
    elseif (pageIndex == 31)
        if (!__page31)
            __page31 = new ActiveMagicEffect[32]
        endif
        __page31[slotIndex] = apElement
    endif
endFunction

;/
    Frees @aiPageIndex's backing array (sets it to None, letting Papyrus reclaim it like any
    other reference - see the top-of-file doc comment) if dense-packing no longer needs it,
    i.e. no live index [0, Count) falls inside it anymore. Only ever called by RemoveElement()
    with the one page that could have just become unused (Count changes by at most 1 per
    call), so no loop over every page is needed here.
/;
function __FreePageIfNowUnused(int aiPageIndex)
    int pagesStillNeeded = 0
    if (__count > 0)
        pagesStillNeeded = ((__count - 1) / PAGE_SIZE) + 1
    endif

    if (aiPageIndex < pagesStillNeeded)
        return
    endif

    if (aiPageIndex == 0)
        __page0 = none
    elseif (aiPageIndex == 1)
        __page1 = none
    elseif (aiPageIndex == 2)
        __page2 = none
    elseif (aiPageIndex == 3)
        __page3 = none
    elseif (aiPageIndex == 4)
        __page4 = none
    elseif (aiPageIndex == 5)
        __page5 = none
    elseif (aiPageIndex == 6)
        __page6 = none
    elseif (aiPageIndex == 7)
        __page7 = none
    elseif (aiPageIndex == 8)
        __page8 = none
    elseif (aiPageIndex == 9)
        __page9 = none
    elseif (aiPageIndex == 10)
        __page10 = none
    elseif (aiPageIndex == 11)
        __page11 = none
    elseif (aiPageIndex == 12)
        __page12 = none
    elseif (aiPageIndex == 13)
        __page13 = none
    elseif (aiPageIndex == 14)
        __page14 = none
    elseif (aiPageIndex == 15)
        __page15 = none
    elseif (aiPageIndex == 16)
        __page16 = none
    elseif (aiPageIndex == 17)
        __page17 = none
    elseif (aiPageIndex == 18)
        __page18 = none
    elseif (aiPageIndex == 19)
        __page19 = none
    elseif (aiPageIndex == 20)
        __page20 = none
    elseif (aiPageIndex == 21)
        __page21 = none
    elseif (aiPageIndex == 22)
        __page22 = none
    elseif (aiPageIndex == 23)
        __page23 = none
    elseif (aiPageIndex == 24)
        __page24 = none
    elseif (aiPageIndex == 25)
        __page25 = none
    elseif (aiPageIndex == 26)
        __page26 = none
    elseif (aiPageIndex == 27)
        __page27 = none
    elseif (aiPageIndex == 28)
        __page28 = none
    elseif (aiPageIndex == 29)
        __page29 = none
    elseif (aiPageIndex == 30)
        __page30 = none
    elseif (aiPageIndex == 31)
        __page31 = none
    endif
endFunction

;/
    Reverse lookup: the key currently mapped to @aiIndex, straight from __indexToKey (O(1)).
    Only ever called by RemoveElement(), for the one element being moved during a swap. This
    used to be an O(n) scan over every key in __keyToIndex, which dominated removal cost at
    scale (see KNOWN_ISSUES.md). Callers must have run __EnsureInitialized() first.
/;
string function __FindKeyForIndex(int aiIndex)
    return FastIntMap_GetString(__indexToKey, aiIndex)
endFunction

; =========================================================
;                            Public
; =========================================================

bool function HasKey(string asKey)
    self.__EnsureInitialized()
    return FastMap_HasKey(__keyToIndex, asKey)
endFunction

ActiveMagicEffect function GetAt(string asKey)
    if (!self.HasKey(asKey))
        return none
    endif

    return self.__GetSlot(FastMap_GetInt(__keyToIndex, asKey))
endFunction

;/
    Returns the element at logical index @aiIndex, where 0 <= aiIndex < Count. Elements are
    always densely packed, so this is a direct, safe 0..Count-1 walk - no gaps to skip, no
    out-of-bounds risk beyond the explicit check below.
/;
ActiveMagicEffect function FromIndex(int aiIndex)
    if (aiIndex < 0 || aiIndex >= __count)
        return none
    endif

    return self.__GetSlot(aiIndex)
endFunction

int function GetSize()
    return __count
endFunction

bool function IsEmpty()
    return __count <= 0
endFunction

string[] function GetKeys()
    self.__EnsureInitialized()
    return FastMap_KeysAsPapyrusArray(__keyToIndex)
endFunction

;/
    Adds @element under @elementKey. No-ops (logs an error, doesn't corrupt anything) if the
    key already exists, or if every configured page is already full.
/;
function AddElement(ActiveMagicEffect element, string elementKey)
    int threadLock = self.__GetThreadLock()
    self.__AcquireThreadLock(threadLock)
    self.__AddElementImpl(element, elementKey)
    RPB_ThreadLock.Release(threadLock)
endFunction

;/
    Puts @element under @elementKey, in the slot the key already has (the count and the index maps do not change), or adds
    it when the key is new. Never dispels the previous element: it is typically the stale instance of an effect that ended
    when its actor unloaded (a reload starts a NEW instance, and Add refuses a duplicate key).
/;
function ReplaceElement(ActiveMagicEffect element, string elementKey)
    int threadLock = self.__GetThreadLock()
    self.__AcquireThreadLock(threadLock)

    if (self.HasKey(elementKey))
        self.__SetSlot(FastMap_GetInt(__keyToIndex, elementKey), element)
    else
        self.__AddElementImpl(element, elementKey)
    endif

    RPB_ThreadLock.Release(threadLock)
endFunction

function __AddElementImpl(ActiveMagicEffect element, string elementKey)
    if (self.HasKey(elementKey))
        Error("Element "+ elementKey +" already exists, cannot add it again!")
        return
    endif

    if (__count >= PAGE_SIZE * PAGE_COUNT)
        Error("ActiveMagicEffectContainer is full ("+ (PAGE_SIZE * PAGE_COUNT) +" entries) - cannot add "+ elementKey +"!")
        return
    endif

    self.__SetSlot(__count, element)
    FastMap_SetInt(__keyToIndex, elementKey, __count)
    FastIntMap_SetString(__indexToKey, __count, elementKey)
    __count += 1
endFunction

;/
    Removes the element stored under @elementKey. If it isn't the last live element, the
    current last element is moved into its slot first (keeping storage dense, no gaps), then
    the vacated last slot is cleared. If that leaves the page it was in entirely unused, that
    page gets freed too (see __FreePageIfNowUnused()).
/;
function RemoveElement(string elementKey, bool dispel = true)
    int threadLock = self.__GetThreadLock()
    self.__AcquireThreadLock(threadLock)
    ActiveMagicEffect removedElement = self.__RemoveElementImpl(elementKey)
    RPB_ThreadLock.Release(threadLock)

    ; Dispelled only after the lock is released: the effect's own callbacks (OnEffectFinish /
    ; OnDestroy) run on other threads and must never end up waiting on a lock still held here
    if (dispel && removedElement)
        ; A stale instance (its effect already ended, e.g. the actor unloaded) has no native object left: Dispel would only error
        RPB_ActorBase removedActorBase = removedElement as RPB_ActorBase
        if (!removedActorBase || removedActorBase.IsEffectActive)
            removedElement.Dispel()
        endif
    endif
endFunction

;/
    The real removal, run while holding the thread lock. Returns the element that was removed (None if
    the key wasn't present, or its payload was None) so RemoveElement() can dispel it afterwards.
/;
ActiveMagicEffect function __RemoveElementImpl(string elementKey)
    if (!self.HasKey(elementKey))
        return none
    endif

    int removedIndex = FastMap_GetInt(__keyToIndex, elementKey)
    ActiveMagicEffect removedElement = self.__GetSlot(removedIndex)

    int lastIndex = __count - 1

    if (removedIndex != lastIndex)
        ActiveMagicEffect lastElement = self.__GetSlot(lastIndex)
        self.__SetSlot(removedIndex, lastElement)

        string lastElementKey = self.__FindKeyForIndex(lastIndex)
        if (lastElementKey != "")
            FastMap_SetInt(__keyToIndex, lastElementKey, removedIndex)
            FastIntMap_SetString(__indexToKey, removedIndex, lastElementKey)
        endif
    endif

    self.__SetSlot(lastIndex, none)
    FastMap_RemoveKey(__keyToIndex, elementKey)
    FastIntMap_RemoveKey(__indexToKey, lastIndex)
    __count -= 1

    self.__FreePageIfNowUnused(lastIndex / PAGE_SIZE)
    return removedElement
endFunction

; =========================================================
;                  Concurrency guard (RPB_ThreadLock)
; =========================================================

;/
    AddElement/RemoveElement are multi-step (read Count, write a slot, write two maps, bump
    Count), and Papyrus can switch to another thread in the middle (JContainers natives and
    latent calls are suspension points). Two simultaneous callers - two actors registering in the
    same window - used to read the same Count and overwrite each other, leaving Count out of
    step with both maps: reproduced in-game by test 39 (8 worker threads: 155 reverse-map
    entries vs Count 160, keys left behind after concurrent removes, Count 29 vs 40 expected).

    Both mutators now hold an RPB_ThreadLock (JContainers JAtomic compare-exchange, a genuinely
    atomic test-and-set) around the real work. It replaced an earlier guard built on a "Busy"
    script state, which worked but had a documented one-instruction window and couldn't be
    reused by other scripts; measured head to head (tests 45/46, since retired) the thread lock
    was within ~5% of it per operation uncontended and at least as fast under contention, and
    test 43 proved it mutually exclusive even with threads suspended inside the section.

    Deliberate details:
      - The lock is per container instance, named AME_<quest id>_<alias id>, and fetched lazily
        into __threadLock (a new field defaults to 0 on aliases saved before it existed).
        RPB_ThreadLock.Get() is atomic, so simultaneous first callers all get the same lock.
      - Waiters sleep a random 0.02-0.06s, bounded (~5s); a thread that dies while holding the
        lock can't deadlock the list - the next caller logs an error and force-takes it. When that
        happens the cached handle is dropped so the next call re-fetches a known-good lock
        instead of stalling on a stale one.
      - Dispel() runs after the lock is released, so effect callbacks never wait on a lock still
        held by their own caller.
      - Reads (HasKey, GetAt, FromIndex, GetKeys, Count) are NOT locked: Count is bumped last on
        an Add, so a reader never sees an unwritten slot; overlapping a swap, a reader can at
        worst see the moved element in two slots for a moment.
      - Requires a JContainers build that includes JAtomic. If its natives are missing, every
        call would silently "succeed" and the lock would protect nothing, so the first fetch
        checks RPB_ThreadLock.IsWorking() and logs an error if it doesn't.
/;
int __threadLock

int function __GetThreadLock()
    if (!__threadLock)
        int formId = self.GetOwningQuest().GetFormID()
        string idPart = formId
        if (formId < 0)
            idPart = "n" + (0 - formId)
        endif

        int found = RPB_ThreadLock.Get("AME_" + idPart + "_" + self.GetID())
        if (!RPB_ThreadLock.IsWorking())
            Error("RPB_ThreadLock is not working on this install (JContainers without JAtomic?) - ActiveMagicEffectContainer's Add/Remove are NOT protected against simultaneous callers!")
        endif

        __threadLock = found
    endif

    return __threadLock
endFunction

function __AcquireThreadLock(int aiThreadLock)
    if (!RPB_ThreadLock.Acquire(aiThreadLock))
        ; Had to force-take it: the previous holder never released it (or this handle is stale).
        ; Re-fetch a known-good lock next time rather than keep stalling on this one.
        __threadLock = 0
    endif
endFunction

;/
    Alias for RemoveElement() - kept for RPB_CaptorList.Remove(), the one real caller still
    using this name. Both removal paths are now the exact same dense-packing operation,
    resolving a previously-documented "two different removal code paths for the same
    operation" design smell as a side effect of this refactor.
/;
function protected_remove(string asKey, bool dispel = true)
    self.RemoveElement(asKey, dispel)
endFunction

; =========================================================
;                  Inspection / self-check
; =========================================================

;/
    The key stored at logical index @aiIndex (0 <= aiIndex < Count), or "" if out of range.
    Reads the reverse map directly, so it doubles as a cheap public probe of it.
/;
string function GetKeyAtIndex(int aiIndex)
    self.__EnsureInitialized()

    if (aiIndex < 0 || aiIndex >= __count)
        return ""
    endif

    return FastIntMap_GetString(__indexToKey, aiIndex)
endFunction

;/
    Verifies the forward (key -> index) and reverse (index -> key) maps agree with each other
    and with Count. Returns "" if everything is consistent, otherwise a description of the
    first inconsistency found. O(n) - meant for tests/debugging, never for hot paths.

    Checks: both maps hold exactly Count entries; every key maps to an in-range index whose
    reverse entry is that same key; every index in [0, Count) has a reverse entry whose key
    maps straight back to that index. (Count entries each way + every forward entry
    round-tripping already makes the maps exact inverses; the second walk is kept anyway
    because it fails with a more specific message when the reverse map has a stray/missing
    entry.)
/;
string function ValidateIndexConsistency()
    self.__EnsureInitialized()

    int forwardSize = FastMap_Size(__keyToIndex)
    int reverseSize = FastMap_Size(__indexToKey)
    if (forwardSize != __count)
        return "key->index map holds " + forwardSize + " entries but Count is " + __count
    endif
    if (reverseSize != __count)
        return "index->key map holds " + reverseSize + " entries but Count is " + __count
    endif

    string[] keys = FastMap_KeysAsPapyrusArray(__keyToIndex)
    int mappedIndex = 0
    string reverseKey = ""

    int i = 0
    while (i < keys.Length)
        mappedIndex = FastMap_GetInt(__keyToIndex, keys[i])
        if (mappedIndex < 0 || mappedIndex >= __count)
            return "key '" + keys[i] + "' maps to out-of-range index " + mappedIndex + " (Count " + __count + ")"
        endif

        reverseKey = FastIntMap_GetString(__indexToKey, mappedIndex)
        if (reverseKey != keys[i])
            return "key '" + keys[i] + "' -> index " + mappedIndex + ", but index " + mappedIndex + " -> '" + reverseKey + "'"
        endif
        i += 1
    endWhile

    string keyAtIndex = ""
    i = 0
    while (i < __count)
        keyAtIndex = FastIntMap_GetString(__indexToKey, i)
        if (keyAtIndex == "")
            return "index " + i + " has no key in the index->key map (Count " + __count + ")"
        endif
        if (!FastMap_HasKey(__keyToIndex, keyAtIndex) || FastMap_GetInt(__keyToIndex, keyAtIndex) != i)
            return "index " + i + " -> '" + keyAtIndex + "', but that key doesn't map back to index " + i
        endif
        i += 1
    endWhile

    return ""
endFunction

;/
    TEST HOOK ONLY. Takes this container's thread lock and never releases it - the state a
    thread that died mid-Add/Remove would leave behind - so the bounded, self-healing wait can
    be exercised in-game.
/;
function DebugSimulateStuckLock()
    RPB_ThreadLock.Acquire(self.__GetThreadLock())
endFunction

;/
    TEST HOOK ONLY. This container's thread lock handle, so a test can look at the lock word
    (0 = free, 1 = held) without taking it - e.g. to see whether an earlier test left it held.
/;
int function DebugGetThreadLockHandle()
    return self.__GetThreadLock()
endFunction

;/
    TEST HOOK ONLY. Puts this alias into the exact state an alias saved before __indexToKey
    existed loads into (valid __keyToIndex and __count, __indexToKey unset) so the migration
    path in __EnsureInitialized() can be exercised in-game without needing an old save. The
    next call to any container method must silently rebuild the mirror.
/;
function DebugSimulateMissingReverseIndex()
    if (__indexToKey)
        FastMap_Release(__indexToKey)
    endif

    __indexToKey = 0
endFunction

;/
    TEST HOOKS ONLY. The raw JContainers handles behind the two maps, so a test can prove Add and
    Remove never allocate JContainers objects per operation (a leak would show up as a handle
    changing, or no longer existing, across many cycles).
/;
int function DebugGetKeyToIndexHandle()
    return __keyToIndex
endFunction

int function DebugGetIndexToKeyHandle()
    return __indexToKey
endFunction

;/
    TEST HOOK ONLY. Drops every entry without dispelling anything and returns the container to
    a genuinely empty state: fresh empty maps (old ones released), Count 0, every page freed.
    Exists so a concurrency stress test that finds the container corrupted can leave the live
    list clean instead of broken. NEVER call this on a container that holds real entries.
/;
function DebugForceReset()
    if (__keyToIndex)
        FastMap_Release(__keyToIndex)
    endif
    if (__indexToKey)
        FastMap_Release(__indexToKey)
    endif

    __keyToIndex = FastMap("<string>", true)
    __indexToKey = FastMap("<int>", true)
    __count = 0

    int page = 0
    while (page < PAGE_COUNT)
        self.__FreePageIfNowUnused(page)
        page += 1
    endWhile
endFunction

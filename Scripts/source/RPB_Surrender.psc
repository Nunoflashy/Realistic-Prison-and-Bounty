scriptname RPB_Surrender extends Quest

;/
    The surrender (split from RPB_Arrest, 2026-10-14): an actor fighting a hold's guards gives up. Their combat targets read
    once, the checks, the pose (the weapons in hand dropped), the guards calmed, the Surrender Scene, the watch until a
    guard takes it or they leave, and its endings: the arrest (RPB_Arrest.ArrestActor), a fake surrender and the guards'
    memory of it, a withdrawn or expired one. Also a takeover's approach (a guard walking over to take a frozen guard's
    submission), which runs on the same machinery. What's taken from them is RPB_Confiscation's. The player's surrender key
    and the controls that end the cower are registered on this script.

@constants:
    float SURRENDER_EXPIRE_SECONDS
    float SURRENDER_LEAVE_DISTANCE
    float SURRENDER_TAKEN_DISTANCE
    int SURRENDER_SCENE_RETRIES
    int SURRENDER_DODGES
    float SURRENDER_FIGHT_WAIT_SECONDS
@references:
    RPB_API API
    RPB_Config Config
    RPB_EventManager EventManager
    RPB_SceneManager SceneManager
    RPB_Arrest Arrest
    RPB_Confiscation Confiscation
@properties:
    string LastSurrenderOutcome
@functions:
    function BeginTakeoverApproach(Actor akActor, Actor akGuard)
    function __RegisterSurrenderControls(bool abRegister)
    bool function __IsTakeoverApproach(Actor akActor)
    function __EludeTakeover(Actor akActor)
    function Surrender(Actor akSurrenderer)
    function SnapshotSurrenderTargets(Actor akSurrenderer, Actor[] akCombatTargets)
    int function __SurrenderSnapshot(Actor akSurrenderer)
    function __ForgetSurrenderSnapshot(Actor akSurrenderer)
    Actor[] function __SnapshotGuards(Actor akSurrenderer)
    Actor function __SnapshotOther(Actor akSurrenderer)
    bool function CanActorSurrender(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    bool function IsSurrenderGuard(Actor akActor)
    bool function __IsStillSurrenderGuard(Actor akGuard)
    bool function HasSurrenderGuard(Actor[] akCombatTargets)
    Actor function GetNonGuardCombatTarget(Actor[] akCombatTargets)
    bool function __IsOfAGuardsCrimeFaction(Actor akActor, Actor[] akCombatTargets)
    Actor[] function GetSurrenderGuards(Actor[] akCombatTargets)
    function __PacifyForSurrender(Actor akSurrenderer, Actor[] akGuards)
    bool function __IsFightingOthers(Actor akGuard, Actor akSurrenderer)
    bool function __GuardsFightingOthers(Actor akSurrenderer, Actor[] akGuards)
    function SurrenderLog(string asMessage) global
    bool function IsSurrendering(Actor akActor)
    function __BeginSurrender(Actor akActor)
    bool function __ClaimSurrender(Actor akActor)
    function __UndoSurrender(Actor akSurrenderer, string asReason, bool abEndScene = true, bool abNotify = true)
    function AbortSurrender(Actor akSurrenderer, string asReason, bool abEndScene = true)
    function __WatchSurrender(Actor akSurrenderer, Actor[] akGuards)
    function OnSurrenderSceneFailed(Actor akSurrenderer)
    string function __GuardsInCombat(Actor[] akGuards)
    int function __NearestGuardIndex(Actor akSurrenderer, Actor[] akGuards)
    float function __GuardDistance(Actor akSurrenderer, Actor[] akGuards, int aiIndex)
    Actor function __NearestSurrenderGuard(Actor akSurrenderer, Actor[] akGuards, Actor akFallback)
    function __FakeSurrender(Actor akSurrenderer, Actor[] akGuards)
    function __WithdrawSurrender(Actor akSurrenderer)
    string function __FakedUntilKey(Faction akFaction)
    bool function HasFakedSurrenderTo(Actor akActor, Faction akFaction)
    float function GetFakedSurrenderUntil(Actor akActor, Faction akFaction)
    function __RememberFakeSurrender(Actor akActor, Faction akFaction)
    function ForgetFakeSurrenders(Actor akActor)
    function ApplySurrenderPenalty(Actor akSurrenderer, Faction akFaction)
    function ApplyFakeSurrenderPenalty(Actor akSurrenderer, Faction akFaction)
    function __AddSurrenderBounty(Actor akSurrenderer, Faction akFaction, float afPercent, int aiFlat, string asFor)
    function PrepareSurrenderer(Actor akSurrenderer, Actor[] akGuards = none)
    int function DropWeaponsInHand(Actor akSurrenderer)
    function __SheatheAfterDrop(Actor akSurrenderer)
    bool function __IsTwoHanded(Form akItem)
    function __DropFromHand(Actor akSurrenderer, Form akItem, int aiRefs, int aiItems)
    function InitiateSurrenderScene(Actor akSurrenderer, Actor[] akSurrendererCaptors)
@events:
    event OnInit()
    event OnKeyDown(int keyCode)
    event OnControlDown(string asControl)
    event OnSurrenderBegin(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    event OnSurrenderEnd(Actor akSurrenderer, Actor akCaptor)
/;

import Math
import RPB_Config
import PO3_SKSEFunctions
import RPB_Utility

; ==========================================================
;                      Script References
; ==========================================================

RPB_API property API
    RPB_API function get()
        return RPB_API.GetSelf()
    endFunction
endProperty

RPB_Config property Config
    RPB_Config function get()
        return API.Config
    endFunction
endProperty

RPB_EventManager property EventManager
    RPB_EventManager function get()
        return API.EventManager
    endFunction
endProperty

RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
    endFunction
endProperty

RPB_Arrest property Arrest
    RPB_Arrest function get()
        return API.Arrest
    endFunction
endProperty

RPB_Confiscation property Confiscation
    RPB_Confiscation function get()
        return API.Confiscation
    endFunction
endProperty

; ==========================================================

; The surrender key (rebindable on the MCM's Keybindings page) is registered on this script
event OnInit()
    RPB_Keybindings.RegisterSurrenderKey()
endEvent

;/
    A takeover's approach (RPB_Arrest.TakeOverSubmission): @akGuard walks over to @akActor, who had submitted to a guard
    that froze, through the Surrender Scene: the surrender's poses (without them the player couldn't tell they were held,
    and a step ended it as eluding, 2026-10-04; the same as a surrender's for now, poses of its own later), its watch
    (leaving is eluding: __EludeTakeover), its end (the arrest with the set-aside bounty, no surrender penalty). Runs on the
    caller's stack until the Scene's end arrests them, or they leave
/;
function BeginTakeoverApproach(Actor akActor, Actor akGuard)
    Actor[] guards = new Actor[1]
    guards[0] = akGuard
    __surrenderGuards = guards
    self.__BeginSurrender(akActor)
    RPB_StorageVars.SetBoolOnReference("Takeover", akActor, true, "Surrender")
    self.PrepareSurrenderer(akActor, guards)
    self.InitiateSurrenderScene(akActor, guards)
    self.__WatchSurrender(akActor, guards)
endFunction


event OnKeyDown(int keyCode)
    if (keyCode == RPB_Keybindings.GetKey("Surrender") && !Utility.IsInMenuMode())
        Debug("Arrest::OnKeyDown", "the surrender key pressed (state '" + self.GetState() + "'), sending the surrender")
        self.Surrender(Config.Player)
    endif
endEvent

; The controls that end the surrender's cower (it loops and ignores movement): the surrender watch registers them
function __RegisterSurrenderControls(bool abRegister)
    string[] controls = new string[8]
    controls[0] = "Forward"
    controls[1] = "Back"
    controls[2] = "Strafe Left"
    controls[3] = "Strafe Right"
    controls[4] = "Move"
    controls[5] = "Jump"
    controls[6] = "Sprint"
    controls[7] = "Ready Weapon"
    int i = 0
    while (i < controls.Length)
        if (abRegister)
            RegisterForControl(controls[i])
        else
            UnregisterForControl(controls[i])
        endif
        i += 1
    endWhile
endFunction

; The player moving (or readying a weapon) while surrendering: out of the cower, so the input takes effect. The watch then
; sees them leave (or a guard close enough takes it anyway).
event OnControlDown(string asControl)
    Actor player = Config.Player
    if (!RPB_StorageVars.GetBoolOnReference("Surrendering", player, "Surrender"))
        return
    endif
    SurrenderLog("Surrender of " + player + ": '" + asControl + "' pressed, leaving the surrender pose")
    Debug.SendAnimationEvent(player, "IdleForceDefaultState")
    if (asControl == "Ready Weapon")
        player.DrawWeapon() ; the press was spent leaving the idle
    endif
endEvent

; A takeover's approach (TakeOverSubmission), not a surrender the player chose: leaving is eluding, its end arrests with
; the set-aside bounty and no surrender penalty
bool function __IsTakeoverApproach(Actor akActor)
    return RPB_StorageVars.GetBoolOnReference("Takeover", akActor, "Surrender")
endFunction

; They left while the takeover guard was coming: they had agreed to go to jail, so that's eluding arrest. The bounty comes
; back with the eluding penalty on top, and the guards deal with it the vanilla way
function __EludeTakeover(Actor akActor)
    if (!self.__ClaimSurrender(akActor))
        return
    endif
    Actor[] noGuards
    __surrenderGuards = noGuards
    LastSurrenderOutcome = "eluded a takeover"
    Faction crimeFaction = RPB_StorageVars.GetFormOnReference("Faction", akActor, "Set-Aside Bounty") as Faction
    self.__UndoSurrender(akActor, "they left while the guard taking over their arrest was coming (eluding)", abNotify = false)
    if (crimeFaction)
        Arrest.ApplyArrestEludedPenalty(crimeFaction)
    endif
endFunction

event OnSurrenderBegin(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    self.__BeginSurrender(akSurrenderer)
    RPB_Utility.FlowMark("Surrender: begun (marked surrendering)")
    Actor outsider = none
    Actor[] guards
    if (self.__SurrenderSnapshot(akSurrenderer)) ; the targets as SnapshotSurrenderTargets saw them a moment ago
        outsider = self.__SnapshotOther(akSurrenderer)
        guards = self.__SnapshotGuards(akSurrenderer)
        self.__ForgetSurrenderSnapshot(akSurrenderer)
    else
        outsider = self.GetNonGuardCombatTarget(akSurrendererCaptors)
        guards = self.GetSurrenderGuards(akSurrendererCaptors)
    endif
    if (outsider)
        RPB_StorageVars.SetFormOnReference("Outsider", akSurrenderer, outsider, "Surrender") ; the watch's leeway
    endif
    __surrenderGuards = guards
    RPB_Utility.FlowMark("Surrender: outsider and guards found (" + guards.Length + ")")
    self.PrepareSurrenderer(akSurrenderer, guards)
    RPB_Utility.FlowMark("Surrender: surrenderer prepared (pose)")
    ; Ended while the pose was being prepared (2s; test 145's teardown, or the surrenderer leaving): it stops here. It went on
    ; to calm the guards and start the Surrender Scene with nothing surrendering any more, a guard left running to the player
    ; (2026-10-06)
    if (!self.IsSurrendering(akSurrenderer))
        return
    endif
    self.__PacifyForSurrender(akSurrenderer, guards)
    RPB_Utility.FlowMark("Surrender: guards calmed")
    if (!self.IsSurrendering(akSurrenderer))
        return
    endif
    self.InitiateSurrenderScene(akSurrenderer, guards)
    RPB_Utility.FlowMark("Surrender: Scene bound and queued")
    ; Runs on this event's own stack until the Scene's end takes the surrender over, or the surrenderer leaves
    self.__WatchSurrender(akSurrenderer, guards)
endEvent

event OnSurrenderEnd(Actor akSurrenderer, Actor akCaptor)
    bool takeover = self.__IsTakeoverApproach(akSurrenderer) ; read before the claim clears it
    ; Already over (they left, an abort): a Scene end arriving late must not arrest anyone
    if (!self.__ClaimSurrender(akSurrenderer))
        SurrenderLog("Surrender Scene of " + akSurrenderer + " ended after the surrender was already over, ignored")
        return
    endif

    ; The Scene's first captor slot is the guard nearest at its start; whoever is nearest now is the one who got there
    akCaptor = self.__NearestSurrenderGuard(akSurrenderer, __surrenderGuards, akCaptor)
    Actor[] noGuards
    __surrenderGuards = noGuards

    if (!self.__IsStillSurrenderGuard(akCaptor)) ; one of the surrender's own guards (the nearest of them, or the Scene's)
        LastSurrenderOutcome = "no guard at the end"
        self.__UndoSurrender(akSurrenderer, "the Scene ended without a guard (captor " + akCaptor + ")")
        return
    endif

    Faction crimeFaction = akCaptor.GetCrimeFaction()
    if (!takeover) ; a takeover's arrest is the player's own submission, set aside: no surrender penalty
        self.ApplySurrenderPenalty(akSurrenderer, crimeFaction)
    endif
    ; The arrest rejects an actor with no bounty, and nothing would give the player back their controls after that
    if (RPB_ActorBase.GetCurrentActiveAndLatentBountyForFaction(akSurrenderer, crimeFaction) <= 0 && !RPB_Arrest.HasSetAsideBounty(akSurrenderer))
        LastSurrenderOutcome = "no bounty"
        self.__UndoSurrender(akSurrenderer, "no bounty in " + RPB_Utility.GetFormNameCached(crimeFaction) + " and no bounty for surrendering is set")
        return
    endif

    LastSurrenderOutcome = "arrest"
    Arrest.ArrestActor(akCaptor, akSurrenderer, Arrest.ARREST_TYPE_ESCORT_TO_JAIL, abKeepFlow = true)
endEvent

;/
    Starts the Surrender procedure for this Actor.

    The verification is handled through EventManager,
    and it's handled by OnSurrenderPreparing

    Actor   @akSurrenderer: The actor that is about to surrender.
/;
function Surrender(Actor akSurrenderer)
    RPB_Utility.FlowBegin("Surrender -> Imprison") ; only with the flow profiler on
    int handle = ModEvent.Create("RPB_Surrender")
    if (handle)
        ModEvent.PushForm(handle, akSurrenderer)
        ModEvent.Send(handle)
    endif
endFunction

; ==========================================================
;                      Surrender-Specific

;/
    Each of @akCombatTargets looked at once, the answers kept for the surrender's checks (CanActorSurrender) and its begin
    (OnSurrenderBegin). They used to look at every target three times in CanActorSurrender (a non-guard, a guard, a fooled
    hold) and a fourth in GetSurrenderGuards, 4-5 calls each (a frame apiece: ~1.5s with 6 guards; 2026-10-14). Here: dead read engine side (no call), disabled, guard, crime faction: 3 calls a
    target. Kept in JDB .rpb_root.surrenderTargets (surrenderer -> { guards, factions, other }) until her surrender begins
/;
function SnapshotSurrenderTargets(Actor akSurrenderer, Actor[] akCombatTargets)
    int guards = JArray.object()
    int factions = JArray.object()
    int others = JArray.object()        ; living non-guards, the law or not (decided below)
    int otherFactions = JArray.object()
    int i = 0
    while (akCombatTargets && i < akCombatTargets.Length)
        Actor target = akCombatTargets[i]
        if (target && !RPB_Utility.IsFrozenNPC(target) && !RPB_Utility.IsDeadNoCall(target) && !target.IsDisabled())
            Faction crime = target.GetCrimeFaction()
            if (target.IsGuard())
                if (crime) ; a guard of a hold takes a surrender (one with no crime faction neither takes it nor counts as other)
                    JArray.addForm(guards, target)
                    JArray.addForm(factions, crime)
                endif
            else
                JArray.addForm(others, target)
                JArray.addForm(otherFactions, crime)
            endif
        endif
        i += 1
    endWhile
    ; The first non-guard who isn't the law: not of a guard's crime faction (Captain Aldis: not flagged a guard, Solitude's)
    Form other = none
    int o = 0
    while (!other && o < JArray.count(others))
        Actor candidate = JArray.getForm(others, o) as Actor
        Form ownCrime = JArray.getForm(otherFactions, o)
        bool law = false
        int g = 0
        while (!law && g < JArray.count(factions))
            Faction guardCrime = JArray.getForm(factions, g) as Faction
            law = guardCrime == ownCrime || candidate.IsInFaction(guardCrime)
            g += 1
        endWhile
        if (!law)
            other = candidate
        endif
        o += 1
    endWhile
    int snapshot = JMap.object()
    RPB_Memory.FastMap_SetObject(snapshot, "guards", guards)
    RPB_Memory.FastMap_SetObject(snapshot, "factions", factions)
    RPB_Memory.FastMap_SetForm(snapshot, "other", other)
    int all = JDB.solveObj(".rpb_root.surrenderTargets")
    if (!all)
        all = JFormMap.object()
        JDB.solveObjSetter(".rpb_root.surrenderTargets", all, true)
    endif
    RPB_Memory.FastFormMap_SetObject(all, akSurrenderer, snapshot)
endFunction

int function __SurrenderSnapshot(Actor akSurrenderer)
    int all = JDB.solveObj(".rpb_root.surrenderTargets")
    if (!all)
        return 0
    endif
    return RPB_Memory.FastFormMap_GetObject(all, akSurrenderer)
endFunction

function __ForgetSurrenderSnapshot(Actor akSurrenderer)
    int all = JDB.solveObj(".rpb_root.surrenderTargets")
    if (all)
        RPB_Memory.FastFormMap_RemoveKey(all, akSurrenderer)
    endif
endFunction

; The snapshot's surrender guards (6 at most, as GetSurrenderGuards)
Actor[] function __SnapshotGuards(Actor akSurrenderer)
    Actor[] result = new Actor[6]
    int snapshot = self.__SurrenderSnapshot(akSurrenderer)
    if (!snapshot)
        return result
    endif
    int guards = RPB_Memory.FastMap_GetObject(snapshot, "guards")
    int i = 0
    while (i < JArray.count(guards) && i < result.Length)
        result[i] = JArray.getForm(guards, i) as Actor
        i += 1
    endWhile
    return result
endFunction

Actor function __SnapshotOther(Actor akSurrenderer)
    int snapshot = self.__SurrenderSnapshot(akSurrenderer)
    if (!snapshot)
        return none
    endif
    return RPB_Memory.FastMap_GetForm(snapshot, "other") as Actor
endFunction

; Whether @akSurrenderer can surrender to @akSurrendererCaptors, from the snapshot of them (SnapshotSurrenderTargets first)
bool function CanActorSurrender(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    bool isPlayer = akSurrenderer == Config.Player
    if (self.IsSurrendering(akSurrenderer))
        SurrenderLog("Surrender of " + akSurrenderer + " ignored: already surrendering")
        return false
    endif
    int arrestStatus = Arrest.GetActorArrestStatus(akSurrenderer)
    if (arrestStatus != Arrest.CAN_BE_ARRESTED)
        SurrenderLog("Surrender of " + akSurrenderer + " refused: arrest status " + arrestStatus)
        return false
    endif
    if (!akSurrenderer.IsInCombat())
        SurrenderLog("Surrender of " + akSurrenderer + " refused: not in combat")
        return false
    endif
    if (RPB_Utility.IsDeadNoCall(akSurrenderer))
        SurrenderLog("Surrender of " + akSurrenderer + " refused: dead")
        return false
    endif
    if (!akSurrendererCaptors)
        LastSurrenderOutcome = "no captors"
        Config.NotifyArrest("There's no one here to surrender to", isPlayer)
        SurrenderLog("Surrender of " + akSurrenderer + " refused: in combat, but with no combat targets")
        return false
    endif
    int snapshot = self.__SurrenderSnapshot(akSurrenderer)
    int guards = RPB_Memory.FastMap_GetObject(snapshot, "guards")
    int factions = RPB_Memory.FastMap_GetObject(snapshot, "factions")
    if (!snapshot || JArray.count(guards) == 0)
        LastSurrenderOutcome = "no guard"
        Config.NotifyArrest("There's no one here to surrender to", isPlayer)
        SurrenderLog("Surrender of " + akSurrenderer + " refused: none of their " + akSurrendererCaptors.Length + " combat targets is a guard")
        return false
    endif
    Actor otherHostile = RPB_Memory.FastMap_GetForm(snapshot, "other") as Actor
    if (otherHostile)
        SurrenderLog("Surrender of " + akSurrenderer + " with " + otherHostile + " (" + RPB_Utility.GetFormNameCached(otherHostile.GetBaseObject()) + ", " + (akSurrenderer.GetDistance(otherHostile) as int) + " away, in combat " + otherHostile.IsInCombat() + ") still in the fight: allowed, with leeway")
    endif
    int i = 0
    while (i < JArray.count(factions))
        Faction crimeFaction = JArray.getForm(factions, i) as Faction
        if (self.HasFakedSurrenderTo(akSurrenderer, crimeFaction))
            LastSurrenderOutcome = "fooled"
            Config.NotifyArrest("The guards won't fall for that again", isPlayer)
            SurrenderLog("Surrender of " + akSurrenderer + " refused: they faked a surrender to " + RPB_Utility.GetFormNameCached(crimeFaction) + " not long ago")
            return false
        endif
        i += 1
    endWhile
    return true
endFunction

; A combat target that can take a surrender: a living guard of a hold (death read engine side: no call, no frame)
bool function IsSurrenderGuard(Actor akActor)
    return akActor && !RPB_Utility.IsFrozenNPC(akActor) && !RPB_Utility.IsDeadNoCall(akActor) && !akActor.IsDisabled() && akActor.IsGuard() && akActor.GetCrimeFaction()
endFunction

;/
    One of the surrender's own guards (__surrenderGuards, from SnapshotSurrenderTargets: already a guard of a hold) still
    able to take it: alive and enabled. Being a guard and his crime faction don't change during a surrender, so they aren't
    read again: one call (IsDisabled) instead of IsSurrenderGuard's four. The Scene's end picks the nearest of them, which
    cost ~30 frames with 6 guards (~0.4s before the arrest started, 2026-10-14)
/;
bool function __IsStillSurrenderGuard(Actor akGuard)
    return akGuard && !RPB_Utility.IsFrozenNPC(akGuard) && !RPB_Utility.IsDeadNoCall(akGuard) && !akGuard.IsDisabled()
endFunction

bool function HasSurrenderGuard(Actor[] akCombatTargets)
    int i = 0
    while (i < akCombatTargets.Length)
        if (self.IsSurrenderGuard(akCombatTargets[i]))
            return true
        endif
        i += 1
    endWhile
    return false
endFunction

;/
    A living combat target that isn't the law (a bandit, a creature), or none. The law is a guard, or anyone of the same
    crime faction as one of the guards fighting them: Captain Aldis (Castle Dour, not flagged a guard) blocked a surrender
    to Solitude's guards as if he were a bandit (2026-10-05). The surrender's StopCombatAlarm calls off that crime
    faction's whole alarm, him included
/;
Actor function GetNonGuardCombatTarget(Actor[] akCombatTargets)
    int i = 0
    while (i < akCombatTargets.Length)
        Actor target = akCombatTargets[i]
        if (target && !RPB_Utility.IsFrozenNPC(target) && !RPB_Utility.IsDeadNoCall(target) && !target.IsDisabled() && !target.IsGuard() && !self.__IsOfAGuardsCrimeFaction(target, akCombatTargets))
            return target
        endif
        i += 1
    endWhile
    return none
endFunction

; @akActor belongs to the crime faction of one of the surrender guards among @akCombatTargets (his own, or a member of it)
bool function __IsOfAGuardsCrimeFaction(Actor akActor, Actor[] akCombatTargets)
    Faction ownCrimeFaction = akActor.GetCrimeFaction()
    int i = 0
    while (i < akCombatTargets.Length)
        if (akCombatTargets[i] != akActor && self.IsSurrenderGuard(akCombatTargets[i]))
            Faction guardCrimeFaction = akCombatTargets[i].GetCrimeFaction()
            if (guardCrimeFaction && (guardCrimeFaction == ownCrimeFaction || akActor.IsInFaction(guardCrimeFaction)))
                return true
            endif
        endif
        i += 1
    endWhile
    return false
endFunction

; The guards among @akCombatTargets, at most the Surrender Scene's 6 captor slots (empty slots stay none, the binding skips them)
Actor[] function GetSurrenderGuards(Actor[] akCombatTargets)
    Actor[] guards = new Actor[6]
    int count = 0
    int i = 0
    while (i < akCombatTargets.Length && count < guards.Length)
        if (self.IsSurrenderGuard(akCombatTargets[i]))
            guards[count] = akCombatTargets[i]
            count += 1
        endif
        i += 1
    endWhile
    return guards
endFunction

; ==========================================================
;               Surrender state (one way in, one way out)

; How long no bound guard can go without coming closer before the surrender expires (nobody is coming to take it)
float property SURRENDER_EXPIRE_SECONDS = 10.0 autoreadonly

; How far the surrenderer can move from where they surrendered before it counts as leaving
float property SURRENDER_LEAVE_DISTANCE = 64.0 autoreadonly

; A guard this close takes the surrender (the Surrender Scene's end condition): moving then isn't leaving
float property SURRENDER_TAKEN_DISTANCE = 300.0 autoreadonly

; How many times a Surrender Scene the engine refused to start (a guard back in combat) is started again
int property SURRENDER_SCENE_RETRIES = 2 autoreadonly

; How many times a surrenderer can step away while someone outside the law (a bandit) is still fighting next to them,
; before stepping away counts as leaving: dodging a blow isn't faking the surrender
int property SURRENDER_DODGES = 3 autoreadonly

; How long a surrender waits for its guards to finish a fight with someone else (bandits) before it's given up. Meanwhile
; it stays on (the pose kept), and leaving costs nothing: nobody has come for it yet
float property SURRENDER_FIGHT_WAIT_SECONDS = 180.0 autoreadonly

; How the last surrender ended or was refused ("no captors", "no guard", "attacked", "fooled", "expired" (still on),
; "faked", "withdrawn", "Scene never started", "no guard at the end", "no bounty", "arrest"): for the tests and the log
string property LastSurrenderOutcome auto hidden

; The guards bound to the current surrender (the Surrender Scene's captor slots), for the Scene's end
Actor[] __surrenderGuards

;/
    Stops the fight on the guards' side before the Surrender Scene: the engine refuses to start a Scene whose actors are
    still in combat, and a disguised surrenderer (a hostile faction on them) kept the guards fighting after the player's
    own StopCombat (the Scene "never started"). Their hostile factions are removed as the arrest would (the snapshot lets
    an undone surrender give them back); a disguise mod re-adds its faction, so I sweep until the guards stay calm, 5s at most.
/;
function __PacifyForSurrender(Actor akSurrenderer, Actor[] akGuards)
    ; A violent crime makes the hold's guards the player's enemies (the faction's player-enemy flag), and calming them didn't
    ; clear it: they were back in the fight within seconds, the Surrender Scene never started, the surrender was undone
    ; (2026-10-07). Cleared as the game's own yield does (there's no reading it back, only setting it)
    if (akSurrenderer == Game.GetFormEx(0x14) as Actor && akGuards.Length > 0 && akGuards[0])
        Faction guardsFaction = akGuards[0].GetCrimeFaction()
        if (guardsFaction)
            guardsFaction.SetPlayerEnemy(false)
            SurrenderLog("Surrender of " + akSurrenderer + ": " + guardsFaction + "'s player-enemy flag cleared (violent bounty " + guardsFaction.GetCrimeGoldViolent() + ")")
        endif
    endif
    float start = Utility.GetCurrentRealTime()
    int passes = 0
    bool fighting = true
    string stillFighting = ""
    while (fighting && (Utility.GetCurrentRealTime() - start) < 5.0)
        passes += 1
        if (RPB_Utility.IsHostileActor(akSurrenderer))
            RPB_Utility.NeutralizeHostileActor(akSurrenderer)
        endif
        akSurrenderer.StopCombat()
        akSurrenderer.StopCombatAlarm()
        fighting = false
        stillFighting = ""
        int i = 0
        while (i < akGuards.Length)
            ; A guard fighting someone else (bandits) is left to it: stopping him every pass pulled him out of that fight
            ; for nothing (he went straight back in), and the surrender waits for him instead (__WatchSurrender)
            ; His combat state read once (__IsFightingOthers reads IsInCombat again)
            bool guardFighting = akGuards[i] && akGuards[i].IsInCombat()
            bool fightingOthers = false
            if (guardFighting)
                Actor guardTarget = akGuards[i].GetCombatTarget()
                fightingOthers = guardTarget && guardTarget != akSurrenderer
            endif
            if (guardFighting && !fightingOthers)
                akGuards[i].StopCombat()
                akGuards[i].StopCombatAlarm()
                fighting = true
                stillFighting += " " + akGuards[i]
            endif
            i += 1
        endWhile
        if (fighting)
            Utility.Wait(0.5)
        endif
    endWhile
    SurrenderLog("Surrender of " + akSurrenderer + ": guards calmed in " + passes + " passes, still fighting " + fighting + string_if(fighting, " (in combat at the last pass:" + stillFighting + ")", "") + ", surrenderer in combat " + akSurrenderer.IsInCombat())
endFunction

; @akGuard is in combat with someone other than @akSurrenderer
bool function __IsFightingOthers(Actor akGuard, Actor akSurrenderer)
    if (!akGuard || !akGuard.IsInCombat())
        return false
    endif
    Actor target = akGuard.GetCombatTarget()
    return target && target != akSurrenderer
endFunction

; Whether the Surrender Scene has to wait for a fight it isn't part of: a living bound guard busy fighting someone other
; than @akSurrenderer, or the surrenderer still fought by someone outside the law (the engine refuses the Scene while
; they're in combat: "never started (no bound guard in combat)" with bandits on the player, undone after 2 retries,
; 2026-10-05)
bool function __GuardsFightingOthers(Actor akSurrenderer, Actor[] akGuards)
    if (akSurrenderer.IsInCombat())
        Actor[] targets = PO3_SKSEFunctions.GetCombatTargets(akSurrenderer)
        if (targets && self.GetNonGuardCombatTarget(targets))
            return true
        endif
    endif
    int i = 0
    while (i < akGuards.Length)
        if (self.__IsStillSurrenderGuard(akGuards[i]) && self.__IsFightingOthers(akGuards[i], akSurrenderer))
            return true
        endif
        i += 1
    endWhile
    return false
endFunction

; Surrender lines reach the log whether DEBUG is on (Info is silent then) or off
function SurrenderLog(string asMessage) global
    if (RPB_Utility.IsDebuggingEnabled())
        Debug("Surrender::Surrender", asMessage)
    else
        Info(asMessage)
    endif
endFunction

;/
    Whether @akActor has a surrender under way. The surrender's watch writes a heartbeat every tick: a flag with no
    heartbeat for an in-game hour has no one left to clear it (a save whose watch never came back), so it doesn't count.
/;
bool function IsSurrendering(Actor akActor)
    if (!RPB_StorageVars.GetBoolOnReference("Surrendering", akActor, "Surrender"))
        return false
    endif
    return (Utility.GetCurrentGameTime() - RPB_StorageVars.GetFloatOnReference("Surrender Heartbeat", akActor, "Surrender")) < (1.0 / 24.0)
endFunction

function __BeginSurrender(Actor akActor)
    RPB_StorageVars.SetBoolOnReference("Surrendering", akActor, true, "Surrender")
    RPB_StorageVars.SetFloatOnReference("Surrender Heartbeat", akActor, Utility.GetCurrentGameTime(), "Surrender")
endFunction

; Takes the surrender over: true for the one caller that gets it (the Scene's end, the watch, an abort), false for the rest
bool function __ClaimSurrender(Actor akActor)
    bool surrendering = self.IsSurrendering(akActor)
    RPB_StorageVars.DeleteCategoryOnReference(akActor, "Surrender")
    return surrendering
endFunction

;/
    Undoes what a surrender did to @akSurrenderer, for every way it can end without an arrest: the Surrender Scene
    (current or queued), the player's AI and controls, the cowering, the forced arrest dialogue switch.
    Call it after __ClaimSurrender() returned true. @abEndScene false from inside the Scene queue itself (a Scene that
    never started is already being dropped there). @abNotify false when the surrenderer ended it themselves.
/;
function __UndoSurrender(Actor akSurrenderer, string asReason, bool abEndScene = true, bool abNotify = true)
    bool isPlayer = akSurrenderer == Config.Player
    SurrenderLog("Surrender of " + akSurrenderer + " undone: " + asReason)
    if (abEndScene)
        SceneManager.EndSceneWithActor(akSurrenderer, "the surrender is over: " + asReason)
    endif
    RPB_Utility.ReleaseAI(isPlayer)
    Debug.SendAnimationEvent(akSurrenderer, "IdleForceDefaultState")
    ; The hostility __PacifyForSurrender removed (nothing when they weren't hostile)
    RPB_Utility.RestoreNeutralizedHostility(akSurrenderer)
    RPB_Arrest.EnableForcedArrestDialogue()
    if (abNotify)
        Config.NotifyArrest("No one took your surrender", isPlayer)
    endif
    ; What they dropped can be picked up again (a fake surrender's guard may still go for it first)
    Confiscation.UnblockDroppedWeapons(akSurrenderer)
    ; A takeover's approach ending without an arrest: the submission's bounty back (nothing set aside for a real surrender)
    RPB_Arrest.GiveBackSetAsideBounty(akSurrenderer, "the takeover's approach ended without an arrest: " + asReason)
endFunction

function AbortSurrender(Actor akSurrenderer, string asReason, bool abEndScene = true)
    if (self.__ClaimSurrender(akSurrenderer))
        self.__UndoSurrender(akSurrenderer, asReason, abEndScene)
    endif
endFunction

;/
    The surrender's own loop, on its event stack, until the Scene's end takes the surrender over. The surrenderer isn't
    arrested yet, so they keep their controls: moving away from where they stand when it starts (the cower is on by then;
    at F8 they could still be moving) or drawing a weapon ends it. Not with a guard within SURRENDER_TAKEN_DISTANCE: he's
    the one taking it (the Scene ends there).
    - While a guard is still coming, that's a fake surrender: a bounty, the guards fight again, and that hold's guards
      won't take a surrender from them for a few days.
    - Once no bound guard has come any closer for SURRENDER_EXPIRE_SECONDS, the surrender expires: nobody is coming, so
      leaving costs nothing. It stays on until then (a guard can still come and take it).
/;
function __WatchSurrender(Actor akSurrenderer, Actor[] akGuards)
    bool isPlayer = akSurrenderer == Config.Player
    float leaveSquared = SURRENDER_LEAVE_DISTANCE * SURRENDER_LEAVE_DISTANCE
    float originX = akSurrenderer.GetPositionX()
    float originY = akSurrenderer.GetPositionY()
    float originZ = akSurrenderer.GetPositionZ()
    ; Per tick (a vanilla native costs about a frame): the position, the weapon and one guard's distance. The nearest guard
    ; is re-scanned every 4th tick, the heartbeat written every 10th, and the time counted in ticks (a late Wait only
    ; makes the expiry later)
    int tracked = self.__NearestGuardIndex(akSurrenderer, akGuards)
    float nearest = self.__GuardDistance(akSurrenderer, akGuards, tracked)
    int ticks = 0
    int lastProgressTick = 0
    int sceneRetries = 0
    int dodges = 0
    Actor outsider = RPB_StorageVars.GetFormOnReference("Outsider", akSurrenderer, "Surrender") as Actor
    bool waitingForFight = false
    int fightWaitTick = 0
    bool expired = false
    bool watching = true
    if (isPlayer)
        self.__RegisterSurrenderControls(true)
    endif
    while (watching)
        Utility.Wait(0.5)
        if (!RPB_StorageVars.GetBoolOnReference("Surrendering", akSurrenderer, "Surrender"))
            watching = false ; the Scene's end (or an abort) took it over
        elseif (RPB_StorageVars.GetBoolOnReference("Scene Failed", akSurrenderer, "Surrender"))
            RPB_StorageVars.DeleteVariableOnReference("Scene Failed", akSurrenderer, "Surrender")
            ; The guards are busy with someone else (bandits): not a failed surrender yet. It waits for them, kept on, and
            ; a retry starts the Scene once they're done (the mod author, 2026-10-05: a long fight used to undo it after 2
            ; retries with the guards all around)
            if (self.__GuardsFightingOthers(akSurrenderer, akGuards))
                if (!waitingForFight)
                    waitingForFight = true
                    fightWaitTick = ticks
                    SurrenderLog("Surrender of " + akSurrenderer + ": the guards are fighting someone else (" + self.__GuardsInCombat(akGuards) + "), waiting for them; leaving meanwhile costs nothing")
                endif
            else
            sceneRetries += 1
            if (sceneRetries <= SURRENDER_SCENE_RETRIES)
                SurrenderLog("Surrender of " + akSurrenderer + ": the Surrender Scene didn't start (" + self.__GuardsInCombat(akGuards) + "), retry " + sceneRetries)
                self.__PacifyForSurrender(akSurrenderer, akGuards)
                self.InitiateSurrenderScene(akSurrenderer, akGuards)
                lastProgressTick = ticks
            else
                watching = false
                if (self.__ClaimSurrender(akSurrenderer))
                    LastSurrenderOutcome = "Scene never started"
                    self.__UndoSurrender(akSurrenderer, "the Surrender Scene never started after " + SURRENDER_SCENE_RETRIES + " retries (" + self.__GuardsInCombat(akGuards) + ")", abEndScene = false)
                endif
            endif
            endif
        elseif (waitingForFight && (ticks - fightWaitTick) * 0.5 >= SURRENDER_FIGHT_WAIT_SECONDS)
            watching = false
            if (self.__ClaimSurrender(akSurrenderer))
                LastSurrenderOutcome = "fight too long"
                self.__UndoSurrender(akSurrenderer, "the guards' fight with someone else lasted over " + (SURRENDER_FIGHT_WAIT_SECONDS as int) + "s (" + self.__GuardsInCombat(akGuards) + ")", abEndScene = false)
            endif
        else
            ticks += 1
            ; Waiting for the guards' other fight: every 2s, once none is fighting anyone else, the Scene again (calmed first)
            if (waitingForFight)
                lastProgressTick = ticks ; no expiry while they're busy
                if (ticks % 4 == 0 && !self.__GuardsFightingOthers(akSurrenderer, akGuards))
                    waitingForFight = false
                    sceneRetries = 0
                    SurrenderLog("Surrender of " + akSurrenderer + ": the guards' fight is over after " + (((ticks - fightWaitTick) * 0.5) as int) + "s, the Surrender Scene again")
                    self.__PacifyForSurrender(akSurrenderer, akGuards)
                    self.InitiateSurrenderScene(akSurrenderer, akGuards)
                endif
            endif
            if (ticks % 10 == 0)
                RPB_StorageVars.SetFloatOnReference("Surrender Heartbeat", akSurrenderer, Utility.GetCurrentGameTime(), "Surrender")
            endif
            if (ticks % 4 == 0 || tracked < 0 || !akGuards[tracked])
                tracked = self.__NearestGuardIndex(akSurrenderer, akGuards)
            endif
            float distance = self.__GuardDistance(akSurrenderer, akGuards, tracked)
            float dx = akSurrenderer.GetPositionX() - originX
            float dy = akSurrenderer.GetPositionY() - originY
            float dz = akSurrenderer.GetPositionZ() - originZ
            float movedSquared = dx * dx + dy * dy + dz * dz
            bool weaponDrawn = akSurrenderer.IsWeaponDrawn()
            ; A close guard only "takes" it while the Surrender Scene plays (its end is the take-over): without the Scene,
            ; a guard standing next to them would hold the surrender on forever
            bool beingTaken = distance <= SURRENDER_TAKEN_DISTANCE && SceneManager.GetCurrentScene() == SceneManager.SCENE_SURRENDER_01
            ; Stepped away with the outsider still fighting nearby: a dodge, the spot they hold moves with them
            if (movedSquared > leaveSquared && !weaponDrawn && !beingTaken && outsider && dodges < SURRENDER_DODGES && !outsider.IsDead() && outsider.IsInCombat() && akSurrenderer.GetDistance(outsider) < 3000.0)
                dodges += 1
                originX = akSurrenderer.GetPositionX()
                originY = akSurrenderer.GetPositionY()
                originZ = akSurrenderer.GetPositionZ()
                SurrenderLog("Surrender of " + akSurrenderer + ": stepped away with " + outsider + " still fighting, a dodge (" + dodges + "/" + SURRENDER_DODGES + ")")
            elseif ((movedSquared > leaveSquared || weaponDrawn) && !beingTaken)
                watching = false
                SurrenderLog("Surrender of " + akSurrenderer + ": they left (moved " + (Math.sqrt(movedSquared) as int) + ", weapon drawn " + weaponDrawn + ", nearest guard " + (distance as int) + ", expired " + expired + ", waiting for the guards' fight " + waitingForFight + string_if(outsider != none, ", outsider " + outsider + " dead " + outsider.IsDead() + " in combat " + outsider.IsInCombat() + " " + (akSurrenderer.GetDistance(outsider) as int) + " away, dodges " + dodges, "") + ")")
                if (self.__IsTakeoverApproach(akSurrenderer))
                    self.__EludeTakeover(akSurrenderer)
                elseif (expired || waitingForFight)
                    self.__WithdrawSurrender(akSurrenderer)
                else
                    self.__FakeSurrender(akSurrenderer, akGuards)
                endif
            elseif (!expired)
                if (distance < nearest - 32.0)
                    nearest = distance
                    lastProgressTick = ticks
                elseif (((ticks - lastProgressTick) * 0.5) >= SURRENDER_EXPIRE_SECONDS)
                    expired = true
                    LastSurrenderOutcome = "expired"
                    SurrenderLog("Surrender of " + akSurrenderer + " expired: no guard came closer in " + (SURRENDER_EXPIRE_SECONDS as int) + "s (nearest " + (nearest as int) + ")")
                    Config.NotifyArrest("No one is coming to take your surrender", isPlayer)
                endif
            endif
        endif
    endWhile
    if (isPlayer)
        self.__RegisterSurrenderControls(false)
    endif
endFunction

;/
    The Surrender Scene didn't start (EventManager.OnSceneStartFailed, inside the Scene queue): the watch retries it on its
    own stack. A surrender that's already over has nothing to retry.
/;
function OnSurrenderSceneFailed(Actor akSurrenderer)
    if (self.IsSurrendering(akSurrenderer))
        RPB_StorageVars.SetBoolOnReference("Scene Failed", akSurrenderer, true, "Surrender")
    endif
endFunction

; Which of @akGuards are in combat, for the log
string function __GuardsInCombat(Actor[] akGuards)
    string fighting = ""
    int i = 0
    while (i < akGuards.Length)
        if (akGuards[i] && akGuards[i].IsInCombat())
            fighting += " " + akGuards[i]
        endif
        i += 1
    endWhile
    if (fighting == "")
        return "no bound guard in combat"
    endif
    return "in combat:" + fighting
endFunction

; The index of the nearest of @akGuards to @akSurrenderer, -1 with none
int function __NearestGuardIndex(Actor akSurrenderer, Actor[] akGuards)
    int best = -1
    float bestDistance = 0.0
    int i = 0
    while (i < akGuards.Length)
        if (akGuards[i])
            float distance = akSurrenderer.GetDistance(akGuards[i])
            if (best < 0 || distance < bestDistance)
                best = i
                bestDistance = distance
            endif
        endif
        i += 1
    endWhile
    return best
endFunction

; The distance from @akSurrenderer to @akGuards[@aiIndex] (a huge one with none)
float function __GuardDistance(Actor akSurrenderer, Actor[] akGuards, int aiIndex)
    if (aiIndex < 0 || !akGuards[aiIndex])
        return 1000000000.0
    endif
    return akSurrenderer.GetDistance(akGuards[aiIndex])
endFunction

; The nearest of @akGuards that can still take the surrender, or @akFallback
Actor function __NearestSurrenderGuard(Actor akSurrenderer, Actor[] akGuards, Actor akFallback)
    Actor best = none
    float bestDistance = 0.0
    int i = 0
    while (i < akGuards.Length)
        if (self.__IsStillSurrenderGuard(akGuards[i])) ; the surrender's own guards: only whether still alive and enabled
            float distance = akSurrenderer.GetDistance(akGuards[i])
            if (!best || distance < bestDistance)
                best = akGuards[i]
                bestDistance = distance
            endif
        endif
        i += 1
    endWhile
    if (!best)
        return akFallback
    endif
    return best
endFunction

; They left while a guard was still coming: the fake surrender's bounty and memory, then the guards fight again
function __FakeSurrender(Actor akSurrenderer, Actor[] akGuards)
    if (!self.__ClaimSurrender(akSurrenderer))
        return
    endif
    Actor[] noGuards
    __surrenderGuards = noGuards
    LastSurrenderOutcome = "faked"
    Actor guard = self.__NearestSurrenderGuard(akSurrenderer, akGuards, none)
    if (guard)
        Faction crimeFaction = guard.GetCrimeFaction()
        self.ApplyFakeSurrenderPenalty(akSurrenderer, crimeFaction)
        self.__RememberFakeSurrender(akSurrenderer, crimeFaction)
    endif
    self.__UndoSurrender(akSurrenderer, "they left while a guard was still coming (a fake surrender)", abNotify = false)
    int i = 0
    while (i < akGuards.Length)
        if (akGuards[i] && !akGuards[i].IsDead())
            akGuards[i].StartCombat(akSurrenderer)
        endif
        i += 1
    endWhile
endFunction

; They left after the surrender expired: nobody was coming to take it, so it's over at no cost
function __WithdrawSurrender(Actor akSurrenderer)
    if (!self.__ClaimSurrender(akSurrenderer))
        return
    endif
    Actor[] noGuards
    __surrenderGuards = noGuards
    LastSurrenderOutcome = "withdrawn"
    self.__UndoSurrender(akSurrenderer, "they left after no guard came", abNotify = false)
endFunction

; ==========================================================
;               Fake surrenders (what the guards remember)

string function __FakedUntilKey(Faction akFaction)
    return RPB_Utility.GetFormNameCached(akFaction) + "::Surrender Faked Until"
endFunction

; Whether @akActor faked a surrender to @akFaction's guards within that hold's "Fake Surrender Memory"
bool function HasFakedSurrenderTo(Actor akActor, Faction akFaction)
    if (!akFaction)
        return false
    endif
    float fakedUntil = RPB_StorageVars.GetFloatOnReference(self.__FakedUntilKey(akFaction), akActor, "Surrender Memory")
    return fakedUntil > 0.0 && Utility.GetCurrentGameTime() < fakedUntil
endFunction

; When the memory of @akActor's fake surrender to @akFaction runs out (game days), 0 with none
float function GetFakedSurrenderUntil(Actor akActor, Faction akFaction)
    return RPB_StorageVars.GetFloatOnReference(self.__FakedUntilKey(akFaction), akActor, "Surrender Memory")
endFunction

function __RememberFakeSurrender(Actor akActor, Faction akFaction)
    float days = Config.GetArrestFakeSurrenderMemory(RPB_Utility.GetFormNameCached(akFaction))
    RPB_StorageVars.SetFloatOnReference(self.__FakedUntilKey(akFaction), akActor, Utility.GetCurrentGameTime() + days, "Surrender Memory")
endFunction

; Forgets every fake surrender of @akActor (the tests' teardown)
function ForgetFakeSurrenders(Actor akActor)
    RPB_StorageVars.DeleteCategoryOnReference(akActor, "Surrender Memory")
endFunction

;/
    The bounty for surrendering to @akFaction's guards: a flat amount plus a share of the current bounty (active and
    latent), set per hold in the MCM. With no bounty only the flat part applies, so a hostile actor who had none is
    still arrested for something.
/;
function ApplySurrenderPenalty(Actor akSurrenderer, Faction akFaction)
    string hold = RPB_Utility.GetFormNameCached(akFaction)
    self.__AddSurrenderBounty(akSurrenderer, akFaction, Config.GetArrestAdditionalBountySurrenderingFromCurrentBounty(hold), Config.GetArrestAdditionalBountySurrenderingFlat(hold), "surrendering")
    RPB_ActorVars.IncrementStat("Arrests Surrendered", akFaction, akSurrenderer)
endFunction

; The bounty for faking a surrender to @akFaction's guards: a flat amount plus a share of the current bounty, per hold
function ApplyFakeSurrenderPenalty(Actor akSurrenderer, Faction akFaction)
    string hold = RPB_Utility.GetFormNameCached(akFaction)
    self.__AddSurrenderBounty(akSurrenderer, akFaction, Config.GetArrestAdditionalBountyFakingSurrenderFromCurrentBounty(hold), Config.GetArrestAdditionalBountyFakingSurrenderFlat(hold), "faking a surrender")
endFunction

function __AddSurrenderBounty(Actor akSurrenderer, Faction akFaction, float afPercent, int aiFlat, string asFor)
    string hold = RPB_Utility.GetFormNameCached(akFaction)
    bool isPlayer = akSurrenderer == Config.Player

    int currentBounty   = RPB_ActorBase.GetCurrentActiveAndLatentBountyForFaction(akSurrenderer, akFaction)
    int penalty         = floor(currentBounty * PercentToDecimal(afPercent)) + aiFlat

    if (penalty > 0)
        if (isPlayer)
            akFaction.ModCrimeGold(penalty)
        else
            RPB_ActorVars.ModCrimeGold(akFaction, akSurrenderer, penalty)
        endif
        Config.NotifyArrest("You have gained " + penalty + " Bounty in " + hold + " for " + asFor, isPlayer)
    endif

    SurrenderLog("Surrender of " + akSurrenderer + " to " + hold + " (" + asFor + "): bounty " + currentBounty + " + " + penalty)
endFunction


;/
    Drops what's in hand, sheathes the rest and plays the surrender and cower idles. The surrenderer keeps their controls:
    they aren't arrested yet, and moving or drawing a weapon ends the surrender (the watch). The arrest takes the controls
    at the Scene's end.
/;
function PrepareSurrenderer(Actor akSurrenderer, Actor[] akGuards = none)
    ; Weapons drawn: what's in hand goes to the ground (the captor picks it up after the cuffs), a spell or nothing left in
    ; hand is sheathed. Weapons put away stay on them (a submission's, or a surrender with only a sheathed sword), until
    ; the strip as before
    if (akSurrenderer.IsWeaponDrawn())
        int dropped = self.DropWeaponsInHand(akSurrenderer)
        RPB_Utility.FlowMark("Surrender: " + dropped + " weapons dropped")
        ; What's left drawn (fists after the drop, a spell) is sheathed, the animations won't play otherwise. Nothing drawn:
        ; no wait (it was a fixed 1s every time)
        if (dropped > 0)
            self.__SheatheAfterDrop(akSurrenderer)
        elseif (akSurrenderer.IsWeaponDrawn())
            ; 1s for its animation (ending the wait once the weapon read as put away, 0.7s, sent the hands up while it was
            ; still finishing, and they never went up)
            akSurrenderer.SheatheWeapon()
            Utility.Wait(1.0)
        endif
    endif
    RPB_Utility.FlowMark("Surrender: weapon sheathed (waited only if drawn)")
    Debug.SendAnimationEvent(akSurrenderer, "IdleSurrender")
    RPB_Utility.FlowMark("Surrender: hands up (after a fixed 1s wait)")

    ; Stop all combat
    akSurrenderer.StopCombat()
    akSurrenderer.StopCombatAlarm()

    ; A guard already this close takes the surrender at once: hands up, straight into the arrest, no cowering first
    if (akGuards)
        float distance = self.__GuardDistance(akSurrenderer, akGuards, self.__NearestGuardIndex(akSurrenderer, akGuards))
        if (distance <= SURRENDER_TAKEN_DISTANCE)
            SurrenderLog("Surrender of " + akSurrenderer + ": a guard is close (" + (distance as int) + "): hands up, no cower")
            return
        endif
    endif

    Utility.Wait(1.0)
    Debug.SendAnimationEvent(akSurrenderer, "IdleCowerEnter")
endFunction

;/
    Drops the weapons in @akSurrenderer's hands: a weapon in either hand, a shield, a torch (a bow too; its arrows stay on
    them). Spells stay (nothing to drop) and so do non-playable items (bound weapons: they'd vanish; and creatures' natural
    weapons). Each dropped reference is remembered with its item, for the captor's pickup and the custody afterwards
    (RPB_Confiscation.RecordDroppedWeapons). Returns how many were dropped.

    Both hands are read once, before any drop: a two-handed weapon or a bow is in both hands and is dropped once (reading the
    left hand again after the right one's drop still found the bow there, and a spare one was dropped too, 2026-10-14);
    the same one-hander in both hands (dual daggers) is two items, both dropped. DropObject takes an item by its form, so
    with a spare of it carried it may drop the spare: whatever of it is still equipped afterwards is unequipped (the same
    item either way, so the hand ends empty, one copy on the ground).
/;
int function DropWeaponsInHand(Actor akSurrenderer)
    int refs = JArray.object()
    int items = JArray.object()
    Form right = akSurrenderer.GetEquippedObject(1)
    Form left = akSurrenderer.GetEquippedObject(0)
    if (left && left == right && self.__IsTwoHanded(left))
        left = none
    endif
    self.__DropFromHand(akSurrenderer, right, refs, items)
    self.__DropFromHand(akSurrenderer, left, refs, items)
    int count = RPB_Memory.FastArray_Size(refs)
    ; A spare dropped instead of the one in hand: the one in hand is unequipped (nothing happens if it isn't equipped)
    int i = 0
    while (i < count)
        akSurrenderer.UnequipItem(RPB_Memory.FastArray_GetForm(items, i), false, true)
        i += 1
    endWhile
    ; Their custody from here on: the captor's pickup, the prison, the release (a new drop replaces the last one's record)
    Confiscation.RecordDroppedWeapons(akSurrenderer, refs, items)
    if (count == 0)
        return 0
    endif
    if (RPB_Utility.IsLoggingEnabled())
        ; Whatever is still in hand: DropObject takes the item by its form, and with a spare of the same one carried it may
        ; have dropped that one instead (to watch for)
        SurrenderLog("Surrender of " + akSurrenderer + ": dropped " + count + " (" + RPB_Utility.GetContainerList(items) + "), in hand now: " + akSurrenderer.GetEquippedObject(1) + " / " + akSurrenderer.GetEquippedObject(0))
    endif
    return count
endFunction

;/
    After a drop the hands are still switching to fists: a SheatheWeapon right then was ignored and the fists stayed up,
    the hands never went up (2026-10-14, a bow), and the surrender watch read the fists as a weapon drawn. So I let the
    switch finish, then sheathe again every 0.3s until it reads put away (2s at most), and give the sheathe animation
    0.7s more to finish before the hands go up
/;
function __SheatheAfterDrop(Actor akSurrenderer)
    Utility.Wait(0.3)
    int tries = 0
    while (akSurrenderer.IsWeaponDrawn() && tries < 7)
        akSurrenderer.SheatheWeapon()
        Utility.Wait(0.3)
        tries += 1
    endWhile
    Utility.Wait(0.7)
    SurrenderLog("Surrender of " + akSurrenderer + ": fists sheathed after the drop (" + tries + " tries), drawn now " + akSurrenderer.IsWeaponDrawn())
endFunction

; A bow, a crossbow or a two-handed weapon (it fills both hands)
bool function __IsTwoHanded(Form akItem)
    Weapon weap = akItem as Weapon
    if (!weap)
        return false
    endif
    int type = weap.GetWeaponType() ; 5 greatsword, 6 battleaxe/warhammer, 7 bow, 9 crossbow
    return type == 5 || type == 6 || type == 7 || type == 9
endFunction

; Drops @akItem from @akSurrenderer's hand, adding the reference and the item to @aiRefs/@aiItems (a spell, a non-playable
; item or an empty hand drops nothing)
function __DropFromHand(Actor akSurrenderer, Form akItem, int aiRefs, int aiItems)
    if (!akItem || akItem as Spell || !akItem.IsPlayable())
        return
    endif
    ObjectReference dropped = akSurrenderer.DropObject(akItem, 1)
    if (dropped)
        ; Nobody picks it up until the surrender is over: the surrenderer took it back before the confrontation began, so the
        ; surrender cost nothing (2026-10-14). Let go when it ends without an arrest (__UndoSurrender), when the pickup is
        ; given up, or when it's forgotten (RPB_Confiscation.ForgetDroppedWeapons)
        dropped.BlockActivation(true)
        RPB_Memory.FastArray_AddForm(aiRefs, dropped)
        RPB_Memory.FastArray_AddForm(aiItems, akItem)
    endif
endFunction



function InitiateSurrenderScene(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    if (RPB_Utility.IsSurrenderSceneForcedToFail())
        return ; tests 144/149: no guard ever comes
    endif
    SceneManager.StartSurrenderScene(akSurrenderer, akSurrendererCaptors, SceneManager.SCENE_SURRENDER_01)
endFunction

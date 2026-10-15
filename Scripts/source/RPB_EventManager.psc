scriptname RPB_EventManager extends Quest

;/
@references:
    RPB_API API
    RPB_Config Config
    RPB_Arrest Arrest
    RPB_Surrender Surrender
    RPB_SceneManager SceneManager
@functions:
    function RegisterEvents()
    function WatchCuffedJumps(bool abOn)
    int function SendSurrenderSceneEvent(string asScene, string asSceneEvent, Actor akSurrenderer, Actor akSurrendererCaptor, string asSceneSecondaryEvent = "null", Form[] akParams = none, Form[] akParams2 = none, bool abTrackBatch = false)
    int function SendArrestSceneEvent(string asScene, string asSceneEvent, Actor akArrestee, Actor akAuthority, string asSceneSecondaryEvent = "null", bool abTrackBatch = false)
    int function SendArrestSceneBulkEvent(string asScene, string asSceneEvent, Form[] akArrestees, Actor akAuthority, string asSceneSecondaryEvent = "null", bool abTrackBatch = false)
    int function SendPrisonSceneEvent(string asScene, string asSceneEvent, Actor akPrisoner, Actor akAuthority, string asSceneSecondaryEvent = "null", bool abTrackBatch = false)
    int function SendPrisonSceneBulkEvent(string asScene, string asSceneEvent, Form[] akPrisoners, Actor akAuthority, string asSceneSecondaryEvent = "null", bool abTrackBatch = false)
    int function SceneEndBatchPending(int aiBatch)
    function EndSceneEndBatch(int aiBatch)
    int function TakeOverFrozenMembers(Form[] akMembers)
    function TraceParams(string params, string paramNames = "", string caller = "")
@events:
    event OnTrace(string msg, string caller)
    event OnArrestBegin(string eventName, string arrestType, float arresteeIdFlt, Form sender)
    event OnArrestResist(string eventName, string unusedStr, float arrestResisterIdFlt, Form sender)
    event OnArrestDefeat(string eventName, string unusedStr, float unusedFlt, Form sender)
    event OnArrestEludeStart(string eventName, string eludeType, float unusedFlt, Form sender)
    event OnCombatYield(string eventName, string unusedStr, float unusedFlt, Form sender)
    event OnArrestSceneChanged(string eventName, string sceneName, float unusedFlt, Form sender)
    event OnArrestGoalChanged(string eventName, string newArrestGoal, float unusedFlt, Form sender)
    event OnPayBounty(string eventName, string categoryPayBounty, float arresteeFormIdFlt, Form sender)
    event OnArrestScene(string asScene, string asSceneEvent, RPB_Arrestee apArrestee, Actor akAuthority, string asSceneSecondaryEvent)
    event OnPrisonScene(string asScene, string asSceneEvent, RPB_Prison apPrison, RPB_Prisoner apPrisoner, Actor akAuthority, string asSceneSecondaryEvent)
    event OnPrisonSceneEvent(string asScene, string asSceneEvent, string asSceneSecondaryEvent, Form akMember, Form akAuthority, int aiPrevious, int aiNumber, int aiBatch, int aiMembers)
    event OnArrestSceneEvent(string asScene, string asSceneEvent, string asSceneSecondaryEvent, Form akMember, Form akAuthority, int aiPrevious, int aiNumber, int aiBatch, int aiMembers)
    event OnSurrenderSceneEvent(string asScene, string asSceneEvent, string asSceneSecondaryEvent, Form akMember, Form akAuthority, int aiPrevious, int aiNumber, int aiBatch, int aiMembers)
    event OnSurrenderPreparing(Form akSurrenderer)
    event OnPickUpWeapons(Form akOwner, Form akCaptor)
    event OnParcelCarrierCombatEnded(Form akCarrier, string asCause)
    event OnParcelCarrierUnloaded(Form akCarrier, string asCause)
    event OnWatchFetch(Form akOwner)
    event OnSurrenderScene(string asScene, string asSceneEvent, Actor akSurrenderer, Actor akSurrendererCaptor, string asSceneSecondaryEvent, Form[] akParams, Form[] akParams2)
    event OnSceneStart(string eventName, string sceneName, float unusedFlt, Form sender)
    event OnScenePlayingStart(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    event OnScenePlayingEnd(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    event OnSceneEnd(string eventName, string sceneName, float unusedFlt, Form sender)
    Actor function __DialogueTargetOf(Actor akSpeaker, string asCaller)
    event OnDialogueTopicStart(string topicInfoDialogue, float topicInfoTypeFlt, Form sender, float afStartedAt)
    event OnDialogueTopicEnd(string topicInfoDialogue, float topicInfoTypeFlt, Form sender, float afStartedAt)
    event OnPackageStart(string eventName, string packageName, float unusedFlt, Form sender)
    event AIPackageManager_OnPackageStart(string packageName, ObjectReference[] data, Form sender)
    event AIPackageManager_OnPackageEnd(string packageName, ObjectReference[] data, Package sender)
/;

import RPB_Config
import RPB_Utility

RPB_API __api
RPB_API property API
    RPB_API function get()
        if (__api)
            return __api
        endif

        __api = RPB_API.GetSelf()
        return __api
    endFunction
endProperty

RPB_Config property Config
    RPB_Config function get()
        return API.Config
    endFunction
endProperty

RPB_Arrest property Arrest
    RPB_Arrest function get()
        return API.Arrest
    endFunction
endProperty

RPB_Surrender property Surrender
    RPB_Surrender function get()
        return API.Surrender
    endFunction
endProperty

RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
    endFunction
endProperty

function RegisterEvents()
    ; Arrest Event Handlers
    RegisterForModEvent("RPB_ArrestBegin", "OnArrestBegin")             ; Start the Arrest
    RegisterForModEvent("RPB_ResistArrest", "OnArrestResist")           ; Resisting Arrest
    RegisterForModEvent("RPB_EludingArrest", "OnArrestEludeStart")      ; Eluding Arrest (Start)
    RegisterForModEvent("RPB_ArrestDefeated", "OnArrestDefeat")         ; Happens after the player is defeated through DA
    RegisterForModEvent("RPB_CombatYield", "OnCombatYield")             ; Happens when the player is spared after yielding
    RegisterForModEvent("RPB_SetArrestScene", "OnArrestSceneChanged")   ; Happens when there's a request to change the Arrest scene
    RegisterForModEvent("RPB_SetArrestGoal", "OnArrestGoalChanged")     ; Happens when there's a request to change the Arrest goal

    ; Surrender Event Handlers
    RegisterForModEvent("RPB_Surrender", "OnSurrenderPreparing")

    ; Jail Event Handlers
    RegisterForModEvent("RPB_JailBegin", "OnJailBegin")
    RegisterForModEvent("RPB_JailEnd", "OnJailEnd")
    RegisterForModEvent("RPB_SendPrisonActionRequest", "OnPrisonActionRequest")

    ; Scene Event Handlers (SF_Scene Scripts)
    RegisterForModEvent("RPB_SceneStart", "OnSceneStart")               ; Handles Scene start events, whenever a Scene begins playing.
    RegisterForModEvent("RPB_ScenePlayingStart", "OnScenePlayingStart") ; Handles Scene ongoing events, divided by phases at the beginning of the phase.
    RegisterForModEvent("RPB_ScenePlayingEnd", "OnScenePlayingEnd")     ; Handles Scene ongoing events, divided by phases at the end of the phase.
    RegisterForModEvent("RPB_SceneEnd", "OnSceneEnd")                   ; Handles Scene end events, whenever a Scene ends playing.

    ; Topic Info Event Handlers (TIF Scripts)
    RegisterForModEvent("RPB_TopicInfoStart", "OnDialogueTopicStart")
    RegisterForModEvent("RPB_TopicInfoEnd", "OnDialogueTopicEnd")
    RegisterForModEvent("RPB_CrimeLineBegan", "OnCrimeLineBegan")

    RegisterForModEvent("RPB_PayBounty", "OnPayBounty")                 ; Happens when the player is about to pay their bounty

    ; Package Event Handlers
    RegisterForModEvent("RPB_PackageEnd", "OnPackageEnd")
    RegisterForModEvent("RPB_PackageStart", "OnPackageStart")

    ; Guard side stacks: a frozen guard only ever holds these (RPB_Utility.ProbeNPC, Prisoner.ClearArrest)
    RegisterForModEvent("RPB_NPCProbe", "OnNPCProbe")
    RegisterForModEvent("RPB_NPCProbeCheck", "OnNPCProbeCheck")
    RegisterForModEvent("RPB_ReleaseCaptor", "OnReleaseCaptor")
    RegisterForModEvent("RPB_ReleaseCaptorBackstop", "OnReleaseCaptorBackstop")
    RegisterForModEvent("RPB_FreeGuard", "OnFreeGuard")

    ; A bounty set aside on submitting, given back if no arrest took it (RPB_Arrest.SetAsideBountyOnSubmission)
    RegisterForModEvent("RPB_SetAsideBountyCheck", "OnSetAsideBountyCheck")
    RegisterForModEvent("RPB_ArrestControlsCheck", "OnArrestControlsCheck")
    RegisterForModEvent("RPB_CancelArrest", "OnCancelArrestRequest")
    RegisterForModEvent("RPB_SubmissionTakeover", "OnSubmissionTakeover")
    RegisterForModEvent("RPB_PickUpWeapons", "OnPickUpWeapons")
    RegisterForModEvent("RPB_ParcelCarrierCombatEnded", "OnParcelCarrierCombatEnded")
    RegisterForModEvent("RPB_ParcelCarrierUnloaded", "OnParcelCarrierUnloaded")
    RegisterForModEvent("RPB_WatchFetch", "OnWatchFetch")
    RegisterForModEvent("RPB_FaintFrozenGuard", "OnFaintFrozenGuard")
    RegisterForModEvent("RPB_MoveGuard", "OnMoveGuard")
    RegisterForModEvent("RPB_StalledEscortTakeover", "OnStalledEscortTakeover")
    RegisterForModEvent("RPB_ConfrontationStalled", "OnConfrontationStalled")
    RegisterForModEvent("RPB_IntakeStalled", "OnIntakeStalled")
    RegisterForModEvent("RPB_SetAsideBounty", "OnSetAsideBounty")
    RegisterForModEvent("RPB_PrisonerFroze", "OnPrisonerFroze")
    RegisterForModEvent("RPB_PrisonSceneEvent", "OnPrisonSceneEvent")
    RegisterForModEvent("RPB_ArrestSceneEvent", "OnArrestSceneEvent")
    RegisterForModEvent("RPB_SurrenderSceneEvent", "OnSurrenderSceneEvent")
    self.__ResetSceneEventOrder()
    RegisterForModEvent("RPB_WorldInteractionApproach", "OnWorldInteractionApproach")
    RegisterForModEvent("RPB_WorldInteractionArrestAnswer", "OnWorldInteractionArrestAnswer")
    RegisterForModEvent("RPB_EncumbranceCheck", "OnEncumbranceCheck")
    RegisterForModEvent("RPB_ReleaseNPC", "OnReleaseNPC")

    ; The cuffed restrictions as the cuffs are now (animation events don't survive a load either)
    RPB_Utility.SyncCuffedRestrictions()

    ; The forced arrest dialogue back on unless an arrest or surrender of the player is under way: left off (a dev arrest
    ; that stopped on the way), no guard could arrest the player again in that save (2026-10-05)
    Actor player = Game.GetPlayer()
    ; Set either way: the arrest-on-sight game settings it also holds last the game session and aren't saved
    bool inCustody = RPB_Utility.IsActorArrested(player) || RPB_Utility.IsActorImprisoned(player) || (Arrest && Surrender.IsSurrendering(player))
    if (inCustody)
        ; Off when the player is in custody: a save from before it was kept off through the custody had it on
        RPB_Arrest.DisableForcedArrestDialogue()
    else
        if (RPB_Utility.RPB_ArrestGlobal("No Dialogue").GetValueInt() != 0)
            RPB_Utility.LogWarn("The forced arrest dialogue was left off with no arrest or surrender under way: turned back on", "EventManager::RegisterEvents")
        endif
        RPB_Arrest.EnableForcedArrestDialogue()
    endif
endFunction

; One NPC release of the player's time skip on a stack of its own (RPB_PrisonMonitor.ReleaseNPC, by event): the skip waits
; for it, bounded, so a release that hangs here doesn't hang the skip
event OnReleaseNPC(Form akActor, int aiPrisonID)
    RPB_Prison prison = API.PrisonManager.GetPrisonByID(aiPrisonID)
    if (!prison)
        RPB_Utility.LogError("No prison " + aiPrisonID + " for the release of " + akActor, "EventManager::OnReleaseNPC")
        return
    endif
    RPB_Prisoner prisoner = prison.Prisoners.AtKey(akActor as Actor)
    if (prisoner)
        ; Test 184's split: the delay before this stack started, and the release's own time (as on the skip's stack)
        float startedAt = Utility.GetCurrentRealTime()
        JDB.solveFltSetter(".rpb_root.npcReleaseLatency", JDB.solveFlt(".rpb_root.npcReleaseLatency") + (startedAt - JDB.solveFlt(".rpb_root.npcReleaseSentAt")), true)
        prison.SendReleaseRequest(prisoner)
        JDB.solveFltSetter(".rpb_root.npcReleaseWork", JDB.solveFlt(".rpb_root.npcReleaseWork") + (Utility.GetCurrentRealTime() - startedAt), true)
    endif
endEvent

; A second after the walking-only limit went on: still over-encumbered, still running? (RPB_Utility.LimitCuffedMovement_Encumbrance)
event OnEncumbranceCheck(string asEventName, string asStringArg, float afNumArg, Form akSender)
    Utility.Wait(1.0)
    if (JDB.solveInt(".rpb_root.cuffedLimit.encumbrance") != 0)
        RPB_Utility.LogInfo("Walking only, 1s later: " + RPB_Utility.EncumbranceTrace(Game.GetPlayer()), "EventManager::OnEncumbranceCheck")
    endif
endEvent

; The player's jumps while cuffed: a jump drops the cuffed pose (ZaZ's), and Papyrus can't block jumping. The player
; sends JumpUp on every jump and JumpFall only on a long fall (once in several jumps), no landing event (2026-10-05)
function WatchCuffedJumps(bool abOn)
    Actor player = Game.GetPlayer()
    bool registered = false
    ; And a load door: past its loading screen the cuffs are on but their pose is gone, as for an NPC whose 3D loads again
    ; (her effect's reattach puts them on again; the player's never detaches). One event per loading screen while cuffed
    if (abOn)
        registered = RegisterForAnimationEvent(player, "JumpUp")
        RegisterForMenu("Loading Menu")
    else
        UnregisterForAnimationEvent(player, "JumpUp")
        UnregisterForAnimationEvent(player, "JumpFall") ; the first version's
        UnregisterForMenu("Loading Menu")
    endif
    __watchingLanding = false
    Debug("EventManager::WatchCuffedJumps", "cuffed jump watch " + string_if(abOn, "on (JumpUp registered " + registered + ")", "off"))
endFunction

bool __watchingLanding ; one landing watch at a time (a second JumpFall mid-air)

; A jump while cuffed: once they've left the ground and landed again (their height still for 0.2s; no event says so),
; the cuffs are put on again (off and on), which plays their pose again
event OnAnimationEvent(ObjectReference akSource, string asEventName)
    Actor player = Game.GetPlayer()
    if (akSource != player || asEventName != "JumpUp" || __watchingLanding || !RPB_Utility.IsCuffed(player))
        return
    endif
    __watchingLanding = true
    float startZ = player.GetPositionZ()
    float waited = 0.0
    ; Up first (the event comes as the jump starts, still on the ground)
    while (Math.abs(player.GetPositionZ() - startZ) < 5.0 && waited < 0.6)
        Utility.Wait(0.05)
        waited += 0.05
    endWhile
    float lastZ = player.GetPositionZ()
    int still = 0
    while (still < 2 && waited < 4.0)
        Utility.Wait(0.1)
        waited += 0.1
        float z = player.GetPositionZ()
        if (Math.abs(z - lastZ) < 1.0)
            still += 1
        else
            still = 0
        endif
        lastZ = z
    endWhile
    __watchingLanding = false
    if (RPB_Utility.RefreshCuffsPose(player))
        Debug("EventManager::OnAnimationEvent", "landed from a jump while cuffed (" + ((waited * 1000.0) as int) + "ms after it started): the cuffs put on again")
    endif
endEvent

; A world interaction's guard comes to the player (WIDeadBody01's opener). A hook: logged and remembered for now; running off
; while he comes is meant to become eluding (the mod author, 2026-10-12)
event OnWorldInteractionApproach(Form akGuard, Form akQuest)
    JDB.solveFormSetter(".rpb_root.worldInteraction.approachGuard", akGuard, true)
    JDB.solveFormSetter(".rpb_root.worldInteraction.approachQuest", akQuest, true)
    JDB.solveFltSetter(".rpb_root.worldInteraction.approachAt", Utility.GetCurrentRealTime(), true)
    RPB_Utility.LogInfo(akGuard + " comes to the player for " + akQuest + " (a world interaction): nothing more yet (eluding later)", "EventManager::OnWorldInteractionApproach")
endEvent

; A world interaction's arrest line ended (WIDeadBody01 "you are now under arrest", @aiStage): the dialogue closing with the
; quest still at that stage (neither go to jail nor resist answered) is resisting arrest. One watch, on the dialogue menu
event OnWorldInteractionArrestAnswer(Form akGuard, Form akQuest, int aiStage)
    JDB.solveFormSetter(".rpb_root.worldInteraction.answerGuard", akGuard, true)
    JDB.solveFormSetter(".rpb_root.worldInteraction.answerQuest", akQuest, true)
    JDB.solveIntSetter(".rpb_root.worldInteraction.answerStage", aiStage, true)
    RegisterForMenu("Dialogue Menu")
endEvent

function __WorldInteractionDialogueClosed()
    UnregisterForMenu("Dialogue Menu")
    Actor guard = JDB.solveForm(".rpb_root.worldInteraction.answerGuard") as Actor
    Quest interaction = JDB.solveForm(".rpb_root.worldInteraction.answerQuest") as Quest
    int stage = JDB.solveInt(".rpb_root.worldInteraction.answerStage")
    JDB.solveFormSetter(".rpb_root.worldInteraction.answerGuard", none, true)
    JDB.solveFormSetter(".rpb_root.worldInteraction.answerQuest", none, true)
    if (!guard || !interaction || !interaction.IsRunning() || interaction.GetStage() != stage)
        return ; answered (go to jail or resist: their lines stopped the quest), or already over
    endif
    interaction.Stop()
    if (RPB_Utility.IsFrozenNPC(guard))
        return
    endif
    RPB_Utility.LogInfo("The player left " + guard + "'s arrest (" + interaction + ") without answering: resisting arrest", "EventManager::__WorldInteractionDialogueClosed")
    RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoStart", "(left the arrest without answering)", 15, guard, RPB_Utility.CrimeLineStamp())
endFunction

; Past a loading screen while cuffed (a load door, or a game load): the cuffs put on again once the player stands in the new
; cell, which plays their pose again. And the dialogue closing after a world interaction's arrest line (above)
event OnMenuClose(string asMenuName)
    if (asMenuName == "Dialogue Menu")
        self.__WorldInteractionDialogueClosed()
        return
    endif
    if (asMenuName != "Loading Menu")
        return
    endif
    Actor player = Game.GetPlayer()
    float waited = 0.0
    while (!player.Is3DLoaded() && waited < 5.0)
        Utility.Wait(0.25)
        waited += 0.25
    endWhile
    Utility.Wait(0.5) ; the 3D just in: its animation graph settles first, or the pose played now is dropped too
    if (RPB_Utility.RefreshCuffsPose(player))
        Debug("EventManager::OnMenuClose", "past a loading screen while cuffed: the cuffs put on again")
    endif
endEvent

event OnFaintFrozenGuard(Form akGuard, bool abAlone)
    RPB_Utility.__FaintFrozenGuard(akGuard as Actor, abAlone)
endEvent

; RPB_Utility.MoveGuardAfterBurst: his move on its own stack, after the burst; a frozen guard holds only this
event OnMoveGuard(Form akGuard, Form akTarget, float afDelay)
    if (afDelay > 0.0)
        Utility.Wait(afDelay)
    endif
    (akGuard as Actor).MoveTo(akTarget as ObjectReference)
    RPB_Utility.__GuardMoved(akGuard as Actor)
endEvent

; RPB_Arrestee.__EscortStalled: another guard of the hold for a stalled escort, or its fallback
event OnStalledEscortTakeover(Form akArrestee, string asReason)
    Arrest.TakeOverStalledEscort(akArrestee as Actor, asReason)
endEvent

; A frozen prisoner left out of a step of her Scene: her prison does what of it needs no call into her
function __FrozenPrisonerSceneStep(Actor akPrisoner, string asScene, string asSceneEvent, string asSceneSecondaryEvent, Actor akAuthority)
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(akPrisoner) ; no call into her
    if (prison)
        prison.FrozenPrisonerSceneStep(akPrisoner, asScene, asSceneEvent, asSceneSecondaryEvent, akAuthority)
    endif
endFunction

; RPB_Utility.MarkNPCFrozen: an NPC prisoner frozen in the prison flow, finished by her prison without a call into her. Her
; Scene events still pending are taken over first: a step stuck in a call into her has nothing after it to find her frozen
; when the Scene waits on it (her cell's "Unlock Cell": the guard stood at the closed door, test 202)
event OnPrisonerFroze(Form akPrisoner)
    self.__TakeOverFrozenMember(akPrisoner as Actor, 0)
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(akPrisoner as Actor)
    if (prison)
        prison.OnPrisonerFroze(akPrisoner as Actor)
    endif
endEvent

; RPB_Arrest.SetAsideBountyOnSubmission: his crime faction read here, a frozen guard holding only this stack
event OnSetAsideBounty(Form akActor, Form akGuard)
    RPB_Arrest.__SetAsideBountyFrom(akActor as Actor, akGuard as Actor)
endEvent

; RPB_Prison's intake watch: a frisk, strip, restrain or clothing stopped moving
event OnIntakeStalled(Form akPrisoner, Form akGuard, string asReason, string asKind)
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(akPrisoner as Actor)
    if (prison)
        prison.__RecoverStalledIntake(akPrisoner as Actor, akGuard as Actor, asReason, asKind)
    endif
endEvent

; RPB_ArrestMonitor: a confrontation stopped moving
event OnConfrontationStalled(Form akArrestee, Form akStuckGuard, string asReason, string asStep)
    Arrest.TakeOverStalledConfrontation(akArrestee as Actor, akStuckGuard as Actor, asReason, asStep)
endEvent

event OnSubmissionTakeover(Form akFrozenGuard)
    Arrest.TakeOverSubmission(akFrozenGuard as Actor)
endEvent

; The weapon pickup Scene's "Pick Up" phase (RPB_SceneManager): the captor picks up what @akOwner dropped
event OnPickUpWeapons(Form akOwner, Form akCaptor)
    API.Confiscation.PickUpWeapons(akOwner as Actor, akCaptor as Actor)
endEvent

; A parcel carrier's fight ended, or he unloaded (RPB_ParcelCarrier): to whoever gave him his job (only Confiscation yet)
event OnParcelCarrierCombatEnded(Form akCarrier, string asCause)
    API.Confiscation.OnCarrierCombatEnded(akCarrier as Actor)
endEvent

event OnParcelCarrierUnloaded(Form akCarrier, string asCause)
    RPB_Utility.LogInfo(akCarrier + " out of sight (" + asCause + ")", "EventManager::OnParcelCarrierUnloaded")
    API.Confiscation.OnCarrierUnloaded(akCarrier as Actor)
endEvent

; A fake surrender's guard running for the dropped weapons (RPB_Confiscation.__Fetch): his watch, on its own stack
event OnWatchFetch(Form akOwner)
    API.Confiscation.WatchFetch(akOwner as Actor)
endEvent

;/
    The movement and fighting an arrest took from the player at its first step (Arrest.OnArrestPreparing), 30s on: still
    off with no arrest Scene playing or queued for them, not cuffed (a pending arrest), not imprisoned or surrendering,
    the arrest got stuck before its confrontation (a guard frozen in the setup) and nothing will give them back: given back
/;
event OnCancelArrestRequest(Form akActor, string asReason)
    RPB_Recovery.CancelArrest(akActor as Actor, asReason)
endEvent

event OnArrestControlsCheck(float afStamp)
    Utility.Wait(30.0)
    if (JDB.solveFlt(".rpb_root.arrestControlsCheck") != afStamp || Game.IsMovementControlsEnabled())
        return ; a later arrest's check stands, or the controls are already back
    endif
    Actor player = Config.Player
    string current = SceneManager.GetCurrentScene()
    bool inScene = current != "" && (SceneManager.GetSceneNthReferenceOfType(current, "Escortee") == player || SceneManager.GetSceneNthReferenceOfType(current, "Prisoner") == player)
    if (inScene || SceneManager.HasQueuedSceneWithActor(player) || RPB_Utility.IsCuffed(player) || RPB_Utility.IsActorImprisoned(player) || Surrender.IsSurrendering(player))
        return
    endif
    RPB_Utility.LogWarn("The player's controls were still off 30s after an arrest began, with no arrest Scene for them: given back", "EventManager::OnArrestControlsCheck")
    Game.EnablePlayerControls(abMovement = true, abFighting = true, abCamSwitch = false, abLooking = false, abSneaking = false, abMenu = false, abActivate = false, abJournalTabs = false, aiDisablePOVType = 0)
endEvent

event OnSetAsideBountyCheck(Form akActor, float afDelay)
    Utility.Wait(afDelay)
    ; A takeover guard still walking over (a surrender-like approach): its own end gives the bounty back or arrests
    while (Surrender.IsSurrendering(akActor as Actor))
        Utility.Wait(5.0)
    endWhile
    if (RPB_Arrest.GiveBackSetAsideBounty(akActor as Actor, "no arrest took it within " + (afDelay as int) + "s"))
        RPB_Utility.LogWarn("A submission's arrest never started: " + akActor + "'s bounty is back", "EventManager::OnSetAsideBountyCheck")
    endif
endEvent

event OnNPCProbe(string asStep, Form akGuard, float afDelay, float afDueAt)
    if (afDelay > 0.0)
        Utility.Wait(afDelay)
        RPB_Utility.__AddPendingProbe(akGuard as Actor, -1) ; out now
    endif
    RPB_Utility.__RunNPCProbe(akGuard as Actor, asStep, afDueAt)
endEvent

; The probe's answer should be in by now: IsFrozenNPC only reads the list, and reports a probe that never came back
; A look at the probe a few seconds on, again while it's still open: one look only missed the 2026-10-02 freeze (the check
; ran before the probe had written itself down, read "no probe", and never looked again)
event OnNPCProbeCheck(Form akGuard, float afDelay)
    Actor guard = akGuard as Actor
    if (afDelay > 0.0)
        Utility.Wait(afDelay)
    endif
    int looks = 0
    while (looks < 3)
        Utility.Wait(3.5)
        if (RPB_Utility.IsFrozenNPC(guard) || (looks > 0 && !RPB_Utility.IsNPCProbeOpen(guard)))
            return
        endif
        looks += 1
    endWhile
endEvent

event OnReleaseCaptor(Form akGuard, Form akArrestee, bool abFreeGuard)
    Arrest.ReleaseCaptorOf(akGuard as Actor, akArrestee as Actor, abFreeGuard)
endEvent

; Freeze experiment D: the guard's release if his package change never came (RPB_Captor.OnPackageChange clears the mark)
event OnReleaseCaptorBackstop(Form akGuard, Form akArrestee, float afDelay)
    Utility.Wait(afDelay)
    if (!RPB_StorageVars.GetFormOnReference("Release Pending", akGuard, "Captor"))
        return
    endif
    RPB_StorageVars.DeleteVariableOnReference("Release Pending", akGuard, "Captor")
    RPB_Utility.LogWarn(akGuard + ": no package change within " + afDelay + "s, released by the backstop (experiment D)", "EventManager::OnReleaseCaptorBackstop")
    Arrest.ReleaseCaptorOf(akGuard as Actor, akArrestee as Actor, true)
endEvent

; A guard's package lock and package, on their own stack (a dead or frozen guard held the handover there)
event OnFreeGuard(Form akGuard)
    RPB_Recovery.__FreeGuard(akGuard as Actor, SceneManager)
endEvent

; ==========================================================
;                      Event Dispatchers
; ==========================================================

;/
    A surrender Scene's event to its surrenderer (@akParams: the guards she surrendered to, at its begin), as the arrest and
    prison ones: per member, on a stack of her own, the guard lists carried on her pending event (a mod event can't carry an
    array); @abTrackBatch (its end) returns the batch the Scene manager waits for. NPCs surrender too, and group surrenders
    will have one event per surrenderer.
/;
int function SendSurrenderSceneEvent(string asScene, string asSceneEvent, Actor akSurrenderer, Actor akSurrendererCaptor, string asSceneSecondaryEvent = "null", Form[] akParams = none, Form[] akParams2 = none, bool abTrackBatch = false)
    if (!akSurrenderer)
        RPB_Utility.LogError("No surrenderer for " + asScene + "'s " + asSceneEvent, "EventManager::SendSurrenderSceneEvent")
        return 0
    endif
    Form[] members = new Form[1]
    members[0] = akSurrenderer
    return self.__DispatchSceneEvent(SCENE_EVENT_SURRENDER, asScene, asSceneEvent, members, akSurrendererCaptor, asSceneSecondaryEvent, abTrackBatch, akParams, akParams2)
endFunction

; The surrenderer's part of a surrender Scene's event. @aiNumber: the event's number (0: unordered, see __IsSceneEventPending)
function __SurrenderSceneForMember(string asScene, string asSceneEvent, Actor akSurrenderer, Actor akSurrendererCaptor, string asSceneSecondaryEvent, Form[] akParams, Form[] akParams2, int aiNumber = 0)
    if (RPB_Utility.IsFrozenNPC(akSurrenderer)) ; her surrender's steps call into her
        RPB_Utility.LogWarn(akSurrenderer + " is frozen: left out of " + asScene + "'s " + asSceneEvent + " until the next load", "EventManager::__SurrenderSceneForMember")
        return
    endif
    if (RPB_Utility.IsFreezePointArmed())
        RPB_Utility.FreezePoint(akSurrenderer, self.__SceneEventPoint(asScene, asSceneEvent, asSceneSecondaryEvent))
    endif
    if (!self.__IsSceneEventPending(aiNumber))
        RPB_Utility.LogWarn(akSurrenderer + "'s " + asScene + " " + asSceneEvent + " was already handled the frozen way (or this stack waited through a load): not handled again", "EventManager::__SurrenderSceneForMember")
        return
    endif
    self.OnSurrenderScene(asScene, asSceneEvent, akSurrenderer, akSurrendererCaptor, asSceneSecondaryEvent, akParams, akParams2)
    self.__FlowMarkSceneEvent(asScene, asSceneEvent, asSceneSecondaryEvent, akSurrenderer)
endFunction

int function SendArrestSceneEvent(string asScene, string asSceneEvent, Actor akArrestee, Actor akAuthority, string asSceneSecondaryEvent = "null", bool abTrackBatch = false)
    Form[] members = new Form[1]
    members[0] = akArrestee
    return self.SendArrestSceneBulkEvent(asScene, asSceneEvent, members, akAuthority, asSceneSecondaryEvent, abTrackBatch)
endFunction

;/
    An arrest Scene's event to each of its arrestees, each on a stack of her own (__DispatchSceneEvent); @abTrackBatch (a
    Scene's end): returns the batch the Scene manager waits for.
/;
int function SendArrestSceneBulkEvent(string asScene, string asSceneEvent, Form[] akArrestees, Actor akAuthority, string asSceneSecondaryEvent = "null", bool abTrackBatch = false)
    if (!akArrestees || akArrestees.Length == 0)
        RPB_Utility.LogError("No Arrestees provided for bulk scene event!")
        return 0
    endif

    return self.__DispatchSceneEvent(SCENE_EVENT_ARREST, asScene, asSceneEvent, akArrestees, akAuthority, asSceneSecondaryEvent, abTrackBatch)
endFunction

; One arrestee's part of an arrest Scene's event. @abOnlyMember: she's the Scene's only arrestee, so her arrest being over
; ends the Scene. @aiNumber: the event's number (0: unordered), see __IsSceneEventPending
function __ArrestSceneForMember(string asScene, string asSceneEvent, Actor akArrestee, Actor akAuthority, string asSceneSecondaryEvent, bool abOnlyMember, int aiNumber = 0)
    if (!akArrestee)
        return
    endif
    if (RPB_Utility.IsFrozenNPC(akArrestee)) ; every step below calls into him
        RPB_Utility.LogWarn(akArrestee + " is frozen: left out of " + asScene + "'s " + asSceneEvent + " until the next load", "EventManager::__ArrestSceneForMember")
        return
    endif
    if (RPB_Utility.IsFreezePointArmed())
        RPB_Utility.FreezePoint(akArrestee, self.__SceneEventPoint(asScene, asSceneEvent, asSceneSecondaryEvent))
    endif
    if (self.__ArrestAlreadyEndedInPrison(akArrestee, asSceneSecondaryEvent))
        if (abOnlyMember)
            self.__EndSceneIfArresteeGone(asScene, akArrestee)
        endif
        return
    endif
    if (self.__ArrestGone(akArrestee, asSceneSecondaryEvent))
        if (abOnlyMember)
            SceneManager.EndSceneEarly(asScene, akArrestee + "'s arrest no longer exists", abRunEndEvents = false)
        endif
        return
    endif

    RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(akArrestee)
    if (arrestee == none)
        RPB_Utility.LogError("Could not retrieve the Arrestee reference from the actor, cannot proceed with the scene!")
        return
    endif
    if (!self.__IsSceneEventPending(aiNumber))
        RPB_Utility.LogWarn(akArrestee + "'s " + asScene + " " + asSceneEvent + " was already handled the frozen way (or this stack waited through a load): not handled again", "EventManager::__ArrestSceneForMember")
        return
    endif

    Debug("EventManager::__ArrestSceneForMember", "Entering OnArrestScene (Arrestee: "+ arrestee +") (Event: "+ asSceneEvent +", "+ asSceneSecondaryEvent +")")
    self.OnArrestScene(asScene, asSceneEvent, arrestee, akAuthority, asSceneSecondaryEvent)
    self.__FlowMarkSceneEvent(asScene, asSceneEvent, asSceneSecondaryEvent, akArrestee)
endFunction

;/
    True if @akActor's arrest has already ended in imprisonment: no longer an Arrestee, already a Prisoner. A confrontation
    Scene keeps playing its later phases after that when the arrest finishes first (the player leaves right after the
    confirmation, and the off-screen path imprisons in about a second while the Scene is still before "Handcuff").
    Awaiting the Arrestee then would put the Arrestee spell back on the prisoner (AwaitEntityReference ensures the spell
    first), and a new Arrestee effect would start on them once they load. So the event is ignored instead.
    The Arrestee lookup comes first and is the only cost for a normal arrest.
/;
bool function __ArrestAlreadyEndedInPrison(Actor akActor, string asSceneSecondaryEvent)
    if (!akActor || Arrest.Arrestees.AtKey(akActor))
        return false
    endif

    if (!akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell()))
        return false
    endif

    Debug("EventManager::__ArrestAlreadyEndedInPrison", akActor + "'s arrest already ended in imprisonment, ignoring the Scene's '" + asSceneSecondaryEvent + "' event")
    return true
endFunction

;/
    @asScene was started but never began playing (the engine silently refuses a Start() it can't run, e.g. an actor still
    in combat). Nothing else will ever move that arrest on, so for an escort I finish it the way the unloaded case in
    Arrestee.EscortToPrison already does: straight to the prison, or to the cell, without the Scene. Only a prisoner that
    isn't imprisoned yet: anything else has already moved on.
/;
function OnSceneStartFailed(string asScene)
    string sceneType = SceneManager.GetSceneType(asScene)
    if (sceneType == SceneManager.CATEGORY_SURRENDER)
        Actor surrenderer = SceneManager.GetSceneNthReferenceOfType(asScene, "Surrenderer") as Actor
        if (surrenderer)
            ; The surrender's watch starts it again (a guard back in combat), and undoes it after the last retry
            Surrender.OnSurrenderSceneFailed(surrenderer)
        endif
        return
    endif

    if (sceneType != SceneManager.CATEGORY_ESCORT_TO_JAIL && sceneType != SceneManager.CATEGORY_ESCORT_TO_CELL)
        return
    endif

    Actor escort    = SceneManager.GetSceneNthReferenceOfType(asScene, "Escort") as Actor
    Actor escortee  = SceneManager.GetSceneNthReferenceOfType(asScene, "Escortee") as Actor
    if (!escortee)
        return
    endif

    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(escortee)
    if (!prison)
        return
    endif

    RPB_Prisoner prisoner = prison.Prisoners.AtKey(escortee)
    if (!prisoner || prisoner.IsImprisoned)
        return
    endif

    ; Its guard dead: his death's own handling owns the arrest (inside the prison, another guard takes over, or the prisoner
    ; waits for one who sees them; outside it, the arrest is cancelled). A Scene with him that the prison flow queued just
    ; before he died never starts, and this teleported the player into the cell over that wait (2026-10-04)
    if (escort && RPB_Utility.IsDeadNoCall(escort))
        Info("EventManager: " + asScene + " never started for " + escortee + ": its guard " + escort + " is dead, his death's handover takes it")
        return
    endif
    bool escortFighting = escort && !RPB_Utility.IsFrozenNPC(escort) && escort.IsInCombat() ; no call on a frozen guard
    Info("EventManager: " + asScene + " never started for " + escortee + " (in combat " + escortee.IsInCombat() + ", escort " + escort + " in combat " + escortFighting + "), moving them without the Scene")
    if (sceneType == SceneManager.CATEGORY_ESCORT_TO_JAIL && escort)
        prisoner.MoveToPrison(escort)
    else
        prisoner.MoveToCell()
    endif
endFunction

;/
    True if @akActor's arrest doesn't exist anymore at all: not an arrestee (no entry, no Arrestee spell) and not a
    prisoner either (no Prisoner spell) - released, reverted or reset while its Scene was still playing. Awaiting the
    Arrestee would put the arrest back on them (AwaitEntityReference ensures the spell first): a prisoner released
    mid-arrest got the Arrestee spell again from the confrontation Scene's next step. A live arrest always passes: the
    Arrestee spell is added first thing in OnArrestBegin, before any Scene starts.
/;
bool function __ArrestGone(Actor akActor, string asSceneSecondaryEvent)
    if (!akActor || Arrest.Arrestees.AtKey(akActor))
        return false
    endif

    if (akActor.HasSpell(RPB_Utility.RPB_ArresteeSpell()) || akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell()))
        return false
    endif

    Debug("EventManager::__ArrestGone", akActor + "'s arrest no longer exists, ignoring the Scene's '" + asSceneSecondaryEvent + "' event")
    return true
endFunction

;/
    The rest of an arrest Scene is only for whoever can see it: once its only arrestee is already imprisoned and not even
    loaded (the player left, the off-screen path imprisoned them), it would otherwise keep playing for up to ~50s and
    hold up every Scene queued behind it. Only called after the arrest has fully ended, so it never cuts a Scene short
    while it still matters.
/;
function __EndSceneIfArresteeGone(string asScene, Actor akArrestee)
    if (akArrestee && !akArrestee.Is3DLoaded())
        SceneManager.EndSceneEarly(asScene, akArrestee + " is already imprisoned and not loaded")
    endif
endFunction

int function SendPrisonSceneEvent(string asScene, string asSceneEvent, Actor akPrisoner, Actor akAuthority, string asSceneSecondaryEvent = "null", bool abTrackBatch = false)
    Form[] members = new Form[1]
    members[0] = akPrisoner
    return self.SendPrisonSceneBulkEvent(asScene, asSceneEvent, members, akAuthority, asSceneSecondaryEvent, abTrackBatch)
endFunction

; A prison Scene's event to each of its prisoners, as SendArrestSceneBulkEvent: each on a stack of her own
int function SendPrisonSceneBulkEvent(string asScene, string asSceneEvent, Form[] akPrisoners, Actor akAuthority, string asSceneSecondaryEvent = "null", bool abTrackBatch = false)
    if (!akPrisoners || akPrisoners.Length == 0)
        RPB_Utility.LogError("No prisoners provided for bulk scene event!", "EventManager::SendPrisonSceneBulkEvent")
        return 0
    endif

    return self.__DispatchSceneEvent(SCENE_EVENT_PRISON, asScene, asSceneEvent, akPrisoners, akAuthority, asSceneSecondaryEvent, abTrackBatch)
endFunction

; One prisoner's part of a prison Scene's event: her prison found, and her step handled. @aiNumber: the event's number (0:
; unordered), see __IsSceneEventPending
function __PrisonSceneForMember(string asScene, string asSceneEvent, Actor akPrisoner, Actor akAuthority, string asSceneSecondaryEvent, int aiNumber = 0)
    if (!akPrisoner)
        return
    endif
    if (RPB_Utility.IsFrozenNPC(akPrisoner)) ; the prison's lookup and her steps call into her
        self.__PrisonSceneForFrozen(asScene, asSceneEvent, akPrisoner, akAuthority, asSceneSecondaryEvent)
        return
    endif
    if (RPB_Utility.IsFreezePointArmed())
        RPB_Utility.FreezePoint(akPrisoner, self.__SceneEventPoint(asScene, asSceneEvent, asSceneSecondaryEvent))
    endif

    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(akPrisoner)
    if (prison == none)
        RPB_Utility.LogError("Could not retrieve the prison from " + akPrisoner + ", cannot proceed with the scene!", "EventManager::__PrisonSceneForMember")
        return
    endif
    if (self.__PrisonerAlreadyGone(prison, akPrisoner, asSceneSecondaryEvent))
        return
    endif

    RPB_Prisoner prisoner = prison.AwaitPrisonerReference(akPrisoner)
    if (prisoner == none)
        RPB_Utility.LogError("Could not retrieve the prisoner from the scene event, cannot proceed with the scene!", "EventManager::__PrisonSceneForMember")
        return
    endif
    ; Stuck in the calls above until she was found frozen (or until a load ended her freeze): her step was then done the
    ; frozen way, by whoever found her
    if (!self.__IsSceneEventPending(aiNumber))
        RPB_Utility.LogWarn(akPrisoner + "'s " + asScene + " " + asSceneEvent + " was already handled the frozen way (or this stack waited through a load): not handled again", "EventManager::__PrisonSceneForMember")
        return
    endif

    self.OnPrisonScene(asScene, asSceneEvent, prison, prisoner, akAuthority, asSceneSecondaryEvent)
    self.__FlowMarkSceneEvent(asScene, asSceneEvent, asSceneSecondaryEvent, akPrisoner)
endFunction

; A prisoner RPB found frozen: left out of her Scene's step, her prison does what of it needs no call into her
function __PrisonSceneForFrozen(string asScene, string asSceneEvent, Actor akPrisoner, Actor akAuthority, string asSceneSecondaryEvent)
    RPB_Utility.LogWarn(akPrisoner + " is frozen: left out of " + asScene + "'s " + asSceneEvent + " until the next load", "EventManager::__PrisonSceneForFrozen")
    RPB_Utility.NoteFrozenAction(akPrisoner, "Left out of the prison's " + asScene + " (" + asSceneEvent + ")")
    self.__FrozenPrisonerSceneStep(akPrisoner, asScene, asSceneEvent, asSceneSecondaryEvent, akAuthority)
endFunction

;/
    An intake Scene's step (frisk, strip, restrain, clothing) restarts the prisoner's clock in her prison's intake watch as
    the Scene sends it, not when her handler gets to it: the watch asks whether her Scene moved on, and with her events in
    order a slow handler held her later steps back, so a strip still playing read as stuck and was taken over (2026-10-13:
    "no step for 17s" while the strip played, and the takeover escorted her to the cell from inside it). No call into her
    (the prison lookup reads its own registry). Dispatched to a frozen member too: the watch passes over her
/;
function __NoteIntakeStepSent(string asScene, string asSceneEvent, string asSceneSecondaryEvent, Actor akMember)
    string sceneType = SceneManager.GetSceneType(asScene)
    if (sceneType != SceneManager.CATEGORY_FRISKING && sceneType != SceneManager.CATEGORY_STRIPPING && sceneType != SceneManager.CATEGORY_RESTRAIN && sceneType != SceneManager.CATEGORY_CLOTHING && sceneType != SceneManager.CATEGORY_NO_CLOTHING)
        return
    endif
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(akMember)
    if (prison)
        prison.NoteIntakeStep(akMember, asScene + ": " + asSceneEvent + RPB_Utility.string_if(asSceneSecondaryEvent != "null", " (" + asSceneSecondaryEvent + ")", ""))
    endif
endFunction

; A Scene event's freeze point name (RPB_Utility.FreezePoint): "<Scene> <event>", and " (<secondary event>)" if any
string function __SceneEventPoint(string asScene, string asSceneEvent, string asSceneSecondaryEvent)
    return asScene + " " + asSceneEvent + RPB_Utility.string_if(asSceneSecondaryEvent != "null" && asSceneSecondaryEvent != "", " (" + asSceneSecondaryEvent + ")", "")
endFunction

; The flow profiler's mark for a member's Scene event handled (only while a flow is being profiled)
function __FlowMarkSceneEvent(string asScene, string asSceneEvent, string asSceneSecondaryEvent, Actor akMember)
    if (!RPB_Utility.IsFlowActive())
        return
    endif
    string secondary = RPB_Utility.string_if(asSceneSecondaryEvent != "null" && asSceneSecondaryEvent != "", " (" + asSceneSecondaryEvent + ")", "")
    RPB_Utility.FlowMark(asScene + " " + asSceneEvent + secondary + " handled for " + akMember)
endFunction

; ==========================================================
;              Scene Events, One Stack per Member
; ==========================================================

;/
    A Scene's event reaches each of its members on a stack of her own (RPB_PrisonSceneEvent / RPB_ArrestSceneEvent, handled
    below), no longer on the Scene manager's. A member frozen but not marked yet (the seconds before her probe found her) hung
    the handler that called into her, and with it the Scene queue: the next Scene only played once the end's handlers had
    returned (KNOWN_ISSUES round 187: frozen during the strip, the strip's end left both of them standing in the intake area).
    Now only her own stack hangs.
    - Order per member: each event is numbered as it's sent, and her handler waits for her previous one to be done (her
      "Lock Cell" step before her escort's end). Members never wait on each other.
    - A Scene's end: the Scene manager waits for its batch before it plays the next Scene
      (RPB_SceneManager.__AwaitSceneEndHandlers).
    - The bookkeeping is in plain script arrays, changed only in this script's functions with no call out in between: no
      other stack can come in halfway (a JContainers call could let one in).
    - Nothing here calls into a member: she's only passed along (pushed to the event, compared in an array).
    - Every event sent is on a pending list (JDB .rpb_root.sceneEventsPending, by number) until it's handled. A member found
      frozen has her pending events taken over (__TakeOverFrozenMember): each run the frozen way, once, in order, from
      whoever found her (her next event's wait, or the Scene end's gate). Her handler stuck in a call into her never gets
      to do it, and the end gate moving on without her would have left her step undone (at the escort to jail's end:
      nothing queued her strip or her escort to the cell). A handler that resumes later (after a load) finds its event
      gone from the list and stops.
/;
; What a Scene event is for (its handler, and what its frozen way is)
int property SCENE_EVENT_ARREST = 0 autoreadonly
int property SCENE_EVENT_PRISON = 1 autoreadonly
int property SCENE_EVENT_SURRENDER = 2 autoreadonly

Form[] __orderMembers   ; the member each ordering slot is for
int[] __orderSent       ; the number of her last event sent
int[] __orderDone       ; the number of her last event handled
int __orderLast         ; the last number given
int[] __batchIds        ; a Scene end's batch, per slot (0: a free slot)
int[] __batchPending    ; its members not handled yet
int __batchLast

function __EnsureSceneEventOrder()
    if (!__orderMembers || __orderMembers.Length == 0)
        __orderMembers = new Form[128]
        __orderSent = new int[128]
        __orderDone = new int[128]
        __batchIds = new int[32]
        __batchPending = new int[32]
    endif
endFunction

; After a load (RegisterEvents): what was in flight before it is let go, an event lost with the save would hold her next
; ones up. A handler restored with the save still runs; it no longer holds anyone up
function __ResetSceneEventOrder()
    self.__EnsureSceneEventOrder()
    JDB.solveObjSetter(".rpb_root.sceneEventsPending", JIntMap.object(), true)
    int i = 0
    while (i < __orderMembers.Length)
        __orderDone[i] = __orderSent[i]
        i += 1
    endWhile
    i = 0
    while (i < __batchIds.Length)
        __batchIds[i] = 0
        __batchPending[i] = 0
        i += 1
    endWhile
endFunction

; @akMember's ordering slot, given one if she has none (a slot with nothing in flight is reused). -1 if all are busy
int function __OrderSlot(Form akMember)
    int slot = __orderMembers.Find(akMember)
    if (slot >= 0)
        return slot
    endif
    slot = __orderMembers.Find(none)
    int i = 0
    while (slot < 0 && i < __orderMembers.Length)
        if (__orderDone[i] >= __orderSent[i])
            slot = i
        endif
        i += 1
    endWhile
    if (slot >= 0)
        __orderMembers[slot] = akMember
        __orderSent[slot] = 0
        __orderDone[slot] = 0
    endif
    return slot
endFunction

; A Scene end's batch (0 if every slot is taken: that end then doesn't wait)
int function __NewBatch()
    int slot = __batchIds.Find(0)
    if (slot < 0)
        RPB_Utility.LogWarn("No free batch slot (32 Scene ends waiting at once?): this end doesn't wait for its handlers", "EventManager::__NewBatch")
        return 0
    endif
    __batchLast += 1
    __batchIds[slot] = __batchLast
    __batchPending[slot] = 0
    return __batchLast
endFunction

; RPB_SceneManager.__AwaitSceneEndHandlers: the members of @aiBatch not handled yet (0 for a batch no longer known)
int function SceneEndBatchPending(int aiBatch)
    int slot = __batchIds.Find(aiBatch)
    if (!aiBatch || slot < 0)
        return 0
    endif
    return __batchPending[slot]
endFunction

; RPB_SceneManager.__AwaitSceneEndHandlers: done waiting for @aiBatch, its slot freed
function EndSceneEndBatch(int aiBatch)
    int slot = __batchIds.Find(aiBatch)
    if (aiBatch && slot >= 0)
        __batchIds[slot] = 0
        __batchPending[slot] = 0
    endif
endFunction

; @akMember's event @aiSeq handled (or given up on): taken off the pending list, her next one may go, and her Scene end's
; batch has one fewer to wait for. Only if it was still pending: one taken over meanwhile was counted then
function __SceneEventDone(Form akMember, int aiSeq, int aiBatch)
    bool claimed = aiSeq <= 0 || RPB_Memory.FastIntMap_RemoveKey(self.__PendingSceneEvents(), aiSeq)
    self.__MarkSceneEventHandled(akMember, aiSeq, aiBatch, claimed)
endFunction

; No call in here (see the arrays above). @abCountForBatch: false for an event already counted (taken over)
function __MarkSceneEventHandled(Form akMember, int aiSeq, int aiBatch, bool abCountForBatch)
    int slot = __orderMembers.Find(akMember)
    if (slot >= 0 && __orderDone[slot] < aiSeq)
        __orderDone[slot] = aiSeq
    endif
    if (aiBatch && abCountForBatch)
        int batchSlot = __batchIds.Find(aiBatch)
        if (batchSlot >= 0)
            __batchPending[batchSlot] = __batchPending[batchSlot] - 1
        endif
    endif
endFunction

int function __PendingSceneEvents()
    int pending = JDB.solveObj(".rpb_root.sceneEventsPending")
    if (!pending)
        pending = JIntMap.object()
        JDB.solveObjSetter(".rpb_root.sceneEventsPending", pending, true)
    endif
    return pending
endFunction

; A guard list carried on pending event @aiNumber (@asKey "params" or "params2"), none if it has none
Form[] function __PendingSceneEventForms(int aiNumber, string asKey)
    Form[] noForms ; returned unset: "return none" logs a cast error for an array
    int entry = RPB_Memory.FastIntMap_GetObject(self.__PendingSceneEvents(), aiNumber)
    if (aiNumber <= 0 || !entry)
        return noForms
    endif
    int forms = RPB_Memory.FastMap_GetObject(entry, asKey)
    if (!forms)
        return noForms
    endif
    return RPB_Memory.FastArray_ToFormArray(forms)
endFunction

; Event @aiNumber not handled yet (0, no ordering slot: always)
bool function __IsSceneEventPending(int aiNumber)
    if (aiNumber <= 0)
        return true
    endif
    return RPB_Memory.FastIntMap_HasKey(self.__PendingSceneEvents(), aiNumber)
endFunction

function __RecordPendingSceneEvent(int aiNumber, int aiKind, string asScene, string asSceneEvent, string asSceneSecondaryEvent, Actor akMember, Actor akAuthority, int aiBatch, Form[] akParams, Form[] akParams2)
    int entry = JMap.object()
    if (akParams)
        RPB_Memory.FastMap_SetObject(entry, "params", RPB_Memory.FastArray_FromFormArray(akParams))
    endif
    if (akParams2)
        RPB_Memory.FastMap_SetObject(entry, "params2", RPB_Memory.FastArray_FromFormArray(akParams2))
    endif
    RPB_Memory.FastMap_SetString(entry, "scene", asScene)
    RPB_Memory.FastMap_SetString(entry, "event", asSceneEvent)
    RPB_Memory.FastMap_SetString(entry, "secondary", asSceneSecondaryEvent)
    RPB_Memory.FastMap_SetForm(entry, "member", akMember)
    RPB_Memory.FastMap_SetForm(entry, "authority", akAuthority)
    RPB_Memory.FastMap_SetInt(entry, "kind", aiKind)
    RPB_Memory.FastMap_SetInt(entry, "batch", aiBatch)
    RPB_Memory.FastIntMap_SetObject(self.__PendingSceneEvents(), aiNumber, entry)
endFunction

;/
    @akMember found frozen: her Scene events not handled yet (up to @aiUpTo, 0: all of them) run the frozen way, once each,
    in the order they were sent. Their handlers are stuck in a call into her, or waiting behind one. Each is claimed first
    (taken off the pending list), so a handler that resumes later, or another takeover, doesn't run it again. No call into her.
/;
function __TakeOverFrozenMember(Actor akMember, int aiUpTo)
    int pending = JDB.solveObj(".rpb_root.sceneEventsPending")
    if (!pending || !akMember)
        return
    endif
    int[] numbers = RPB_Memory.FastIntMap_KeysAsPapyrusArray(pending)
    ; Ascending (the order they were sent)
    int i = 1
    while (numbers && i < numbers.Length)
        int current = numbers[i]
        int j = i - 1
        while (j >= 0 && numbers[j] > current)
            numbers[j + 1] = numbers[j]
            j -= 1
        endWhile
        numbers[j + 1] = current
        i += 1
    endWhile

    i = 0
    while (numbers && i < numbers.Length)
        int number = numbers[i]
        int entry = RPB_Memory.FastIntMap_GetObject(pending, number)
        if ((aiUpTo <= 0 || number <= aiUpTo) && entry && RPB_Memory.FastMap_GetForm(entry, "member") == akMember)
            string sceneName = RPB_Memory.FastMap_GetString(entry, "scene")
            string sceneEvent = RPB_Memory.FastMap_GetString(entry, "event")
            string secondary = RPB_Memory.FastMap_GetString(entry, "secondary")
            Actor authority = RPB_Memory.FastMap_GetForm(entry, "authority") as Actor
            bool isPrison = RPB_Memory.FastMap_GetInt(entry, "kind") == SCENE_EVENT_PRISON
            int batch = RPB_Memory.FastMap_GetInt(entry, "batch")
            if (RPB_Memory.FastIntMap_RemoveKey(pending, number))
                RPB_Utility.LogWarn(akMember + " is frozen: her " + sceneName + " " + sceneEvent + " (#" + number + ") taken over, done the frozen way", "EventManager::__TakeOverFrozenMember")
                if (isPrison)
                    self.__PrisonSceneForFrozen(sceneName, sceneEvent, akMember, authority, secondary)
                endif
                self.__MarkSceneEventHandled(akMember, number, batch, true)
            endif
        endif
        i += 1
    endWhile
endFunction

; RPB_SceneManager.__AwaitSceneEndHandlers: the members of a Scene's end found frozen get their pending events taken over.
; Returns how many were frozen
int function TakeOverFrozenMembers(Form[] akMembers)
    int frozen = 0
    int i = 0
    while (akMembers && i < akMembers.Length)
        Actor member = akMembers[i] as Actor
        if (member && RPB_Utility.IsFrozenNPC(member))
            self.__TakeOverFrozenMember(member, 0)
            frozen += 1
        endif
        i += 1
    endWhile
    return frozen
endFunction

;/
    Sends @asScene's @asSceneEvent to each of @akMembers on a stack of her own (OnPrisonSceneEvent / OnArrestSceneEvent). A
    member already marked frozen is handled here, with no call into her. @abTrackBatch (a Scene's end): returns the batch
    the Scene manager waits for, else 0.
/;
int function __DispatchSceneEvent(int aiKind, string asScene, string asSceneEvent, Form[] akMembers, Actor akAuthority, string asSceneSecondaryEvent, bool abTrackBatch, Form[] akParams = none, Form[] akParams2 = none)
    self.__EnsureSceneEventOrder()
    bool abPrison = aiKind == SCENE_EVENT_PRISON
    string eventName = "RPB_ArrestSceneEvent"
    if (abPrison)
        eventName = "RPB_PrisonSceneEvent"
    elseif (aiKind == SCENE_EVENT_SURRENDER)
        eventName = "RPB_SurrenderSceneEvent"
    endif
    int batch = 0
    if (abTrackBatch)
        batch = self.__NewBatch()
    endif

    int frozenMap = RPB_Utility.FrozenNPCsForScan()
    int i = 0
    while (i < akMembers.Length)
        Actor member = akMembers[i] as Actor
        if (member && abPrison)
            self.__NoteIntakeStepSent(asScene, asSceneEvent, asSceneSecondaryEvent, member)
        endif
        if (!member)
            ; an empty alias
        elseif (frozenMap && RPB_Utility.IsListedFrozen(frozenMap, member))
            self.__TakeOverFrozenMember(member, 0) ; her earlier ones first, in order (none if her mark already took them)
            if (abPrison)
                self.__PrisonSceneForFrozen(asScene, asSceneEvent, member, akAuthority, asSceneSecondaryEvent)
            else
                RPB_Utility.LogWarn(member + " is frozen: left out of " + asScene + "'s " + asSceneEvent + " until the next load", "EventManager::__DispatchSceneEvent")
            endif
        else
            ; Numbered here, with nothing called in between: two Scene events sent at once (a step and the end) can't take
            ; the same number
            int slot = self.__OrderSlot(member)
            int previous = 0
            int number = 0
            if (slot >= 0)
                __orderLast += 1
                number = __orderLast
                previous = __orderSent[slot]
                __orderSent[slot] = number
            else
                RPB_Utility.LogWarn("Every ordering slot is busy: " + member + "'s " + asScene + " " + asSceneEvent + " goes unordered", "EventManager::__DispatchSceneEvent")
                if (aiKind == SCENE_EVENT_SURRENDER)
                    ; Its guard lists ride on the pending event, which needs a number: handled here, on this stack
                    self.__SurrenderSceneForMember(asScene, asSceneEvent, member, akAuthority, asSceneSecondaryEvent, akParams, akParams2)
                    return batch
                endif
            endif
            if (batch)
                int batchSlot = __batchIds.Find(batch)
                if (batchSlot >= 0)
                    __batchPending[batchSlot] = __batchPending[batchSlot] + 1
                endif
            endif
            if (number > 0)
                self.__RecordPendingSceneEvent(number, aiKind, asScene, asSceneEvent, asSceneSecondaryEvent, member, akAuthority, batch, akParams, akParams2)
            endif

            int handle = ModEvent.Create(eventName)
            if (handle)
                ModEvent.PushString(handle, asScene)
                ModEvent.PushString(handle, asSceneEvent)
                ModEvent.PushString(handle, asSceneSecondaryEvent)
                ModEvent.PushForm(handle, member)
                ModEvent.PushForm(handle, akAuthority)
                ModEvent.PushInt(handle, previous)
                ModEvent.PushInt(handle, number)
                ModEvent.PushInt(handle, batch)
                ModEvent.PushInt(handle, akMembers.Length)
                ModEvent.Send(handle)
            else
                ; Never sent: counted as done, or her later events and this end would wait on it
                RPB_Utility.LogError("Could not create " + eventName + " for " + member + " (" + asScene + " " + asSceneEvent + "): her step is skipped", "EventManager::__DispatchSceneEvent")
                self.__SceneEventDone(member, number, batch)
            endif
        endif
        i += 1
    endWhile
    return batch
endFunction

; A member's Scene event on her own stack. Found frozen while waiting her turn: her events up to this one done the frozen way
; (the stuck one before it too). Already taken over meanwhile: nothing left to do
event OnPrisonSceneEvent(string asScene, string asSceneEvent, string asSceneSecondaryEvent, Form akMember, Form akAuthority, int aiPrevious, int aiNumber, int aiBatch, int aiMembers)
    Actor member = akMember as Actor
    if (!self.__AwaitTurn(member, aiPrevious, asScene + " " + asSceneEvent))
        if (aiNumber > 0)
            self.__TakeOverFrozenMember(member, aiNumber)
        else
            self.__PrisonSceneForFrozen(asScene, asSceneEvent, member, akAuthority as Actor, asSceneSecondaryEvent)
        endif
    elseif (self.__IsSceneEventPending(aiNumber))
        self.__PrisonSceneForMember(asScene, asSceneEvent, member, akAuthority as Actor, asSceneSecondaryEvent, aiNumber)
    endif
    self.__SceneEventDone(akMember, aiNumber, aiBatch)
endEvent

event OnSurrenderSceneEvent(string asScene, string asSceneEvent, string asSceneSecondaryEvent, Form akMember, Form akAuthority, int aiPrevious, int aiNumber, int aiBatch, int aiMembers)
    Actor member = akMember as Actor
    if (!self.__AwaitTurn(member, aiPrevious, asScene + " " + asSceneEvent))
        self.__TakeOverFrozenMember(member, aiNumber)
    elseif (self.__IsSceneEventPending(aiNumber))
        Form[] params = self.__PendingSceneEventForms(aiNumber, "params")
        Form[] params2 = self.__PendingSceneEventForms(aiNumber, "params2")
        self.__SurrenderSceneForMember(asScene, asSceneEvent, member, akAuthority as Actor, asSceneSecondaryEvent, params, params2, aiNumber)
    endif
    self.__SceneEventDone(akMember, aiNumber, aiBatch)
endEvent

event OnArrestSceneEvent(string asScene, string asSceneEvent, string asSceneSecondaryEvent, Form akMember, Form akAuthority, int aiPrevious, int aiNumber, int aiBatch, int aiMembers)
    Actor member = akMember as Actor
    if (!self.__AwaitTurn(member, aiPrevious, asScene + " " + asSceneEvent))
        if (aiNumber > 0)
            self.__TakeOverFrozenMember(member, aiNumber)
        else
            RPB_Utility.LogWarn(member + " is frozen: left out of " + asScene + "'s " + asSceneEvent + " until the next load", "EventManager::OnArrestSceneEvent")
        endif
    elseif (self.__IsSceneEventPending(aiNumber))
        self.__ArrestSceneForMember(asScene, asSceneEvent, member, akAuthority as Actor, asSceneSecondaryEvent, aiMembers == 1, aiNumber)
    endif
    self.__SceneEventDone(akMember, aiNumber, aiBatch)
endEvent

;/
    @akMember's previous Scene event (@aiPrevious, 0: none) handled first. False if she's found frozen meanwhile: this one
    then goes the frozen way. Her previous one still not done after the Advanced wait (RPB_Utility.SceneEventProbeAfter)
    gets her probed; it may only be slow (a heavy script load), so I keep waiting, up to the longest wait
    (RPB_Utility.SceneEventGiveUpAfter: a handler stuck on someone else, her guard frozen, never finishes). Each look waits a
    frame or so; the waits are counted, so time in a menu doesn't count.
/;
bool function __AwaitTurn(Actor akMember, int aiPrevious, string asWhat)
    if (aiPrevious <= 0)
        return true
    endif
    float probeAfter = RPB_Utility.SceneEventProbeAfter()
    float giveUpAfter = RPB_Utility.SceneEventGiveUpAfter()
    float waited = 0.0
    bool probed = false
    while (true)
        int slot = __orderMembers.Find(akMember)
        if (slot < 0 || __orderDone[slot] >= aiPrevious)
            return true
        endif
        if (RPB_Utility.IsFrozenNPC(akMember))
            return false
        endif
        if (waited >= giveUpAfter)
            RPB_Utility.LogWarn(akMember + "'s previous Scene event still not done after " + (waited as int) + "s: " + asWhat + " goes ahead of it", "EventManager::__AwaitTurn")
            return true
        endif
        if (!probed && waited >= probeAfter)
            probed = true
            if (!RPB_Utility.IsNPCProbeOpen(akMember))
                RPB_Utility.ProbeNPC(akMember, asWhat + ": her previous Scene event not done after " + (waited as int) + "s", 0.0, "PRISONER")
            endif
        endif
        Utility.Wait(0.02)
        waited += 0.02
    endWhile
    return true
endFunction

;/
    True if @akActor is no longer a prisoner of @apPrison (released, or reset): neither registered nor carrying the Prisoner
    spell (checked second: an away prisoner isn't in the list but keeps the spell). A Scene can still be running for them,
    and awaiting the prisoner would make them one again (AwaitEntityReference ensures the spell first) and run its step on
    them anyway: a prisoner released mid-escort got stripped a second later by the escort's own end.
/;
bool function __PrisonerAlreadyGone(RPB_Prison apPrison, Actor akActor, string asSceneSecondaryEvent)
    if (!akActor || apPrison.Prisoners.AtKey(akActor))
        return false
    endif

    if (akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell()))
        return false
    endif

    Debug("EventManager::__PrisonerAlreadyGone", akActor + " is no longer a prisoner of " + apPrison.Name + ", ignoring the Scene's '" + asSceneSecondaryEvent + "' event")
    return true
endFunction

; ==========================================================
;                       Logging Events
; ==========================================================

event OnTrace(string msg, string caller)
    Trace(caller, msg)
endEvent

; Logging: RPB_Utility.LogInfo/LogWarn/LogError (the leveled log); the SendInfo/SendWarning/SendError copies here are gone

function TraceParams(string params, string paramNames = "", string caller = "")
    string[] splitParams    = StringUtil.Split(params, ",")
    string[] splitNames     = StringUtil.Split(paramNames, ", ")

    string traceMsg = "[\n"
    int i = 0
    while (i < splitParams.Length)
        string paramName = string_if (splitNames[i], splitNames[i], i)
        traceMsg = "\t" + paramName + ": " + splitParams[i] + "\n"
        ; if (i < splitParams.Length - 1)
        ;     traceMsg += "\n"
        ; endif
        i += 1
    endWhile
    traceMsg += "\n]"
    
    self.OnTrace(traceMsg, caller)
endFunction

; ==========================================================
;                        Arrest Events
; ==========================================================

event OnArrestBegin(string eventName, string arrestType, float arresteeIdFlt, Form sender)
    RPB_Utility.FlowEnsure("Arrest -> Imprison")
    RPB_Utility.FlowMark("EventManager.OnArrestBegin: mod event delivered")

    Actor captor = (sender as Actor)
    ; Before any call on him: a frozen guard's first call never returns, and this arrest would hang with it
    if (captor && RPB_Utility.IsFrozenNPC(captor))
        Warn("Arrest by " + captor + " rejected: the guard is frozen (see FROZEN GUARD)")
        ; A submission to him: another guard takes it over (no-op otherwise)
        RPB_Arrest.RequestSubmissionTakeover(captor)
        return
    endif
    Faction crimeFaction = form_if ((sender as Faction), (sender as Faction), captor.GetCrimeFaction()) as Faction

    if (captor == none && crimeFaction == none)
        RPB_Utility.LogError("Either there's no Captor, or no Crime Faction! (["+ "Captor: "+ captor + ", Faction: " + crimeFaction +"])", "EventManager::OnArrestBegin")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return
    endif

    ; A dead guard can't arrest anyone. Rejected here, before any arrest state exists: later, the Captor effect can't even
    ; start on a dead actor, and the arrest only got cancelled after that wait timed out (~10s)
    if (captor && (captor.IsDead() || captor.IsDisabled()))
        Info("Arrest by " + captor + " rejected: the guard is dead or gone")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return
    endif

    int actorPlayerId = 0x14
    bool isPlayer = (arresteeIdFlt as int) == actorPlayerId
    Actor arrestee = Game.GetFormEx(int_if (isPlayer, actorPlayerId, arresteeIdFlt as int)) as Actor

    if (!arrestee)
        RPB_Utility.LogError("There's no one to be arrested! (Arrestee is "+ arrestee +")", "EventManager::OnArrestBegin")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return
    endif

    if (!Arrest.ValidateArrestType(arrestType))
        RPB_Utility.LogError("Arrest Type is invalid, got: " + arrestType + ". (valid options: "+ Arrest.GetValidArrestTypes() +") ", "EventManager::OnArrestBegin")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return
    endif

    ; Their last arrest still being cancelled (its wait after the guard's Scene stop) would read as "already arrested"
    RPB_Recovery.FinishCancelNow(arrestee)

    int arrestStatus = Arrest.GetActorArrestStatus(arrestee)

    if (arrestStatus == Arrest.ALREADY_ARRESTED)
        Config.NotifyArrest("You are already under arrest.", isPlayer) ; Might be removed
        RPB_Utility.LogError(arrestee.GetBaseObject().GetName() + " has already been arrested, cannot arrest for "+ RPB_Utility.GetFormNameCached(crimeFaction) +", aborting!", "EventManager::OnArrestBegin")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return

    elseif (arrestStatus == Arrest.ALREADY_IMPRISONED)
        Config.NotifyArrest("You are already in prison.", isPlayer) ; Might be removed
        RPB_Utility.LogError(arrestee.GetBaseObject().GetName() + " has already been arrested, and is currently in prison. Cannot arrest for "+ RPB_Utility.GetFormNameCached(crimeFaction) +", aborting!", "EventManager::OnArrestBegin")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return
    endif

    RPB_Utility.FlowMark("OnArrestBegin: validated (type, arrest status)")
    RPB_Utility.Crumb(arrestee, "OnArrestBegin: validated (type, arrest status)")

    ; Handle Before Arrest event
    Arrest.OnArrestPreparing(arrestee, captor, crimeFaction, arrestType)
    RPB_Utility.FlowMark("Arrest.OnArrestPreparing done")
    RPB_Utility.Crumb(arrestee, "Arrest.OnArrestPreparing done")

    RPB_Arrestee arresteeRef = Arrest.AwaitArresteeReference(arrestee)  ; Mark this Actor as one that is to be arrested (Cast the spell in order to have Arrestee related functions on them through RPB_Arrestee)

    RPB_Utility.FlowMark("AwaitArresteeReference done (spell, effect start, register)")
    RPB_Utility.Crumb(arrestee, "AwaitArresteeReference done (spell, effect start, register)")

    if (!arresteeRef)
        ; The Arrestee never registered - e.g. the actor died before its effect could start (a corpse can't take it).
        ; Nothing else has run yet, so undo the only things that did happen - the spell and its Hold binding - instead
        ; of leaving the actor half-arrested with a spell no script will ever answer for.
        arrestee.RemoveSpell(RPB_Utility.RPB_ArresteeSpell())
        RPB_StorageVars.DeleteVariableOnReference("Hold UUID", arrestee, "Arrest")
        ; A surrender's dropped weapons, locked while it was on: nobody's coming for them now (a save during this arrest's
        ; start, loaded, reverted it with the weapon still locked, 2026-10-14). Still remembered, for a later arrest's pickup
        API.Confiscation.UnblockDroppedWeapons(arrestee)
        RPB_Utility.Crumb(arrestee, "OnArrestBegin: arrestee never registered, spell removed (reverted)")
        Config.NotifyArrest("Could not arrest " + arrestee.GetDisplayName())
        RPB_Utility.LogError("Could not arrest " + arrestee + " for "+ RPB_Utility.GetFormNameCached(crimeFaction) +", the Arrestee never registered! (reverted)", "EventManager::OnArrestBegin")
        if (isPlayer) ; the controls Arrest.OnArrestPreparing took
            Game.EnablePlayerControls(abMovement = true, abFighting = true, abCamSwitch = false, abLooking = false, abSneaking = false, abMenu = false, abActivate = false, abJournalTabs = false, aiDisablePOVType = 0)
        endif
        return
    endif

    if (!arresteeRef.InitializeState())
        Config.NotifyArrest("Could not arrest " + arresteeRef.Name)
        RPB_Utility.LogError("Could not arrest " + arresteeRef.Name + " for "+ RPB_Utility.GetFormNameCached(crimeFaction) +", the state was invalid! (aborting)", "EventManager::OnArrestBegin")
        if (isPlayer) ; the controls Arrest.OnArrestPreparing took
            Game.EnablePlayerControls(abMovement = true, abFighting = true, abCamSwitch = false, abLooking = false, abSneaking = false, abMenu = false, abActivate = false, abJournalTabs = false, aiDisablePOVType = 0)
        endif
        return
    endif

    RPB_Utility.FlowMark("Arrestee.InitializeState done")
    RPB_Utility.Crumb(arrestee, "Arrestee.InitializeState done")

    ; Faction Arrest
    if (captor == none)
        Arrest.OnArrestBegin(arresteeRef, none, crimeFaction, arrestType)
        return
    endif

    RPB_Captor captorRef = Arrest.AwaitCaptorReference(captor)
    RPB_Utility.FlowMark("AwaitCaptorReference done")
    RPB_Utility.Crumb(arrestee, "AwaitCaptorReference done" + RPB_Utility.string_if(!captorRef, " - NO CAPTOR (" + captor + " never registered)", ""))
    RPB_Utility.Crumb(captor, "Captor await for " + arrestee + ": " + captorRef)

    ; Captor Arrest
    Arrest.OnArrestBegin(arresteeRef, captorRef, crimeFaction, arrestType)
endEvent

event OnArrestResist(string eventName, string unusedStr, float arrestResisterIdFlt, Form sender)
    Actor guard = (sender as Actor)
    Faction crimeFaction = form_if ((sender as Faction), (sender as Faction), guard.GetCrimeFaction()) as Faction

    if (guard == none && crimeFaction == none)
        RPB_Utility.LogError("Either there's no Guard, or no Crime Faction! (["+ "Lead Captor: "+ guard + ", Faction: " + crimeFaction +"])", "EventManager::OnArrestResist")
        return
    endif

    ; Not the player
    Actor arrestResister = Game.GetFormEx(arrestResisterIdFlt as int) as Actor
    if (arrestResister.GetFormID() != 0x14)
        RPB_Utility.LogError("Someone other than the player ("+ arrestResister +") has resisted arrest (how?), returning...", "EventManager::OnArrestResist")
        return
    endif

    Arrest.OnArrestResist(arrestResister, guard, crimeFaction)
endEvent

event OnArrestDefeat(string eventName, string unusedStr, float unusedFlt, Form sender)
    Actor attacker = (sender as Actor)
    Faction crimeFaction = attacker.GetCrimeFaction()

    if (!attacker)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestDefeat")
        return
    endif

    Arrest.OnArrestDefeat(attacker)
endEvent

;/
    Event that happens when the player is beginning to elude arrest.
    For Pursuit type arrest eludes, this is the only event that happens, because once the state is changed to Eluded,
    the penalty is given there. However, for Dialogue type arrest eluding, this is the event that is first fired upon making
    contact with a guard, which then gives way to their new dialogue that triggers OnEludingArrestDialogue which is where the penalties are given
    for that arrest elude type.

    string  @eludeType: How the arrest is being eluded, options are: [Dialogue, Pursuit]
        Eluding arrest through Dialogue means that the player has tried to avoid the "Wait, I know you..." guard dialogue
        but they caught up and demanded an explanation.

        Eluding arrest through Pursuit means that the player is trying to run away from the guards after they say lines such as:
        "In the name of the Jarl, I command you to stop!", or "Come quietly or face the Jarl's justice!"

    Form    @sender: Can only be cast to Actor, this is either akSpeaker in case of Dialogue or akPursuer in case of Pursuit.
/;
event OnArrestEludeStart(string eventName, string eludeType, float unusedFlt, Form sender)
    Actor eludedGuard = (sender as Actor)

    if (!eludeType)
        RPB_Utility.LogError("There is no Elude Type, failed check!", "EventManager::OnArrestEludeStart")
        return
    endif

    if (!eludedGuard)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestEludeStart")
        return
    endif

    if (!Arrest.MeetsPursuitEludeRequirements(config.Player) && eludeType == "Pursuit")
        ; Player is not running, therefore this doesn't count as eluding arrest if we're processing Pursuit eludes.
        ; This verification is in place to avoid triggering Eluding when going to jail / speaking to the guards,
        ; because those dialogue lines do trigger this since the script is attached to them.
        return
    endif

    Arrest.OnArrestEludeStart(eludedGuard, eludeType)
endEvent

event OnCombatYield(string eventName, string unusedStr, float unusedFlt, Form sender)
    Actor guard = (sender as Actor)

    if (!guard)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnCombatYield")
        return
    endif

    if (!guard.IsGuard())
        RPB_Utility.LogError("Actor is not a guard, the event will not proceed!", "EventManager::OnCombatYield")
        return
    endif

    ; A real dialogue target only, not __DialogueTargetOf's nearby-player fallback: a yield bark ("All right, you've had
    ; enough") has none, and with the fallback (0.13.1) every yield arrested the player on the spot. Without it, as before,
    ; the guard's own forcegreet follows and the arrest dialogue decides
    Actor yieldedArrestee = guard.GetDialogueTarget()
    if (yieldedArrestee == guard)
        yieldedArrestee = none
    endif

    if (!yieldedArrestee)
        RPB_Utility.Debug("EventManager::OnCombatYield", guard + "'s yield line has no dialogue target: left to his forcegreet")
        Trace("EventManager::OnCombatYield", "Stack Trace: [\n" + \
            "\teventName: " + eventName + "\n" + \
            "\tsender: " + sender + "\n" + \
            "\tguard: " + guard + "\n" + \
            "\tyieldedArrestee: " + yieldedArrestee + "\n" + \
        "\n]")
        return
    endif

    Arrest.OnCombatYield(guard, yieldedArrestee)
endEvent

event OnArrestSceneChanged(string eventName, string sceneName, float unusedFlt, Form sender)
    Actor arrestee = (sender as Actor)

    if (sceneName == "")
        RPB_Utility.LogError("There was no Scene passed in to the request.", "EventManager::OnArrestSceneChanged")
        return
    endif

    if (!arrestee)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestSceneChanged")
        return
    endif

    if (!SceneManager.SceneExists(sceneName))
        RPB_Utility.LogError("The Scene " + sceneName + " does not exist, returning...", "EventManager::OnArrestSceneChanged")
        return
    endif

    if (!SceneManager.IsSceneOfType(sceneName, SceneManager.CATEGORY_ARREST_START))
        RPB_Utility.LogError("The Scene " + sceneName + " is not a valid Scene for the type "+ SceneManager.CATEGORY_ARREST_START +", returning...", "EventManager::OnArrestSceneChanged")
        return
    endif

    Arrest.OnArrestSceneChanged(arrestee, sceneName)
endEvent

event OnArrestGoalChanged(string eventName, string newArrestGoal, float unusedFlt, Form sender)
    Actor arrestee = (sender as Actor)
    
    if (newArrestGoal == "")
        RPB_Utility.LogError("There was no Arrest Goal passed in to the request.", "EventManager::OnArrestGoalChanged")
        return
    endif

    string currentArrestGoal = Arrest.GetArrestGoal(arrestee)

    if (newArrestGoal == currentArrestGoal)
        RPB_Utility.LogError("The requested arrest goal is the same as the current one set, returning...", "EventManager::OnArrestGoalChanged")
        return
    endif

    if (!arrestee)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestGoalChanged")
        return
    endif

    if (!Arrest.IsValidArrestGoal(newArrestGoal))
        RPB_Utility.LogError("The Arrest Goal Type " + newArrestGoal + " is not a valid goal, returning...", "EventManager::OnArrestGoalChanged")
        return
    endif

    Arrest.OnArrestGoalChanged(arrestee, currentArrestGoal, newArrestGoal)
endEvent

event OnPayBounty(string eventName, string categoryPayBounty, float arresteeFormIdFlt, Form sender)
    Actor guard = (sender as Actor)

    if (!guard)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnPayBounty")
        return
    endif

    if (!guard.IsGuard())
        RPB_Utility.LogError("Actor is not a Guard, the event will not proceed!", "EventManager::OnPayBounty")
        return
    endif

    Actor arrestee = self.__DialogueTargetOf(guard, "EventManager::OnPayBounty")

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!arrestee)
        RPB_Utility.LogError("Could not get the dialogue target of " + guard + ", returning...", "EventManager::OnPayBounty")
        Trace("EventManager::OnPayBounty", "Stack Trace: [\n" + \
            "\teventName: " + eventName + "\n" + \
            "\tsender: " + sender + "\n" + \
            "\tguard: " + guard + "\n" + \
            "\tarrestee: " + arrestee + "\n" + \
        "\n]")
        return
    endif

    Faction crimeFaction = guard.GetCrimeFaction()

    Arrest.OnArrestPayBounty(guard, arrestee, crimeFaction, categoryPayBounty)
endEvent

;/
    Handles an Arrest Scene based Event sent from SceneManager.

    string          @asScene: The name of the Scene.
    string          @asSceneEvent: The event that takes place within the Scene.
    RPB_Arrestee    @apArrestee: The arrestee that is taking part in the Scene.
    Actor           @akAuthority: The authority figure of this event (Guard, Captor, Escort, etc...)
    string          @asSceneSecondaryEvent: The secondary event taking place within this scene event.
/;
event OnArrestScene(string asScene, string asSceneEvent, RPB_Arrestee apArrestee, Actor akAuthority, string asSceneSecondaryEvent)
    string sceneType = SceneManager.GetSceneType(asScene)

    if (sceneType == SceneManager.CATEGORY_ARREST_START)
        Actor escort = akAuthority
        
        if (asSceneEvent == SceneManager.EVENT_ARREST_BEGIN)
            ; Each step restarts the stuck-confrontation clock (RPB_ArrestMonitor)
            string step = asSceneSecondaryEvent
            if (step == "" || step == "NULL")
                step = "Begun"
            endif
            Arrest.NoteConfrontationStep(apArrestee.GetActor(), step)
            RetainAI(apArrestee.IsPlayer())

            if (asSceneSecondaryEvent == "Hands Behind Back")
                Debug("EventManager::OnArrestScene", "Arrestee: " + apArrestee + ", Secondary Event: " + asSceneSecondaryEvent)
                ; Back turned to him, read from the arrestee alone: copying his angle was a call into him, and a frozen guard
                ; held the pose back until he answered, after the cuffs were on (2026-10-04)
                RPB_Utility.TurnBackTo(apArrestee.GetActor(), escort)
                ; Sheathed again first: the arrest sheathes at its start (Arrest.OnArrestPreparing), and a weapon drawn again
                ; before the confrontation (a delayed start) took the pose half on (a bow held in the left hand): the pose
                ; is a raw animation event, nothing checks the actor's state
                Actor posing = apArrestee.GetActor()
                if (posing.IsWeaponDrawn())
                    posing.SheatheWeapon()
                    float sheatheStart = Utility.GetCurrentRealTime()
                    while (posing.IsWeaponDrawn() && (Utility.GetCurrentRealTime() - sheatheStart) < 1.5)
                        Utility.Wait(0.1)
                    endWhile
                endif
                apArrestee.PlayAnimation("IdleHandsBehindBack")
            
            elseif (asSceneSecondaryEvent == "Handcuff")
                apArrestee.Restrain()
                Arrest.OnArresteeRestrained(apArrestee)

            elseif (asSceneSecondaryEvent == "Kneel Down")
                apArrestee.PlayAnimation("ZazAPC018")

            elseif (asSceneSecondaryEvent == "Lie Down")
                apArrestee.PlayAnimation("ZazAPC011")
            endif

            apArrestee.OnArrestBegin()

        elseif (asSceneEvent == SceneManager.EVENT_ARREST_END)
            Arrest.StopWatchingConfrontation(apArrestee.GetActor())
            apArrestee.OnArrestEnd()
        endif

    elseif (sceneType == SceneManager.CATEGORY_ESCORT_TO_JAIL)
        RPB_Prison prison = apArrestee.GetPotentialPrison()
        Actor escort = akAuthority
        RPB_Utility.LogInfo("Prison: " + prison + ", Escort: " + escort + ", Arrestee: " + apArrestee.GetActor(), "EventManager::OnArrestScene")

        if (asSceneEvent == SceneManager.EVENT_ESCORT_BEGIN)
            prison.OnEscortPrisonerToJailBegin(apArrestee, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORT_END)
            prison.OnEscortPrisonerToJailEnd(apArrestee, escort)
        endif

        RPB_Utility.LogInfo("Arrestee -> " + asScene + ": " + asSceneEvent, "EventManager::OnArrestScene")

    elseif (sceneType == SceneManager.CATEGORY_ELUDING)
        Actor guard = akAuthority

        if (asSceneEvent == SceneManager.EVENT_ELUDE_BEGIN)
            if (asSceneSecondaryEvent == "Dialogue")
                Arrest.OnArrestEludeTriggered(guard, asSceneSecondaryEvent)
            endif
        endif

    elseif (sceneType == SceneManager.CATEGORY_PAY_BOUNTY)
        Actor escort    = akAuthority
        Actor escortee  = apArrestee.GetActor()

        if (asSceneEvent == SceneManager.EVENT_ARREST_PAYING_BOUNTY)
            if (asSceneSecondaryEvent == "Hands Behind Back")
                RetainAI(apArrestee.IsPlayer())
                apArrestee.OrientRelativeTo(escort, afRotZ = 180)
                apArrestee.PlayAnimation("ZazAPC001") ; Make arrestee put their hands behind the back
            endif

        elseif (asSceneEvent == SceneManager.EVENT_ARREST_PAY_BOUNTY_END)
            if (asSceneSecondaryEvent == "Follow Willingly")
                Arrest.OnArrestPayBountyEnd(escort, escortee, escort.GetCrimeFaction(), false)

            elseif (asSceneSecondaryEvent == "Escort by Force")
                Arrest.OnArrestPayBountyEnd(escort, escortee, escort.GetCrimeFaction(), true)
            endif

            ReleaseAI(apArrestee.IsPlayer()) ; Need to check if this makes sense in this Scene
        endif
    endif
endEvent

; ==========================================================
;                       Prison Events
; ==========================================================

;/
    Handles a Prison Scene based Event sent from SceneManager.

    string          @asScene: The name of the Scene.
    string          @asSceneEvent: The event that takes place within the Scene.
    RPB_Prison      @apPrison: The prison that is responsible for the Scene.
    RPB_Prisoner    @apPrisoner: The prisoner that is taking part in the Scene.
    Actor           @akAuthority: The authority figure of this event (Guard, Captor, Escort, Stripper, etc...)
    string          @asSceneSecondaryEvent: The secondary event taking place within this scene event.
/;
event OnPrisonScene(string asScene, string asSceneEvent, RPB_Prison apPrison, RPB_Prisoner apPrisoner, Actor akAuthority, string asSceneSecondaryEvent)
    string sceneType  = SceneManager.GetSceneType(asScene)

    ; Return right before calling the event handler for the main event if we're processing a secondary event
    bool handlingSecondaryEvent = asSceneSecondaryEvent != "null"

    ; Nothing is done to the prisoner by a dead guard: a phase event already on its way when he died (the handover ends his
    ; Scene, RPB_Arrestee.HandOverInPrison) still stripped and cuffed the prisoner with nobody there. The next guard's own
    ; Scene does it.
    ; Asked without calling into him (PO3 reads it engine side): this runs inside SceneManager's own Scene events, and a
    ; frozen guard's IsDead() held them there, so a stripping never started nor the escort to the cell after it (2026-10-03)
    if ((sceneType == SceneManager.CATEGORY_STRIPPING || sceneType == SceneManager.CATEGORY_RESTRAIN || sceneType == SceneManager.CATEGORY_CLOTHING) && RPB_Utility.IsDeadNoCall(akAuthority))
        Debug("EventManager::OnPrisonScene", asScene + " " + asSceneEvent + " (" + asSceneSecondaryEvent + ") skipped: " + akAuthority + " is dead")
        return
    endif

    ; Each step of the intake restarts the prisoner's clock in the prison's intake watch, as the Scene sends it
    ; (__NoteIntakeStepSent); her escort to the cell ends it
    if (sceneType == SceneManager.CATEGORY_ESCORT_TO_CELL && asSceneEvent == SceneManager.EVENT_ESCORT_BEGIN)
        apPrison.StopWatchingIntake(apPrisoner.GetActor())
    endif
    if (sceneType == SceneManager.CATEGORY_ESCORT_TO_JAIL)
        Actor escort = akAuthority

        if (asSceneEvent == SceneManager.EVENT_ESCORT_BEGIN)
            ; The game started it (RPB_Arrestee.__EscortNeverBegan). Here, not in OnArrestScene: the escort to jail's begin
            ; comes through the prison's bulk event only, and marked there it never was (every escort read as never started
            ; after 10s, 2026-10-11). Test 198 drops it once, as if the game never started the Scene (rare, can't be provoked)
            RPB_Arrestee escortedState = Arrest.Arrestees.AtKey(apPrisoner.GetActor())
            if (escortedState)
                if (JDB.solveInt(".rpb_root.testSkipEscortBegun") == 1)
                    JDB.solveIntSetter(".rpb_root.testSkipEscortBegun", 0, true)
                    Debug("EventManager::OnPrisonScene", "test 198: the escort's begin mark dropped for " + apPrisoner.GetActor())
                else
                    escortedState.SetBool("Escort Begun", true)
                endif
            endif
            RetainAI(apPrisoner.IsPlayer())
            apPrison.OnEscortPrisonerToJailBegin(apPrisoner, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORT_END)
            apPrison.OnEscortPrisonerToJailEnd(apPrisoner, escort)
        endif

    elseif (sceneType == SceneManager.CATEGORY_ESCORT_TO_CELL)
        Actor escort = akAuthority
        RPB_JailCell jailCell = apPrisoner.JailCell

        if (asSceneEvent == SceneManager.EVENT_ESCORT_BEGIN)
            RetainAI(apPrisoner.IsPlayer())
            apPrison.OnEscortPrisonerToCellBegin(apPrisoner, escort)
            ; No Crumb() coverage existed anywhere in this Scene's own phase transitions before round 19 - the
            ; confrontation flow (OnArrestBegin, MoveToPrison, etc.) is densely instrumented, but a stalled off-screen
            ; Escort-to-Cell walk had no trail at all to show how far it actually got. Added specifically to diagnose
            ; test 101's continued off-screen stall with real evidence instead of another guessed fix.
            RPB_Utility.Crumb(apPrisoner.GetActor(), "EscortToCell: Begin")
            ; An NPC's escort watched from its start too, with a long timeout ("Lock Cell" below re-arms it short): Taarie's,
            ; with no door bound, never reached "Lock Cell", so nothing watched it and the player's Scenes queued behind it
            ; waited for good (2026-10-06). The player's is armed from the escort assist (Prisoner, 90s)
            if (!apPrisoner.IsPlayer())
                apPrison.QueueEscortToCellStallCheck(apPrisoner.GetActor(), 120.0)
            endif

        elseif (asSceneEvent == SceneManager.EVENT_ESCORTING)
            if (asSceneSecondaryEvent == "Release from Captor") ; May be refactored into OnArrestScene
                RPB_Captor captor = Arrest.AwaitCaptorReference(escort)
                captor.StopEscorting()
                ; Arrest.OnCaptorEscortPrisonerEnd()
                ; Arrest.OnCaptorEscortedPrisoner()
            endif

            RPB_Utility.Crumb(apPrisoner.GetActor(), "EscortToCell: Escorting" + RPB_Utility.string_if(handlingSecondaryEvent, " (" + asSceneSecondaryEvent + ")", ""))

            if (handlingSecondaryEvent)
                return
            endif

            apPrison.OnEscortingPrisonerToCell(apPrisoner, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORT_END)
            if (asSceneSecondaryEvent == "Lock Cell")
                jailCell.CellDoor.Close()
                jailCell.CellDoor.Lock()
                Debug.SendAnimationEvent(escort, "IdleLockpick") ; Lock animation
                RPB_Utility.Crumb(apPrisoner.GetActor(), "EscortToCell: Lock Cell")

                ; A takeover's intake goes on in the cell (RPB_Prison.EscortToCellForIntake): the escort stops here, him at the
                ; door (after this step the Scene walks him off), and the strip and clothing are played through the bars
                if (apPrisoner.GetBool("Intake In Cell"))
                    SceneManager.EndSceneWithActor(apPrisoner.GetActor(), "the rest of the intake in the cell")
                    apPrison.ContinueIntakeInCell(apPrisoner, escort)
                    return
                endif

                ; Arms the Escort-to-Cell stall failsafe here, not at the Scene's own start: a real debug-level log
                ; confirmed this is the last phase cue that reliably fires in a stalled run - phase 4/5/6 end and this
                ; one (phase 7 start) always arrive, nothing after it ever does, in both the successful and the
                ; stalled case. A short, universal timeout from here is safe regardless of player distance, unlike a
                ; longer one guessed from the Scene's own start (round 6's now-removed distance-based split) - lives
                ; on RPB_Prison, not the escorted RPB_Prisoner itself (see QueueEscortToCellStallCheck's own comment).
                apPrison.QueueEscortToCellStallCheck(apPrisoner.GetActor(), 8.0)

            elseif (asSceneSecondaryEvent == "Unlock Cell")
                Debug.SendAnimationEvent(escort, "IdleLockpick")
                jailCell.CellDoor.Unlock()
                jailCell.CellDoor.Open()

            elseif (asSceneSecondaryEvent == "Hands Behind Back")
                apPrisoner.OrientRelativeTo(escort, afRotZ = 180)
                apPrisoner.PlayAnimation("ZazAPC001")

            elseif (asSceneSecondaryEvent == "Restrain Prisoner")
                apPrison.RestrainPrisoner(apPrisoner)
            endif

            if (handlingSecondaryEvent)
                return
            endif

            ; Stopped at "Lock Cell" for a takeover's intake in the cell: the Scene's own end still comes (stopping a Scene runs
            ; its end), and its silent strip and the imprisonment ran before the strip Scene played (2026-10-12). The intake's
            ; own end does this (RPB_Prison.__FinishIntakeInCell)
            if (apPrisoner.GetBool("Intake In Cell"))
                return
            endif

            ReleaseAI(apPrisoner.IsPlayer())
            apPrison.OnEscortPrisonerToCellEnd(apPrisoner, jailCell, escort)
        endif

    elseif (sceneType == SceneManager.CATEGORY_ESCORT_FROM_CELL)
        Actor escort = akAuthority

        if (asSceneEvent == SceneManager.EVENT_ESCORT_BEGIN)
            RetainAI(apPrisoner.IsPlayer())
            apPrison.OnEscortPrisonerFromCellBegin(apPrisoner, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORTING)
            RetainAI(apPrisoner.IsPlayer())

        elseif (asSceneEvent == SceneManager.EVENT_ESCORT_END)
            ReleaseAI(apPrisoner.IsPlayer())
            apPrison.OnEscortPrisonerFromCellEnd(apPrisoner, escort)
        endif

    elseif (sceneType == SceneManager.CATEGORY_STRIPPING)
        Actor stripper = akAuthority

        if (asSceneEvent == SceneManager.EVENT_STRIP_BEGIN)
            RetainAI(apPrisoner.IsPlayer())

            if (asSceneSecondaryEvent == "Undress to Underwear")
                apPrisoner.Strip(abRemoveUnderwear = false)

            elseif (asSceneSecondaryEvent == "Lie Down")
                apPrisoner.PlayAnimation("IdleLayDownEnter")
            endif

            if (handlingSecondaryEvent)
                return
            endif

            apPrison.OnPrisonerStripBegin(apPrisoner, stripper)

        elseif (asSceneEvent == SceneManager.EVENT_STRIPPING)
            RetainAI(apPrisoner.IsPlayer())
            apPrison.OnPrisonerStripping(apPrisoner, stripper, asSceneSecondaryEvent)

        elseif (asSceneEvent == SceneManager.EVENT_STRIP_END)
            if (asSceneSecondaryEvent == "Restrain Prisoner")
                ; Front cuffs; any other pair comes off first (and no load-order-dependent FormID)
                RPB_Utility.EquipCuffs(apPrisoner.GetActor(), abFront = true)

            elseif (asSceneSecondaryEvent == "Stand Up (Kneel)")
                apPrisoner.PlayAnimation("IdleKneelExit") ; TODO: Not working
                API.Arrest.RestrainArrestee(apPrisoner.GetActor())
            endif

            if (handlingSecondaryEvent)
                return
            endif

            apPrison.OnPrisonerStripEnd(apPrisoner, stripper)

        elseif (asSceneEvent == SceneManager.EVENT_FORCED_STRIP_BEGIN)
            apPrison.OnPrisonerStripBegin(apPrisoner, stripper)

        elseif (asSceneEvent == SceneManager.EVENT_FORCED_STRIPPING)
            apPrison.OnPrisonerStripping(apPrisoner, stripper, asSceneSecondaryEvent)

        elseif (asSceneEvent == SceneManager.EVENT_FORCED_STRIP_END)
            apPrison.OnPrisonerStripEnd(apPrisoner, stripper)
        endif

    elseif (sceneType == SceneManager.CATEGORY_CLOTHING)
        Actor clothingGiver = akAuthority

        if (asSceneEvent == SceneManager.EVENT_CLOTHING_BEGIN)
            apPrison.OnPrisonerClothingBegin(apPrisoner, clothingGiver)

        elseif (asSceneEvent == SceneManager.EVENT_CLOTHING)
            apPrison.OnPrisonerClothingOngoing(apPrisoner, clothingGiver)

        elseif (asSceneEvent == SceneManager.EVENT_CLOTHING_END)
            ; ReleaseAI(apPrisoner.IsPlayer())
            apPrison.OnPrisonerClothingEnd(apPrisoner, clothingGiver)
        endif

    elseif (sceneType == SceneManager.CATEGORY_NO_CLOTHING)

    elseif (sceneType == SceneManager.CATEGORY_RESTRAIN)
        Actor guard = akAuthority

        if (asSceneEvent == SceneManager.EVENT_RESTRAIN_BEGIN)
            if (asSceneSecondaryEvent == "Hands in Front")
                apPrisoner.PlayAnimation("IdleWarmHands")

            elseif (asSceneSecondaryEvent == "Hands Behind Back")
                apPrisoner.OrientRelativeTo(guard)
                apPrisoner.PlayAnimation("IdleHandsBehindBack")
            endif

        elseif (asSceneEvent == SceneManager.EVENT_RESTRAIN_END)
            apPrison.RestrainPrisoner(apPrisoner, true)
        endif
    endif
endEvent

; ==========================================================
;                        Surrender Events
; ==========================================================

event OnSurrenderPreparing(Form akSurrenderer)
    RPB_Utility.FlowMark("Surrender: event delivered")
    Actor surrenderer = akSurrenderer as Actor
    Debug("EventManager::OnSurrenderPreparing", "RPB_Surrender received for " + akSurrenderer)
    if (!surrenderer)
        return
    endif

    ; The captors that will surround the surrenderer
    Actor[] surrendererCaptors = PO3_SKSEFunctions.GetCombatTargets(surrenderer)
    Debug("EventManager::OnSurrenderPreparing", "combat targets of " + surrenderer + ": " + surrendererCaptors + " (in combat " + surrenderer.IsInCombat() + ")")

    Surrender.SnapshotSurrenderTargets(surrenderer, surrendererCaptors) ; each target looked at once, for the checks and the begin
    if (!Surrender.CanActorSurrender(surrenderer, surrendererCaptors))
        return
    endif
    RPB_Utility.FlowMark("Surrender: combat targets read, allowed")

    ; Should only be for player (to avoid forced dialogue during surrender)
    RPB_Arrest.DisableForcedArrestDialogue()

    Surrender.OnSurrenderBegin(surrenderer, surrendererCaptors)
endEvent

event OnSurrenderScene(string asScene, string asSceneEvent, Actor akSurrenderer, Actor akSurrendererCaptor, string asSceneSecondaryEvent, Form[] akParams, Form[] akParams2)
    string sceneType = SceneManager.GetSceneType(asScene)

    if (sceneType == SceneManager.CATEGORY_SURRENDER)
        if (asSceneEvent == SceneManager.EVENT_SURRENDER_BEGIN)
            ; The main captor is bound by the Scene manager at the step itself (RPB_SceneManager.__BindNearestSurrenderCaptor)
            Debug("EventManager::OnSurrenderScene", "akParams: " + akParams + ", akSurrenderer: " + akSurrenderer)

        elseif (asSceneEvent == SceneManager.EVENT_SURRENDER_END)
            ; Not for a surrender already undone: that would lock the player again, with nothing left to release them
            RetainAI(akSurrenderer.GetFormID() == 0x14 && Surrender.IsSurrendering(akSurrenderer))

            ; The forced arrest dialogue stays off from here: turned back on at BeginArrest's end (Arrest.OnArrestEnd), once
            ; the bounty is hidden, or by an undone surrender. Turned on here, an alerted guard force-greeted the player in
            ; the seconds the surrender bounty was still active, and leaving that dialogue counted as resisting.
            Surrender.OnSurrenderEnd(akSurrenderer, akSurrendererCaptor)
        endif
    endif
endEvent

; ==========================================================
;                        Scene Events
; ==========================================================

event OnSceneStart(string eventName, string sceneName, float unusedFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        RPB_Utility.LogError("There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnSceneStart")
        return
    endif

    SceneManager.OnSceneStart(sceneName, (sender as Scene))
endEvent

event OnScenePlayingStart(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        RPB_Utility.LogError("[" + sceneName + ": PHASE_START] There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnScenePlayingStart")
        return
    endif

    if ((scenePhaseFlt as int) < 1 || !scenePhaseFlt)
        RPB_Utility.LogError("[" + sceneName + ": PHASE_START] There's no passed in Scene Phase as a parameter, returning!", "EventManager::OnScenePlayingStart")
        return
    endif
    
    SceneManager.OnScenePlaying(sceneName, SceneManager.PHASE_START, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnScenePlayingEnd(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        RPB_Utility.LogError("[" + sceneName + ": PHASE_END] There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnScenePlayingEnd")
        return
    endif

    if ((scenePhaseFlt as int) < 1 || !scenePhaseFlt)
        RPB_Utility.LogError("[" + sceneName + ": PHASE_END] There's no passed in Scene Phase as a parameter, returning!", "EventManager::OnScenePlayingEnd")
        return
    endif
    
    SceneManager.OnScenePlaying(sceneName, SceneManager.PHASE_END, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnSceneEnd(string eventName, string sceneName, float unusedFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        RPB_Utility.LogError("There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnSceneEnd")
        return
    endif

    SceneManager.OnSceneEnd(sceneName, (sender as Scene))
endEvent

; ====================================================================================================================
;                                                   Topic Dialogue Events
; ====================================================================================================================

;/
    Who @akSpeaker is talking to, for his dialogue fragments' events. GetDialogueTarget() returns none when many guards talk
    at once, and sometimes the speaker himself: a guard who had been fighting next to the player confronted "himself", and
    his go-to-jail line then arrested him instead of the player (2026-10-02). Either way, the player is the fallback when
    nearby: for now these crime lines are only spoken to the player, so with the player nearby the target is the player,
    whoever GetDialogueTarget() names. When NPCs get them too (NPC Bounty Detection), this has to know the real target.
/;
Actor function __DialogueTargetOf(Actor akSpeaker, string asCaller)
    if (RPB_Utility.IsFrozenNPC(akSpeaker))
        return none ; GetDialogueTarget() on him hangs
    endif
    Actor target = akSpeaker.GetDialogueTarget()
    if (target == Config.Player)
        return target
    endif
    ; Anyone else nearby is a wrong read while these lines are only spoken to the player: a killed frozen clone lying next
    ; to the guard (2026-10-05), the bandit he had just fought (2026-10-08: the player's "go to jail" arrested the bandit,
    ; the player was never arrested and got their set-aside bounty back 30s later)
    if (akSpeaker.GetDistance(Config.Player) <= 1000)
        RPB_Utility.LogWarn("The dialogue target of " + akSpeaker + " came back as " + target + ", falling back to the player since they are nearby", asCaller)
        return Config.Player
    endif
    ; The player far off: the target as read, if it's someone who can be spoken to
    if (target && target != akSpeaker && !RPB_Utility.IsFrozenNPC(target) && !RPB_Utility.IsDeadNoCall(target))
        return target
    endif
    return none
endFunction

; A crime line began (RPB_Utility.ProbeSpeaker): a speaker whose earlier line is still stuck is probed
event OnCrimeLineBegan(Form akSpeaker)
    RPB_Utility.__NoteCrimeLine(akSpeaker as Actor)
endEvent

event OnDialogueTopicStart(string topicInfoDialogue, float topicInfoTypeFlt, Form sender, float afStartedAt)
    string eventName = "RPB_TopicInfoStart"
    int topicInfoType = (topicInfoTypeFlt as int)
    Actor akSpeaker = (sender as Actor)

    if (!RPB_Utility.IsTopicInfoFresh(afStartedAt))
        RPB_Utility.LogWarn("Ignored a crime line by " + akSpeaker + " that began before the last load (a replay): '" + topicInfoDialogue + "'", "EventManager::OnDialogueTopicStart")
        return
    endif

    if (!topicInfoType)
        RPB_Utility.LogError("Topic Info Type is none or invalid, returning...", "EventManager::OnDialogueTopicStart")
        return
    endif

    if (!akSpeaker)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnDialogueTopicStart")
        return
    endif

    Actor akSpokenTo = self.__DialogueTargetOf(akSpeaker, "EventManager::OnDialogueTopicStart")

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!akSpokenTo)
        RPB_Utility.LogError("Could not get the dialogue target of " + akSpeaker + ", returning...", "EventManager::OnDialogueTopicStart")
        Trace("EventManager::OnDialogueTopicStart", "Stack Trace: [\n" + \
            "\teventName: " + eventName + "\n" + \
            "\ttopicInfoDialogue: " + topicInfoDialogue + "\n" + \
            "\ttopicInfoType: " + topicInfoType + "\n" + \
            "\tsender: " + sender + "\n" + \
            "\takSpeaker: " + akSpeaker + "\n" + \
            "\takSpokenTo: " + akSpokenTo + "\n" + \
        "\n]")
        return
    endif

    ; Only handle Arrest Events
    if (topicInfoType >= Arrest.TOPIC_TYPE_ARREST_SUSPICIOUS && topicInfoType <= Arrest.TOPIC_TYPE_ARREST_GO_TO_JAIL)
        Arrest.OnArrestDialogue(Arrest.TOPIC_START, topicInfoType, topicInfoDialogue, akSpeaker, akSpokenTo)
    endif
endEvent

event OnDialogueTopicEnd(string topicInfoDialogue, float topicInfoTypeFlt, Form sender, float afStartedAt)
    string eventName    = "RPB_TopicInfoEnd"
    int topicInfoType   = (topicInfoTypeFlt as int)
    Actor akSpeaker     = (sender as Actor)

    if (!RPB_Utility.IsTopicInfoFresh(afStartedAt))
        RPB_Utility.LogWarn("Ignored a crime line by " + akSpeaker + " that began before the last load (a replay): '" + topicInfoDialogue + "'", "EventManager::OnDialogueTopicEnd")
        return
    endif

    if (!topicInfoType)
        RPB_Utility.LogError("Topic Info Type is none or invalid, returning...", "EventManager::OnDialogueTopicEnd")
        return
    endif

    if (!akSpeaker)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnDialogueTopicEnd")
        return
    endif

    Actor akSpokenTo = self.__DialogueTargetOf(akSpeaker, "EventManager::OnDialogueTopicEnd")

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!akSpokenTo)
        RPB_Utility.LogError("Could not get the dialogue target of " + akSpeaker + ", returning...", "EventManager::OnDialogueTopicEnd")
        TraceParams(eventName + "," + topicInfoDialogue +","+topicInfoType, "eventName, topicInfoDialogue, topicInfoType")
        Trace("EventManager::OnDialogueTopicEnd", "Stack Trace: [\n" + \
            "\teventName: " + eventName + "\n" + \
            "\ttopicInfoDialogue: " + topicInfoDialogue + "\n" + \
            "\ttopicInfoType: " + topicInfoType + "\n" + \
            "\tsender: " + sender + "\n" + \
            "\takSpeaker: " + akSpeaker + "\n" + \
            "\takSpokenTo: " + akSpokenTo + "\n" + \
        "\n]")
        return
    endif

    ; Only handle Arrest Events
    if (topicInfoType >= Arrest.TOPIC_TYPE_ARREST_SUSPICIOUS && topicInfoType <= Arrest.TOPIC_TYPE_ARREST_GO_TO_JAIL)
        Arrest.OnArrestDialogue(Arrest.TOPIC_END, topicInfoType, topicInfoDialogue, akSpeaker, akSpokenTo)
    endif
endEvent

; ==========================================================
;                        Package Events
; ==========================================================

; event OnPackageEnd(string eventName, string packageName, float unusedFlt, Form sender)
;     ObjectReference[] data = new ObjectReference[10]

;     data[0] = Guard_EscortLocation.GetReference()
;     data[1] = Escort.GetActorReference()

;     ; AIPackageManager.OnPackageEnd(packageName, data, (sender as Package))
; endEvent


event OnPackageStart(string eventName, string packageName, float unusedFlt, Form sender)
    AIPackageManager_OnPackageStart(packageName, none, sender)
    ; AIPackageManager.OnPackageStart(packageName, data, (sender as Package))
endEvent


; AIPackageManager.psc
event AIPackageManager_OnPackageStart(string packageName, ObjectReference[] data, Form sender)
    ; if (packageName == "RPB_DGForcegreetPackage")
    ;     Actor speaker = (sender as Actor)
    ;     Arrest.ApplyArrestEludedPenalty(speaker.GetCrimeFaction())

    ; elseif (packageName == "RPB_LockCellDoor")
    ;     OrientRelative(data[1], data[0], afRotZ = 180)
    ; endif
endEvent

event AIPackageManager_OnPackageEnd(string packageName, ObjectReference[] data, Package sender)
    if (packageName == "RPB_LockCellDoor")
        data[0].SetLockLevel(100)
        data[0].Lock()
    endif
endEvent

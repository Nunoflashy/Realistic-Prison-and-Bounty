scriptname RealisticPrisonAndBounty_Arrest extends Quest

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config
import PO3_SKSEFunctions

string property STATE_RESISTED      = "Resisted" autoreadonly
string property STATE_ELUDING       = "Eluding" autoreadonly
string property STATE_UNCONSCIOUS   = "Unconscious" autoreadonly
string property STATE_ARRESTED      = "Arrested" autoreadonly
string property STATE_SURRENDER     = "Surrender" autoreadonly

string property ARREST_TYPE_TELEPORT_TO_JAIL    = "TeleportToJail" autoreadonly
string property ARREST_TYPE_TELEPORT_TO_CELL    = "TeleportToCell" autoreadonly
string property ARREST_TYPE_ESCORT_TO_JAIL      = "EscortToJail" autoreadonly
string property ARREST_TYPE_ESCORT_TO_CELL      = "EscortToCell" autoreadonly


RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Jail property jail
    RealisticPrisonAndBounty_Jail function get()
        return config.jail
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property arrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return config.arrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_ActorVars property actorVars
    RealisticPrisonAndBounty_ActorVars function get()
        return config.actorVars
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property miscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return config.miscVars
    endFunction
endProperty

RealisticPrisonAndBounty_SceneManager property sceneManager
    RealisticPrisonAndBounty_SceneManager function get()
        return config.sceneManager
    endFunction
endProperty

GlobalVariable property RPB_AllowArrestForcegreet
    GlobalVariable function get()
        return GetFormFromMod(0x130D7) as GlobalVariable
    endFunction
endProperty

ReferenceAlias property CaptorRef auto

function RegisterEvents()

endFunction

function RegisterHotkeys()
    RegisterForKey(0x58) ; F12
    RegisterForKey(0x57) ; F11
    RegisterForKey(0x44) ; F10
    RegisterForKey(0x42) ; F8
    RegisterForKey(0x41) ; F7
    RegisterForKey(0x40) ; F6
endFunction

;/
    Registers a delayed event through a state's OnUpdate()
    string  @stateName: The name of the state that represents the event name
    float   @delaySeconds: The time waited in seconds before the event is fired
/;
function RegisterForDelayedEvent(string stateName, float delaySeconds)
    RegisterForSingleUpdate(delaySeconds)
    GotoState(stateName)
endFunction

;/
    Registers a delayed event through a state's OnUpdateGameTime()
    string  @stateName: The name of the state that represents the event name
    float   @delayGameTime: The time waited in game-time before the event is fired (1 = 1 Day | 1/24 = 1h)
/;
function RegisterForDelayedEventGameTime(string stateName, float delayGameTime)
    RegisterForSingleUpdateGameTime(delayGameTime)
    GotoState(stateName)
endFunction

function AddBountyGainedWhileJailed(Faction akArrestFaction)
    arrestVars.ModInt("Jail::Bounty Non-Violent", akArrestFaction.GetCrimeGoldNonViolent())
    arrestVars.ModInt("Jail::Bounty Violent", akArrestFaction.GetCrimeGoldViolent())
    ClearBounty(akArrestFaction)
endFunction

function SetEludedGuard(Actor akEludedGuard, string asEludeType)
    arrestVars.SetActor("Arrest::Eluded Captor", akEludedGuard)
    arrestVars.SetString("Arrest::Elude Type", asEludeType)
endFunction

function TriggerForcegreetEluding(Actor akEludedGuard)
    self.SetEludedGuard(akEludedGuard, "Dialogue")
    sceneManager.StartEludingArrest(akEludedGuard, config.Player)
endFunction

function TriggerPursuitEluding(Actor akEludedGuard)
    self.SetEludedGuard(akEludedGuard, "Pursuit")
    RegisterForDelayedEvent("Eluding", config.ArrestEludeWarningTime) ; Register for a delayed event on Eluding::OnUpdate()
endFunction

event OnInit()
    RegisterHotkeys()
endEvent

event OnPlayerLoadGame()
    RegisterHotkeys()
endEvent

event OnKeyDown(int keyCode)
    if (keyCode == 0x58) ; F12
        string currentHold = config.GetCurrentPlayerHoldLocation()
        arrestVars.SetForm("Arrest::Arrest Faction", config.GetCrimeFaction(currentHold))
        Faction crimeFaction = arrestVars.GetForm("Arrest::Arrest Faction") as Faction
        Actor nearbyGuard = GetNearestActor(config.Player, 7000)
        nearbyGuard.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_TELEPORT_TO_CELL)
    
    elseif (keyCode == 0x44) ; F10
        ; Actor nearbyGuard = GetNearestActor(config.Player, 7000)
        ; nearbyGuard.GetCrimeFaction().SendPlayerToJail(true, true)
        ; Actor nearbyGuard = GetNearestGuard(config.Player, 3500, none)
        ; Debug(self, "Arrest::OnKeyDown", "Guard: " + nearbyGuard)
        Quest WIRemoveItem01 = Game.GetFormEx(0x2C6AB) as Quest

        WIRemoveItem01.Start()

        Actor solitudeGuard = Game.GetFormEx(0xF684E) as Actor
        config.Player.PlaceActorAtMe(config.Player.GetBaseObject() as ActorBase, 1, none)
        Debug(self, "Arrest::OnKeyDown", "F10 Pressed")
        ; sceneManager.StartEscortFromCell(arrestVars.Captor, arrestVars.Arrestee, arrestVars.CellDoor, arrestVars.PrisonerItemsContainer)
        ; Debug(self, "Arrest::OnKeyDown", "F10 Pressed - SceneManager")

        ; self.TriggerSurrender()
    elseif (keyCode == 0x42)
        Debug(self, "Arrest::OnKeyDown", "F8 Pressed")
        ; Actor solitudeGuard = Game.GetFormEx(0xF684E) as Actor
        ; Actor theGuard = config.Player.PlaceActorAtMe(solitudeGuard.GetBaseObject() as ActorBase, 1, none)
        Actor nearbyGuard = GetNearestGuard(config.Player, 3500, none)
        ObjectReference arrestee = Game.GetCurrentCrosshairRef()
        nearbyGuard.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_ESCORT_TO_JAIL, arrestee.GetFormID())
    endif
endEvent

function PlaySurrenderAnimation(Actor akActorSurrendering)
    Debug.SendAnimationEvent(akActorSurrendering, "IdleSurrender")
endFunction

;/
    Resets the arrest resisted flag for all the holds.

    This flag is used to determine whether an actor should be punished for resisting arrest,
    and is set to true upon resisting, and for the remainder of that time, no further resists will
    incur another penalty, unless enough time has passed to where the flag gets set to false here
    in this function, at which point the resist will be punished again.
/;
function ResetResistedFlag()
    int i = 0
    while (i < miscVars.GetLengthOf("Holds"))
        string hold = miscVars.GetStringFromArray("Holds", i) ; To be tested
        string arrestResistKey = "Arrest::"+ hold +"::Arrest Resisted"

        if (arrestVars.Exists(arrestResistKey))
            arrestVars.Remove(arrestResistKey)
            Info(self, "Arrest::ResetResistedFlag", "The resist arrest flag for " + hold +" has been reset.")
        endif
        i += 1
    endWhile
endFunction

function ResetEludedFlag()
    Debug(self, "Arrest::ResetEludedFlag", "This is called")
    int i = 0
    while (i < miscVars.GetLengthOf("Holds"))
        string hold = miscVars.GetStringFromArray("Holds", i) ; To be tested
        string arrestEludeKey = "Arrest::"+ hold +"::Arrest Eluded"

        if (arrestVars.Exists(arrestEludeKey))
            arrestVars.Remove(arrestEludeKey)
            Info(self, "Arrest::ResetEludedFlag", "The eluding arrest flag for " + hold +" has been reset.")
        endif
        i += 1
    endWhile
endFunction

;/
    Sets the arrest resisted flag to true.
    While the flag is active, further arrests of this faction will no longer incur a penalty upon resisting again. 
    This is to prevent multiple guards trying to arrest the player
    and eventually end up with multiple penalties from each guard for something that should only be punished once.
    After some time, this flag will be set to false and the next arrest will be punished once again.
    For more info, see the Resisted state
/;
function SetResistedFlag(Faction akFaction)
    arrestVars.SetBool("Arrest::"+ akFaction.GetName() +"::Arrest Resisted", true) ; Set arrest resisted flag
    RegisterForDelayedEventGameTime("Resisted", 1.0)
endFunction

function SetEludedFlag(Faction akFaction)
    arrestVars.SetBool("Arrest::"+ akFaction.GetName() +"::Arrest Eluded", true) ; Set arrest eluded flag
    RegisterForDelayedEventGameTime("Eluding", 1.0)
endFunction

bool function HasResistedArrestRecently(Faction akArrestFaction)
    return arrestVars.GetBool("Arrest::" + akArrestFaction.GetName() + "::Arrest Resisted")
endFunction

bool function HasEludedArrestRecently(Faction akArrestFaction)
    return arrestVars.GetBool("Arrest::" + akArrestFaction.GetName() + "::Arrest Eluded")
endFunction

;/
    Sets the passed in actor as arrested for this faction to the system.
/;
function SetAsArrested(Actor akArrestee, Faction akFaction)
    if (akArrestee == config.Player)
        arrestVars.SetBool("Arrest::Arrested", true)
        arrestVars.SetFloat("Arrest::Time of Arrest", Utility.GetCurrentGameTime())
        config.NotifyArrest("You have been arrested in " + akFaction.GetName())
        Info(self, "Arrest::SetAsArrested", akArrestee.GetBaseObject().GetName() + " has been arrested in " + akFaction.GetName() + " at " + Utility.GetCurrentGameTime())
    endif
endFunction

function AllowArrestForcegreets(bool allow = true)
    if (allow)
        ; Reallow Forcegreets (used in AI package RPB_DGForcegreet for Arrest eludes)
        RPB_AllowArrestForcegreet.SetValueInt(1)
    else
        ; Disallow Forcegreets (used in AI package RPB_DGForcegreet for Arrest eludes)
        RPB_AllowArrestForcegreet.SetValueInt(0)
    endif
endFunction

function ReleaseDetainee(Actor akCaptor, Actor akDetainee)
    ; Revert Bounty
    Faction crimeFaction = akCaptor.GetCrimeFaction()
    crimeFaction.SetCrimeGold(arrestVars.BountyNonViolent)
    crimeFaction.SetCrimeGoldViolent(arrestVars.BountyViolent)

    arrestVars.Remove("Arrest::Captured")
    arrestVars.Remove("Arrest::Arrest Faction")
    arrestVars.Remove("Arrest::Hold")
    arrestVars.Remove("Arrest::Arrestee")
    arrestVars.Remove("Arrest::Arrest Type")
    arrestVars.Remove("Arrest::Arrested")
    arrestVars.Remove("Arrest::Time of Arrest")

    self.AllowArrestForcegreets()
    Game.SetPlayerAIDriven(false)
endFunction

function ChangeArrestEscort(Actor akNewEscort, Actor akDetainee)
    ; A new guard was found, escort Detainee to jail
    arrestVars.SetReference("Arrest::Arresting Guard", akNewEscort) ; Change the captor for further scenes and to lead to the cell
    BindAliasTo(CaptorRef, akNewEscort)
    sceneManager.StartEscortToJail(akNewEscort, arrestVars.Arrestee, arrestVars.PrisonerItemsContainer)
endFunction

function ApplyArrestEludedPenalty(Faction akArrestFaction)
    if (self.HasEludedArrestRecently(akArrestFaction))
        Info(self, "Arrest::ApplyArrestEludedPenalty", "You have already eluded arrest recently, no bounty will be added as it most likely is the same arrest.")
        return
    endif

    string hold = akArrestFaction.GetName()

    int eludeBountyFlat = config.GetArrestAdditionalBountyEludingFlat(akArrestFaction.GetName())
    float eludeBountyPercent = GetPercentAsDecimal(config.GetArrestAdditionalBountyEludingFromCurrentBounty(akArrestFaction.GetName()))
    int totalEludeBounty = int_if (eludeBountyPercent > 0, round(akArrestFaction.GetCrimeGold() * eludeBountyPercent)) + eludeBountyFlat

    if (totalEludeBounty > 0)
        akArrestFaction.ModCrimeGold(totalEludeBounty)
        config.NotifyArrest("You have gained " + totalEludeBounty + " Bounty in " + hold + " for eluding arrest!")
    endif

    arrestVars.SetBool("Arrest::Eluded", true)
    self.SetEludedFlag(akArrestFaction)
endFunction

bool function MeetsPursuitEludeRequirements(Actor akEluder)
    return akEluder.IsRunning() || akEluder.IsSprinting()
endFunction

function ApplyArrestResistedPenalty(Faction akArrestFaction)
    string hold = akArrestFaction.GetName()

    int resistBountyFlat                    = config.GetArrestAdditionalBountyResistingFlat(hold)
    float resistBountyFromCurrentBounty     = GetPercentAsDecimal(config.GetArrestAdditionalBountyResistingFromCurrentBounty(hold))
    int resistArrestPenalty                 = int_if (resistBountyFromCurrentBounty > 0, floor(akArrestFaction.GetCrimeGold() * resistBountyFromCurrentBounty)) + resistBountyFlat

    if (resistArrestPenalty > 0)
        akArrestFaction.ModCrimeGold(resistArrestPenalty)
        config.NotifyArrest("You have gained " + resistArrestPenalty + " Bounty in " + hold +" for resisting arrest!")
    endif

    Actor arrestResister = config.Player ; Temporary

    actorVars.IncrementStat("Arrests Resisted", akArrestFaction, arrestResister)
    self.SetResistedFlag(akArrestFaction)
endFunction

;/
    Refactor idea:
    Have an ArresteeRef or SuspectRef script that is attached to each character arrested, storing their arrest state and then:
    Arrestee.ApplyDefeatedPenalty()
    Since the state is known, the hold, bounty and everything will be handled internally by the function without any need for params
/;
function ApplyArrestDefeatedPenalty(Faction akArrestFaction)
    string hold = akArrestFaction.GetName()

    ; Setup Defeated penalties
    ; Helper.GetArrestAdditionalBountyOnDefeat(hold)
    ; arrestVars.SetInt("Arrest::Bounty for Defeat", Helper.GetArrestAdditionalBountyOnDefeat(hold))
    arrestVars.SetInt("Arrest::Additional Bounty when Defeated", config.GetArrestAdditionalBountyDefeatedFlat(hold))
    arrestVars.SetFloat("Arrest::Additional Bounty when Defeated from Current Bounty", GetPercentAsDecimal(config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold)))
    arrestVars.SetInt("Arrest::Bounty for Defeat", int_if (arrestVars.DefeatedAdditionalBountyPercentage > 0, round(akArrestFaction.GetCrimeGold() * arrestVars.DefeatedAdditionalBountyPercentage)) + arrestVars.DefeatedAdditionalBounty)
    arrestVars.SetBool("Arrest::Defeated", true)

    ; Bounty is applied later at the Arrest stage.
endFunction

function SetArrestParams(string asArrestType, Actor akArrestee, Actor akCaptor, Faction akCrimeFaction = none)
    Faction crimeFaction = akCrimeFaction

    if (akCaptor)
        crimeFaction = akCaptor.GetCrimeFaction()
        arrestVars.SetForm("Arrest::Arresting Guard", akCaptor)
        CaptorRef.ForceRefTo(akCaptor)
        Debug(self, "Arrest::SetArrestParams", "Arrest is being done through a captor ("+ akCaptor +")")
    endif

    if (!crimeFaction)
        Error(self, "Arrest::SetArrestParams", "Both the captor and faction are none, cannot proceed with the arrest! (returning...)")
        return
    endif

    arrestVars.SetBool("Arrest::Captured", true)
    arrestVars.SetForm("Arrest::Arrest Faction", crimeFaction)
    arrestVars.SetString("Arrest::Hold", crimeFaction.GetName())
    arrestVars.SetForm("Arrest::Arrestee", akArrestee)
    arrestVars.SetString("Arrest::Arrest Type", ARREST_TYPE_ESCORT_TO_JAIL)

    Debug(self, "Arrest::SetArrestParams", "[\n" + \ 
        "\tCaptured: "+ arrestVars.GetBool("Arrest::Captured") +" \n" + \
        "\tArrest Faction: "+ arrestVars.GetForm("Arrest::Arrest Faction") +"\n" + \
        "\tHold: "+ arrestVars.GetString("Arrest::Hold") +"\n" + \
        "\tArrestee: "+ arrestVars.GetForm("Arrest::Arrestee") +"\n" + \
        "\tArrest Type: "+ arrestVars.GetString("Arrest::Arrest Type") +"\n" + \
    "]")

endFunction

event OnArrestBegin(Actor akArrestee, Actor akCaptor, Faction akCrimeFaction, string asArrestType)
    if (!self.ValidateArrestType(asArrestType))
        Error(self, "Arrest::OnArrestBegin", "Arrest Type is invalid, got: " + asArrestType + ". (valid options: "+ self.GetValidArrestTypes() +") ")
        return
    endif

    if (arrestVars.IsArrested)
        config.NotifyArrest("You are already under arrest")
        Error(self, "Arrest::OnArrestBegin", akArrestee.GetBaseObject().GetName() + " has already been arrested, cannot arrest for "+ akCrimeFaction.GetName() +", aborting!")

        ; Add the bounty gained while in jail and clear the active faction bounty
        self.AddBountyGainedWhileJailed(akCrimeFaction)
        return
    endif

    if (!self.HasLatentBounty() && !self.HasActiveBounty(akCrimeFaction) && akArrestee == config.Player)
        config.NotifyArrest("You can't be arrested in " + akCrimeFaction.GetName() + " since you do not have a bounty in the hold")
        Error(self, "Arrest::OnArrestBegin", akArrestee.GetBaseObject().GetName() + " has no bounty, cannot arrest for "+ akCrimeFaction.GetName() +", aborting!")
        return
    endif

    self.SetArrestParams( \
        asArrestType    = ARREST_TYPE_ESCORT_TO_JAIL, \
        akArrestee      = akArrestee, \
        akCaptor        = akCaptor, \
        akCrimeFaction  = akCrimeFaction \
    )

    if (akArrestee == config.Player)
        self.AllowArrestForcegreets(false)
    endif

    self.BeginArrest()
endEvent

event OnArrestDefeat(Actor akAttacker)
    self.ApplyArrestDefeatedPenalty(akAttacker.GetCrimeFaction())

    Form handcuffs = Game.GetFormEx(0xA033D9E)
    config.Player.StopCombatAlarm()
    config.Player.EquipItem(handcuffs, true, true)
    ; GotoState(STATE_UNCONSCIOUS)
endEvent

event OnArrestResist(Actor akArrestResister, Actor akGuard, Faction akCrimeFaction)
    bool captured = arrestVars.GetBool("Arrest::Captured")
    if (captured)
        Warn(self, "Arrest::OnArrestResist", akArrestResister.GetBaseObject().GetName() + " was arrested, no arrest was resisted (maybe multiple guards talked at once and triggered resist arrest?) [BUG]")
        return
    endif
    ; bool isAwaitingArrest = arrestVars.GetBool("Arrest::Awaiting Arrest")
    ; if (isAwaitingArrest)
    ;     Info(self, "Arrest::OnArrestResist", "The suspect is currently awaiting arrest, this should not count as resisting, returning...")
    ;     return
    ; endif

    akGuard.SetPlayerResistingArrest() ; Needed to make the guards attack the player, otherwise they will loop arrest dialogue

    if (self.HasResistedArrestRecently(akCrimeFaction))
        Info(self, "Arrest::OnArrestResist", "You have already resisted arrest recently, no bounty will be added as it most likely is the same arrest.")
        return
    endif

    self.ApplyArrestResistedPenalty(akCrimeFaction)
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
/;
event OnArrestEludeStart(Actor akEludedGuard, string asEludeType)
    Debug(self, "Arrest::OnArrestEludeStart", "This is called - Elude Type: " + asEludeType)

    if (asEludeType == "Dialogue")
        self.TriggerForcegreetEluding(akEludedGuard)
        return

    elseif (asEludeType == "Pursuit")
        self.TriggerPursuitEluding(akEludedGuard)
        return
    endif

    Error(self, "Arrest::OnArrestEludeStart", "The passed in Elude Type is invalid, the event failed!")
endEvent

event OnArrestEludeTriggered(Actor akEludedGuard, string asEludeType)
    self.ApplyArrestEludedPenalty(akEludedGuard.GetCrimeFaction()) ; Set as eluding arrest from this guard

    if (asEludeType == "Pursuit")
        akEludedGuard.StartCombat(config.Player)
    
    elseif (asEludeType == "Dialogue")
        sceneManager.ReleaseAlias("Guard") ; Unbind alias running the AI package from eluded guard
        sceneManager.ReleaseAlias("Eluder") ; Unbind alias from the player
    endif
endEvent

event OnArrestCaptorDeath(Actor akCaptor, Actor akCaptorKiller)
    Actor anotherGuard = GetNearestGuard(arrestVars.Arrestee, 3500, exclude = akCaptor)

    if (!anotherGuard)
        config.NotifyArrest("Your captor has died, you may now try to break free")
        self.ReleaseDetainee(akCaptor, arrestVars.Arrestee)
        return
    endif

    config.NotifyArrest("Your captor has died, you are being escorted by another guard")
    self.ChangeArrestEscort(anotherGuard, arrestVars.Arrestee)

    if (akCaptorKiller == none) ; to be changed to Player later, but this is easier to test
        int bounty = 10000
        config.NotifyArrest("You have gained " + bounty + " Bounty in " + arrestVars.Hold + " for killing your captor!")
    endif

    Debug(self, "Arrest::OnArrestCaptorDeath", "[\n"+ \ 
        "\tOld Captor: "+ akCaptor +"\n" + \
        "\tNew Captor: "+ anotherGuard +"\n" \
    +"]")
endEvent

; event OnArrestWait(string eventName, string unusedStr, float unusedFlt, Form sender)
;     Actor akSpeaker = sender as Actor
;     arrestVars.SetActor("Arrest::Waiting Captor", akSpeaker)
;     arrestVars.SetBool("Arrest::Awaiting Arrest", true)
;     Debug(self, "Arrest::OnArrestWaitStop", "Set the Awaiting Arrest flag to true")
;     ; GotoState("WaitingOnArrest")
; endEvent

; event OnArrestWaitStop(string eventName, string unusedStr, float unusedFlt, Form sender)
;     arrestVars.SetBool("Arrest::Awaiting Arrest", false)
;     Debug(self, "Arrest::OnArrestWaitStop", "Set the Awaiting Arrest flag to false")
; endEvent

function BeginArrest()
    string hold             = arrestVars.Hold
    string arrestType       = arrestVars.ArrestType
    Faction arrestFaction   = arrestVars.ArrestFaction
    Actor arrestee          = arrestVars.Arrestee
    Actor captor            = arrestVars.Captor ; May be undefined if the arrest is not done through a captor

    self.SetBounty()

    ; Idea for refactor: bool assignedJailCellSuccessfully = jail.AssignJailCell(SuspectRef) where SuspectRef is a script that handles anything related to the arrest Suspect
    ; OR: SuspectRef.AssignToJailCell()
    bool assignedJailCellSuccessfully = jail.AssignJailCell(arrestee) ; Not guaranteed to go to jail, but we set it up here either way
    
    if (!assignedJailCellSuccessfully)
        self.ResetArrest("Could not assign a jail cell to " + arrestee + ". (Aborting arrest...)")
        return
    endif

    arrestee.StopCombat()
    arrestee.StopCombatAlarm()

    ; Will most likely be used when the arrestee has no chance to pay their bounty, and therefore will get immediately thrown into the cell
    if (arrestType == ARREST_TYPE_TELEPORT_TO_CELL)
        jail.StartTeleportToCell()
        ; Suspect.TeleportToCell()

    ; Could be used when the arrestee still has a chance to pay their bounty, and not go to the cell immediately
    elseif (arrestType == ARREST_TYPE_TELEPORT_TO_JAIL) ; Not implemented yet (Idea: Arrestee will be teleported to some location in jail and then either escorted or teleported to the cell)
        jail.TeleportToJail()
        ; Suspect.TeleportToJail()
    
    ; Will most likely be used when the arrestee has no chance to pay their bounty, and therefore will get immediately escorted into the cell
    elseif (arrestType == ARREST_TYPE_ESCORT_TO_CELL) ; Not implemented yet (Idea: Arrestee will be escorted directly to the cell)
        jail.EscortToCell()
        ; Suspect.EscortToCell()
        ; Captor.EscortToCell(Suspect)

    elseif (arrestType == ARREST_TYPE_ESCORT_TO_JAIL) ; Not implemented yet (Idea: Arrestee will be escorted to the jail, and then processed before being escorted into the cell)
        if (arrestee.GetDistance(captor))
            ; Later have several ArrestStart scenes happen depending on the distance and maybe have a more hostile version for the arrests eluded / resisted etc.
        endif
        sceneManager.StartArrestStart02(captor, arrestee)
        ; jail.EscortToJail()
    endif

    ; SendModEvent("RPB_JailBegin")
    
    self.UpdateArrestStats()
    self.SetAsArrested(arrestee, arrestFaction)
    ; self.RestrainArrestee(arrestee)

    ; ================== TESTING ==================
    ; miscVars.ListContainer("Locations")
    ; miscVars.ListContainer("Factions")
    ; miscVars.ListContainer("Jail::Cells")
    ; miscVars.ListContainer("Holds")
    ; miscVars.List()
    ; miscVars.ListContainer("Jail::Cells")
    ; Debug(self, "Arrest::ArrestBegin", "\n" + \
    ;     "LengthOf(Jail::Cells): " + miscVars.GetLengthOf("Jail::Cells") + "\n" + \
    ;     "LengthOf(Locations): " + miscVars.GetLengthOf("Locations") + "\n" + \
    ;     "LengthOf(Holds): " + miscVars.GetLengthOf("Holds") + "\n" \
    ; )
    ; miscVars.List()
    ; =============================================
endFunction

event OnArrestStart(Actor akCaptor, Actor akArrestee)
    jail.EscortToJail()
endEvent

event OnArresting(Actor akCaptor, Actor akArrestee)
    self.RestrainArrestee(akArrestee)
endEvent

function SetAsDefeated(Faction akCrimeFaction)
    if (!self.HasResistedArrestRecently(akCrimeFaction))
        ; Do not punish if the player hasn't resisted arrest upon being defeated
        return
    endif

    string hold = akCrimeFaction.GetName()

    int defeatBountyFlat                = config.GetArrestAdditionalBountyDefeatedFlat(hold)
    float defeatBountyFromCurrentBounty = config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold)
    float defeatBountyPercentModifier   = GetPercentAsDecimal(defeatBountyFromCurrentBounty)
    int defeatArrestPenalty             = floor(akCrimeFaction.GetCrimeGold() * defeatBountyPercentModifier) + defeatBountyFlat

    Debug(self, "Arrest::SetAsDefeated", "\n" +  \
        "defeatBountyFlat: " + defeatBountyFlat + "\n" + \
        "defeatBountyFromCurrentBounty: " + defeatBountyFromCurrentBounty + "\n" + \
        "defeatBountyPercentModifier: " + defeatBountyPercentModifier  + "\n" + \
        "defeatArrestPenalty: " + defeatArrestPenalty  + "\n" \
    )

    if (defeatArrestPenalty > 0)
        arrestVars.ModInt("Arrest::Bounty Non-Violent", defeatArrestPenalty)
        config.NotifyArrest("You have gained " + defeatArrestPenalty + " Bounty in " + hold +" for being defeated")
    endif
endFunction

function TriggerSurrender()
    string currentHold = config.GetCurrentPlayerHoldLocation()
    Faction currentHoldFaction = config.GetFaction(currentHold)
    Actor arresteeRef = config.Player

    if (arrestVars.IsArrested)
        config.NotifyArrest("You are already arrested")
        Error(self, "Arrest::OnArrestBegin", arresteeRef.GetBaseObject().GetName() + " is already arrested, cannot arrest for "+ currentHoldFaction.GetName() +", aborting!")
        return
    endif

    self.PlaySurrenderAnimation(arrestVars.Arrestee)

    self.SetAsDefeated(currentHoldFaction)
    currentHoldFaction.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_TELEPORT_TO_CELL)

    ; GotoState(STATE_SURRENDER)
    ; RegisterForSingleUpdate(4.0)

    ; currentHoldFaction.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_TELEPORT_TO_CELL)
endFunction

bool function HasLatentBounty()
    return arrestVars.Bounty > 0
endFunction

bool function HasActiveBounty(Faction akCrimeFaction)
    return akCrimeFaction.GetCrimeGold() > 0
endFunction

function ResetArrest(string reason = "")
    ; Clear all arrest related vars
    arrestVars.Clear()
    Info(self, "ResetArrest", reason, reason != "")
endFunction

function SetBounty()
    Faction arrestFaction = arrestVars.ArrestFaction

    if (self.HasLatentBounty())
        ; Add the "active bounty" if there's any, to the latent bounty
        arrestVars.ModInt("Arrest::Bounty Non-Violent", arrestFaction.GetCrimeGoldNonViolent())
        arrestVars.ModInt("Arrest::Bounty Violent", arrestFaction.GetCrimeGoldViolent())
    else
        ; Set the bounties to be latent
        arrestVars.SetFloat("Arrest::Bounty Non-Violent", arrestFaction.GetCrimeGoldNonViolent())
        arrestVars.SetFloat("Arrest::Bounty Violent", arrestFaction.GetCrimeGoldViolent())
    endif

    if (arrestVars.WasDefeated && arrestVars.DefeatedBounty > 0)
        arrestVars.ModInt("Arrest::Bounty Non-Violent", arrestVars.DefeatedBounty)
        config.NotifyArrest("You were defeated, " + arrestVars.DefeatedBounty + " Bounty gained in " + arrestVars.Hold)
    endif

    ; if (arrestVars.GetBool("Jail::Escaped"))
    ;     int currentBounty = arrestVars.BountyNonViolent - 1000 ; Subtract 1000 which is the bounty given after escape success
    ;     int currentBountyViolent = arrestVars.BountyViolent
    ;     int escapeBountyNonViolent = arrestVars.GetInt("Escape::Bounty Non-Violent")
    ;     int escapeBountyViolent = arrestVars.GetInt("Escape::Bounty Violent")
    ;     int totalBounty = (currentBounty + escapeBountyNonViolent) + (currentBountyViolent + escapeBountyViolent)

    ;     arrestVars.SetFloat("Arrest::Bounty Non-Violent", currentBounty + escapeBountyNonViolent)
    ;     arrestVars.SetFloat("Arrest::Bounty Violent", currentBountyViolent + escapeBountyViolent)

    ;     Debug(none, "SetBounty", "currentBounty: " + currentBounty + ", currentBountyV: " + currentBountyViolent + ", escapeBountyNv: " + escapeBountyNonViolent + ", escapeBountyV: " + escapeBountyViolent + ", totalBounty: " + totalBounty)
    ; endif

    if (arrestVars.HasOverride("Arrest::Bounty Non-Violent"))
        Debug(self, "SetBounty", "\n" + \
            "(Overridden) Arrest::Bounty Non-Violent: " + arrestVars.BountyNonViolent + "\n" \
        )
    endif

    if (arrestVars.HasOverride("Arrest::Bounty Non-Violent"))
        Debug(self, "SetBounty", "\n" + \
            "(Overridden) Arrest::Bounty Violent: " + arrestVars.BountyViolent + "\n" \
        )
    endif

    ClearBounty(arrestFaction)
    arrestFaction.PlayerPayCrimeGold(false, false) ; Just in case?
endFunction

function UpdateArrestStats()
    Actor arrestee  = arrestVars.Arrestee

    if (arrestee == config.Player)
        string hold     = arrestVars.Hold
        int bounty      = arrestVars.Bounty

        int currentLargestBounty = actorVars.GetLargestBounty(arrestVars.ArrestFaction, arrestVars.Arrestee)
        actorVars.SetCurrentBounty(arrestVars.ArrestFaction, arrestVars.Arrestee, bounty)
        actorVars.SetLargestBounty(arrestVars.ArrestFaction, arrestVars.Arrestee, int_if (currentLargestBounty < bounty, bounty, currentLargestBounty))
        actorVars.ModTotalBounty(arrestVars.ArrestFaction, arrestVars.Arrestee, bounty)
        actorVars.ModTimesArrested(arrestVars.ArrestFaction, arrestVars.Arrestee, 1)

    else ; Processing for NPC stats later
        ; e.g:
        ; Actor arrestee  = arrestVars.Arrestee
        ; string hold = arrestVars.GetString("["+ arrestee.GetFormID() +"]Arrest::Hold")
        ; int bounty  = arrestVars.GetInt("["+ arrestee.GetFormID() +"]Arrest::Bounty")

        ; actorVars.SetStat(hold, "["+ arrestee.GetFormID() +"]Current Bounty", bounty)
    endif
endFunction

bool function ValidateArrestType(string arrestType)
    return  arrestType == ARREST_TYPE_TELEPORT_TO_JAIL || \ 
            arrestType == ARREST_TYPE_TELEPORT_TO_CELL || \ 
            arrestType == ARREST_TYPE_ESCORT_TO_JAIL || \
            arrestType == ARREST_TYPE_ESCORT_TO_CELL
endFunction

string function GetValidArrestTypes()
    return  ARREST_TYPE_TELEPORT_TO_JAIL + ", " + \ 
            ARREST_TYPE_TELEPORT_TO_CELL + ", " + \ 
            ARREST_TYPE_ESCORT_TO_JAIL + ", " + \ 
            ARREST_TYPE_ESCORT_TO_CELL
endFunction

function RestrainArrestee(Actor akArrestee)
    ; Hand Cuffs Backside Rusty - 0xA081D2F
    ; Hand Cuffs Front Rusty - 0xA081D33
    ; Hand Cuffs Front Shiny - 0xA081D34
    ; Hand Cuffs Crossed Front 01 - 0xA033D9D
    ; Hands Crossed Front in Scarfs - 0xA073A14
    ; Hands in Irons Front Black - 0xA033D9E
    Form cuffs = Game.GetFormEx(0xA081D2F)
    akArrestee.SheatheWeapon()
    UnequipHandsForActor(akArrestee)
    akArrestee.EquipItem(cuffs, true, true)
endFunction



; ==========================================================
;                   States & Delayed Events
; ==========================================================

;/
    The state where the actor should be upon being arrested.
/;
state Arrested
    event OnBeginState()
        Info(self, "Arrest::OnBeginState", "Begin State " + self.GetState())
    endEvent

    event OnUpdateGameTime()
    endEvent

    event OnEndState()
        Info(self, "Arrest::OnEndState", "End State " + self.GetState())
    endEvent
endState

;/
    The state where the actor should be upon resisting arrest.
/;
state Resisted
    event OnUpdateGameTime()
        self.ResetResistedFlag()
        GotoState("")
    endEvent

    event OnEndState()
        Debug(self, "Arrest::OnEndState", "End State " + self.GetState(), config.IS_DEBUG)
    endEvent
endState

state Eluding
    event OnBeginState()
        Debug(self, "Arrest::OnBeginState", "Begin State " + self.GetState())
    endEvent

    event OnUpdate()
        string eludeType = arrestVars.GetString("Arrest::Elude Type")

        if (eludeType == "Pursuit")
            if (self.MeetsPursuitEludeRequirements(arrestVars.Arrestee))
                Actor eludedCaptor = arrestVars.GetActor("Arrest::Eluded Captor")
                self.OnArrestEludeTriggered(eludedCaptor, eludeType) ; Explicitly call Event
            endif
        endif

        GotoState("")
    endEvent

    event OnUpdateGameTime()
        self.ResetEludedFlag()
        GotoState("")
    endEvent

    event OnEndState()
        Debug(self, "Arrest::OnStartState", "End State " + self.GetState())
    endEvent
endState

;/
    The state where the actor should be upon surrendering.
/;
state Surrender
    event OnBeginState()
        self.PlaySurrenderAnimation(arrestVars.Arrestee)
    endEvent

    event OnUpdate()
    endEvent

    event OnEndState()
        ; Actually arrest the actor
        string currentHold = config.GetCurrentPlayerHoldLocation()
        Faction currentHoldFaction = config.GetFaction(currentHold)
        currentHoldFaction.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_TELEPORT_TO_CELL)
    endEvent
endState

state WaitingOnArrest
    event OnBeginState()
        RegisterForSingleUpdate(5.0)
    endEvent

    event OnUpdate()
        Debug(self, "Arrest::OnUpdate", "IsAwaitingArrest: " + arrestVars.IsAwaitingArrest + ", Explicitly: " + arrestVars.GetBool("Arrest::Awaiting Arrest"))
        bool isAwaitingArrest = arrestVars.GetBool("Arrest::Awaiting Arrest")
        if (isAwaitingArrest)
            Actor akWaitingCaptor = arrestVars.GetActor("Arrest::Waiting Captor")
            akWaitingCaptor.GetCrimeFaction().ModCrimeGold(4000)

            ; Idea for later: Have the captor walk towards the player and arrest them then
            akWaitingCaptor.SendModEvent("RPB_ArrestBegin", "TeleportToCell", 0x14)
        endif
    endEvent

    event OnEndState()
        
    endEvent
endState

state Unconscious
    event OnBeginState()
        config.Player.SetActorValue("Paralysis", 1)
        config.Player.SetUnconscious(true)
        config.Player.PushActorAway(config.Player, 4.0)

        ; float randomTime = Utility.RandomFloat(1.0, 8)
        RegisterForSingleUpdateGameTime(2.0)
    endEvent

    event OnUpdateGameTime()
        config.Player.SetActorValue("Paralysis", 0)
        config.Player.SetUnconscious(false)
    endEvent
endState
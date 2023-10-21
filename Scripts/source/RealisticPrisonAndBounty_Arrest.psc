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

; ==========================================================
;                      Arrest Topic Types
; ==========================================================
int property TOPIC_START    = 0 autoreadonly
int property TOPIC_END      = 1 autoreadonly

int property TOPIC_TYPE_ARREST_SUSPICIOUS       = 5 autoreadonly
int property TOPIC_TYPE_ARREST_DIALOGUE_ELUDING = 6 autoreadonly
int property TOPIC_TYPE_ARREST_PURSUIT_ELUDING  = 7 autoreadonly
int property TOPIC_TYPE_ARREST_CONFRONT         = 10 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY       = 11 autoreadonly
int property TOPIC_TYPE_ARREST_RESIST           = 15 autoreadonly
int property TOPIC_TYPE_COMBAT_YIELD            = 16 autoreadonly
int property TOPIC_TYPE_ARREST_GO_TO_JAIL       = 20 autoreadonly

; ==========================================================
;                         Arrest Types
; ==========================================================

string property ARREST_TYPE_TELEPORT_TO_JAIL    = "TeleportToJail" autoreadonly
string property ARREST_TYPE_TELEPORT_TO_CELL    = "TeleportToCell" autoreadonly
string property ARREST_TYPE_ESCORT_TO_JAIL      = "EscortToJail" autoreadonly
string property ARREST_TYPE_ESCORT_TO_CELL      = "EscortToCell" autoreadonly


RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Jail property Jail
    RealisticPrisonAndBounty_Jail function get()
        return Config.Jail
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property ArrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return Config.ArrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_ActorVars property ActorVars
    RealisticPrisonAndBounty_ActorVars function get()
        return Config.ActorVars
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property MiscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return Config.MiscVars
    endFunction
endProperty

RealisticPrisonAndBounty_SceneManager property SceneManager
    RealisticPrisonAndBounty_SceneManager function get()
        return Config.SceneManager
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
    ArrestVars.ModInt("Jail::Bounty Non-Violent", akArrestFaction.GetCrimeGoldNonViolent())
    ArrestVars.ModInt("Jail::Bounty Violent", akArrestFaction.GetCrimeGoldViolent())
    ClearBounty(akArrestFaction)
endFunction

function SetEludedGuard(Actor akEludedGuard, string asEludeType)
    ArrestVars.SetActor("Arrest::Eluded Captor", akEludedGuard)
    ArrestVars.SetString("Arrest::Elude Type", asEludeType)
endFunction

function TriggerForcegreetEluding(Actor akEludedGuard)
    Debug(self, "Arrest::TriggerForcegreetEluding", "RPB_AllowArrestForcegreet: " + RPB_AllowArrestForcegreet.GetValueInt())
    Debug(self, "Arrest::TriggerForcegreetEluding", "Distance from Speaker: " + akEludedGuard.GetDistance(akEludedGuard.GetDialogueTarget()))
    self.SetEludedGuard(akEludedGuard, "Dialogue")
    SceneManager.StartEludingArrest(akEludedGuard, config.Player)
endFunction

function TriggerPursuitEluding(Actor akEludedGuard)
    self.SetEludedGuard(akEludedGuard, "Pursuit")
    RegisterForDelayedEvent("Eluding", config.ArrestEludeWarningTime) ; Register for a delayed event on Eluding::OnUpdate()
endFunction

function SetupArrestPayableBountyVars(Faction akCrimeFaction)
    GlobalVariable RPB_ArrestGuaranteedPayableBounty = GetFormFromMod(0x161D2) as GlobalVariable
    GlobalVariable RPB_ArrestMaxPayableBounty        = GetFormFromMod(0x161D4) as GlobalVariable
    GlobalVariable RPB_ArrestRollDiceResult          = GetFormFromMod(0x16737) as GlobalVariable
    
    ; Update Globals (Determines if the arrest will be payable for sure, or if it falls within the maximum payable, which needs a roll of the dice)
    RPB_ArrestGuaranteedPayableBounty.SetValueInt(Config.GetArrestGuaranteedPayableBounty(akCrimeFaction.GetName()))
    RPB_ArrestMaxPayableBounty.SetValueInt(Config.GetArrestMaximumPayableBounty(akCrimeFaction.GetName()))

    ; Roll the dice for max payable bounty chance
    int maxPayableChance = Config.GetArrestMaximumPayableChance(akCrimeFaction.GetName())
    int random = Utility.RandomInt(1, 100)
    if (random <= maxPayableChance)
        RPB_ArrestRollDiceResult.SetValueInt(random) ; Any value other than 0 will represent success
    endif
    Debug(self, "Arrest::SetupArrestPayableBountyVars", "Needed: <= " + maxPayableChance + ", Got: " + random)
endFunction

;/
    Master Event for all types of dialogue concerning Arrest, anything to do with arrest through dialogue is
    handled here.

    int     @aiTopicInfoType: The type of the dialogue, Arrest to Jail, Arrest Resist, Arrest Confront, etc...
    int     @aiTopicInfoEvent: The time of the event, at the Start or End of the dialogue.
    string  @asTopicInfoDialogue: The dialogue lines, used if a unique action should be done depending on the dialogue.
    Actor   @akSpeakerArrester: The guard actively trying to arrest the player.
    Actor   @akSpokenToArrestee: The Actor that is being spoken to by @akSpeakerArrester, in most cases, an arrestee.

    Dialogue Lines (@asTopicInfoDialogue):
        - TOPIC_TYPE_ARREST_DIALOGUE_ELUDING
            - Wait... I know you.

        - TOPIC_TYPE_ARREST_PURSUIT_ELUDING
            - That'll teach you to break the law on my watch.
            - I thought it was finally going to be a quiet day.
            - You really thought you could get away with it?
            - Don't get any bright ideas.
            - Stop, in the name of the Jarl!
            - Come quietly or face the Jarl's justice!
            - By order of the Jarl, I command you to halt!
            - Sheathe your wepaons and come quietly!

        - TOPIC_TYPE_ARREST_CONFRONT
            - By order of the Jarl, stop right there!
            - You have committed crimes against Skyrim and her people. What say you in your defense?

        - TOPIC_TYPE_ARREST_PAY_BOUNTY
            - Smart man. Now come along with us. We'll take any stolen goods and you'll be free to go. After you pay the fine, of course.
            - Smart woman. Now come along with us. We'll take any stolen goods and you'll be free to go. After you pay the fine, of course.
            - Good enough. I'll just confiscate any stolen goods you're carrying, then you're free to go.

        - TOPIC_TYPE_COMBAT_YIELD
            - I'll let you live. This time
            - I'll spare you - for now.
            - All right, you've had enough.
            - You're not worth it.
            - I didn't think you had the stomach for it.

        - TOPIC_TYPE_ARREST_RESIST
            - Time to cleanse the Empire of its filth.
            - Then suffer the Emperor's wrath.
            - Skyrim has no use for your kind.
            - Then let me speed your passage to Sovngarde!
            - Then pay with your blood.
            - That can be arranged.
            - So be it.
/;
event OnArrestDialogue(int aiTopicInfoEvent, int aiTopicInfoType, string asTopicInfoDialogue, Actor akSpeakerArrester, Actor akSpokenToArrestee)
    if (aiTopicInfoEvent == TOPIC_START)
        if (aiTopicInfoType == TOPIC_TYPE_ARREST_CONFRONT)
            self.SetupArrestPayableBountyVars(akSpeakerArrester.GetCrimeFaction()) ; Setup arrest payable bounty vars

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_RESIST)
            akSpeakerArrester.SendModEvent("RPB_ResistArrest", "", akSpokenToArrestee.GetFormID())

        elseif (aiTopicInfoType == TOPIC_TYPE_COMBAT_YIELD)
            akSpeakerArrester.SendModEvent("RPB_CombatYield", "", akSpokenToArrestee.GetFormID())
        endif

    elseif (aiTopicInfoEvent == TOPIC_END)
        if (aiTopicInfoType == TOPIC_TYPE_ARREST_DIALOGUE_ELUDING)
            akSpeakerArrester.SendModEvent("RPB_EludingArrest", "Dialogue")

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PURSUIT_ELUDING)
            akSpeakerArrester.SendModEvent("RPB_EludingArrest", "Pursuit")

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_GO_TO_JAIL)
            akSpeakerArrester.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_ESCORT_TO_JAIL, akSpokenToArrestee.GetFormID())
        endif
    endif
endEvent

function ResetDiceRollForMaxPayableBounty()
    GlobalVariable RPB_ArrestRollDiceResult = GetFormFromMod(0x16737) as GlobalVariable
    RPB_ArrestRollDiceResult.SetValueInt(0)
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
        ArrestVars.SetForm("Arrest::Arrest Faction", config.GetCrimeFaction(currentHold))
        Faction crimeFaction = ArrestVars.GetForm("Arrest::Arrest Faction") as Faction
        Actor nearbyGuard = GetNearestActor(config.Player, 7000)
        nearbyGuard.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_TELEPORT_TO_CELL)
    
    elseif (keyCode == 0x44) ; F10

        Quest WIRemoveItem01 = Game.GetFormEx(0x2C6AB) as Quest

        WIRemoveItem01.Start()

        Actor solitudeGuard = Game.GetFormEx(0xF684E) as Actor
        config.Player.PlaceActorAtMe(config.Player.GetBaseObject() as ActorBase, 1, none)
        Debug(self, "Arrest::OnKeyDown", "F10 Pressed")
        ; sceneManager.StartEscortFromCell(ArrestVars.Captor, ArrestVars.Arrestee, ArrestVars.CellDoor, ArrestVars.PrisonerItemsContainer)
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

        if (ArrestVars.Exists(arrestResistKey))
            ArrestVars.Remove(arrestResistKey)
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

        if (ArrestVars.Exists(arrestEludeKey))
            ArrestVars.Remove(arrestEludeKey)
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

    Faction     @akFaction: The arresting faction
/;
function SetResistedFlag(Faction akFaction)
    ArrestVars.SetBool("Arrest::"+ akFaction.GetName() +"::Arrest Resisted", true) ; Set arrest resisted flag
endFunction

;/
    Sets the Eluded Arrest flag to be active.
    While this flag is active, further arrest attempts of this Faction will no longer incur a penalty upon eluding again.

    This is to prevent multiple guards attempting to arrest the player and eventually end up with multiple penalties from each
    guard for something that should only be punished once.

    After some time, this flag will be inactive again and the next arrest attempt will be punished once again.

    Faction     @akFaction: The arresting faction
/;
function SetEludedFlag(Faction akFaction)
    ArrestVars.SetBool("Arrest::"+ akFaction.GetName() +"::Arrest Eluded", true) ; Set arrest eluded flag
    RegisterForDelayedEventGameTime("Eluding", 1.0)
endFunction

bool function HasResistedArrestRecently(Faction akArrestFaction)
    return ArrestVars.GetBool("Arrest::" + akArrestFaction.GetName() + "::Arrest Resisted")
endFunction

bool function HasEludedArrestRecently(Faction akArrestFaction)
    return ArrestVars.GetBool("Arrest::" + akArrestFaction.GetName() + "::Arrest Eluded")
endFunction

;/
    Sets the passed in actor as arrested for this faction to the system.
/;
function SetAsArrested(Actor akArrestee, Faction akFaction)
    if (akArrestee == config.Player)
        ArrestVars.SetBool("Arrest::Arrested", true)
        ArrestVars.SetFloat("Arrest::Time of Arrest", Utility.GetCurrentGameTime())
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
    crimeFaction.SetCrimeGold(ArrestVars.BountyNonViolent)
    crimeFaction.SetCrimeGoldViolent(ArrestVars.BountyViolent)

    ArrestVars.Remove("Arrest::Captured")
    ArrestVars.Remove("Arrest::Arrest Faction")
    ArrestVars.Remove("Arrest::Hold")
    ArrestVars.Remove("Arrest::Arrestee")
    ArrestVars.Remove("Arrest::Arrest Type")
    ArrestVars.Remove("Arrest::Arrested")
    ArrestVars.Remove("Arrest::Time of Arrest")

    self.AllowArrestForcegreets()
    Game.SetPlayerAIDriven(false)
endFunction

function ChangeArrestEscort(Actor akNewEscort, Actor akDetainee)
    ; A new guard was found, escort Detainee to jail
    ArrestVars.SetReference("Arrest::Arresting Guard", akNewEscort) ; Change the captor for further scenes and to lead to the cell
    BindAliasTo(CaptorRef, akNewEscort)
    sceneManager.StartEscortToJail(akNewEscort, ArrestVars.Arrestee, ArrestVars.PrisonerItemsContainer)
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

    ArrestVars.SetBool("Arrest::Eluded", true)
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
    ; ArrestVars.SetInt("Arrest::Bounty for Defeat", Helper.GetArrestAdditionalBountyOnDefeat(hold))
    ArrestVars.SetInt("Arrest::Additional Bounty when Defeated", config.GetArrestAdditionalBountyDefeatedFlat(hold))
    ArrestVars.SetFloat("Arrest::Additional Bounty when Defeated from Current Bounty", GetPercentAsDecimal(config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold)))
    ArrestVars.SetInt("Arrest::Bounty for Defeat", int_if (ArrestVars.DefeatedAdditionalBountyPercentage > 0, round(akArrestFaction.GetCrimeGold() * ArrestVars.DefeatedAdditionalBountyPercentage)) + ArrestVars.DefeatedAdditionalBounty)
    ArrestVars.SetBool("Arrest::Defeated", true)

    ; Bounty is applied later at the Arrest stage.
endFunction

function SetArrestParams(string asArrestType, Actor akArrestee, Actor akCaptor, Faction akCrimeFaction = none)
    Faction crimeFaction = akCrimeFaction

    if (akCaptor)
        crimeFaction = akCaptor.GetCrimeFaction()
        ArrestVars.SetForm("Arrest::Arresting Guard", akCaptor)
        CaptorRef.ForceRefTo(akCaptor)
        Debug(self, "Arrest::SetArrestParams", "Arrest is being done through a captor ("+ akCaptor +")")
    endif

    if (!crimeFaction)
        Error(self, "Arrest::SetArrestParams", "Both the captor and faction are none, cannot proceed with the arrest! (returning...)")
        return
    endif

    ArrestVars.SetBool("Arrest::Captured", true)
    ArrestVars.SetForm("Arrest::Arrest Faction", crimeFaction)
    ArrestVars.SetString("Arrest::Hold", crimeFaction.GetName())
    ArrestVars.SetForm("Arrest::Arrestee", akArrestee)
    ArrestVars.SetString("Arrest::Arrest Type", asArrestType)

    if (asArrestType == ARREST_TYPE_ESCORT_TO_JAIL || \
        asArrestType == ARREST_TYPE_ESCORT_TO_CELL)
        
        ; Default Scene
        if (!ArrestVars.Exists("Arrest::Arrest Scene"))
            ArrestVars.SetString("Arrest::Arrest Scene", "ArrestStart02")
        endif
    endif

    Debug(self, "Arrest::SetArrestParams", "[\n" + \ 
        "\tCaptured: "+ ArrestVars.GetBool("Arrest::Captured") +" \n" + \
        "\tArrest Faction: "+ ArrestVars.GetForm("Arrest::Arrest Faction") +"\n" + \
        "\tHold: "+ ArrestVars.GetString("Arrest::Hold") +"\n" + \
        "\tArrestee: "+ ArrestVars.GetForm("Arrest::Arrestee") +"\n" + \
        "\tArrest Type: "+ ArrestVars.GetString("Arrest::Arrest Type") +"\n" + \
    "]")

endFunction

event OnArrestBegin(Actor akArrestee, Actor akCaptor, Faction akCrimeFaction, string asArrestType)
    if (!self.ValidateArrestType(asArrestType))
        Error(self, "Arrest::OnArrestBegin", "Arrest Type is invalid, got: " + asArrestType + ". (valid options: "+ self.GetValidArrestTypes() +") ")
        return
    endif

    if (ArrestVars.IsArrested)
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
endEvent

event OnArrestResist(Actor akArrestResister, Actor akGuard, Faction akCrimeFaction)
    if (ArrestVars.GetBool("Arrest::Captured"))
        Warn(self, "Arrest::OnArrestResist", akArrestResister.GetBaseObject().GetName() + " was arrested, no arrest was resisted (maybe multiple guards talked at once and triggered resist arrest?) [BUG]")
        return
    endif

    akGuard.SetPlayerResistingArrest() ; Needed to make the guards attack the player, otherwise they will loop arrest dialogue

    if (self.HasResistedArrestRecently(akCrimeFaction))
        Info(self, "Arrest::OnArrestResist", "You have already resisted arrest recently, no bounty will be added as it most likely is the same arrest.")
        return
    endif

    self.ApplyArrestResistedPenalty(akCrimeFaction)
endEvent

event OnCombatYield(Actor akGuard, Actor akYieldedArrestee)
    ; Only begin arrest if they are within this distance,
    ; this is to avoid Guards triggering their dialogue while the player has already ran away.
    if (akYieldedArrestee.GetDistance(akGuard) <= 1200)
        ArrestVars.SetString("Arrest::Arrest Scene", "ArrestStartFree01")
        akGuard.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_ESCORT_TO_JAIL, akYieldedArrestee.GetFormID())
    endif
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
    Debug(self, "Arrest::OnArrestEludeStart", "Started Eluding Arrest with Elude Type: " + asEludeType + ", akEludedGuard: " + akEludedGuard)

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
        SceneManager.ReleaseAlias("Guard") ; Unbind alias running the AI package from eluded guard
        SceneManager.ReleaseAlias("Eluder") ; Unbind alias from the player
    endif
endEvent

event OnArrestCaptorDeath(Actor akCaptor, Actor akCaptorKiller)
    Actor anotherGuard = GetNearestGuard(ArrestVars.Arrestee, 3500, exclude = akCaptor)

    if (!anotherGuard)
        config.NotifyArrest("Your captor has died, you may now try to break free")
        self.ReleaseDetainee(akCaptor, ArrestVars.Arrestee)
        return
    endif

    config.NotifyArrest("Your captor has died, you are being escorted by another guard")
    self.ChangeArrestEscort(anotherGuard, ArrestVars.Arrestee)

    if (akCaptorKiller == none) ; to be changed to Player later, but this is easier to test
        int bounty = 10000
        config.NotifyArrest("You have gained " + bounty + " Bounty in " + ArrestVars.Hold + " for killing your captor!")
    endif

    Debug(self, "Arrest::OnArrestCaptorDeath", "[\n"+ \ 
        "\tOld Captor: "+ akCaptor +"\n" + \
        "\tNew Captor: "+ anotherGuard +"\n" \
    +"]")
endEvent

function BeginArrest()
    string hold             = ArrestVars.Hold
    string arrestType       = ArrestVars.ArrestType
    Faction arrestFaction   = ArrestVars.ArrestFaction
    Actor arrestee          = ArrestVars.Arrestee
    Actor captor            = ArrestVars.Captor ; May be undefined if the arrest is not done through a captor

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

        ; SceneManager.StartArrestStartPrison_01(captor, arrestee)
        SceneManager.StartArrestStart03(captor, arrestee)
        ; int sceneParams = JMap.object()
        ; JMap.setForm(sceneParams, "Escort", captor)
        ; JMap.setForm(sceneParams, "Escortee", arrestee)
        ; SceneManager.StartScene(SceneManager.SCENE_ARREST_START_PRISON_01, sceneParams)
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
    Jail.EscortToJail()
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
        ArrestVars.ModInt("Arrest::Bounty Non-Violent", defeatArrestPenalty)
        config.NotifyArrest("You have gained " + defeatArrestPenalty + " Bounty in " + hold +" for being defeated")
    endif
endFunction

function TriggerSurrender()
    string currentHold = config.GetCurrentPlayerHoldLocation()
    Faction currentHoldFaction = config.GetFaction(currentHold)
    Actor arresteeRef = config.Player

    if (ArrestVars.IsArrested)
        config.NotifyArrest("You are already arrested")
        Error(self, "Arrest::OnArrestBegin", arresteeRef.GetBaseObject().GetName() + " is already arrested, cannot arrest for "+ currentHoldFaction.GetName() +", aborting!")
        return
    endif

    self.PlaySurrenderAnimation(ArrestVars.Arrestee)

    self.SetAsDefeated(currentHoldFaction)
    currentHoldFaction.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_TELEPORT_TO_CELL)
endFunction

bool function HasLatentBounty()
    return ArrestVars.Bounty > 0
endFunction

bool function HasActiveBounty(Faction akCrimeFaction)
    return akCrimeFaction.GetCrimeGold() > 0
endFunction

function ResetArrest(string reason = "")
    ; Clear all arrest related vars
    ArrestVars.Clear()
    Info(self, "ResetArrest", reason, reason != "")
endFunction

function SetBounty()
    Faction arrestFaction = ArrestVars.ArrestFaction

    if (self.HasLatentBounty())
        ; Add the "active bounty" if there's any, to the latent bounty
        ArrestVars.ModInt("Arrest::Bounty Non-Violent", arrestFaction.GetCrimeGoldNonViolent())
        ArrestVars.ModInt("Arrest::Bounty Violent", arrestFaction.GetCrimeGoldViolent())
    else
        ; Set the bounties to be latent
        ArrestVars.SetFloat("Arrest::Bounty Non-Violent", arrestFaction.GetCrimeGoldNonViolent())
        ArrestVars.SetFloat("Arrest::Bounty Violent", arrestFaction.GetCrimeGoldViolent())
    endif

    if (ArrestVars.WasDefeated && ArrestVars.DefeatedBounty > 0)
        ArrestVars.ModInt("Arrest::Bounty Non-Violent", ArrestVars.DefeatedBounty)
        config.NotifyArrest("You were defeated, " + ArrestVars.DefeatedBounty + " Bounty gained in " + ArrestVars.Hold)
    endif

    ; if (ArrestVars.GetBool("Jail::Escaped"))
    ;     int currentBounty = ArrestVars.BountyNonViolent - 1000 ; Subtract 1000 which is the bounty given after escape success
    ;     int currentBountyViolent = ArrestVars.BountyViolent
    ;     int escapeBountyNonViolent = ArrestVars.GetInt("Escape::Bounty Non-Violent")
    ;     int escapeBountyViolent = ArrestVars.GetInt("Escape::Bounty Violent")
    ;     int totalBounty = (currentBounty + escapeBountyNonViolent) + (currentBountyViolent + escapeBountyViolent)

    ;     ArrestVars.SetFloat("Arrest::Bounty Non-Violent", currentBounty + escapeBountyNonViolent)
    ;     ArrestVars.SetFloat("Arrest::Bounty Violent", currentBountyViolent + escapeBountyViolent)

    ;     Debug(none, "SetBounty", "currentBounty: " + currentBounty + ", currentBountyV: " + currentBountyViolent + ", escapeBountyNv: " + escapeBountyNonViolent + ", escapeBountyV: " + escapeBountyViolent + ", totalBounty: " + totalBounty)
    ; endif

    if (ArrestVars.HasOverride("Arrest::Bounty Non-Violent"))
        Debug(self, "SetBounty", "\n" + \
            "(Overridden) Arrest::Bounty Non-Violent: " + ArrestVars.BountyNonViolent + "\n" \
        )
    endif

    if (ArrestVars.HasOverride("Arrest::Bounty Non-Violent"))
        Debug(self, "SetBounty", "\n" + \
            "(Overridden) Arrest::Bounty Violent: " + ArrestVars.BountyViolent + "\n" \
        )
    endif

    ClearBounty(arrestFaction)
    arrestFaction.PlayerPayCrimeGold(false, false) ; Just in case?
endFunction

function UpdateArrestStats()
    Actor arrestee  = ArrestVars.Arrestee

    if (arrestee == config.Player)
        string hold     = ArrestVars.Hold
        int bounty      = ArrestVars.Bounty

        int currentLargestBounty = actorVars.GetLargestBounty(ArrestVars.ArrestFaction, ArrestVars.Arrestee)
        actorVars.SetCurrentBounty(ArrestVars.ArrestFaction, ArrestVars.Arrestee, bounty)
        actorVars.SetLargestBounty(ArrestVars.ArrestFaction, ArrestVars.Arrestee, int_if (currentLargestBounty < bounty, bounty, currentLargestBounty))
        actorVars.ModTotalBounty(ArrestVars.ArrestFaction, ArrestVars.Arrestee, bounty)
        actorVars.ModTimesArrested(ArrestVars.ArrestFaction, ArrestVars.Arrestee, 1)

    else ; Processing for NPC stats later
        ; e.g:
        ; Actor arrestee  = ArrestVars.Arrestee
        ; string hold = ArrestVars.GetString("["+ arrestee.GetFormID() +"]Arrest::Hold")
        ; int bounty  = ArrestVars.GetInt("["+ arrestee.GetFormID() +"]Arrest::Bounty")

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

state Eluding
    event OnBeginState()
        Debug(self, "Arrest::OnBeginState", "Begin State " + self.GetState())
    endEvent

    event OnUpdate()
        string eludeType = ArrestVars.GetString("Arrest::Elude Type")

        if (eludeType == "Pursuit")
            if (self.MeetsPursuitEludeRequirements(Config.Player))
                Actor eludedCaptor = ArrestVars.GetActor("Arrest::Eluded Captor")
                self.OnArrestEludeTriggered(eludedCaptor, eludeType) ; Explicitly call Event
            endif
        endif

        GotoState("")
    endEvent

    event OnEndState()
        Debug(self, "Arrest::OnStartState", "End State " + self.GetState())
    endEvent
endState

event OnUpdateGameTime()
    self.ResetEludedFlag()      ; Reset Eluded Arrest flags for all Holds
    self.ResetResistedFlag()    ; Reset Resisted Arrest flags for all Holds
endEvent
scriptname RealisticPrisonAndBounty_Arrest extends Quest

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config
import PO3_SKSEFunctions

; ==========================================================
;                      Arrest Topic Types
; ==========================================================

int property TOPIC_START    = 0 autoreadonly
int property TOPIC_END      = 1 autoreadonly

int property TOPIC_TYPE_ARREST_SUSPICIOUS                       = 5 autoreadonly
int property TOPIC_TYPE_ARREST_DIALOGUE_ELUDING                 = 6 autoreadonly
int property TOPIC_TYPE_ARREST_PURSUIT_ELUDING                  = 7 autoreadonly
int property TOPIC_TYPE_ARREST_CONFRONT                         = 10 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT               = 11 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_WILLINGLY      = 12 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_ARRESTED       = 13 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_MAX                   = 14 autoreadonly
int property TOPIC_TYPE_ARREST_RESIST                           = 15 autoreadonly
int property TOPIC_TYPE_COMBAT_YIELD                            = 16 autoreadonly
int property TOPIC_TYPE_ARREST_GO_TO_JAIL                       = 20 autoreadonly

; ==========================================================
;                 Arrest Pay Bounty Scenarios
; ==========================================================

string property ARREST_PAY_BOUNTY_ON_SPOT           = "ArrestPayOnSpot" autoreadonly
string property ARREST_PAY_BOUNTY_ESCORT_WILLINGLY  = "ArrestEscortWillingly" autoreadonly
string property ARREST_PAY_BOUNTY_ESCORT_BY_FORCE   = "ArrestEscortByForce" autoreadonly

; ==========================================================
;                         Arrest Types
; ==========================================================

string property ARREST_TYPE_TELEPORT_TO_JAIL    = "TeleportToJail" autoreadonly
string property ARREST_TYPE_TELEPORT_TO_CELL    = "TeleportToCell" autoreadonly
string property ARREST_TYPE_ESCORT_TO_JAIL      = "EscortToJail" autoreadonly
string property ARREST_TYPE_ESCORT_TO_CELL      = "EscortToCell" autoreadonly

; ==========================================================
;                         Arrest Goals
; ==========================================================

string property ARREST_GOAL_IMPRISONMENT        = "Imprisonment" autoreadonly
string property ARREST_GOAL_BOUNTY_PAYMENT      = "BountyPayment" autoreadonly
string property ARREST_GOAL_TEMPORARY_HOLD      = "TemporaryHold" autoreadonly ; Unused for Now


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

RealisticPrisonAndBounty_CaptorRef property CaptorRef auto

function RegisterEvents()

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

    elseif (keyCode == 0x42)
        Debug(self, "Arrest::OnKeyDown", "F8 Pressed")
        ; Actor solitudeGuard = Game.GetFormEx(0xF684E) as Actor
        ; Actor theGuard = config.Player.PlaceActorAtMe(solitudeGuard.GetBaseObject() as ActorBase, 1, none)
        Actor nearbyGuard = GetNearestGuard(config.Player, 3500, none)
        ObjectReference arrestee = Game.GetCurrentCrosshairRef()
        nearbyGuard.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_ESCORT_TO_JAIL, arrestee.GetFormID())
    endif
endEvent


; Temporary Event Handlers
event OnArrestStart(Actor akCaptor, Actor akArrestee)
    Jail.EscortToJail()
endEvent

event OnArresting(Actor akCaptor, Actor akArrestee)
    self.RestrainArrestee(akArrestee)
endEvent

; ==========================================================
;                        Event Handlers
; ==========================================================

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

        - TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT
            - Good enough. I'll just confiscate any stolen goods you're carrying, then you're free to go.

        - TOPIC_TYPE_ARREST_PAY_BOUNTy_ESCORT_WILLINGLY
            - Smart man. Now come along with us. We'll take any stolen goods and you'll be free to go. After you pay the fine, of course.
            - Smart woman. Now come along with us. We'll take any stolen goods and you'll be free to go. After you pay the fine, of course.

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
            self.SetActorWantsToPayBounty(akSpokenToArrestee, false) ; Reset any possibility of paying the bounty, before actually selecting it

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_RESIST)
            self.SetAsResisting(akSpeakerArrester, akSpokenToArrestee)

        elseif (aiTopicInfoType == TOPIC_TYPE_COMBAT_YIELD)
            self.SetAsYielding(akSpeakerArrester, akSpokenToArrestee)
        endif

    elseif (aiTopicInfoEvent == TOPIC_END)
        if (aiTopicInfoType == TOPIC_TYPE_ARREST_DIALOGUE_ELUDING)
            self.SetAsEluding(akSpeakerArrester, akSpokenToArrestee, "Dialogue")

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PURSUIT_ELUDING)
            self.SetAsEluding(akSpeakerArrester, akSpokenToArrestee, "Pursuit")

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT)
            self.StartBountyPayment(akSpeakerArrester, akSpokenToArrestee, ARREST_PAY_BOUNTY_ON_SPOT)

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_WILLINGLY)
            self.StartBountyPayment(akSpeakerArrester, akSpokenToArrestee, ARREST_PAY_BOUNTY_ESCORT_WILLINGLY)
            
        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_ARRESTED)
            self.StartBountyPayment(akSpeakerArrester, akSpokenToArrestee, ARREST_PAY_BOUNTY_ESCORT_BY_FORCE)

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_GO_TO_JAIL)
            self.ArrestActor(akSpeakerArrester, akSpokenToArrestee, ARREST_TYPE_ESCORT_TO_JAIL)
        endif
    endif
endEvent

event OnArrestBegin(Actor akArrestee, Actor akCaptor, Faction akCrimeFaction, string asArrestType)
    ; This verification must be changed later to account for every possible Actor, something like:
    ;/
        if (self.IsArrested(akArrestee)) -> Where a verification will happen on a script that is attached to the ref passed in to this function and check the state of the Actor
            
        endif
    /;
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
        asArrestType    = asArrestType, \
        akArrestee      = akArrestee, \
        akCaptor        = akCaptor, \
        akCrimeFaction  = akCrimeFaction \
    )

    if (akArrestee == Config.Player)
        self.AllowArrestForcegreets(false)
    endif

    self.BeginArrest()
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

event OnArrestPayBounty(Actor akArresterGuard, Actor akPayerArrestee, Faction akCrimeFaction, string asPayBountyScenario)
    Debug(self, "Arrest::OnArrestPayBounty", "Paying Bounty for Faction " + akCrimeFaction + ", Payer: " + akPayerArrestee + ", paying to: " + akArresterGuard)

    if (asPayBountyScenario == ARREST_PAY_BOUNTY_ON_SPOT)
        self.PayCrimeGold(akPayerArrestee, akCrimeFaction)

    elseif (asPayBountyScenario == ARREST_PAY_BOUNTY_ESCORT_WILLINGLY)
        ; Start escort Scene, where guard will take the person paying the bounty to jail, to be frisked and pay it.
        ; If the payer strays from the path, give a bounty penalty and start combat
        CaptorRef.ForceRefTo(akArresterGuard)
        CaptorRef.AssignArrestee(akPayerArrestee)
        CaptorRef.RegisterForSingleUpdate(5.0)
        self.SetActorWantsToPayBounty(akPayerArrestee)
        self.SetArrestGoal(akPayerArrestee, ARREST_GOAL_BOUNTY_PAYMENT)

        ; Get current bounty and hide it
        self.HideBounty(akCrimeFaction)

        SceneManager.StartArrestBountyPaymentFollowWillingly(akArresterGuard, akPayerArrestee, Config.GetJailPrisonerItemsContainer(akCrimeFaction.GetName()) as ObjectReference)
    elseif (asPayBountyScenario == ARREST_PAY_BOUNTY_ESCORT_BY_FORCE)
        ; Start escort Scene, where guard will detain the person paying the bounty to jail and take them there by force, to be frisked and pay it.
        ; temporary escort location:
        self.SetArrestScene(akPayerArrestee, SceneManager.SCENE_ARREST_START_01)
        self.ArrestActor(akArresterGuard, akPayerArrestee, ARREST_TYPE_ESCORT_TO_JAIL)

        ; Set vars to differentiate from normal arrest
        self.SetActorWantsToPayBounty(akPayerArrestee)
        self.SetArrestGoal(akPayerArrestee, ARREST_GOAL_BOUNTY_PAYMENT)
    endif
endEvent

event OnArrestDefeat(Actor akAttacker)
    self.ApplyArrestDefeatedPenalty(akAttacker.GetCrimeFaction())

    Form handcuffs = Game.GetFormEx(0xA033D9E)
    config.Player.StopCombatAlarm()
    config.Player.EquipItem(handcuffs, true, true)
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

;/
    Event to handle what happens when the arrestee yields in combat against a guard.

    Actor   @akGuard: The guard that is in combat and trying to perform an arrest.
    Actor   @akYieldedArrestee: The Actor that has yielded and is about to be arrested.
/;
event OnCombatYield(Actor akGuard, Actor akYieldedArrestee)
    ; Only begin arrest if they are within this distance,
    ; this is to avoid Guards triggering their dialogue while the player has already ran away.
    if (akYieldedArrestee.GetDistance(akGuard) <= 1200)
        ArrestVars.SetString("Arrest::Arrest Scene", "ArrestStartFree01")
        akGuard.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_ESCORT_TO_JAIL, akYieldedArrestee.GetFormID())
    endif
endEvent

;/
    Event to handle what happens when the bounty payer gets to jail to pay their bounty.
    
    Actor   @akArresterGuard: The guard that performed the arrest to take the person to pay their bounty.
    Actor   @akPayerArrestee: The actor currently detained in order to pay their bounty.
    Faction @akCrimeFaction: The crime faction this bounty's going to.
    bool    @abEscortedForcefully: Whether the bounty payer was restrained and escorted forcefully while getting to jail.
/;
event OnArrestPayBountyEnd(Actor akArresterGuard, Actor akPayerArrestee, Faction akCrimeFaction, bool abEscortedForcefully)
    if (abEscortedForcefully) ; Payer is restrained
        self.UnrestrainArrestee(akPayerArrestee)
    endif

    self.PayCrimeGold(akPayerArrestee, akCrimeFaction)

    ; Reset Bounty Payment vars
    self.SetActorWantsToPayBounty(akPayerArrestee, false)
endEvent

event OnArrestSceneChanged(Actor akArrestee, string asSceneName)
    if (akArrestee == Config.Player)
        ArrestVars.SetString("Arrest::Scene", asSceneName)
    endif
endEvent

;/
    Event to handle what happens when the arrest goal for a specific arrestee changes.

    Actor   @akArrestee: The Actor that is currently arrested and is having their goal for the arrest changed.
    string  @asOldArrestGoal: The previous arrest goal for this Actor.
    string  @asNewArrestGoal: The new arrest goal for this Actor.
/;
event OnArrestGoalChanged(Actor akArrestee, string asOldArrestGoal, string asNewArrestGoal)
    ArrestVars.SetString("Arrest::Arrest Goal", asNewArrestGoal)
    Debug(self, "Arrest::OnArrestGoalChanged", "Arrest Goal for Actor " + akArrestee + " was set to " + asNewArrestGoal, asOldArrestGoal == "")
    Debug(self, "Arrest::OnArrestGoalChanged", "Arrest Goal for Actor " + akArrestee + " was changed from " + asOldArrestGoal + " to " + asNewArrestGoal, asOldArrestGoal != "")
endEvent

event OnUpdateGameTime()
    self.ResetEludedFlag()      ; Reset Eluded Arrest flags for all Holds
    self.ResetResistedFlag()    ; Reset Resisted Arrest flags for all Holds
endEvent

; ==========================================================
;                           Functions
; ==========================================================
; ==========================================================
;                      Callers to Events

;/
    Sets the arrest scene for @akArrestee.

    The verification is handled through EventManager which is then handled
    through OnArrestSceneChanged.

    Actor   @akArrestee: The arrestee from the arrest of which the scene is to be set.
    string  @asSceneName: The name of the arrest scene.
/;
function SetArrestScene(Actor akArrestee, string asSceneName)
    akArrestee.SendModEvent("RPB_SetArrestScene", asSceneName)
endFunction

;/
    Sets the primary arrest goal for @akArrestee.

    The verification is handled through EventManager which is then handled
    through OnArrestGoalChanged.

    Actor   @akArrestee: The arrestee from the arrest of which the scene is to be set.
    string  @asArrestGoal: The type of the arrest goal.
/;
function SetArrestGoal(Actor akArrestee, string asArrestGoal)
    akArrestee.SendModEvent("RPB_SetArrestGoal", asArrestGoal)
endFunction

;/
    Arrests the passed in Actor.

    The verification is handled through EventManager,
    the arrest begins with OnArrestBegin.

    Actor   @akArrester: The Actor that is performing the arrest, usually a guard.
    Actor   @akArrestee: The Actor that is to be arrested.
    string  @asArrestType: The type of the arrest, whether to escort to jail, cell, or teleport to jail or cell.
/;
function ArrestActor(Actor akArrester, Actor akArrestee, string asArrestType)
    akArrester.SendModEvent("RPB_ArrestBegin", asArrestType, akArrestee.GetFormID())
endFunction

;/
    Sets the passed in Actor as being eluding arrest.

    The verification is handled through EventManager,
    and it's handled by OnArrestEludeStart

    Actor   @akEludedGuard: The Actor that is performing the arrest, usually a guard.
    Actor   @akEluder: The Actor that is eluding arrest.
    string  @asEludeType: The type of the arrest elude, Dialogue or Pursuit
/;
function SetAsEluding(Actor akEludedGuard, Actor akEluder, string asEludeType)
    akEludedGuard.SendModEvent("RPB_EludingArrest", asEludeType)
endFunction

;/
    Sets the passed in Actor as being resisting arrest.

    The verification is handled through EventManager,
    and it's handled by OnArrestResist

    Actor   @akGuard: The Actor that is performing the arrest, usually a guard.
    Actor   @akResister: The Actor that is resisting arrest.
/;
function SetAsResisting(Actor akGuard, Actor akResister)
    akGuard.SendModEvent("RPB_ResistArrest", "", akResister.GetFormID())
endFunction

;/
    Sets the passed in Actor as having yielded and been spared.

    The verification is handled through EventManager,
    and it's handled by OnCombatYield

    Actor   @akSparerGuard: The Actor that is performing the arrest, usually a guard.
    Actor   @akYieldedArrestee: The Actor that has yielded and will be arrested.
/;
function SetAsYielding(Actor akSparerGuard, Actor akYieldedArrestee)
    akSparerGuard.SendModEvent("RPB_CombatYield", "", akYieldedArrestee.GetFormID())
endFunction

;/
    Starts the bounty payment scenario for @akPayerArrestee, handled by @akGuard.

    The verification is handled through EventManager,
    and it's handled by OnArrestPayBounty

    Actor   @akGuard: The Actor that isrequesting the payment, usually a guard.
    Actor   @akPayerArrestee: The Actor that is going to pay the bounty.
    string  @asBountyPaymentScenario: Whether the payer will pay the bounty on the spot, be escorted willingly or restrained and escorted forcefully
/;
function StartBountyPayment(Actor akGuard, Actor akPayerArrestee, string asBountyPaymentScenario)
    akGuard.SendModEvent("RPB_PayBounty", asBountyPaymentScenario, akPayerArrestee.GetFormID())
endFunction

; ==========================================================
;                       Arrest-Specific

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

        ; SceneManager.StartArrestStart01(captor, arrestee)
        SceneManager.StartArrestScene( \
            akGuard     = captor, \
            akArrestee  = arrestee, \
            asScene     = self.GetArrestScene(arrestee) \
        )

        ; Reset Arrest scene for future arrests
        self.SetArrestScene(arrestee, SceneManager.SCENE_ARREST_START_02)
    endif
    
    self.UpdateArrestStats()
    self.SetAsArrested(arrestee, arrestFaction)
    self.SetArrestGoal(arrestee, ARREST_GOAL_IMPRISONMENT)
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

function PunishPaymentEvader(Actor akGuard, Actor akPayerArrestee)
    Debug(self, "Arrest::PunishPaymentEvader", "You have strayed too far from the path, punishment is upon you!")

    int evadingPenalty = 2000
    Faction crimeFaction = akGuard.GetCrimeFaction()
    string hold = crimeFaction.GetName()

    ; Revert Bounty
    self.RevertBounty(akGuard.GetCrimeFaction())
    crimeFaction.ModCrimeGold(evadingPenalty)

    CaptorRef.AssignArrestee(none)
    BindAliasTo(CaptorRef, none)
    akGuard.StartCombat(akPayerArrestee)

    ; Reset Bounty Payment vars
    self.SetActorWantsToPayBounty(akPayerArrestee, false)
    self.SetArrestGoal(akPayerArrestee, ARREST_GOAL_IMPRISONMENT)

    Config.NotifyArrest("You have gained " + evadingPenalty + " bounty in " + hold + " for evading bounty payment!")
endFunction

function ChangeArrestEscort(Actor akNewEscort, Actor akDetainee)
    ; A new guard was found, escort Detainee to jail
    ArrestVars.SetReference("Arrest::Arresting Guard", akNewEscort) ; Change the captor for further scenes and to lead to the cell
    BindAliasTo(CaptorRef, akNewEscort)
    sceneManager.StartEscortToJail(akNewEscort, ArrestVars.Arrestee, ArrestVars.PrisonerItemsContainer)
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

        ; Keep track of the arrestee for this Captor (Later a captor should be able to have more than one Arrestee, when handling escorting multiple Actors)
        CaptorRef.AssignArrestee(akArrestee) 
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

bool function HasActiveBounty(Faction akCrimeFaction)
    return akCrimeFaction.GetCrimeGold() > 0
endFunction

bool function HasLatentBounty()
    return ArrestVars.Bounty > 0
endFunction

bool function MeetsPursuitEludeRequirements(Actor akEluder)
    return akEluder.IsRunning() || akEluder.IsSprinting()
endFunction

bool function HasResistedArrestRecently(Faction akArrestFaction)
    return ArrestVars.GetBool("Arrest::" + akArrestFaction.GetName() + "::Arrest Resisted")
endFunction

bool function HasEludedArrestRecently(Faction akArrestFaction)
    return ArrestVars.GetBool("Arrest::" + akArrestFaction.GetName() + "::Arrest Eluded")
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

function AddBountyGainedWhileJailed(Faction akArrestFaction)
    ArrestVars.ModInt("Jail::Bounty Non-Violent", akArrestFaction.GetCrimeGoldNonViolent())
    ArrestVars.ModInt("Jail::Bounty Violent", akArrestFaction.GetCrimeGoldViolent())
    ClearBounty(akArrestFaction)
endFunction

function SetActorWantsToPayBounty(Actor akPayerArrestee, bool abWantsToPay = true)
    ArrestVars.SetBool("Arrest::Paying Bounty" , abWantsToPay)
    Debug(self, "Arrest::SetActorWantsToPayBounty", "Arrest::Paying Bounty: " + ArrestVars.GetBool("Arrest::Paying Bounty"))
endFunction

bool function GetActorIsPayingBounty(Actor akPayerArrestee)
    return ArrestVars.GetBool("Arrest::Paying Bounty")
endFunction

string function GetArrestScene(Actor akArrestee, string asFallbackScene = "RPB_ArrestStart02")
    if (akArrestee == Config.Player)

        if (ArrestVars.Exists("Arrest::Scene"))
            return ArrestVars.GetString("Arrest::Scene")
        endif

        return asFallbackScene
    endif
endFunction

string function GetArrestGoal(Actor akArrestee)
    return ArrestVars.GetString("Arrest::Arrest Goal")
endFunction

bool function IsActorToBeImprisoned(Actor akArrestee)
    return self.GetArrestGoal(akArrestee) == ARREST_GOAL_IMPRISONMENT
endFunction

bool function IsActorToPayBounty(Actor akArrestee)
    return self.GetArrestGoal(akArrestee) == ARREST_GOAL_BOUNTY_PAYMENT
endFunction

function PayCrimeGold(Actor akPayer, Faction akCrimeFaction)
    if (akPayer == Config.Player) ; Later this should be dynamic for all Actors without a condition
        int currentBountyNonViolent = ArrestVars.GetInt("Arrest::Bounty Non-Violent")
        int currentBountyViolent    = ArrestVars.GetInt("Arrest::Bounty Violent")
        int totalBounty = currentBountyNonViolent + currentBountyViolent
        Form gold = Game.GetFormEx(0xF)
        akPayer.RemoveItem(gold, totalBounty, true)

        ; Clear Bounty
        ArrestVars.Remove("Arrest::Bounty Non-Violent")
        ArrestVars.Remove("Arrest::Bounty Violent")
        akCrimeFaction.PlayerPayCrimeGold(false, false)

        Config.NotifyArrest("Your bounty in " + akCrimeFaction.GetName() + " has been paid")
    endif
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

function ResetArrestVars(Actor akArrestee)
    Debug(self, "Arrest::ResetArrestVars", "Resetting Arrest Variables for " + akArrestee)

    if (akArrestee == Config.Player) ; Should be dynamic later for all Actors
        ArrestVars.Remove("Arrest::Arrest Faction")
        ArrestVars.Remove("Arrest::Arrest Scene")
        ArrestVars.Remove("Arrest::Arrest Type")
        ArrestVars.Remove("Arrest::Arrested")
        ArrestVars.Remove("Arrest::Arrestee")
        ArrestVars.Remove("Arrest::Arresting Guard")
        ArrestVars.Remove("Arrest::Captured")
        ArrestVars.Remove("Arrest::Hold")
        ArrestVars.Remove("Arrest::Scenario")
        ArrestVars.Remove("Arrest::Time of Arrest")

    else
        ArrestVars.RemoveForActor(akArrestee, "Arrest::Arrest Faction")
        ArrestVars.RemoveForActor(akArrestee, "Arrest::Arrest Scene")
        ArrestVars.RemoveForActor(akArrestee, "Arrest::Arrest Type")
        ArrestVars.RemoveForActor(akArrestee, "Arrest::Arrested")
        ArrestVars.RemoveForActor(akArrestee, "Arrest::Arrestee")
        ArrestVars.RemoveForActor(akArrestee, "Arrest::Arresting Guard")
        ArrestVars.RemoveForActor(akArrestee, "Arrest::Captured")
        ArrestVars.RemoveForActor(akArrestee, "Arrest::Hold")
        ArrestVars.RemoveForActor(akArrestee, "Arrest::Scenario")
        ArrestVars.RemoveForActor(akArrestee, "Arrest::Time of Arrest")
    endif
endFunction

function ResetArrest(string reason = "")
    ; Clear all arrest related vars
    ArrestVars.Clear()
    Info(self, "ResetArrest", reason, reason != "")
endFunction

; ==========================================================
;                           Utility

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

function UnrestrainArrestee(Actor akRestrainedArrestee)
    Form restraints = akRestrainedArrestee.GetEquippedArmorInSlot(59)
    akRestrainedArrestee.UnequipItemSlot(59)
    akRestrainedArrestee.RemoveItem(restraints)
    ReleaseAI()
endFunction

function HideBounty(Faction akCrimeFaction)
    int nonViolent = akCrimeFaction.GetCrimeGold()
    int violent    = akCrimeFaction.GetCrimeGoldViolent()

    if (self.HasLatentBounty())
        ; Add active bounty to latent
        ArrestVars.ModInt("Arrest::Bounty Non-Violent", nonViolent)
        ArrestVars.ModInt("Arrest::Bounty Violent", violent)
    else
        ; No latent bounty, transfer the active bounty
        ArrestVars.SetInt("Arrest::Bounty Non-Violent", nonViolent)
        ArrestVars.SetInt("Arrest::Bounty Violent", violent)
    endif

    akCrimeFaction.SetCrimeGold(0)
    akCrimeFaction.SetCrimeGoldViolent(0)
endFunction

function RevertBounty(Faction akCrimeFaction)
    int nonViolent = ArrestVars.GetInt("Arrest::Bounty Non-Violent")
    int violent    = ArrestVars.GetInt("Arrest::Bounty Violent")

    if (akCrimeFaction.GetCrimeGold() > 0)
        ; Add latent bounty to active
        akCrimeFaction.ModCrimeGold(nonViolent)
        akCrimeFaction.ModCrimeGold(violent, true)
    else
        ; No active bounty, transfer the latent bounty
        akCrimeFaction.SetCrimeGold(nonViolent)
        akCrimeFaction.SetCrimeGoldViolent(violent)
    endif

    ArrestVars.Remove("Arrest::Bounty Non-Violent")
    ArrestVars.Remove("Arrest::Bounty Violent")
endFunction

; ==========================================================
;                  Validation & Maintenance

function RegisterHotkeys()
    RegisterForKey(0x58) ; F12
    RegisterForKey(0x57) ; F11
    RegisterForKey(0x44) ; F10
    RegisterForKey(0x42) ; F8
    RegisterForKey(0x41) ; F7
    RegisterForKey(0x40) ; F6
endFunction

function AllowArrestForcegreets(bool allow = true)
    ; Allow/Disallow Forcegreets (used in AI package RPB_DGForcegreet for Arrest eludes)
    RPB_AllowArrestForcegreet.SetValueInt(int_if (allow, 1, 0))
endFunction

function SetupArrestPayableBountyVars(Faction akCrimeFaction)
    GlobalVariable RPB_ArrestGuaranteedPayableBounty = GetFormFromMod(0x161D2) as GlobalVariable
    GlobalVariable RPB_ArrestMaxPayableBounty        = GetFormFromMod(0x161D4) as GlobalVariable
    GlobalVariable RPB_ArrestRollDiceResult          = GetFormFromMod(0x16737) as GlobalVariable
    GlobalVariable RPB_ArrestAllowFrisk              = GetFormFromMod(0x1776A) as GlobalVariable
    
    string hold = akCrimeFaction.GetName()

    ; Update Globals (Determines if the arrest will be payable for sure, or if it falls within the maximum payable, which needs a roll of the dice)
    RPB_ArrestGuaranteedPayableBounty.SetValueInt(Config.GetArrestGuaranteedPayableBounty(hold))
    RPB_ArrestMaxPayableBounty.SetValueInt(Config.GetArrestMaximumPayableBounty(hold))
    RPB_ArrestAllowFrisk.SetValueInt(Config.IsFriskingEnabled(hold) as int)

    ; Roll the dice for max payable bounty chance
    int maxPayableChance = Config.GetArrestMaximumPayableChance(hold)
    int random = Utility.RandomInt(1, 100)
    RPB_ArrestRollDiceResult.SetValueInt(int_if (random <= maxPayableChance, 1, 0)) ; 1 = able to pay max bounty / 0 = not able
    Debug(self, "Arrest::SetupArrestPayableBountyVars", "Needed: <= " + maxPayableChance + ", Got: " + random)

    Trace(self, "Arrest::SetupArrestPayableBountyVars", "Stack Trace: [\n" + \
        "\tRPB_ArrestGuaranteedPayableBounty: " + RPB_ArrestGuaranteedPayableBounty.GetValueInt() + "\n" + \
        "\tRPB_ArrestMaxPayableBounty: " + RPB_ArrestMaxPayableBounty.GetValueInt() + "\n" + \
        "\tRPB_ArrestRollDiceResult: " + RPB_ArrestRollDiceResult.GetValueInt() + "\n" + \
        "\tmaxPayableChance: " + maxPayableChance + "\n" + \
        "\trandom: " + random + "\n" + \
        "\tAble to Pay Max Bounty: " + (random <= maxPayableChance) + "\n" + \
        "\takCrimeFaction: " + akCrimeFaction + "\n" + \
    "\n]")
endFunction

function ResetDiceRollForMaxPayableBounty()
    GlobalVariable RPB_ArrestRollDiceResult = GetFormFromMod(0x16737) as GlobalVariable
    RPB_ArrestRollDiceResult.SetValueInt(0)
endFunction

bool function IsValidArrestGoal(string asArrestGoal)
    return  asArrestGoal == ARREST_GOAL_IMPRISONMENT || \
            asArrestGoal == ARREST_GOAL_BOUNTY_PAYMENT || \
            asArrestGoal == ARREST_GOAL_TEMPORARY_HOLD
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

scriptname RealisticPrisonAndBounty_Arrest extends Quest

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config
import PO3_SKSEFunctions

string property STATE_RESISTED = "Resisted" autoreadonly
string property STATE_ARRESTED = "Arrested" autoreadonly
string property STATE_SURRENDER = "Surrender" autoreadonly

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
        return Game.GetFormFromFile(0x3DF8, GetPluginName()) as RealisticPrisonAndBounty_Jail
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property arrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return config.arrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property miscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return config.miscVars
    endFunction
endProperty

ReferenceAlias property CaptorRef auto

function RegisterEvents()
    RegisterForModEvent("RPB_ArrestBegin", "OnArrestBegin")
    RegisterForModEvent("RPB_ArrestEnd", "OnArrestEnd")
    RegisterForModEvent("RPB_ResistArrest", "OnArrestResist")
    Debug(self, "Arrest::RegisterEvents", "Registered Arrest Events")
endFunction

function RegisterHotkeys()
    RegisterForKey(0x58) ; F12
    RegisterForKey(0x57) ; F11
    RegisterForKey(0x44) ; F10
    RegisterForKey(0x42) ; F8
    RegisterForKey(0x41) ; F7
    RegisterForKey(0x40) ; F6
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
        crimeFaction.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_TELEPORT_TO_CELL)
    
    elseif (keyCode == 0x44) ; F10
        self.TriggerSurrender()
    endif
endEvent

function PlaySurrenderAnimation(Actor akActorSurrendering)
    Debug.SendAnimationEvent(akActorSurrendering, "IdleSurrender")
endFunction

bool function HasResistedArrest(string hold)
    return arrestVars.GetBool("Arrest::" + hold + "::Arrest Resisted")
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
            arrestVars.SetBool(arrestResistKey, false)
            Info(self, "Arrest::ResetResistedFlag", "The resist arrest flag for " + hold +" has been reset.")
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
    GotoState(STATE_RESISTED)
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

    GotoState(STATE_ARRESTED)
endFunction

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
    event OnBeginState()
        Debug(self, "Arrest::OnBeginState", "Begin State " + self.GetState(), config.IS_DEBUG)
        RegisterForSingleUpdateGameTime(1.0)
    endEvent

    event OnUpdateGameTime()
        GotoState("")
    endEvent

    event OnEndState()
        Debug(self, "Arrest::OnEndState", "End State " + self.GetState(), config.IS_DEBUG)
        self.ResetResistedFlag()
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

event OnArrestBegin(string eventName, string arrestType, float arresteeId, Form sender)
    Actor captor            = (sender as Actor)
    Faction crimeFaction    = form_if ((sender as Faction), (sender as Faction), captor.GetCrimeFaction()) as Faction 

    if (!self.ValidateArrestType(arrestType))
        Error(self, "Arrest::OnArrestBegin", "Arrest Type is invalid, got: " + arrestType + ". (valid options: "+ self.GetValidArrestTypes() +") ")
        return
    endif

    if (!captor && !crimeFaction)
        Error(self, "Arrest::OnArrestBegin", "Captor or Faction are invalid ["+ "Captor: "+ captor + ", Faction: " + crimeFaction +"], cannot start arrest process!")
        return
    endif

    ; If no arresteeId passed in, arrest the player by default
    Actor arrestee = Game.GetFormEx(int_if (!arresteeId, 0x14, arresteeId as int)) as Actor

    if (!arrestee)
        Error(self, "OnArrestBegin", "Arrestee not found for this arrest, aborting!")
        return
    endif

    if (arrestVars.IsArrested)
        config.NotifyArrest("You are already arrested")
        Error(self, "Arrest::OnArrestBegin", arrestee.GetBaseObject().GetName() + " is already arrested, cannot arrest for "+ crimeFaction.GetName() +", aborting!")
        return
    endif

    if (!self.HasLatentBounty() && !self.HasActiveBounty(crimeFaction))
        config.NotifyArrest("You can't be arrested in " + crimeFaction.GetName() + " since you do not have a bounty in the hold")
        Error(self, "OnArrestBegin", arrestee.GetBaseObject().GetName() + " has no bounty, cannot arrest for "+ crimeFaction.GetName() +", aborting!")
        return
    endif

    if (captor)
        CaptorRef.ForceRefTo(captor)
        arrestVars.SetForm("Arrest::Arresting Guard", captor)
        Debug(self, "OnArrestBegin", "Arrest is being done through a captor ("+ captor +")")
    endif

    arrestVars.SetForm("Arrest::Arrest Faction", crimeFaction)
    arrestVars.SetString("Arrest::Hold", crimeFaction.GetName())
    arrestVars.SetForm("Arrest::Arrestee", arrestee)
    arrestVars.SetString("Arrest::Arrest Type", arrestType)

    self.BeginArrest()
endEvent

event OnArrestResist(string eventName, string unusedStr, float arrestResisterId, Form sender)
    Actor guard            = (sender as Actor)
    Faction crimeFaction   = form_if ((sender as Faction), (sender as Faction), guard.GetCrimeFaction()) as Faction

    if (!guard && !crimeFaction)
        Error(self, "Arrest::OnArrestResist", "Guard or Faction are invalid ["+ "Guard: "+ guard + ", Faction: " + crimeFaction +"], cannot start arrest process!")
        return
    endif

    ; Not the player
    if ((arrestResisterId as int) != 0x14)
        Error(self, "Arrest::OnArrestResist", "Someone other than the player ("+ Game.GetFormEx(arrestResisterId as int) +") has resisted arrest (how?), returning...")
        return
    endif

    guard.SetPlayerResistingArrest() ; Needed to make the guards attack the player, otherwise they will loop arrest dialogue

    bool hasResistedArrestRecentlyInThisHold = arrestVars.GetBool("Arrest::" + crimeFaction.GetName() + "::Arrest Resisted")

    if (hasResistedArrestRecentlyInThisHold)
        Info(self, "Arrest::OnArrestResist", "You have already resisted arrest recently, no bounty will be added as it most likely is the same arrest.")
        return
    endif

    self.TriggerResistArrest(guard, crimeFaction)
endEvent

function BeginArrest()
    string hold             = arrestVars.Hold
    string arrestType       = arrestVars.ArrestType
    Faction arrestFaction   = arrestVars.ArrestFaction
    Actor arrestee          = arrestVars.Arrestee
    Actor captor            = arrestVars.Captor ; May be undefined if the arrest is not done through a captor

    self.SetBounty()

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
    
    ; Could be used when the arrestee still has a chance to pay their bounty, and not go to the cell immediately
    elseif (arrestType == ARREST_TYPE_TELEPORT_TO_JAIL) ; Not implemented yet (Idea: Arrestee will be teleported to some location in jail and then either escorted or teleported to the cell)
        ; jail.StartTeleportToJail()
    
    ; Will most likely be used when the arrestee has no chance to pay their bounty, and therefore will get immediately escorted into the cell
    elseif (arrestType == ARREST_TYPE_ESCORT_TO_CELL) ; Not implemented yet (Idea: Arrestee will be escorted directly to the cell)
        arrestVars.SetReference("Jail::Cell Door", GetNearestJailDoorOfType(GetJailBaseDoorID(arrestVars.Hold), arrestVars.JailCell, 10000))
        jail.StartEscortToCell()

    elseif (arrestType == ARREST_TYPE_ESCORT_TO_JAIL) ; Not implemented yet (Idea: Arrestee will be escorted to the jail, and then processed before being escorted into the cell)
        ; jail.StartEscortToJail()
    endif

    SendModEvent("RPB_JailBegin")
    
    self.UpdateArrestStats()
    self.SetAsArrested(arrestee, arrestFaction)

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

function SetAsDefeated(Faction akCrimeFaction)
    if (!self.HasResistedArrest(akCrimeFaction.GetName()))
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

function TriggerResistArrest(Actor akGuard, Faction akCrimeFaction)
    string hold = akCrimeFaction.GetName()

    int resistBountyFlat                    = config.GetArrestAdditionalBountyResistingFlat(hold)
    float resistBountyFromCurrentBounty     = config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold)
    float resistBountyPercentModifier       = GetPercentAsDecimal(resistBountyFromCurrentBounty)
    int resistArrestPenalty                 = floor(akCrimeFaction.GetCrimeGold() * resistBountyPercentModifier) + resistBountyFlat

    if (resistArrestPenalty > 0)
        akCrimeFaction.ModCrimeGold(resistArrestPenalty)
        config.NotifyArrest("You have gained " + resistArrestPenalty + " Bounty in " + hold +" for resisting arrest!")
    endif

    self.SetResistedFlag(akCrimeFaction)
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

    if (arrestVars.HasOverride("Arrest::Bounty Non-Violent"))
        Debug(self, "SetBounty", "\n" + \
            "(Overriden) Arrest::Bounty Non-Violent: " + arrestVars.BountyNonViolent + "\n" \
        )
    endif

    if (arrestVars.HasOverride("Arrest::Bounty Non-Violent"))
        Debug(self, "SetBounty", "\n" + \
            "(Overriden) Arrest::Bounty Violent: " + arrestVars.BountyViolent + "\n" \
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

        config.SetStat(hold, "Current Bounty", bounty)
        int currentLargestBounty = config.GetStat(hold, "Largest Bounty")
        config.SetStat(hold, "Largest Bounty", int_if (currentLargestBounty < bounty, bounty, currentLargestBounty))
        config.IncrementStat(hold, "Total Bounty", bounty)
        config.IncrementStat(hold, "Times Arrested")

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
    akArrestee.EquipItem(cuffs, true, true)
endFunction

; scriptname RealisticPrisonAndBounty_Arrest extends Quest

; import Math
; import RealisticPrisonAndBounty_Util
; import RealisticPrisonAndBounty_Config
; import PO3_SKSEFunctions

; RealisticPrisonAndBounty_Config property config
;     RealisticPrisonAndBounty_Config function get()
;         return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
;     endFunction
; endProperty

; RealisticPrisonAndBounty_Jail property jail
;     RealisticPrisonAndBounty_Jail function get()
;         return Game.GetFormFromFile(0x3DF8, GetPluginName()) as RealisticPrisonAndBounty_Jail
;     endFunction
; endProperty

; RealisticPrisonAndBounty_ArrestVars property arrestVars
;     RealisticPrisonAndBounty_ArrestVars function get()
;         return config.arrestVars
;     endFunction
; endProperty

; RealisticPrisonAndBounty_ActorVars property actorVars
;     RealisticPrisonAndBounty_ActorVars function get()
;         return config.actorVars
;     endFunction
; endProperty

; string property STATE_ARRESTED = "Arrested" autoreadonly

; string property ARREST_TYPE_TELEPORT_TO_JAIL    = "TeleportToJail" autoreadonly
; string property ARREST_TYPE_TELEPORT_TO_CELL    = "TeleportToCell" autoreadonly
; string property ARREST_TYPE_ESCORT_TO_JAIL      = "EscortToJail" autoreadonly
; string property ARREST_TYPE_ESCORT_TO_CELL      = "EscortToCell" autoreadonly

; ReferenceAlias property CaptorRef auto

; function RegisterEvents()
;     RegisterForModEvent("ArrestBegin", "OnArrestBegin")
;     RegisterForModEvent("ArrestEnd", "OnArrestEnd")
;     RegisterForModEvent("RPB_ResistArrest", "OnArrestResist")
;     Debug(self, "RegisterEvents", "Registered Events")
; endFunction

; event OnInit()
;     RegisterEvents()
;     RegisterForKey(0x58) ; F12
;     RegisterForKey(0x57) ; F11
;     RegisterForKey(0x44) ; F10
;     RegisterForKey(0x42) ; F8
;     RegisterForKey(0x41) ; F7
;     RegisterForKey(0x40) ; F6
; endEvent

; event OnPlayerLoadGame()
;     RegisterEvents()
;     RegisterForKey(0x58) ; F12
;     RegisterForKey(0x57) ; F11
;     RegisterForKey(0x44) ; F10
;     RegisterForKey(0x42) ; F8
;     RegisterForKey(0x41) ; F7
;     RegisterForKey(0x40) ; F6
; endEvent

; event OnKeyDown(int keyCode)
;     if (keyCode == 0x58)
;         string currentHold = config.GetCurrentPlayerHoldLocation()
;         arrestVars.SetForm("Arrest::Arrest Faction", config.GetFaction(currentHold))
;         Actor arrestee = Game.GetCurrentConsoleRef() as Actor
;         arrestVars.ArrestFaction.SendModEvent("ArrestBegin", "TeleportToCell", arrestee.GetFormID())

;     elseif (keyCode == 0x57)
;         Game.QuitToMainMenu()

;     elseif (keyCode == 0x44 || keyCode == 0x42 || keyCode == 0x41 || keyCode == 0x40) ; Surrender (Testing)
;         self.TriggerSurrender()
;     endif
; endEvent

; event OnArrestResist(string eventName, string unusedStr, float arrestResisterId, Form sender)
;     Actor guard            = (sender as Actor)
;     Faction crimeFaction    = form_if ((sender as Faction), (sender as Faction), guard.GetCrimeFaction()) as Faction

;     if (!guard && !crimeFaction)
;         Error(self, "Arrest::OnArrestResist", "Guard or Faction are invalid ["+ "Guard: "+ guard + ", Faction: " + crimeFaction +"], cannot start arrest process!")
;         return
;     endif

;     ; Not the player
;     if ((arrestResisterId as int) != 0x14)
;         Error(self, "Arrest::OnArrestResist", "Someone other than the player ("+ Game.GetFormEx(arrestResisterId as int) +") has resisted arrest (how?), returning...")
;         return
;     endif

;     guard.SetPlayerResistingArrest() ; Needed to make the guards attack the player, otherwise they will loop arrest dialogue

;     bool hasResistedArrestRecentlyInThisHold = arrestVars.GetBool("Arrest::" + crimeFaction.GetName() + "::Arrest Resisted")

;     if (hasResistedArrestRecentlyInThisHold)
;         Info(self, "Arrest::OnArrestResist", "You have already resisted arrest recently, no bounty will be added as it most likely is the same arrest.")
;         return
;     endif

;     self.TriggerResistArrest(guard, crimeFaction)
; endEvent

; event OnUpdateGameTime()
;     int i = 0
;     while (i < config.Holds.Length)
;         ; Set arrest resist to false on all holds, enough time has passed to reset it
;         string hold = config.Holds[i]
;         arrestVars.SetBool("Arrest::"+ hold +"::Arrest Resisted", false)
;     endWhile
;     Debug(self, "Arrest::OnUpdateGameTime", "Lets see how many times this gets called")
; endEvent

; event OnArrestBegin(string eventName, string arrestType, float arresteeId, Form sender)
;     Actor captor            = (sender as Actor)
;     Faction crimeFaction    = form_if ((sender as Faction), (sender as Faction), captor.GetCrimeFaction()) as Faction

;     if (!self.ValidateArrestType(arrestType))
;         Error(self, "Arrest::OnArrestBegin", "Arrest Type is invalid, got: " + arrestType + ". (valid options: "+ self.GetValidArrestTypes() +") ")
;         return
;     endif

;     if (!captor && !crimeFaction)
;         Error(self, "OnArrestBegin", "Captor or Faction are invalid ["+ "Captor: "+ captor + ", Faction: " + crimeFaction +"], cannot start arrest process!")
;         return
;     endif

;     if (arrestVars.Arrestee == config.Player && arrestVars.IsArrested)
;         self.UpdateArrest()
;         return
;     endif

;     Actor arresteeRef = Game.GetForm(arresteeId as int) as Actor

;     if (!arresteeRef)
;         Error(self, "OnArrestBegin", "Arrestee not found for this arrest, aborting!")
;         return
;     endif

;     bool isJailUnconditional = config.IsJailUnconditional(crimeFaction.GetName())
;     if (!self.HasLatentBounty() && !self.HasActiveBounty(crimeFaction) && !isJailUnconditional)
;         Error(self, "OnArrestBegin", arresteeRef.GetBaseObject().GetName() + " has no bounty, cannot arrest for "+ crimeFaction.GetName() +", aborting!")
;         return
;     endif

;     if (captor)
;         CaptorRef.ForceRefTo(captor)
;         arrestVars.SetForm("Arrest::Arresting Guard", captor)
;         Debug(self, "OnArrestBegin", "Arrest is being done through a captor")

;     elseif (crimeFaction)
;         Debug(self, "OnArrestBegin", "Arrest is being done through a faction directly")
;     endif

;     arrestVars.SetForm("Arrest::Arrest Faction", crimeFaction)
;     arrestVars.SetString("Arrest::Hold", crimeFaction.GetName())
;     arrestVars.SetForm("Arrest::Arrestee", arresteeRef)
;     arrestVars.SetString("Arrest::Arrest Type", arrestType)

;     self.BeginArrest()
; endEvent

; event OnEscortToJailBegin()

; endEvent

; event OnEscortToJailEnd()
    
; endEvent

; event OnArrestEnd(string eventName, string strArg, float numArg, Form sender)
;     Debug(self, "OnArrestEnd", "Ending arrest process for Actor: ")
;     arrestVars.SetBool("Arrest::Arrested", false)
; endEvent

; state Arrested
;     event OnArrestBegin(string eventName, string unusedStr, float arresteeRefId, Form sender)
;         if (arrestVars.IsArrested && arrestVars.Arrestee == config.Player)
;             self.UpdateArrest()
;             return
;         endif
        
;         Error(self, "OnArrestBegin", "Actor is already in the Arrested state, aborting call!")
;     endEvent

;     event OnEscortToJailBegin()
;         ; Begin escort to jail after being arrested
;     endEvent
    
;     event OnEscortToJailEnd()
;         ; if (ShouldBeImprisoned)
;         ;     jail.OnEscortToJailEnd()
;         ; endif
;     endEvent
; endState

; function BeginArrest()
;     string hold             = arrestVars.Hold
;     string arrestType       = arrestVars.ArrestType
;     Faction arrestFaction   = arrestVars.ArrestFaction
;     Actor arrestee          = arrestVars.Arrestee
;     Actor captor            = arrestVars.Captor ; May be undefined if the arrest is not done through a captor
                      
;     self.SetBounty()
;     bool assignedJailCellSuccessfully = jail.AssignJailCell(arrestee) ; Not guaranteed to go to jail, but we set it up here either way
    
;     if (!assignedJailCellSuccessfully)
;         arrestVars.Clear()
;         Error(self, "BeginArrest", "Could not assign a jail cell to " + arrestee + ". (Aborting arrest...)")
;         return
;     endif

;     int bountyNonViolent        = arrestVars.BountyNonViolent
;     int bountyViolent           = arrestVars.BountyViolent
;     int bounty                  = bountyNonViolent + bountyViolent
;     ObjectReference jailCell    = arrestVars.JailCell

;     arrestVars.SetBool("Arrest::Arrested", true)
;     arrestVars.SetFloat("Arrest::Time of Arrest", Utility.GetCurrentGameTime())

;     arrestee.StopCombat()
;     arrestee.StopCombatAlarm()

;     SendModEvent("JailBegin")

;     ; Will most likely be used when the arrestee has no chance to pay their bounty, and therefore will get immediately thrown into the cell
;     if (arrestType == ARREST_TYPE_TELEPORT_TO_CELL)
;         jail.StartTeleportToCell()
    
;     ; Could be used when the arrestee still has a chance to pay their bounty, and not go to the cell immediately
;     elseif (arrestType == ARREST_TYPE_TELEPORT_TO_JAIL) ; Not implemented yet (Idea: Arrestee will be teleported to some location in jail and then either escorted or teleported to the cell)
;         ; jail.StartTeleportToJail()
    
;     ; Will most likely be used when the arrestee has no chance to pay their bounty, and therefore will get immediately escorted into the cell
;     elseif (arrestType == ARREST_TYPE_ESCORT_TO_CELL) ; Not implemented yet (Idea: Arrestee will be escorted directly to the cell)
;         jail.StartEscortToCell()

;     elseif (arrestType == ARREST_TYPE_ESCORT_TO_JAIL) ; Not implemented yet (Idea: Arrestee will be escorted to the jail, and then processed before being escorted into the cell)
;         ; jail.StartEscortToJail()
;     endif

;     self.UpdateArrestStats()

;     config.NotifyArrest("You have been arrested in " + hold)
;     GotoState(STATE_ARRESTED)
; endFunction

; function TriggerResistArrest(Actor akGuard, Faction akCrimeFaction)
;     string hold = akCrimeFaction.GetName()

;     int resistBountyFlat                    = config.GetArrestAdditionalBountyResistingFlat(hold)
;     float resistBountyFromCurrentBounty     = config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold)
;     float resistBountyPercentModifier       = GetPercentAsDecimal(resistBountyFromCurrentBounty)
;     int resistArrestPenalty                 = floor(akCrimeFaction.GetCrimeGold() * resistBountyPercentModifier) + resistBountyFlat

;     akCrimeFaction.ModCrimeGold(resistArrestPenalty)
;     config.NotifyArrest("You have gained " + resistArrestPenalty + " Bounty in " + hold +" for resisting arrest!")

;     arrestVars.SetBool("Arrest::"+ hold +"::Arrest Resisted", true) ; Set arrest resisted flag
;     RegisterForSingleUpdateGameTime(1.0)
; endFunction

; function TriggerSurrender()
;     string currentHold = config.GetCurrentPlayerHoldLocation()
;     Faction currentHoldFaction = config.GetFaction(currentHold)
;     Actor arresteeRef = config.Player

;     if (arrestVars.IsArrested)
;         config.NotifyArrest("You are already arrested")
;         Error(self, "Arrest::OnArrestBegin", arresteeRef.GetBaseObject().GetName() + " is already arrested, cannot arrest for "+ currentHoldFaction.GetName() +", aborting!")
;         return
;     endif

;     bool isJailUnconditional = config.IsJailUnconditional(currentHold)

;     Debug(self, "Arrest::TriggerSurrender", "\n" + \
;         "arresteeRef: " + arresteeRef + "\n" + \
;         "currentHold: " + currentHold + "\n" + \
;         "currentHoldFaction: " + currentHoldFaction + "\n" + \
;         "Has Latent Bounty: " + self.HasLatentBounty() + "\n" + \
;         "Has Active Bounty: " + self.HasActiveBounty(currentHoldFaction) + "\n" + \
;         "Unconditional Imprisonment: " + isJailUnconditional + "\n" + \
;         "Latent Bounty: " + arrestVars.Bounty + "\n" + \
;         "Active Bounty: " + currentHoldFaction.GetCrimeGold() + "\n" \
;     )

;     if (!self.HasLatentBounty() && !self.HasActiveBounty(currentHoldFaction) && !isJailUnconditional)
;         config.NotifyArrest("You can't be arrested in " + currentHold + " since you have no bounty in this hold")
;         Error(self, "Arrest::OnArrestBegin", arresteeRef.GetBaseObject().GetName() + " has no bounty, cannot arrest for "+ currentHoldFaction.GetName() +", aborting!")
;         return
;     endif

;     if (!self.MeetsBountyRequirements(currentHoldFaction) && !isJailUnconditional)
;         config.NotifyArrest("You can't be arrested in " + currentHold + " since you do not have enough bounty in this hold")
;         Error(self, "Arrest::OnArrestBegin", arresteeRef.GetBaseObject().GetName() + " does not have enough bounty, cannot arrest for "+ currentHoldFaction.GetName() +", aborting!")
;         return
;     endif

;     config.NotifyArrest("You have surrendered to the guards in " + currentHold)

;     self.RestrainArrestee(arresteeRef)
;     ; Utility.Wait(2.0)

;     arrestVars.SetInt("Arrest::Bounty Non-Violent", currentHoldFaction.GetCrimeGoldNonViolent())
;     arrestVars.SetInt("Arrest::Bounty Violent", currentHoldFaction.GetCrimeGoldViolent())

;     ClearBounty(currentHoldFaction)

;     config.Player.StopCombat()
;     config.Player.StopCombatAlarm()

;     currentHoldFaction.SendModEvent("ArrestBegin", "TeleportToCell", arresteeRef.GetFormID())
; endFunction

; function RestrainArrestee(Actor akArrestee)
;     ; Hand Cuffs Backside Rusty - 0xA081D2F
;     ; Hand Cuffs Front Rusty - 0xA081D33
;     ; Hand Cuffs Front Shiny - 0xA081D34
;     ; Hand Cuffs Crossed Front 01 - 0xA033D9D
;     ; Hands Crossed Front in Scarfs - 0xA073A14
;     ; Hands in Irons Front Black - 0xA033D9E
;     Form cuffs = Game.GetFormEx(0xA081D2F)
;     akArrestee.EquipItem(cuffs, true, true)
; endFunction

; function UpdateArrest()
;     ; Already arrested, we dont want to proceed, this probably happened with 0 bounty,
;     ; but in case it didn't, update the bounty to the sentence
;     if (arrestVars.IsJailed && jail.Prisoner.HasActiveBounty())
;         jail.Prisoner.UpdateSentenceFromCurrentBounty()
;     endif

;     ClearBounty(arrestVars.ArrestFaction)

;     bool isArresteeInsideCell = IsActorNearReference(arrestVars.Arrestee, arrestVars.JailCell)
    
;     if (arrestVars.IsJailed && !isArresteeInsideCell)
;         ; Possibly have an event to escort the prisoner to the cell
;         ; OnEscortToCellBegin()
;         jail.MovePrisonerToCell()
;     endif

;     Debug(self, "UpdateArrest", "\n" + \
;         "Arrested: " + arrestVars.IsArrested + "\n" + \
;         "Jailed: " + arrestVars.IsJailed + "\n" + \
;         "Has Active Bounty: " + jail.Prisoner.HasActiveBounty() + "\n" + \
;         "Is Inside Jail Cell: " + isArresteeInsideCell + "\n" \
;     )
; endFunction

; bool function HasLatentBounty()
;     return arrestVars.Bounty > 0
; endFunction

; bool function HasActiveBounty(Faction akCrimeFaction)
;     return akCrimeFaction.GetCrimeGold() > 0
; endFunction

; bool function MeetsBountyRequirements(Faction akCrimeFaction)
;     int minBountyToArrest = config.GetArrestRequiredBounty(akCrimeFaction.GetName())
;     return akCrimeFaction.GetCrimeGold() >= minBountyToArrest || arrestVars.Bounty >= minBountyToArrest
; endFunction

; function SetBounty()
;     Faction arrestFaction = arrestVars.ArrestFaction

;     if (self.HasLatentBounty())
;         ; Add the "active bounty" if there's any, to the latent bounty
;         arrestVars.ModInt("Arrest::Bounty Non-Violent", arrestFaction.GetCrimeGoldNonViolent())
;         arrestVars.ModInt("Arrest::Bounty Violent", arrestFaction.GetCrimeGoldViolent())
;     else
;         ; Set the bounties to be latent
;         arrestVars.SetFloat("Arrest::Bounty Non-Violent", arrestFaction.GetCrimeGoldNonViolent())
;         arrestVars.SetFloat("Arrest::Bounty Violent", arrestFaction.GetCrimeGoldViolent())
;     endif

;     if (arrestVars.HasOverride("Arrest::Bounty Non-Violent"))
;         Debug(self, "SetBounty", "\n" + \
;             "(Overriden) Arrest::Bounty Non-Violent: " + arrestVars.BountyNonViolent + "\n" \
;         )
;     endif

;     if (arrestVars.HasOverride("Arrest::Bounty Non-Violent"))
;         Debug(self, "SetBounty", "\n" + \
;             "(Overriden) Arrest::Bounty Violent: " + arrestVars.BountyViolent + "\n" \
;         )
;     endif

;     ClearBounty(arrestFaction)
;     arrestFaction.PlayerPayCrimeGold(false, false) ; Just in case?
; endFunction

; function UpdateArrestStats()
;     Actor arrestee  = arrestVars.Arrestee

;     if (arrestee == config.Player)
;         string hold     = arrestVars.Hold
;         int bounty      = arrestVars.Bounty

;         config.SetStat(hold, "Current Bounty", bounty)
;         int currentLargestBounty = config.GetStat(hold, "Largest Bounty")
;         config.SetStat(hold, "Largest Bounty", int_if (currentLargestBounty < bounty, bounty, currentLargestBounty))
;         config.IncrementStat(hold, "Total Bounty", bounty)
;         config.IncrementStat(hold, "Times Arrested")

;     else ; Processing for NPC stats later
;         ; e.g:
;         ; Actor arrestee  = arrestVars.Arrestee
;         ; string hold = arrestVars.GetString("["+ arrestee.GetFormID() +"]Arrest::Hold")
;         ; int bounty  = arrestVars.GetInt("["+ arrestee.GetFormID() +"]Arrest::Bounty")

;         ; actorVars.SetStat(hold, "["+ arrestee.GetFormID() +"]Current Bounty", bounty)
;     endif
; endFunction

; bool function ValidateArrestType(string arrestType)
;     return  arrestType == ARREST_TYPE_TELEPORT_TO_JAIL || \ 
;             arrestType == ARREST_TYPE_TELEPORT_TO_CELL || \ 
;             arrestType == ARREST_TYPE_ESCORT_TO_JAIL || \
;             arrestType == ARREST_TYPE_ESCORT_TO_CELL
; endFunction

; string function GetValidArrestTypes()
;     return  ARREST_TYPE_TELEPORT_TO_JAIL + ", " + \ 
;             ARREST_TYPE_TELEPORT_TO_CELL + ", " + \ 
;             ARREST_TYPE_ESCORT_TO_JAIL + ", " + \ 
;             ARREST_TYPE_ESCORT_TO_CELL
; endFunction
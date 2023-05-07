scriptname RealisticPrisonAndBounty_Arrest extends Quest

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config
import PO3_SKSEFunctions

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

string property STATE_ARRESTED = "Arrested" autoreadonly

ReferenceAlias property CaptorRef auto

function RegisterEvents()
    RegisterForModEvent("ArrestBegin", "OnArrestBegin")
    RegisterForModEvent("ArrestEnd", "OnArrestEnd")
    Debug(self, "RegisterEvents", "Registered Events")
endFunction

event OnInit()
    RegisterEvents()
    RegisterForKey(0x58) ; F12
    RegisterForKey(0x57) ; F11
endEvent

event OnPlayerLoadGame()
    RegisterEvents()
endEvent

; event OnKeyDown(int keyCode)
;     if (keyCode == 0x58)
;         ObjectReference consoleRef = Game.GetCurrentConsoleRef()
;         Debug(self, "OnKeyDown", "ConsoleRef: " + consoleRef.GetFormID() + " ("+ consoleRef.GetBaseObject().GetName() +")")

;         CaptorRef.ForceRefTo(consoleRef)
;         ; (consoleRef as Actor).EvaluatePackage()
        
;         ; Game.SetPlayerAIDriven()
;         ; config.Player.PathToReference(consoleRef, 1.0)

;         Debug(self, "OnKeyDown", "Bound CaptorRef ReferenceAlias to " + consoleRef + "("+ consoleRef.GetBaseObject().GetName() +")")
;         Faction theRift = config.GetFaction("The Rift")
;         theRift.SendModEvent("ArrestBegin", numArg = consoleRef.GetFormID())
;     endif

;     Debug(self, "OnKeyDown", "Key Pressed: " + keyCode)
; endEvent

event OnKeyDown(int keyCode)
    if (keyCode == 0x58)
        string currentHold = config.GetCurrentPlayerHoldLocation()
        arrestVars.SetForm("Arrest::Arrest Faction", config.GetFaction(currentHold))

        ; arrestVars.SetInt("Override::Arrest::Bounty Non-Violent", 6000)
        ; arrestVars.SetInt("Override::Arrest::Bounty Violent", 1500)
        ; arrestVars.SetInt("Override::Jail::Sentence", 30)
        arrestVars.SetForm("Override::Arrest::Arrest Faction", config.GetFaction("The Rift"))
        
        arrestVars.ArrestFaction.SendModEvent("ArrestBegin", "TeleportToCell", 0x14)


    elseif (keyCode == 0x57)
        Game.QuitToMainMenu()
    endif
endEvent

event OnArrestBegin(string eventName, string arrestType, float arresteeId, Form sender)
    Actor captor            = (sender as Actor)
    Faction crimeFaction    = form_if ((sender as Faction), (sender as Faction), captor.GetCrimeFaction()) as Faction

    if (!captor && !crimeFaction)
        Error(self, "OnArrestBegin", "Captor or Faction are invalid ["+ "Captor: "+ captor + ", Faction: " + crimeFaction +"], cannot start arrest process!")
        return
    endif

    if (arrestVars.Arrestee == config.Player && arrestVars.IsArrested)
        self.UpdateArrest()
        return
    endif

    Actor arresteeRef = Game.GetForm(arresteeId as int) as Actor

    if (!arresteeRef)
        Error(self, "OnArrestBegin", "Arrestee not found for this arrest, aborting!")
        return
    endif

    if (captor)
        CaptorRef.ForceRefTo(captor)
        Debug(self, "OnArrestBegin", "Arrest is being done through a captor")

    elseif (crimeFaction)
        Debug(self, "OnArrestBegin", "Arrest is being done through a faction directly")
    endif

    arrestVars.SetForm("Arrest::Arrest Faction", crimeFaction)
    arrestVars.SetString("Arrest::Hold", crimeFaction.GetName())
    arrestVars.SetForm("Arrest::Arrestee", arresteeRef)
    arrestVars.SetForm("Arrest::Arresting Guard", captor)

    self.BeginArrest()
endEvent

event OnEscortToJailBegin()

endEvent

event OnEscortToJailEnd()
    
endEvent

event OnArrestEnd(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnArrestEnd", "Ending arrest process for Actor: ")
    arrestVars.SetBool("Arrest::Arrested", false)
endEvent

state Arrested
    event OnArrestBegin(string eventName, string unusedStr, float arresteeRefId, Form sender)
        if (arrestVars.Arrestee == config.Player && arrestVars.IsArrested)
            self.UpdateArrest()
            return
        endif
        
        Error(self, "OnArrestBegin", "Actor is already in the Arrested state, aborting call!")
    endEvent

    event OnEscortToJailBegin()
        ; Begin escort to jail after being arrested
    endEvent
    
    event OnEscortToJailEnd()
        ; if (ShouldBeImprisoned)
        ;     jail.OnEscortToJailEnd()
        ; endif
    endEvent
endState

function BeginArrest()
    string hold             = arrestVars.Hold
    Faction arrestFaction   = arrestVars.ArrestFaction
    Actor arrestee          = arrestVars.Arrestee
    Actor captor            = arrestVars.Captor ; May be undefined if the arrest is not done through a captor
                      
    self.SetBounty()
    bool assignedJailCellSuccessfully = jail.AssignJailCell(arrestee) ; Not guaranteed to go to jail, but we set it up here either way

    if (!assignedJailCellSuccessfully)
        arrestVars.Delete()
        Error(self, "BeginArrest", "Could not assign a jail cell to " + arrestee + ". (Aborting arrest...)")
        return
    endif

    int bountyNonViolent        = arrestVars.BountyNonViolent
    int bountyViolent           = arrestVars.BountyViolent
    int bounty                  = bountyNonViolent + bountyViolent
    ObjectReference jailCell    = arrestVars.JailCell

    arrestVars.SetBool("Arrest::Arrested", true)
    arrestVars.SetFloat("Arrest::Time of Arrest", Utility.GetCurrentGameTime())

    arrestee.StopCombat()
    arrestee.StopCombatAlarm()

    ; OpenMultipleDoorsOfType(GetJailBaseDoorID(arrestVars.Hold), arrestee, 1000)

    arrestVars.SetForm("Jail::Cell Door", GetNearestJailDoorOfType(GetJailBaseDoorID(arrestVars.Hold), Arrestee, 10000))
    ; jail.StartEscortToCell()
    jail.StartTeleportToCell()
    SendModEvent("JailBegin")

    config.SetStat(hold, "Current Bounty", bounty)
    int currentLargestBounty = config.GetStat(hold, "Largest Bounty")
    config.SetStat(hold, "Largest Bounty", int_if (currentLargestBounty < bounty, bounty, currentLargestBounty))
    config.IncrementStat(hold, "Total Bounty", bounty)
    config.IncrementStat(hold, "Times Arrested")

    config.NotifyArrest("You have been arrested in " + hold)
    GotoState(STATE_ARRESTED)
endFunction

function UpdateArrest()
    ; Already arrested, we dont want to proceed, this probably happened with 0 bounty,
    ; but in case it didn't, update the bounty to the sentence
    if (arrestVars.IsJailed && jail.Prisoner.HasActiveBounty())
        jail.Prisoner.UpdateSentenceFromCurrentBounty()
    endif

    ClearBounty(arrestVars.ArrestFaction)

    bool isArresteeInsideCell = IsActorNearReference(arrestVars.Arrestee, arrestVars.JailCell)
    
    if (arrestVars.IsJailed && !isArresteeInsideCell)
        ; Possibly have an event to escort the prisoner to the cell
        ; OnEscortToCellBegin()
        jail.MovePrisonerToCell()
    endif

    Debug(self, "UpdateArrest", "\n" + \
        "Arrested: " + arrestVars.IsArrested + "\n" + \
        "Jailed: " + arrestVars.IsJailed + "\n" + \
        "Has Active Bounty: " + jail.Prisoner.HasActiveBounty() + "\n" + \
        "Is Inside Jail Cell: " + isArresteeInsideCell + "\n" \
    )
endFunction

function SetBounty()
    Faction arrestFaction = arrestVars.ArrestFaction

    arrestVars.SetFloat("Arrest::Bounty Non-Violent", arrestFaction.GetCrimeGoldNonViolent())
    arrestVars.SetFloat("Arrest::Bounty Violent", arrestFaction.GetCrimeGoldViolent())

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

; bool function SetJailCell()
;     string hold = arrestVars.Hold

;     if (arrestVars.HasOverride("Jail::Cell"))
;         Debug(self, "SetJailCell", "\n" + \
;             "(Overriden) Jail::Cell: " + arrestVars.JailCell + "\n" \
;         )
;     endif

;     Debug(self, "SetJailCell", "\n" + \
;         "Jail::Cell: " + arrestVars.JailCell + "\n" \
;     )

;     Debug(self, "SetJailCell", "\n" + \
;         "Hold: " + arrestVars.Hold + "\n" + \
;         "Faction: " + arrestVars.ArrestFaction + "\n" \
;     )

;     ; Get the jail cell for this arrestee
;     ; Possibly check later if there are NPC's in this cell, the number of beds available if we want shared cells, etc...
;     if (!arrestVars.GetForm("Jail::Cell"))
;         ObjectReference jailCellMarker = config.GetRandomJailMarker(hold)
;         arrestVars.SetForm("Jail::Cell", jailCellMarker)
;         Debug(self, "SetJailCell", "Set up new Jail Cell: " + arrestVars.JailCell + "(original ref: "+ jailCellMarker +")")
;     endif

;     return arrestVars.JailCell != none
; endFunction
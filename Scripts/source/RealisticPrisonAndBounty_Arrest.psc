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

Faction property ArrestFaction
    Faction function get()
        return arrestVars.GetForm("Arrest::Arrest Faction") as Faction
    endFunction
endProperty

int property BountyNonViolent
    int function get()
        return arrestVars.GetFloat("Arrest::Bounty Non-Violent") as int
    endFunction
endProperty

int property BountyViolent
    int function get()
        return arrestVars.GetFloat("Arrest::Bounty Violent") as int
    endFunction
endProperty

int property Bounty
    int function get()
        return BountyNonViolent + BountyViolent
    endFunction
endProperty

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

function SetArrestParams()
    AddArrestParam("Bounty Non-Violent", 1700)
    AddArrestParam("Bounty Violent", 300)
    AddArrestParam("Arrestee", config.Player.GetFormID())
    ; AddArrestParam("Sentence", 38)
    AddArrestParamString("TestParam", "TestParamValue")
    AddArrestParamBool("Enemy of Hold", true)

    ObjectReference jailCellMarker = config.GetRandomJailMarker("Haafingar")
    ObjectReference jailCellMarkerRift = config.GetRandomJailMarker("The Rift")

    ; int testFormMap2 = JFormMap.object()
    ; JFormMap.setForm(testFormMap2, config.Player, config.Player)
    ; JFormMap.setForm(testFormMap2, jailCellMarker, jailCellMarker)

    ; int testFormMap = JFormMap.object()
    ; JFormMap.setForm(testFormMap, config.Player, config.Player)
    ; JFormMap.setForm(testFormMap, jailCellMarker, jailCellMarker)
    ; JFormMap.setObj(testFormMap, jailCellMarkerRift, testFormMap2)

    int testArray = JArray.object()
    ; JArray.addStr(testArray, "Gata")
    ; JArray.addStr(testArray, "Portatil")

    int testMap4 = JMap.object()
    JMap.setStr(testMap4, "Gata", "Gatinha")
    JMap.setStr(testMap4, "Portatil", "Legions")

    int testMap3 = JMap.object()
    ; JMap.setStr(testMap3, "Gata", "Gatinha")
    ; JMap.setStr(testMap3, "Portatil", "Legion")
    ; JMap.setObj(testMap3, "testMap4", testMap4)

    int testMap2 = JMap.object()
    JMap.setStr(testMap2, "Gata", "Gatinha")
    JMap.setStr(testMap2, "Portatil", "Legion")
    JMap.setObj(testMap2, "testMap3", testMap3)


    int testMap = JMap.object()
    JMap.setStr(testMap, "Gata", "Gatinha")
    JMap.setStr(testMap, "Portatil", "Legion")
    JMap.setObj(testMap, "testMap2", testMap2)
    JMap.setObj(testMap, "testArray", testArray)

    ; AddArrestParamObject("TestMap", testMap)

    ; int arrestParams = JMap.object()
    ; JMap.setInt(arrestParams, "Bounty Non-Violent", 1700)
    ; JMap.setInt(arrestParams, "Bounty Violent", 300)
    ; JMap.setInt(arrestParams, "Arrestee", config.Player.GetFormID())

    ; config.SetArrestVarInt("Arrest::Arrest Params", arrestParams)
endFunction

bool function AddArrestParam(string paramName, int value, bool checkIntegrity = true)
    int arrestParams = arrestVars.GetObject("Arrest::Arrest Params")

    if (!arrestParams)
        arrestParams = JMap.object()
        JValue.retain(arrestParams)
        arrestVars.SetObject("Arrest::Arrest Params", arrestParams)
    endif

    JMap.setInt(arrestParams, paramName, value)

    return bool_if (checkIntegrity, JMap.hasKey(arrestParams, paramName), true)
endFunction

bool function AddArrestParamObject(string paramName, int value, bool checkIntegrity = true)
    int arrestParams = arrestVars.GetObject("Arrest::Arrest Params")

    if (!arrestParams)
        arrestParams = JMap.object()
        JValue.retain(arrestParams)
        arrestVars.SetObject("Arrest::Arrest Params", arrestParams)
    endif

    JMap.setObj(arrestParams, paramName, value)

    return bool_if (checkIntegrity, JMap.hasKey(arrestParams, paramName), true)
endFunction

bool function AddArrestParamBool(string paramName, bool value, bool checkIntegrity = true)
    int arrestParams = arrestVars.GetObject("Arrest::Arrest Params")

    if (!arrestParams)
        arrestParams = JMap.object()
        JValue.retain(arrestParams)
        arrestVars.SetObject("Arrest::Arrest Params", arrestParams)
    endif

    JMap.setInt(arrestParams, paramName, value as int)

    return bool_if (checkIntegrity, JMap.hasKey(arrestParams, paramName), true)
endFunction

bool function AddArrestParamString(string paramName, string value, bool checkIntegrity = true)
    int arrestParams = arrestVars.GetObject("Arrest::Arrest Params")

    if (!arrestParams)
        arrestParams = JMap.object()
        JValue.retain(arrestParams)
        arrestVars.SetObject("Arrest::Arrest Params", arrestParams)
    endif

    JMap.setStr(arrestParams, paramName, value)

    return bool_if (checkIntegrity, JMap.hasKey(arrestParams, paramName), true)
endFunction

event OnKeyDown(int keyCode)
    if (keyCode == 0x58)
        string currentHold = config.GetCurrentPlayerHoldLocation()
        Faction crimeFaction = config.GetFaction(currentHold)

        ; ; Get a random jail cell for the current hold's prison
        ; ObjectReference jailCellMarker = config.GetRandomJailMarker(currentHold)

        ; arrestVars.SetBool("Arrest::Arrested", true)
        ; arrestVars.SetString("Arrest::Hold", crimeFaction.GetName())
        ; arrestVars.SetFloat("Arrest::Bounty Non-Violent", crimeFaction.GetCrimeGoldNonViolent())
        ; arrestVars.SetFloat("Arrest::Bounty Violent", crimeFaction.GetCrimeGoldViolent())
        ; arrestVars.SetForm("Arrest::Arrest Faction", crimeFaction)

        ; ; TODO: Refactor this into the jail script, since Arrested does not necessarily mean jailed, the Actor might still pay their bounty.
        ; arrestVars.SetForm("Jail::Cell", jailCellMarker)
        arrestVars.Delete()
        SetArrestParams()

        config.NotifyArrest("You have been arrested in " + currentHold)
        crimeFaction.SendModEvent("ArrestBegin", numArg = arrestVars.GetObject("Arrest::Arrest Params"))

    elseif (keyCode == 0x57)
        Game.QuitToMainMenu()
    endif
endEvent

event OnArrestBegin(string eventName, string unusedStr, float arrestParams, Form sender)
    Actor captor            = (sender as Actor)
    Faction crimeFaction    = form_if ((sender as Faction), (sender as Faction), captor.GetCrimeFaction()) as Faction

    if (!captor && !crimeFaction)
        Error(self, "OnArrestBegin", "Captor or Faction are invalid ["+ "Captor: "+ captor + ", Faction: " + crimeFaction +"], cannot start arrest process!")
        return
    endif

    int arresteeRefId = JMap.getInt(arrestParams as int, "Arrestee") as int
    int bountyNonViolentOverride = JMap.getInt(arrestParams as int, "Bounty Non-Violent")
    int bountyViolentOverride = JMap.getInt(arrestParams as int, "Bounty Violent")

    if (arrestParams == 0x14)
        arresteeRefId = 0x14
    endif

    Actor arresteeRef = Game.GetForm(arresteeRefId) as Actor

    if (!arresteeRef)
        Error(self, "OnArrestBegin", "Arrestee not found for this arrest, aborting!")
        return
    endif

    if (bountyNonViolentOverride || bountyViolentOverride)
        Debug(self, "OnArrestBegin", "Arresting with a bounty override of: { "+ "Non-Violent: "+ bountyNonViolentOverride + ", Violent: " + bountyViolentOverride + " }")
    endif

    SetupArrestVars()

    arrestVars.SetBool("Arrest::Arrested", true)
    arrestVars.SetString("Arrest::Hold", crimeFaction.GetName())
    arrestVars.SetFloat("Arrest::Bounty Non-Violent", int_if(bountyNonViolentOverride > 0, bountyNonViolentOverride, crimeFaction.GetCrimeGoldNonViolent()))
    arrestVars.SetFloat("Arrest::Bounty Violent", int_if (bountyViolentOverride > 0, bountyViolentOverride, crimeFaction.GetCrimeGoldViolent()))
    arrestVars.SetForm("Arrest::Arrest Faction", crimeFaction)
    arrestVars.SetForm("Arrest::Arrestee", arresteeRef)
    arrestVars.SetForm("Arrest::Arresting Guard", captor)

    Debug(self, "OnArrestBegin", "Vars: ["+ "Hold: " + crimeFaction.GetName() + ", BountyNonViolent: " + crimeFaction.GetCrimeGoldNonViolent() + ", BountyViolent: " + crimeFaction.GetCrimeGoldViolent() + "]")
    Debug(self, "OnArrestBegin", "StoredVars: ["+ "Hold: " + arrestVars.GetString("Arrest::Hold") + ", BountyNonViolent: " + arrestVars.GetFloat("Arrest::BountyNonViolent") + ", BountyViolent: " + arrestVars.GetFloat("Arrest::BountyViolent") + "]")

    string hold = crimeFaction.GetName()

    Debug(self, "OnArrestBegin", "Has Jail Cell: " + (arrestVars.GetForm("Jail::Cell") != none) + ", REF: " + arrestVars.GetForm("Jail::Cell"))

    if (!arrestVars.GetForm("Jail::Cell"))
        ObjectReference jailCellMarker = config.GetRandomJailMarker(hold)

        ; Setup which jail cell to go to
        ; TODO: Refactor this into the jail script, since Arrested does not necessarily mean jailed, the Actor might still pay their bounty.
        arrestVars.SetForm("Jail::Cell", jailCellMarker)
        Debug(self, "OnArrestBegin", "Set up new Jail Cell: " + arrestVars.GetReference("Jail::Cell") + "(original ref: "+ jailCellMarker +")")
    endif

    config.NotifyArrest("You have been arrested in " + hold)

    if (captor)
        CaptorRef.ForceRefTo(captor)
        Debug(self, "OnArrestBegin", "Arrest is being done through a captor")

    elseif (crimeFaction)
        Debug(self, "OnArrestBegin", "Arrest is being done through a faction directly")
    endif

    if (captor || crimeFaction)
        crimeFaction.SetCrimeGold(0)
        crimeFaction.SetCrimeGoldViolent(0)
        crimeFaction.PlayerPayCrimeGold(false, false)
        arresteeRef.StopCombat()
        arresteeRef.StopCombatAlarm()
        arresteeRef.MoveTo(config.JailCell)
        SendModEvent("JailBegin")
    endif

    config.IncrementStat(hold, "Times Arrested")
    config.SetStat(hold, "Current Bounty", Bounty)

    int currentLargestBounty = config.GetStat(hold, "Largest Bounty")
    config.SetStat(hold, "Largest Bounty", int_if (currentLargestBounty < Bounty, Bounty, currentLargestBounty))
    config.IncrementStat(hold, "Total Bounty", Bounty)
    
    Debug(self, "OnArrestBegin", "Beginning arrest process for Actor: " + arresteeRef + ", Hold is " + hold)
endEvent

; event OnArrestBegin(string eventName, string unusedStr, float arresteeRefId, Form sender)
;     Actor captor            = (sender as Actor)
;     Faction crimeFaction    = form_if ((sender as Faction), (sender as Faction), captor.GetCrimeFaction()) as Faction

;     if (!captor && !crimeFaction)
;         Error(self, "OnArrestBegin", "Captor or Faction are invalid ["+ "Captor: "+ captor + ", Faction: " + crimeFaction +"], cannot start arrest process!")
;         return
;     endif

;     Actor arresteeRef = Game.GetForm(arresteeRefId as int) as Actor
;     ; Actor arresteeRef = Game.GetCurrentConsoleRef() as Actor

;     if (!arresteeRef)
;         Error(self, "OnArrestBegin", "Arrestee not found for this arrest, aborting!")
;         return
;     endif

;     SetupArrestVars()

;     arrestVars.SetBool("Arrest::Arrested", true)
;     arrestVars.SetString("Arrest::Hold", crimeFaction.GetName())
;     arrestVars.SetFloat("Arrest::Bounty Non-Violent", crimeFaction.GetCrimeGoldNonViolent())
;     arrestVars.SetFloat("Arrest::Bounty Violent", crimeFaction.GetCrimeGoldViolent())
;     arrestVars.SetForm("Arrest::Arrest Faction", crimeFaction)

;     Debug(self, "OnArrestBegin", "Vars: ["+ "Hold: " + crimeFaction.GetName() + ", BountyNonViolent: " + crimeFaction.GetCrimeGoldNonViolent() + ", BountyViolent: " + crimeFaction.GetCrimeGoldViolent() + "]")
;     Debug(self, "OnArrestBegin", "StoredVars: ["+ "Hold: " + arrestVars.GetString("Arrest::Hold") + ", BountyNonViolent: " + arrestVars.GetFloat("Arrest::BountyNonViolent") + ", BountyViolent: " + arrestVars.GetFloat("Arrest::BountyViolent") + "]")

;     string hold = crimeFaction.GetName()
;     ObjectReference jailCellMarker = config.GetRandomJailMarker(hold)

;     ; Setup which jail cell to go to
;     ; TODO: Refactor this into the jail script, since Arrested does not necessarily mean jailed, the Actor might still pay their bounty.
;     arrestVars.SetForm("Jail::Cell", jailCellMarker)

;     config.NotifyArrest("You have been arrested in " + hold)

;     if (captor)
;         CaptorRef.ForceRefTo(captor)
;         Debug(self, "OnArrestBegin", "Arrest is being done through a captor")

;     elseif (crimeFaction)
;         Debug(self, "OnArrestBegin", "Arrest is being done through a faction directly")
;     endif

;     if (captor || crimeFaction)
;         crimeFaction.SetCrimeGold(0)
;         arresteeRef.RemoveAllItems()
;         arresteeRef.MoveTo(config.JailCell)
;         config.PrepareActorForJail(arresteeRef)
;         SendModEvent("JailBegin")
;     endif

;     config.IncrementStat(hold, "Times Arrested")
;     config.SetStat(hold, "Current Bounty", Bounty)

;     int currentLargestBounty = config.GetStat(hold, "Largest Bounty")
;     config.SetStat(hold, "Largest Bounty", int_if (currentLargestBounty < Bounty, Bounty, currentLargestBounty))
;     config.IncrementStat(hold, "Total Bounty", Bounty)
    
;     Debug(self, "OnArrestBegin", "Beginning arrest process for Actor: " + arresteeRef + ", Hold is " + hold)
; endEvent

event OnEscortToJailBegin()

endEvent

event OnEscortToJailEnd()
    
endEvent

event OnArrestEnd(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnArrestEnd", "Ending arrest process for Actor: ")
    arrestVars.SetBool("Arrest::Arrested", false)
endEvent

function SetupArrestVars()
    arrestVars.SetFloat("Arrest::Time of Arrest", Utility.GetCurrentGameTime())

endFunction

function StartArrestFromCaptor()

endFunction

state Arrested
    event OnArrestBegin(string eventName, string unusedStr, float arresteeRefId, Form sender)
        Error(self, "OnArrestBegin", "Actor is already in the Arrested state, aborting call!")
    endEvent

    event OnEscortToJailBegin()
        ; Begin escort to jail after being arrested
    endEvent
    
    event OnEscortToJailEnd()
        ; End escort to jail, the Actor should now be at the processing stage at the jail
        if (jail.IsInfamyEnabled)
            bool hasBountyToTriggerPenalty = (Bounty >= arrestVars.GetInt("Jail::Bounty to Trigger Infamy"))
            if (jail.IsInfamyRecognized || jail.IsInfamyKnown)
                int currentInfamy  = config.GetInfamyGained(jail.Hold)
                float criminalPenalty  = float_if (jail.IsInfamyKnown, arrestVars.GetFloat("Jail::Known Criminal Penalty"), arrestVars.GetFloat("Jail::Recognized Criminal Penalty"))
                int currentNonViolentBounty = arrestVars.GetFloat("Arrest::Bounty Non-Violent") as int
                arrestVars.SetFloat("Arrest::Bounty Non-Violent", currentNonViolentBounty + (currentInfamy * floor(percent(criminalPenalty))))
            endif
        endif

        ; if (ShouldBeImprisoned)
        ;     jail.OnEscortToJailEnd()
        ; endif
    endEvent
endState
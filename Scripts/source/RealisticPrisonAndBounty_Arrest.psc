scriptname RealisticPrisonAndBounty_Arrest extends Quest

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config
import PO3_SKSEFunctions

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

Faction property ArrestFaction
    Faction function get()
        return config.GetArrestVarForm("Arrest::Arrest Faction") as Faction
    endFunction
endProperty

int property BountyNonViolent
    int function get()
        return config.GetArrestVarFloat("Arrest::Bounty Non-Violent") as int
    endFunction
endProperty

int property BountyViolent
    int function get()
        return config.GetArrestVarFloat("Arrest::Bounty Violent") as int
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
endEvent

event OnPlayerLoadGame()
    RegisterEvents()
endEvent

event OnKeyDown(int keyCode)
    if (keyCode == 0x58)
        Faction theRift = config.GetFaction("The Rift")
        theRift.SendModEvent("ArrestBegin", numArg = 0x14)
    endif

    Debug(self, "OnKeyDown", "Key Pressed: " + keyCode)
endEvent

event OnArrestBegin(string eventName, string unusedStr, float arresteeRefId, Form sender)
    Actor captor            = (sender as Actor)
    Faction crimeFaction    = form_if ((sender as Faction), (sender as Faction), captor.GetCrimeFaction()) as Faction

    if (!captor && !crimeFaction)
        Error(self, "OnArrestBegin", "Captor or Faction are invalid ["+ "Captor: "+ captor + ", Faction: " + crimeFaction +"], cannot start arrest process!")
        return
    endif

    Actor arresteeRef = Game.GetForm(arresteeRefId as int) as Actor

    if (!arresteeRef)
        Error(self, "OnArrestBegin", "Arrestee not found for this arrest, aborting!")
        return
    endif

    config.SetArrestVarBool("Arrest::Arrested", true)
    config.SetArrestVarString("Arrest::Hold", crimeFaction.GetName())
    config.SetArrestVarFloat("Arrest::Bounty Non-Violent", crimeFaction.GetCrimeGoldNonViolent())
    config.SetArrestVarFloat("Arrest::Bounty Violent", crimeFaction.GetCrimeGoldViolent())
    config.SetArrestVarForm("Arrest::Arrest Faction", crimeFaction)

    Debug(self, "OnArrestBegin", "Vars: ["+ "Hold: " + crimeFaction.GetName() + ", BountyNonViolent: " + crimeFaction.GetCrimeGoldNonViolent() + ", BountyViolent: " + crimeFaction.GetCrimeGoldViolent() + "]")
    Debug(self, "OnArrestBegin", "StoredVars: ["+ "Hold: " + config.GetArrestVarString("Arrest::Hold") + ", BountyNonViolent: " + config.GetArrestVarFloat("Arrest::BountyNonViolent") + ", BountyViolent: " + config.GetArrestVarFloat("Arrest::BountyViolent") + "]")

    string hold = crimeFaction.GetName()
    ObjectReference jailCellMarker = config.GetRandomJailMarker(hold)

    config.NotifyArrest("You have been arrested in " + hold)

    if (captor)
        ; Setup which jail cell to go to
        config.SetArrestVarForm("Jail::Cell", jailCellMarker)

        ; captor.PathToReference(jailCellMarker, 1.0)
        ; arresteeRef.PathToReference(captor, 1.0)
        ; CaptorRef.ForceRefTo(captor)
        crimeFaction.SetCrimeGold(0)
        arresteeRef.MoveTo(config.JailCell)
        arresteeRef.RemoveAllItems()
        ; config.PrepareActorForJail(arresteeRef)
        Debug(self, "OnArrestBegin", "Arrest is being done through a captor")
        SendModEvent("JailBegin")

    elseif (crimeFaction)
        arresteeRef.RemoveAllItems()
        arresteeRef.MoveTo(jailCellMarker)
        config.PrepareActorForJail(arresteeRef)
        crimeFaction.SetCrimeGold(0)
        Debug(self, "OnArrestBegin", "Arrest is being done through a faction directly")
        SendModEvent("JailBegin")

    endif

    config.IncrementStat(hold, "Times Arrested")
    config.SetStat(hold, "Current Bounty", Bounty)

    int currentLargestBounty = config.GetStat(hold, "Largest Bounty")
    config.SetStat(hold, "Largest Bounty", int_if (currentLargestBounty < Bounty, Bounty, currentLargestBounty))
    config.IncrementStat(hold, "Total Bounty", Bounty)
    
    Debug(self, "OnArrestBegin", "Beginning arrest process for Actor: " + arresteeRef + ", Hold is " + hold)
endEvent

event OnEscortToJailBegin(string eventName, string strArg, float numArg, Form sender)

endEvent

event OnEscortToJailEnd(string eventName, string strArg, float numArg, Form sender)
    
endEvent

event OnArrestEnd(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnArrestEnd", "Ending arrest process for Actor: ")
    config.SetArrestVarBool("Arrest::Arrested", false)
endEvent

function SetupArrestVars()

endFunction

function StartArrestFromCaptor()

endFunction

state Arrested
    event OnArrestBegin(string eventName, string unusedStr, float arresteeRefId, Form sender)
        Error(self, "OnArrestBegin", "Actor is already in the Arrested state, aborting call!")
    endEvent
endState
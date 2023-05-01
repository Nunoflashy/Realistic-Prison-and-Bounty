scriptname RealisticPrisonAndBounty_Jail extends Quest

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config
import PO3_SKSEFunctions

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

bool property InfamyEnabled
    bool function get()
        return config.GetArrestVarBool("Jail::Infamy Enabled")
    endFunction
endProperty

float property CurrentTime
    float function get()
        return Utility.GetCurrentGameTime()
    endFunction
endProperty

bool property SentenceServed
    bool function get()
        return CurrentTime >= ReleaseTime
    endFunction
endProperty

int property MinimumSentence
    int function get()
        return config.GetArrestVarFloat("Jail::Minimum Sentence") as int
    endFunction
endProperty

int property MaximumSentence
    int function get()
        return config.GetArrestVarFloat("Jail::Maximum Sentence") as int
    endFunction
endProperty

int property BountyToSentence
    int function get()
        return config.GetArrestVarFloat("Jail::Bounty to Sentence") as int
    endFunction
endProperty

int property Sentence
    int function get()
        return config.GetArrestVarFloat("Jail::Sentence") as int
    endFunction
endProperty

bool property IsArrested
    bool function get()
        return config.GetArrestVarBool("Arrest::Arrested")
    endFunction
endProperty

bool property IsJailed
    bool function get()
        return config.GetArrestVarBool("Jail::Jailed")
    endFunction
endProperty

string property Hold
    string function get()
        return config.GetArrestVarString("Arrest::Hold")
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

float property TimeOfImprisonment
    float function get()
        return config.GetArrestVarFloat("Jail::Time of Imprisonment")
    endFunction
endProperty

; float _timeOfImprisonment
; float property TimeOfImprisonment
;     float function get()
;         if (!_timeOfImprisonment)
;             Error(self, "Property::TimeOfImprisonment", "Property not set. (Not initialized in Jailed::OnStateBegin()?)")
;         endif
;         return _timeOfImprisonment
;     endFunction

;     function set(float value)
;         if (self.GetState() != "Jailed")
;             Error(self, "Property::TimeOfImprisonment", "Cannot change this property outside of the Jailed state, aborting!")
;             return
;         endif

;         _timeOfImprisonment = value
;     endFunction
; endProperty

float property ReleaseTime
    float function get()
        float gameHour = 0.04166666666666666666666666666667
        return TimeOfImprisonment + (gameHour * 24 * Sentence)
    endFunction
endProperty

; float property CurrentTimeServed
;     float function get()
;         return TimeOfImprisonment * (24 * Sentence)
;     endFunction
; endProperty

ObjectReference property JailCell
    ObjectReference function get()
        return config.GetArrestVarForm("Jail::Cell") as ObjectReference
    endFunction
endProperty

ObjectReference property JailCellDoor
    ObjectReference function get()
        ; TODO: Scan for nearby ObjectReferences near this Marker, once the Cell Door is found, return that reference.
        ObjectReference jailCellMarker = config.GetArrestVarForm("Jail::Cell") as ObjectReference
    endFunction
endProperty

bool property IsClothingEnabled
    bool function get()
        return config.GetArrestVarBool("Clothing::Allow Clothing")
    endFunction
endProperty

string property OutfitName
    string function get()
        return config.GetArrestVarString("Clothing::Outfit::Name")
    endFunction
endProperty

Armor property OutfitHead
    Armor function get()
        return config.GetArrestVarForm("Clothing::Outfit::Head") as Armor
    endFunction
endProperty

Armor property OutfitBody
    Armor function get()
        return config.GetArrestVarForm("Clothing::Outfit::Body") as Armor
    endFunction
endProperty

Armor property OutfitHands
    Armor function get()
        return config.GetArrestVarForm("Clothing::Outfit::Hands") as Armor
    endFunction
endProperty

Armor property OutfitFeet
    Armor function get()
        return config.GetArrestVarForm("Clothing::Outfit::Feet") as Armor
    endFunction
endProperty

bool property IsOutfitConditional
    bool function get()
        return config.GetArrestVarBool("Clothing::Outfit::Conditional")
    endFunction
endProperty

int property OutfitMinBounty
    int function get()
        return config.GetArrestVarFloat("Clothing::Outfit::Minimum Bounty") as int
    endFunction
endProperty

int property OutfitMaxBounty
    int function get()
        return config.GetArrestVarFloat("Clothing::Outfit::Maximum Bounty") as int
    endFunction
endProperty

; Has enough time elapsed in order to serve the sentence?
bool function ShouldBeReleased()
    return true
endFunction

bool hasInfamyRecognizedMessageBeenShown = false
bool hasInfamyKnownMessageBeenShown = false

ReferenceAlias property CaptorRef auto

function RegisterEvents()
    RegisterForModEvent("JailBegin", "OnJailedBegin")
    RegisterForModEvent("JailEnd", "OnJailedEnd")
    Debug(self, "RegisterEvents", "Registered Events")
endFunction

event OnInit()
    RegisterEvents()
endEvent

event OnPlayerLoadGame()
    RegisterEvents()
endEvent

function UpdateTimeOfImprisonment()
    if (self.GetState() != "Jailed")
        Error(self, "UpdateTimeOfImprisonment", "Cannot update this property when not in the Jailed state, returning!")
        return
    endif

    config.SetArrestVarFloat("Jail::Time of Imprisonment", CurrentTime)
endFunction

function SetupJailVars()
    config.SetArrestVarBool("Jail::Infamy Enabled", config.IsInfamyEnabled(Hold))
    config.SetArrestVarFloat("Jail::Infamy Recognized Threshold", config.GetInfamyRecognizedThreshold(Hold))
    config.SetArrestVarFloat("Jail::Infamy Known Threshold", config.GetInfamyKnownThreshold(Hold))
    config.SetArrestVarFloat("Jail::Infamy Gained Daily from Current Bounty", config.GetInfamyGainedDailyFromArrestBounty(Hold))
    config.SetArrestVarFloat("Jail::Infamy Gained Daily", config.GetInfamyGainedDaily(Hold))
    config.SetArrestVarFloat("Jail::Bounty to Sentence", config.GetJailBountyToSentence(Hold))
    config.SetArrestVarFloat("Jail::Minimum Sentence", config.GetJailMinimumSentence(Hold))
    config.SetArrestVarFloat("Jail::Maximum Sentence", config.GetJailMaximumSentence(Hold))
    config.SetArrestVarFloat("Jail::Cell Search Thoroughness", config.GetJailCellSearchThoroughness(Hold))
    config.SetArrestVarString("Jail::Cell Lock Level", config.GetJailCellDoorLockLevel(Hold))
    ; config.SetArrestVarString("Jail::Old Cell Lock Level", ;/Get the cell's lock level through a ObjectReference scan near XMarker/;)
    config.SetArrestVarBool("Jail::Fast Forward", config.IsJailFastForwardEnabled(Hold))
    config.SetArrestVarFloat("Jail::Day to Fast Forward From", config.GetJailFastForwardDay(Hold))
    config.SetArrestVarString("Jail::Handle Skill Loss", config.GetJailHandleSkillLoss(Hold))
    config.SetArrestVarFloat("Jail::Day to Start Losing Skills", config.GetJailDayToStartLosingSkills(Hold))
    config.SetArrestVarFloat("Jail::Chance to Lose Skills", config.GetJailChanceToLoseSkillsDaily(Hold))
    config.SetArrestVarFloat("Jail::Recognized Criminal Penalty", config.GetJailRecognizedCriminalPenalty(Hold))
    config.SetArrestVarFloat("Jail::Known Criminal Penalty", config.GetJailKnownCriminalPenalty(Hold))
    config.SetArrestVarFloat("Jail::Bounty to Trigger Infamy", config.GetJailBountyToTriggerCriminalPenalty(Hold))
    config.SetArrestVarBool("Release::Release Fees Enabled", config.IsJailReleaseFeesEnabled(Hold))
    config.SetArrestVarFloat("Release::Chance for Release Fees Event", config.GetReleaseChanceForReleaseFeesEvent(Hold))
    config.SetArrestVarFloat("Release::Bounty to Owe Fees", config.GetReleaseBountyToOweFees(Hold))
    config.SetArrestVarFloat("Release::Release Fees from Arrest Bounty", config.GetReleaseReleaseFeesFromBounty(Hold))
    config.SetArrestVarFloat("Release::Release Fees Flat", config.GetReleaseReleaseFeesFlat(Hold))
    config.SetArrestVarFloat("Release::Days Given to Pay Release Fees", config.GetReleaseDaysGivenToPayReleaseFees(Hold))
    config.SetArrestVarBool("Release::Item Retention Enabled", config.IsItemRetentionEnabledOnRelease(Hold))
    config.SetArrestVarFloat("Release::Bounty to Retain Items", config.GetReleaseBountyToRetainItems(Hold))
    config.SetArrestVarBool("Release::Redress on Release", config.IsAutoDressingEnabledOnRelease(Hold))
    config.SetArrestVarFloat("Escape::Escape Bounty from Current Arrest", config.GetEscapedBountyFromCurrentArrest(Hold))
    config.SetArrestVarFloat("Escape::Escape Bounty Flat", config.GetEscapedBountyFlat(Hold))
    config.SetArrestVarBool("Escape::Allow Surrendering", config.IsSurrenderEnabledOnEscape(Hold))
    config.SetArrestVarBool("Escape::Should Frisk Search", config.ShouldFriskOnEscape(Hold))
    config.SetArrestVarBool("Escape::Should Strip Search", config.ShouldStripOnEscape(Hold))
    config.SetArrestVarFloat("Additional Charges::Bounty for Impersonation", config.GetChargeBountyForImpersonation(Hold))
    config.SetArrestVarFloat("Additional Charges::Bounty for Enemy of Hold", config.GetChargeBountyForEnemyOfHold(Hold))
    config.SetArrestVarFloat("Additional Charges::Bounty for Stolen Items", config.GetChargeBountyForStolenItems(Hold))
    config.SetArrestVarFloat("Additional Charges::Bounty for Stolen Item", config.GetChargeBountyForStolenItemFromItemValue(Hold))
    config.SetArrestVarFloat("Additional Charges::Bounty for Contraband", config.GetChargeBountyForContraband(Hold))
    config.SetArrestVarFloat("Additional Charges::Bounty for Cell Key", config.GetChargeBountyForCellKey(Hold))
    config.SetArrestVarBool("Frisking::Allow Frisking", config.IsFriskingEnabled(Hold))
    config.SetArrestVarBool("Frisking::Unconditional Frisking", config.IsFriskingUnconditional(Hold))
    config.SetArrestVarFloat("Frisking::Bounty for Frisking", config.GetFriskingBountyRequired(Hold))
    config.SetArrestVarFloat("Frisking::Frisking Thoroughness", config.GetFriskingThoroughness(Hold))
    config.SetArrestVarBool("Frisking::Confiscate Stolen Items", config.IsFriskingStolenItemsConfiscated(Hold))
    config.SetArrestVarBool("Frisking::Strip if Stolen Items Found", config.IsFriskingStripSearchWhenStolenItemsFound(Hold))
    config.SetArrestVarFloat("Frisking::Stolen Items Required for Stripping", config.GetFriskingStolenItemsRequiredForStripping(Hold))
    config.SetArrestVarBool("Stripping::Allow Stripping", config.IsStrippingEnabled(Hold))
    config.SetArrestVarString("Stripping::Handle Stripping On", config.GetStrippingHandlingCondition(Hold))
    config.SetArrestVarFloat("Stripping::Bounty to Strip", config.GetStrippingMinimumBounty(Hold))
    config.SetArrestVarFloat("Stripping::Violent Bounty to Strip", config.GetStrippingMinimumViolentBounty(Hold))
    config.SetArrestVarFloat("Stripping::Sentence to Strip", config.GetStrippingMinimumSentence(Hold))
    config.SetArrestVarBool("Stripping::Strip when Defeated", config.IsStrippedOnDefeat(Hold))
    config.SetArrestVarFloat("Stripping::Stripping Thoroughness", config.GetStrippingThoroughness(Hold))
    config.SetArrestVarBool("Clothing::Allow Clothing", config.IsClothingEnabled(Hold))
    config.SetArrestVarString("Clothing::Handle Clothing On", config.GetClothingHandlingCondition(Hold))
    config.SetArrestVarFloat("Clothing::Maximum Bounty to Clothe", config.GetClothingMaximumBounty(Hold))
    config.SetArrestVarFloat("Clothing::Maximum Violent Bounty to Clothe", config.GetClothingMaximumViolentBounty(Hold))
    config.SetArrestVarFloat("Clothing::Maximum Sentence to Clothe", config.GetClothingMaximumSentence(Hold))
    config.SetArrestVarBool("Clothing::Clothe when Defeated", config.IsClothedOnDefeat(Hold))
    config.SetArrestVarString("Clothing::Outfit", config.GetClothingOutfit(Hold))

    ; Outfit
    config.SetArrestVarString("Clothing::Outfit::Name", config.GetClothingOutfit(Hold))
    config.SetArrestVarForm("Clothing::Outfit::Head", config.GetOutfitPart(Hold, "Head"))
    config.SetArrestVarForm("Clothing::Outfit::Body", config.GetOutfitPart(Hold, "Body"))
    config.SetArrestVarForm("Clothing::Outfit::Hands", config.GetOutfitPart(Hold, "Hands"))
    config.SetArrestVarForm("Clothing::Outfit::Feet", config.GetOutfitPart(Hold, "Feet"))
    config.SetArrestVarBool("Clothing::Outfit::Conditional", config.IsClothingOutfitConditional(Hold))
    config.SetArrestVarFloat("Clothing::Outfit::Minimum Bounty", config.GetClothingOutfitMinimumBounty(Hold))
    config.SetArrestVarFloat("Clothing::Outfit::Maximum Bounty", config.GetClothingOutfitMaximumBounty(Hold))

    ; Dynamic Vars
    config.SetArrestVarForm("Arrest::Arrest Faction", config.GetFaction(Hold))
    config.SetArrestVarFloat("Jail::Sentence", (BountyNonViolent + BountyViolent) / BountyToSentence)
    config.SetArrestVarFloat("Jail::Time of Imprisonment", CurrentTime)
    config.SetArrestVarBool("Jail::Jailed", true)

    Debug(self, "SetupJailVars", "Finished setting up jail variables...")
endFunction

; Should be called everytime the actor gets to jail (initial jailing and on escape fail)
function UpdateSentence()
    int _bountyNonViolent    = ArrestFaction.GetCrimeGoldNonViolent()
    int _bountyViolent       = ArrestFaction.GetCrimeGoldViolent()

    config.SetArrestVarFloat("Arrest::Bounty Non-Violent", _bountyNonViolent)
    config.SetArrestVarFloat("Arrest::Bounty Violent", _bountyViolent)
    config.SetArrestVarFloat("Jail::Sentence", (_bountyNonViolent + _bountyViolent) / BountyToSentence)
endFunction

; Get the bounty from storage and add it into active bounty for this faction.
function RevertBounty()
    ArrestFaction.SetCrimeGold(BountyNonViolent)
    ArrestFaction.SetCrimeGoldViolent(BountyViolent)

    ; Should we clear it from storage vars?
endFunction

int function GetInfamyGainedDaily()
    int infamyGainedFlat                    = config.GetArrestVarFloat("Jail::Infamy Gained Daily") as int
    float infamyGainedFromCurrentBounty     = config.GetArrestVarFloat("Jail::Infamy Gained Daily from Current Bounty")

    ; floor(7000 * ToPercent(1.44) + 40 = 7000 * 0.0144 + 40 = 100.8 + 40 = 140.8)
    ; <=> floor(140.8) = 140
    return floor((Bounty * ToPercent(infamyGainedFromCurrentBounty)) + infamyGainedFlat)
endFunction

bool function IncreaseSentence(int daysToIncreaseBy, bool shouldAffectBounty = false)
    int previousSentence = Sentence
    int newSentence = Sentence + Max(0, daysToIncreaseBy) as int
    config.SetArrestVarFloat("Jail::Sentence", newSentence)

    if (shouldAffectBounty)
        config.SetArrestVarFloat("Arrest::Bounty Non-Violent", BountyNonViolent + (daysToIncreaseBy * BountyToSentence))
    endif

    config.NotifyJail("Your sentence has been increased by " + daysToIncreaseBy + " days")
    config.NotifyJail("Your bounty has also increased by " + (daysToIncreaseBy * BountyToSentence), condition = shouldAffectBounty)

    return newSentence == previousSentence + daysToIncreaseBy
endFunction

bool function DecreaseSentence(int daysToDecreaseBy, bool shouldAffectBounty = false)
    int previousSentence = Sentence
    int newSentence = Sentence - Max(0, daysToDecreaseBy) as int
    config.SetArrestVarFloat("Jail::Sentence", newSentence)

    if (shouldAffectBounty)
        config.SetArrestVarFloat("Arrest::Bounty Non-Violent", BountyNonViolent - (daysToDecreaseBy * BountyToSentence))
    endif

    config.NotifyJail("Your sentence has been decreased by " + daysToDecreaseBy + " days")
    config.NotifyJail("Your bounty has also decreased by " + (daysToDecreaseBy * BountyToSentence), condition = shouldAffectBounty)

    return newSentence == previousSentence - daysToDecreaseBy
endFunction

function ShowJailVars()
    Debug(self, "ShowJailVars", "\n" + Hold + " Arrest Vars: { \n\t" + \
        "Hold: " + Hold + ", \n\t" + \
        "Bounty Non-Violent: " + BountyNonViolent + ", \n\t" + \
        "Bounty Violent: " + BountyViolent + ", \n\t" + \
        "Arrested: " + IsArrested + ", \n\t" + \
        "Jailed: " + IsJailed + ", \n\t" + \
        "Jail Cell: " + JailCell + ", \n\t" + \
        "Minimum Sentence: " + MinimumSentence + " Days, \n\t" + \
        "Maximum Sentence: " + MaximumSentence + " Days, \n\t" + \
        "Sentence: " + Sentence + " Days, \n\t" + \
        "Time of Imprisonment: " + TimeOfImprisonment + ", \n\t" + \
        "Release Time: " + ReleaseTime + "\n" + \
    " }")
endFunction

function ShowOutfitInfo()
    Debug(self, "ShowOutfitInfo", "\n" + config.GetCityNameFromHold(Hold) + " Outfit: { \n\t" + \
        "Name: " + OutfitName + ", \n\t" + \
        "Head: " + OutfitHead + " ("+ OutfitHead.GetName() +")" + ", \n\t" + \
        "Body: " + OutfitBody + " ("+ OutfitBody.GetName() +")" + ", \n\t" + \
        "Hands: " + OutfitHands + " ("+ OutfitHands.GetName() +")" + ", \n\t" + \
        "Feet: " + OutfitFeet + " ("+ OutfitFeet.GetName() +")" + ", \n\t" + \
        "Conditional: " + IsOutfitConditional + ", \n\t" + \
        "Minimum Bounty: " + OutfitMinBounty + ", \n\t" + \
        "Maximum Bounty: " + OutfitMaxBounty + ", \n" + \
    " }")
endFunction

function ShowHoldStats()
    int currentBounty = config.QueryStat(Hold, "Current Bounty")
    int largestBounty = config.QueryStat(Hold, "Largest Bounty")
    int totalBounty = config.QueryStat(Hold, "Total Bounty")
    int timesArrested = config.QueryStat(Hold, "Times Arrested")
    int timesFrisked = config.QueryStat(Hold, "Times Frisked")
    int feesOwed = config.QueryStat(Hold, "Fees Owed")
    int daysInJail = config.QueryStat(Hold, "Days in Jail")
    int longestSentence = config.QueryStat(Hold, "Longest Sentence")
    int timesJailed = config.QueryStat(Hold, "Times Jailed")
    int timesEscaped = config.QueryStat(Hold, "Times Escaped")
    int timesStripped = config.QueryStat(Hold, "Times Stripped")
    int infamyGained = config.QueryStat(Hold, "Infamy Gained")

    Debug(self, "ShowHoldStats", "\n" + Hold + " Stats: { \n\t" + \
        "Current Bounty: " + currentBounty + ", \n\t" + \
        "Largest Bounty: " + largestBounty + ", \n\t" + \
        "Total Bounty: " + totalBounty + ", \n\t" + \
        "Times Arrested: " + timesArrested + ", \n\t" + \
        "Times Frisked: " + timesFrisked + ", \n\t" + \
        "Fees Owed: " + feesOwed + ", \n\t" + \
        "Days in Jail: " + daysInJail + ", \n\t" + \
        "Longest Sentence: " + longestSentence + ", \n\t" + \
        "Times Jailed: " + timesJailed + ", \n\t" + \
        "Times Escaped: " + timesEscaped + ", \n\t" + \
        "Times Stripped: " + timesStripped + ", \n\t" + \
        "Infamy Gained: " + infamyGained + "\n" + \
    " }")
endFunction

event OnJailedBegin(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnJailedBegin", "Starting jailing process...")
    SetupJailVars()
    GotoState("Jailed")
endEvent

event OnUndressed(string eventName, string strArg, float numArg, Form sender)
    
endEvent


event OnJailedEnd(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnJailedEnd", "Ending jailing process... (Released, Escaped?)")
    config.ResetArrestVars()
endEvent

state Jailed
    event OnBeginState()
        Debug(self, "OnBeginState", "Jailed state begin")
        ; Begin Jailed process, Actor is arrested and jailed
        ; Switch timescale to prison timescale
        config.IncrementStat(Hold, "Times Jailed")

        int currentLongestSentence = config.GetStat(Hold, "Longest Sentence")
        config.SetStat(Hold, "Longest Sentence", int_if (currentLongestSentence < Sentence, Sentence, currentLongestSentence))
        ShowJailVars()
        ShowOutfitInfo()
        ShowHoldStats()

        config.NotifyJail("You have been sentenced to " + Sentence + " days in jail")

        ; if (IsClothingEnabled)
        ;     config.Player.EquipItem(OutfitHead)
        ;     config.Player.EquipItem(OutfitBody)
        ;     config.Player.EquipItem(OutfitHands)
        ;     config.Player.EquipItem(OutfitFeet)
        ; endif

        RegisterForSingleUpdateGameTime(1.0)
    endEvent

    event OnUpdateGameTime()
        ; Check if sentence is served, if so, get out of this state
        ; Check if the actor has escaped, if so, go to that state (might be better to leave this for a door event OnOpen or something...)
        Debug(self, "OnUpdateGameTime", "Time passed")

        if (InfamyEnabled)
            ; Update infamy
            config.IncrementStat(Hold, "Infamy Gained", GetInfamyGainedDaily())
            config.NotifyInfamy(GetInfamyGainedDaily() + " Infamy gained in " + config.GetCityNameFromHold(Hold))

            ; Notify once when Recognized/Known Threshold is met
            int currentInfamy = config.GetInfamyGained(Hold)

            if (currentInfamy >= config.GetArrestVarFloat("Jail::Infamy Known Threshold"))
                config.NotifyInfamyKnownThresholdMet(Hold, hasInfamyKnownMessageBeenShown)
                hasInfamyKnownMessageBeenShown = true

            elseif (currentInfamy >= config.GetArrestVarFloat("Jail::Infamy Recognized Threshold"))
                config.NotifyInfamyRecognizedThresholdMet(Hold, hasInfamyRecognizedMessageBeenShown)
                hasInfamyRecognizedMessageBeenShown = true
            endif


        endif

        if (SentenceServed)
            GotoState("Released")
        endif

        ; IncreaseSentence(12, true)

        ; Display time served
        float timeServed = Utility.GetCurrentGameTime() - TimeOfImprisonment
        float timeLeftInSentence = (ReleaseTime - TimeOfImprisonment) - timeServed
        Debug(self, "Jailed::OnUpdateGameTime", "Time { Served: " + timeServed + ", Left: " + timeLeftInSentence + " }")
        Debug(self, "Jailed::OnUpdateGameTime", "Bounty { Non-Violent: " + BountyNonViolent + ", Violent: " + BountyViolent + " } [Total: " + Bounty + "]")

        config.IncrementStat(Hold, "Days Jailed")
        Game.IncrementStat("Days Jailed")
    
        ; Keep updating while in jail
        RegisterForSingleUpdateGameTime(1.0)
    endEvent

    event OnEndState()
        Debug(self, "OnEndState", "Jailed state end")
        ; Terminate Jailed process, Actor should be released by now.
        ; Revert to normal timescale
    endEvent
endState

state Escaped
    event OnBeginState()
        Debug(self, "OnBeginState", "Escaped state begin")
        config.SetArrestVarBool("Jail::Jailed", false)
        config.IncrementStat(Hold, "Times Escaped")
        Game.IncrementStat("Times Escaped")

        ; Begin Escaped process, Actor is arrested and is trying to escape
        ; Add back bounty to active from storage and apply the escape penalty if there's any
        ; Optionally, make guards aggressive (maybe depending on the bounty?)
        RevertBounty()
    endEvent

    event OnUpdateGameTime()

    endEvent

    event OnEscapeFail()
        UpdateSentence()
    endEvent

    event OnEndState()
        Debug(self, "OnEndState", "Escaped state end")
        ; Terminate Escaped process, Actor should have escaped by now.
    endEvent
endState

state Released
    event OnBeginState()
        Debug(self, "OnBeginState", "Released state begin")
        ; Begin Release process, Actor is arrested and not yet free
        Debug.CenterOnCell("RiftenJail01")
    endEvent
    
    ; event OnEscortOutOfCell()
        
    ; endEvent

    event OnEndState()
        Debug(self, "OnEndState", "Released state end")
        ; Terminate Release process, Actor should be free at this point
    endEvent
endState

state Free
    event OnBeginState()
        Debug(self, "OnBeginState", "Free state begin")
        ; Begin Free process, Actor is not arrested and is Free
    endEvent

    event OnUpdateGameTime()

    endEvent

    event OnEndState()
        Debug(self, "OnEndState", "Free state end")
        ; Terminate Free process, Processing after Actor is free should be done by now.
    endEvent
endState

; Placeholders for State events
event OnEscapeFail()
    Error(self, "OnEscapeFail", "Not currently in the Escaped state, invalid call!")
endEvent
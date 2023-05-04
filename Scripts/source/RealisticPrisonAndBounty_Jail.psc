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

float property TimeOfArrest
    float function get()
        return config.GetArrestVarFloat("Arrest::Time of Arrest")
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

int property BountyExchange
    int function get()
        return config.GetArrestVarFloat("Jail::Bounty Exchange") as int
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
        return config.GetArrestVarInt("Arrest::Bounty Non-Violent")
    endFunction
endProperty

int property BountyViolent
    int function get()
        return config.GetArrestVarInt("Arrest::Bounty Violent")
    endFunction
endProperty

float property EscapeBountyFromCurrentArrest
    float function get()
        return config.GetArrestVarFloat("Escape::Escape Bounty from Current Arrest")
    endFunction
endProperty

int property EscapeBounty
    int function get()
        return config.GetArrestVarFloat("Escape::Escape Bounty Flat") as int
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

float property ReleaseTime
    float function get()
        float gameHour = 0.04166666666666666666666666666667
        return TimeOfImprisonment + (gameHour * 24 * Sentence)
    endFunction
endProperty

float property TimeServed
    float function get()
        return CurrentTime - TimeOfImprisonment
    endFunction
endProperty

float property TimeLeftInSentence
    float function get()
        return (ReleaseTime - TimeOfImprisonment) - TimeServed
    endFunction
endProperty

float property LastUpdate auto

;/
    Gets the time since the last update.
    1 Hour In-Game = 0.04166666666666666666666666666667
    Formula: Hours / 24
    f(h / 24) = hours in game
/;
float property TimeSinceLastUpdate
    float function get()
        return CurrentTime - LastUpdate
    endFunction
endProperty

int property InfamyGainedDaily
    ;/
        infamyGainedFlat: 40
        infamyGainedFromCurrentBounty: 1.44%
        Bounty: 3000
        <=> floor(3000 * (1.44/100) + 40)
        <=> floor(3000 * 0.0144) + 40
        <=> floor(43.2) + 40
        <=> 43 + 40 = 83
    /;
    int function get()
        int infamyGainedFlat                    = config.GetArrestVarFloat("Jail::Infamy Gained Daily") as int
        float infamyGainedFromCurrentBounty     = config.GetArrestVarFloat("Jail::Infamy Gained Daily from Current Bounty")

        return floor(Bounty * percent(infamyGainedFromCurrentBounty)) + infamyGainedFlat
    endFunction
endProperty

int property InfamyGainedPerUpdate
    ;/
        InfamyGainedDaily: 83
        TimeSinceLastUpdate: 0.16666666666666666666666666666667 (4 / 24) [4 Hours passed since last update]
        <=> ceil(83 * 0.16666666666666666666666666666667)
        <=> ceil(13.833333333333333333333333333334)
        <=> 14

        if 1 hour passed then TimeSinceLastUpdate = 0.16666666666666666666666666666667 / 4
        <=> TimeSinceLastUpdate: 0.04166666666666666666666666666667
        <=> ceil (83 * 0.04166666666666666666666666666667)
        <=> ceil (3.4583333333333333333333333333334)
        <=> 4
    /;
    int function get()
        return ceiling(InfamyGainedDaily * TimeSinceLastUpdate)
    endFunction
endProperty

bool property IsInfamyRecognized
    bool function get()
        int currentInfamy = config.GetInfamyGained(Hold)
        int recognizedThreshold = config.GetArrestVarFloat("Jail::Infamy Recognized Threshold") as int

        return currentInfamy >= recognizedThreshold
    endFunction
endProperty

bool property IsInfamyKnown
    bool function get()
        int currentInfamy = config.GetInfamyGained(Hold)
        int knownThreshold = config.GetArrestVarFloat("Jail::Infamy Known Threshold") as int
        
        return currentInfamy >= knownThreshold
    endFunction
endProperty

ObjectReference property JailCell
    ObjectReference function get()
        return config.GetArrestVarForm("Jail::Cell") as ObjectReference
    endFunction
endProperty

ObjectReference property CellDoor
    ObjectReference function get()
        return config.GetArrestVarForm("Jail::Cell Door") as ObjectReference
    endFunction
endProperty

Actor property Arrestee
    Actor function get()
        return config.GetArrestVarForm("Arrest::Arrestee") as Actor
    endFunction
endProperty

bool property IsStrippingEnabled
    bool function get()
        return config.GetArrestVarBool("Stripping::Allow Stripping")
    endFunction
endProperty

bool property IsClothingEnabled
    bool function get()
        return config.GetArrestVarBool("Clothing::Allow Clothing")
    endFunction
endProperty

string property ClothingHandling
    string function get()
        return config.GetArrestVarString("Clothing::Handle Clothing On")
    endFunction
endProperty

int property ClothingMaxBounty
    int function get()
        return config.GetArrestVarInt("Clothing::Maximum Bounty to Clothe")
    endFunction
endProperty

int property ClothingMaxBountyViolent
    int function get()
        return config.GetArrestVarInt("Clothing::Maximum Violent Bounty to Clothe")
    endFunction
endProperty

int property ClothingMaxSentence
    int function get()
        return config.GetArrestVarInt("Clothing::Maximum Sentence to Clothe")
    endFunction
endProperty

bool property ClotheWhenDefeated
    bool function get()
        return config.GetArrestVarBool("Clothing::Clothe when Defeated")
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

bool property IsStripped
    bool function get()
        return config.GetArrestVarBool("Jail::Stripped")
    endFunction
endProperty

bool property IsClothed
    bool function get()
        return config.GetArrestVarBool("Jail::Clothed")
    endFunction
endProperty

bool property ShouldBeStripped
    bool function get()
        if (IsStrippingEnabled)
            string strippingHandling        = config.GetArrestVarString("Stripping::Handle Stripping On")
            int strippingMinBounty          = config.GetArrestVarInt("Stripping::Bounty to Strip")
            int strippingMinViolentBounty   = config.GetArrestVarInt("Stripping::Violent Bounty to Strip")
            int strippingMinSentence        = config.GetArrestVarInt("Stripping::Sentence to Strip")
    
            bool meetsBountyRequirements = (BountyNonViolent >= strippingMinBounty) || (BountyViolent >= strippingMinViolentBounty)
            bool meetsSentenceRequirements = Sentence >= strippingMinSentence
            bool shouldStrip =  (strippingHandling == "Unconditionally") || \
                                (strippingHandling == "Minimum Bounty" && meetsBountyRequirements) || \
                                (strippingHandling == "Minimum Sentence" && meetsSentenceRequirements)
            
            LogProperty(self, "ShouldBeStripped", "\n" + \
                "strippingHandling: " + strippingHandling + "\n" + \
                "strippingMinBounty: " + strippingMinBounty + "\n" + \
                "strippingMinViolentBounty: " + strippingMinViolentBounty + "\n" + \
                "strippingMinSentence: " + strippingMinSentence + "\n" + \
                "meetsBountyRequirements: " + meetsBountyRequirements + "\n" + \
                "meetsSentenceRequirements: " + meetsSentenceRequirements + "\n" + \
                "shouldStrip: " + shouldStrip + "\n" \
            )

            return shouldStrip
        endif
    
        return false
    endFunction
endProperty

bool property ShouldBeClothed
    bool function get()
        if (IsClothingEnabled)
            bool meetsBountyRequirements = (BountyNonViolent <= ClothingMaxBounty) && (BountyViolent <= ClothingMaxBountyViolent)
            bool meetsSentenceRequirements = Sentence <= ClothingMaxSentence
            bool shouldClothe = (ClothingHandling == "Unconditionally") || \
                                (ClothingHandling == "Maximum Bounty" && meetsBountyRequirements) || \
                                (ClothingHandling == "Maximum Sentence" && meetsSentenceRequirements)
            
            return shouldClothe
        endif
    
        return false
    endFunction
endProperty



ReferenceAlias property CaptorRef auto
ReferenceAlias property CellDoorRef auto

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
    config.SetArrestVarFloat("Jail::Bounty Exchange", config.GetJailBountyExchange(Hold))
    config.SetArrestVarFloat("Jail::Bounty to Sentence", config.GetJailBountyToSentence(Hold))
    config.SetArrestVarFloat("Jail::Minimum Sentence", config.GetJailMinimumSentence(Hold))
    config.SetArrestVarFloat("Jail::Maximum Sentence", config.GetJailMaximumSentence(Hold))
    config.SetArrestVarFloat("Jail::Cell Search Thoroughness", config.GetJailCellSearchThoroughness(Hold))
    config.SetArrestVarString("Jail::Cell Lock Level", config.GetJailCellDoorLockLevel(Hold))
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
    config.SetArrestVarInt("Stripping::Bounty to Strip", config.GetStrippingMinimumBounty(Hold))
    config.SetArrestVarInt("Stripping::Violent Bounty to Strip", config.GetStrippingMinimumViolentBounty(Hold))
    config.SetArrestVarInt("Stripping::Sentence to Strip", config.GetStrippingMinimumSentence(Hold))
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
    int arrestParams = config.GetArrestVarObj("Arrest::Arrest Params")
    int sentenceOverride = JMap.getInt(arrestParams, "Sentence")
    bool hasSentenceOverride = JMap.hasKey(arrestParams, "Sentence")
    config.SetArrestVarForm("Arrest::Arrest Faction", config.GetFaction(Hold))
    config.SetArrestVarFloat("Jail::Sentence", int_if(hasSentenceOverride, sentenceOverride, (BountyNonViolent + GetViolentBountyConverted()) / BountyToSentence))
    config.SetArrestVarFloat("Jail::Time of Imprisonment", CurrentTime)
    config.SetArrestVarBool("Jail::Jailed", true)
    config.SetArrestVarInt("Jail::Cell Door Old Lock Level", CellDoor.GetLockLevel())
    config.SetArrestVarForm("Jail::Cell Door", GetNearestDoor(Arrestee, 200))

    Debug(self, "SetupJailVars", "Finished setting up jail variables...")
endFunction

int function GetViolentBountyConverted()
    Debug(self, "GetViolentBountyConverted", "Violent Bounty Exchanged: " + floor(BountyViolent * (100 / BountyExchange)))
    Debug(self, "GetViolentBountyConverted", "Violent Bounty: " + BountyViolent)
    Debug(self, "GetViolentBountyConverted", "Bounty Exchange: " + BountyExchange)
    return floor(BountyViolent * (100 / BountyExchange))
endFunction

; Should be called everytime the actor gets to jail (initial jailing and on escape fail)
function UpdateSentence()
    int _bountyNonViolent    = ArrestFaction.GetCrimeGoldNonViolent()
    int _bountyViolent       = ArrestFaction.GetCrimeGoldViolent()

    config.SetArrestVarFloat("Arrest::Bounty Non-Violent", _bountyNonViolent)
    config.SetArrestVarFloat("Arrest::Bounty Violent", _bountyViolent)
    config.SetArrestVarFloat("Jail::Sentence", (_bountyNonViolent + GetViolentBountyConverted()) / BountyToSentence)
endFunction

function UpdateSentenceFromBounty()
    int _bountyNonViolent    = ArrestFaction.GetCrimeGoldNonViolent()
    int _bountyViolent       = ArrestFaction.GetCrimeGoldViolent()

    ; Debug(self, "UpdateSentenceFromBounty", "_bountyNonViolent: " + _bountyNonViolent)
    ; Debug(self, "UpdateSentenceFromBounty", "_bountyViolent: " + _bountyViolent)
    ; Debug(self, "UpdateSentenceFromBounty", "BountyNonViolent: " + _bountyViolent)

    config.SetArrestVarFloat("Arrest::Bounty Non-Violent", BountyNonViolent + _bountyNonViolent)
    config.SetArrestVarFloat("Arrest::Bounty Violent", BountyViolent + _bountyViolent)
    config.SetArrestVarFloat("Jail::Sentence", (BountyNonViolent + GetViolentBountyConverted()) / BountyToSentence)

    ClearBountyFromFaction()
endFunction

function ClearBountyFromFaction()
    ArrestFaction.SetCrimeGold(0)
    ArrestFaction.SetCrimeGoldViolent(0)
endFunction

; Get the bounty from storage and add it into active bounty for this faction.
function RevertBounty()
    ArrestFaction.SetCrimeGold(BountyNonViolent)
    ArrestFaction.SetCrimeGoldViolent(BountyViolent)

    ; Should we clear it from storage vars?
    config.SetArrestVarInt("Arrest::Bounty Non-Violent", 0)
    config.SetArrestVarInt("Arrest::Bounty Violent", 0)
endFunction

int function GetCellDoorLockLevel()
    string configuredLockLevel = config.GetArrestVarString("Jail::Cell Lock Level")
    return  int_if (configuredLockLevel == "Novice", 1, \
            int_if (configuredLockLevel == "Apprentice", 25, \
            int_if (configuredLockLevel == "Adept", 50, \
            int_if (configuredLockLevel == "Expert", 75, \
            int_if (configuredLockLevel == "Master", 100, \
            int_if (configuredLockLevel == "Requires Key", 255))))))
endFunction

function AddEscapedBounty()
    ArrestFaction.ModCrimeGold(floor((BountyNonViolent * percent(EscapeBountyFromCurrentArrest))) + EscapeBounty)
endFunction

int function GetInfamyGainedDaily()
    int infamyGainedFlat                    = config.GetArrestVarFloat("Jail::Infamy Gained Daily") as int
    float infamyGainedFromCurrentBounty     = config.GetArrestVarFloat("Jail::Infamy Gained Daily from Current Bounty")

    ; floor(7000 * percent(1.44) + 40 = 7000 * 0.0144 + 40 = 100.8 + 40 = 140.8)
    ; <=> floor(140.8) = 140
    return floor((Bounty * percent(infamyGainedFromCurrentBounty)) + infamyGainedFlat)
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

function ShowArrestVars()
    Debug(self, "ShowArrestVars", "\n" + Hold + " Arrest Vars: " + GetContainerList(config.GetArrestVars()))
endFunction

function ShowArrestParams()
    int arrestParams = config.GetArrestVarObj("Arrest::Arrest Params")
    int arrestParamsObj = JMap.getObj(config.GetArrestVars(), "Arrest::Arrest Params")
    int arrestParamsBV = JMap.getInt(config.GetArrestVars(), "Arrest::Bounty Violent")
    bool isObject = JValue.isMap(arrestParamsObj)
    Debug(self, "ShowArrestParams (id: "+ arrestParamsObj +", isObject: "+ isObject +", arrestParamsBV: "+ arrestParamsBV +")", "\n" + Hold + " Arrest Params: " + GetContainerList(arrestParams))
endFunction

int function GetTimeServedDays()
    return floor(TimeServed)
endFunction

int function GetTimeServedHoursOfDay()
    float timeLeftOverOfDay = (TimeServed - GetTimeServedDays()) * 24 ; Hours and Minutes
    return floor(timeLeftOverOfDay)
endFunction

int function GetTimeServedMinutesOfHour()
    float timeLeftOverOfDay = (TimeServed - GetTimeServedDays()) * 24 ; Hours and Minutes
    float timeLeftOverOfHour = (timeLeftOverOfDay - floor(timeLeftOverOfDay)) * 60 ; Minutes
    return floor(timeLeftOverOfHour)
endFunction

int function GetTimeServedSecondsOfMinute()
    float timeLeftOverOfDay = (TimeServed - GetTimeServedHoursOfDay()) * 24 ; Hours and Minutes
    float timeLeftOverOfHour = (timeLeftOverOfDay - floor(timeLeftOverOfDay)) * 60 ; Minutes
    float timeLeftOverOfMinute = (timeLeftOverOfHour - floor(timeLeftOverOfHour)) * 60 ; Seconds
    return floor(timeLeftOverOfMinute)
endFunction

int function GetTimeLeftDays()
    return floor(TimeLeftInSentence)
endFunction

int function GetTimeLeftHours()
    float timeLeftToServeLeftOverOfDay = (TimeLeftInSentence - GetTimeLeftDays()) * 24; Hours and Minutes
    return floor(timeLeftToServeLeftOverOfDay)
endFunction

int function GetTimeLeftMinutes()
    float timeLeftToServeLeftOverOfDay = (TimeLeftInSentence - GetTimeLeftDays()) * 24; Hours and Minutes
    float timeLeftToServeLeftOverOfHour = (timeLeftToServeLeftOverOfDay - floor(timeLeftToServeLeftOverOfDay)) * 60 ; Minutes
    return floor(timeLeftToServeLeftOverOfHour)
endFunction

int function GetTimeLeftSeconds()
    float timeLeftToServeLeftOverOfDay = (TimeLeftInSentence - GetTimeLeftDays()) * 24; Hours and Minutes
    float timeLeftToServeLeftOverOfHour = (timeLeftToServeLeftOverOfDay - floor(timeLeftToServeLeftOverOfDay)) * 60 ; Minutes
    float timeLeftToServeLeftOverOfMinute = (timeLeftToServeLeftOverOfHour - floor(timeLeftToServeLeftOverOfHour)) * 60 ; Seconds
    return floor(timeLeftToServeLeftOverOfMinute)
endFunction

function ShowSentenceInfo()
    int timeServedDays      = GetTimeServedDays()
    int timeServedHours     = GetTimeServedHoursOfDay()
    int timeServedMinutes   = GetTimeServedMinutesOfHour()
    int timeServedSeconds   = GetTimeServedSecondsOfMinute()

    int timeLeftToServeDays      = GetTimeLeftDays()
    int timeLeftToServeHours     = GetTimeLeftHours()
    int timeLeftToServeMinutes   = GetTimeLeftMinutes()
    int timeLeftToServeSeconds   = GetTimeLeftSeconds()

    Debug(self, "ShowJailVars", "\n" + Hold + " Sentence: { \n\t" + \
        "Minimum Sentence: " + MinimumSentence + " Days, \n\t" + \
        "Maximum Sentence: " + MaximumSentence + " Days, \n\t" + \
        "Sentence: " + Sentence + " Days, \n\t" + \
        "Time of Arrest: " + TimeOfArrest+ ", \n\t" + \
        "Time of Imprisonment: " + TimeOfImprisonment + ", \n\t" + \
        "Time Served: " + TimeServed + " ("+ (TimeServed * 24) + " Hours" +") ["+ timeServedDays + " Days, " + timeServedHours + " Hours, " +  timeServedMinutes + " Minutes, " + timeServedSeconds + " Seconds" +"], \n\t" + \
        "Time Left: " + TimeLeftInSentence + " ("+ (TimeLeftInSentence * 24) + " Hours" +") ["+ timeLeftToServeDays + " Days, " + timeLeftToServeHours + " Hours, " +  timeLeftToServeMinutes + " Minutes, " + timeLeftToServeSeconds + " Seconds" +"], \n\t" + \
        "Release Time: " + ReleaseTime + "\n\t" + \
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

; Sets the jail outfit for @undressedActor.
; This function assumes the actor is already undressed.
; TODO: In case of the actor escaping, the outfit should be the same if the condition is met, and the default outfit should also be the same
; if they already worn it for the first time
function SetJailOutfit(Actor undressedActor, bool useDefaultOutfits = false, bool includeFeetClothingOnDefaultOutfit = true)
    Armor headClothing  = none
    Armor bodyClothing  = none
    Armor handsClothing = none
    Armor feetClothing  = none

    if (OutfitName == "Default" || useDefaultOutfits)
        ; Set default jail outfits
        int OUTFIT_DEFAULT_ROUGHSPUN_TUNIC  = 0
        int OUTFIT_DEFAULT_RAGGED_TROUSERS  = 1
        int OUTFIT_DEFAULT_RAGGED_ROBES     = 2

        int whichDefaultOutfit = Utility.RandomInt(0, 2)

        if (whichDefaultOutfit == OUTFIT_DEFAULT_ROUGHSPUN_TUNIC)
            bodyClothing = Game.GetFormEx(0x3C9FE) as Armor ; Roughspun Tunic
            feetClothing = form_if (includeFeetClothingOnDefaultOutfit, Game.GetFormEx(0x3CA00), none)  as Armor ; Footwraps

        elseif (whichDefaultOutfit == OUTFIT_DEFAULT_RAGGED_TROUSERS)
            bodyClothing = Game.GetFormEx(0x8F19A) as Armor ; Ragged Trousers
            feetClothing = form_if (includeFeetClothingOnDefaultOutfit, Game.GetFormEx(0x3CA00), none)  as Armor ; Footwraps

        elseif (whichDefaultOutfit == OUTFIT_DEFAULT_RAGGED_ROBES)
            bodyClothing = Game.GetFormEx(0x13105) as Armor ; Ragged Robes
            feetClothing = form_if (includeFeetClothingOnDefaultOutfit, Game.GetFormEx(0x3CA00), none)  as Armor ; Footwraps
        endif

        string defaultOutfitReturned =  string_if (whichDefaultOutfit == OUTFIT_DEFAULT_ROUGHSPUN_TUNIC, "Roughspun Tunic", \
                                        string_if (whichDefaultOutfit == OUTFIT_DEFAULT_RAGGED_TROUSERS, "Ragged Trousers", \
                                        string_if (whichDefaultOutfit == OUTFIT_DEFAULT_RAGGED_ROBES, "Ragged Robes")))

        Debug(self, "SetJailOutfit", "Got the " + defaultOutfitReturned + " default outfit. (" + "got feet clothing: " + (feetClothing != none) + ")")

    else
        ; TODO: if max bounty is the same as min bounty, then the condition should be removed
        bool meetsCondition = !IsOutfitConditional || (IsOutfitConditional && Bounty >= OutfitMinBounty && Bounty <= OutfitMaxBounty)

        if (meetsCondition)
            headClothing    = OutfitHead
            bodyClothing    = OutfitBody
            handsClothing   = OutfitHands
            feetClothing    = OutfitFeet
        
        else
            ; Condition not met for this outfit, revert to defaults
            bool includeFeetClothing = Utility.RandomInt(0, 3) >= 1 ; 75% chance to include feet clothing
            SetJailOutfit(undressedActor, true, includeFeetClothing)
        endif

    endif

    if (!AlreadyHasWornOutfit())
        ; Set currently worn outfit, if the actor escapes, the outfit will always be the same
        config.SetArrestVarForm("Jail::Worn Outfit::Head", headClothing)
        config.SetArrestVarForm("Jail::Worn Outfit::Body", bodyClothing)
        config.SetArrestVarForm("Jail::Worn Outfit::Hands", handsClothing)
        config.SetArrestVarForm("Jail::Worn Outfit::Feet", feetClothing)
    endif

    undressedActor.EquipItem(headClothing)
    undressedActor.EquipItem(bodyClothing)
    undressedActor.EquipItem(handsClothing)
    undressedActor.EquipItem(feetClothing)
endFunction

bool function AlreadyHasWornOutfit()
    return  config.GetArrestVarForm("Jail::Worn Outfit::Head") || \
            config.GetArrestVarForm("Jail::Worn Outfit::Body") || \
            config.GetArrestVarForm("Jail::Worn Outfit::Hands") || \
            config.GetArrestVarForm("Jail::Worn Outfit::Feet")
endFunction

event OnJailedBegin(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnJailedBegin", "Starting jailing process...")
    SetupJailVars()
    GotoState("Jailed")
endEvent


event OnJailedEnd(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnJailedEnd", "Ending jailing process... (Released, Escaped?)")
    config.ResetArrestVars()
endEvent

; ObjectReference function GetNearestCellDoor()
;     int i = 10
;     float range = 200.0

;     while (i > 0)
;         ObjectReference _cellDoor = Game.FindRandomReferenceOfTypeFromRef(config.DoorRef.GetBaseObject(), config.Player, range)
;         if (_cellDoor)
;             return _cellDoor
;         endif

;         if (range < 8000)
;             range *= 2
;         endif
;         i -= 1
;     endWhile

;     return none
; endFunction

state Jailed
    event OnBeginState()
        Debug(self, "OnBeginState", "Jailed state begin")
        ; Begin Jailed process, Actor is arrested and jailed
        ; Switch timescale to prison timescale
        config.IncrementStat(Hold, "Times Jailed")

        if (JailCell)
            CellDoor.SetOpen(false)
            CellDoor.Lock()
        endif

        if (ShouldBeStripped)
            float strippingThoroughness = config.GetArrestVarFloat("Stripping::Stripping Thoroughness")

            ; Determine what to strip based on thoroughness

            if (strippingThoroughness >= 20.0)
                ; Strip naked, leaving no chance for lockpicks

            elseif (strippingThoroughness >= 10.0)
                ; Strip naked, leaving very little chance for lockpicks

            elseif (strippingThoroughness >= 8)
                ; Strip naked, leaving little chance for lockpicks

            elseif (strippingThoroughness >= 6)
                ; Strip naked, leaving some chance for lockpicks

            elseif (strippingThoroughness >= 4)
                ; Strip to underwear, leaving average chance for lockpicks

            elseif (strippingThoroughness >= 2)
                ; Strip to underwear, leaving high chance for lockpicks and 1 key

            elseif (strippingThoroughness >= 0)
                ; Strip to underwear, leaving high chance for lockpicks and high chance for keys

            endif

            ; Stripping naked should only be allowed if a nude body mod is installed
            ; Likewise, stripping to underwear should only be allowed if a nude body mod AND a wearable underwear mod are installed, or if no nude body mod is installed (underwear by default)
            Debug(self, "OnBeginState", "Undressed Actor: " + Arrestee)

            Arrestee.RemoveAllItems()
            OnUndressed(Arrestee)

        elseif (ShouldBeClothed && !ActorHasClothing(Arrestee))
            ; Only handle clothing here when not stripped, which means the Actor did not have any clothing
            SetJailOutfit(Arrestee, includeFeetClothingOnDefaultOutfit = Utility.RandomInt(0, 3) == 0) ; 25% Chance to include feet clothing
            OnClothed(Arrestee)
        endif


        int currentLongestSentence = config.GetStat(Hold, "Longest Sentence")
        config.SetStat(Hold, "Longest Sentence", int_if (currentLongestSentence < Sentence, Sentence, currentLongestSentence))
        ShowJailVars()
        ; ShowOutfitInfo()
        ; ShowHoldStats()
        ShowArrestParams()
        ShowArrestVars()

        config.NotifyJail("Your sentence in " + Hold + " was set to " + Sentence + " days in jail")

        CellDoorRef.ForceRefTo(CellDoor)
        
        ; Debug(self, "OnBeginState", "DoorRef: " + config.DoorRef + ", DoorRef.Type: " + config.DoorRef.GetType() + ", JailCellMarker: " + JailCell + ", Found cell door: " + jailCellDoorRef)

        LastUpdate = Utility.GetCurrentGameTime()
        RegisterForSingleUpdateGameTime(1.0)
    endEvent

    event OnFriskBegin(Actor friskSearchPerformer, Actor actorToFrisk)
        ; Happens when the actor is beginning to be frisked
    endEvent

    event OnFriskEnd(Actor friskSearchPerformer, Actor friskedActor)
        ; Happens when the actor has been frisked
    endEvent

    event OnStripBegin(Actor stripSearchPerformer, Actor actorToStrip)
        ; Happens when the actor is about to be stripped
    endEvent

    event OnStripEnd(Actor stripSearchPerformer, Actor strippedActor)
        ; Happens when the actor has been stripped
    endEvent

    event OnEscortToCellBegin(Actor escortActor, Actor escortedActor)
        ; Happens when the actor is being escorted to their cell
    endEvent

    event OnEscortToCellEnd(Actor escortActor, Actor escortedActor)
        ; Happens when the actor has been escorted to their cell
    endEvent

    event OnEscortFromCellBegin(Actor escortActor, Actor escortedActor, ObjectReference destination)
        ; Happens when the actor is being escorted from their cell to the destination
    endEvent

    event OnEscortFromCellEnd(Actor escortActor, Actor escortedActor, ObjectReference destination)
        ; Happens when the actor has been escorted from their cell to the destination
    endEvent

    event OnActorCuffed(Actor cuffedActor, bool hands, bool feet)
        ; Happens when the actor has been cuffed (hands bound, maybe feet?)
    endEvent

    event OnActorUncuffed(Actor uncuffedActor, bool hands, bool feet)
        ; Happens when the actor has been uncuffed (hands unbound, maybe feet?)
    endEvent

    event OnUndressed(Actor undressedActor)
        ; Actor should be undressed at this point
        if (ShouldBeClothed)
            SetJailOutfit(undressedActor, true, false)
            OnClothed(undressedActor)
        endif

        Debug(self, "OnUndressed", "undressedActor: " + undressedActor)
    endEvent

    event OnClothed(Actor clothedActor)
        ; Do anything that needs to be done after the actor has been stripped and clothed.
        Debug(self, "OnClothed", "clothedActor: " + clothedActor)

    endEvent

    event OnCellDoorOpen(ObjectReference _cellDoor, Actor whoOpened)
        if (whoOpened == Arrestee)
            GotoState("Escaped")
        endif
    endEvent

    event OnCellDoorClosed(ObjectReference _cellDoor, Actor whoClosed)
        if (whoClosed == Arrestee)
            ;/ 
                If the prisoner closed the door, that means that it has been lockpicked or unlocked with the key
                Maybe make a guard suspicion system that checks if the door is unlocked, and locks it when he passes by (optionally adding bounty for unlocking the door)
            /;
        endif
        ; Lock the cell door when it's closed
        Debug(self, "OnCellDoorClosed", "Locked Cell Door with a " + config.GetArrestVarString("Jail::Cell Door Lock Level") + " ("+ GetCellDoorLockLevel() +") " + "lock level")
        _cellDoor.SetLockLevel(GetCellDoorLockLevel())
        _cellDoor.Lock()
    endEvent

    event OnUpdateGameTime()
        ; Check if sentence is served, if so, get out of this state
        ; Check if the actor has escaped, if so, go to that state (might be better to leave this for a door event OnOpen or something...)

        ; float timeSinceLastUpdate = CurrentTime - LastUpdate
        Debug(self, "OnUpdateGameTime", "{ timeSinceLastUpdate: "+ TimeSinceLastUpdate +", CurrentTime: "+ CurrentTime +", LastUpdate: "+ LastUpdate +" }")

        ;/
            if (CurrentTime - TimeOfImprisonment) - LastUpdate >= 1 
        /;

        ObjectReference jailCellDoorRef = Game.FindClosestReferenceOfTypeFromRef(config.DoorRef, JailCell, 50.0)
        Debug(self, "OnBeginState", "Found cell door: " + jailCellDoorRef)
 
        UpdateSentenceFromBounty()
        ShowSentenceInfo()

        if (InfamyEnabled)
            ; Update infamy
            config.IncrementStat(Hold, "Infamy Gained", InfamyGainedPerUpdate)
            config.NotifyInfamy(InfamyGainedPerUpdate + " Infamy gained in " + config.GetCityNameFromHold(Hold), config.IS_DEBUG)

            ; Notify once when Recognized/Known Threshold is met

            if (IsInfamyKnown)
                config.NotifyInfamyKnownThresholdMet(Hold)

            elseif (IsInfamyRecognized)
                config.NotifyInfamyRecognizedThresholdMet(Hold)
            endif
            
        endif

        if (SentenceServed)
            GotoState("Released")
        endif

        ; IncreaseSentence(12, true)

        if ((CurrentTime - TimeOfImprisonment) - LastUpdate >= 1)
            config.IncrementStat(Hold, "Days in Jail")
            Game.IncrementStat("Days Jailed")
            config.NotifyJail("Increasing Days Jailed by " + floor((CurrentTime - TimeOfImprisonment) - LastUpdate))
        endif
    
        LastUpdate = Utility.GetCurrentGameTime()
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

        int escapeBountyGotten = floor((BountyNonViolent * percent(EscapeBountyFromCurrentArrest))) + EscapeBounty

        config.NotifyJail("You have gained " + escapeBountyGotten + " Bounty in " + Hold + " for Escaping")
        RevertBounty()
        AddEscapedBounty()
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

event OnFriskBegin(Actor friskSearchPerformer, Actor actorToFrisk)
    ; Happens when the actor is beginning to be frisked
endEvent

event OnFriskEnd(Actor friskSearchPerformer, Actor friskedActor)
    ; Happens when the actor has been frisked
endEvent

event OnStripBegin(Actor stripSearchPerformer, Actor actorToStrip)
    ; Happens when the actor is about to be stripped
endEvent

event OnStripEnd(Actor stripSearchPerformer, Actor strippedActor)
    ; Happens when the actor has been stripped
endEvent

event OnEscortToCellBegin(Actor escortActor, Actor escortedActor)
    ; Happens when the actor is being escorted to their cell
endEvent

event OnEscortToCellEnd(Actor escortActor, Actor escortedActor)
    ; Happens when the actor has been escorted to their cell
endEvent

event OnEscortFromCellBegin(Actor escortActor, Actor escortedActor, ObjectReference destination)
    ; Happens when the actor is being escorted from their cell to the destination
endEvent

event OnEscortFromCellEnd(Actor escortActor, Actor escortedActor, ObjectReference destination)
    ; Happens when the actor has been escorted from their cell to the destination
endEvent

event OnActorCuffed(Actor cuffedActor, bool hands, bool feet)
    ; Happens when the actor has been cuffed (hands bound, maybe feet?)
endEvent

event OnActorUncuffed(Actor uncuffedActor, bool hands, bool feet)
    ; Happens when the actor has been uncuffed (hands unbound, maybe feet?)
endEvent

event OnUndressed(Actor undressedActor)

endEvent

event OnClothed(Actor clothedActor)
    ; Do anything that needs to be done after the actor has been stripped and clothed.
endEvent

event OnCellDoorLocked(ObjectReference _cellDoor, Actor whoLocked)

endEvent

event OnCellDoorUnlocked(ObjectReference _cellDoor, Actor whoUnlocked)

endEvent

event OnCellDoorOpen(ObjectReference _cellDoor, Actor whoOpened)
    ; If the cell door was open by the player, and they are not jailed, this must mean that they lockpicked the door either just because or to get someone out of jail.
    if (whoOpened == config.Player)
        Faction jailFaction = config.GetFaction(config.GetCurrentPlayerHoldLocation())
        ; Add bounty for lockpicking / breaking someone out of jail  if they are witnessed
        ; if (witnessedCrime)
        jailFaction.ModCrimeGold(2000) ; TODO: Test if this works, the faction gotten from the door may not be the crime faction
        Debug(self, "OnCellDoorOpen", "jailFaction: " + jailFaction + ", bounty: " + jailFaction.GetCrimeGold())
    endif
endEvent

event OnCellDoorClosed(ObjectReference _cellDoor, Actor whoOpened)
    ; TODO: Use this event to trigger the Jailed state when the jailor closes the door for the escort scenario
    ; Error(self, "OnCellDoorClosed", "Not currently Jailed, invalid call!")
    ; CellDoorRef.Clear()
    ; Lock the cell door when it's closed
    Debug(self, "OnCellDoorClosed", "Locked Cell Door with a " + config.GetArrestVarString("Jail::Cell Door Lock Level") + " ("+ GetCellDoorLockLevel() +") " + "lock level")
    _cellDoor.SetLockLevel(GetCellDoorLockLevel())
    _cellDoor.Lock()
    CellDoorRef.Clear()
    Debug(self, "OnCellDoorClosed", "Locked Cell Door with a " + config.GetArrestVarString("Jail::Cell Door Lock Level") + " ("+ GetCellDoorLockLevel() +") " + "lock level")
endEvent

; Placeholders for State events
event OnEscapeFail()
    Error(self, "OnEscapeFail", "Not currently Escaping, invalid call!")
endEvent
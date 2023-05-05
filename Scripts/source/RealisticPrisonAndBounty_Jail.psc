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

RealisticPrisonAndBounty_Arrest property arrest
    RealisticPrisonAndBounty_Arrest function get()
        return Game.GetFormFromFile(0x3DF8, GetPluginName()) as RealisticPrisonAndBounty_Arrest
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property arrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return config.arrestVars
    endFunction
endProperty

string property STATE_JAILED    = "Jailed" autoreadonly
string property STATE_ESCAPING  = "Escaping" autoreadonly
string property STATE_ESCAPED   = "Escaped" autoreadonly
string property STATE_RELEASED  = "Released" autoreadonly
string property STATE_FREE      = "Free" autoreadonly

float property TimeOfArrest
    float function get()
        return arrestVars.GetFloat("Arrest::Time of Arrest")
    endFunction
endProperty

bool property IsInfamyEnabled
    bool function get()
        return arrestVars.GetBool("Jail::Infamy Enabled")
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
        return arrestVars.GetFloat("Jail::Minimum Sentence") as int
    endFunction
endProperty

int property MaximumSentence
    int function get()
        return arrestVars.GetFloat("Jail::Maximum Sentence") as int
    endFunction
endProperty

int property BountyExchange
    int function get()
        return arrestVars.GetFloat("Jail::Bounty Exchange") as int
    endFunction
endProperty

int property BountyToSentence
    int function get()
        return arrestVars.GetFloat("Jail::Bounty to Sentence") as int
    endFunction
endProperty

int property Sentence
    int function get()
        return arrestVars.GetFloat("Jail::Sentence") as int
    endFunction
endProperty

bool property IsArrested
    bool function get()
        return arrestVars.GetBool("Arrest::Arrested")
    endFunction
endProperty

bool property IsJailed
    bool function get()
        return arrestVars.GetBool("Jail::Jailed")
    endFunction
endProperty

string property Hold
    string function get()
        return arrestVars.GetString("Arrest::Hold")
    endFunction
endProperty

Faction property ArrestFaction
    Faction function get()
        return arrestVars.GetForm("Arrest::Arrest Faction") as Faction
    endFunction
endProperty

int property BountyNonViolent
    int function get()
        return arrestVars.GetInt("Arrest::Bounty Non-Violent")
    endFunction
endProperty

int property BountyViolent
    int function get()
        return arrestVars.GetInt("Arrest::Bounty Violent")
    endFunction
endProperty

float property EscapeBountyFromCurrentArrest
    float function get()
        return arrestVars.GetFloat("Escape::Escape Bounty from Current Arrest")
    endFunction
endProperty

int property EscapeBounty
    int function get()
        return arrestVars.GetFloat("Escape::Escape Bounty Flat") as int
    endFunction
endProperty

int property Bounty
    int function get()
        return BountyNonViolent + BountyViolent
    endFunction
endProperty

float property TimeOfImprisonment
    float function get()
        return arrestVars.GetFloat("Jail::Time of Imprisonment")
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
float property TimeOfEscape auto

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
        int infamyGainedFlat                    = arrestVars.GetFloat("Jail::Infamy Gained Daily") as int
        float infamyGainedFromCurrentBounty     = arrestVars.GetFloat("Jail::Infamy Gained Daily from Current Bounty")

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
        int recognizedThreshold = arrestVars.GetFloat("Jail::Infamy Recognized Threshold") as int

        return currentInfamy >= recognizedThreshold
    endFunction
endProperty

bool property IsInfamyKnown
    bool function get()
        int currentInfamy = config.GetInfamyGained(Hold)
        int knownThreshold = arrestVars.GetFloat("Jail::Infamy Known Threshold") as int
        
        return currentInfamy >= knownThreshold
    endFunction
endProperty

ObjectReference property JailCell
    ObjectReference function get()
        return arrestVars.GetForm("Jail::Cell") as ObjectReference
    endFunction
endProperty

ObjectReference property CellDoor
    ObjectReference function get()
        return arrestVars.GetForm("Jail::Cell Door") as ObjectReference
    endFunction
endProperty

Actor property Arrestee
    Actor function get()
        return arrestVars.GetForm("Arrest::Arrestee") as Actor
    endFunction
endProperty

bool property IsFriskingEnabled
    bool function get()
        return arrestVars.GetBool("Frisking::Allow Frisking")
    endFunction
endProperty

bool property IsStrippingEnabled
    bool function get()
        return arrestVars.GetBool("Stripping::Allow Stripping")
    endFunction
endProperty

bool property IsClothingEnabled
    bool function get()
        return arrestVars.GetBool("Clothing::Allow Clothing")
    endFunction
endProperty

string property ClothingHandling
    string function get()
        return arrestVars.GetString("Clothing::Handle Clothing On")
    endFunction
endProperty

int property ClothingMaxBounty
    int function get()
        return arrestVars.GetInt("Clothing::Maximum Bounty to Clothe")
    endFunction
endProperty

int property ClothingMaxBountyViolent
    int function get()
        return arrestVars.GetInt("Clothing::Maximum Violent Bounty to Clothe")
    endFunction
endProperty

int property ClothingMaxSentence
    int function get()
        return arrestVars.GetInt("Clothing::Maximum Sentence to Clothe")
    endFunction
endProperty

bool property ClotheWhenDefeated
    bool function get()
        return arrestVars.GetBool("Clothing::Clothe when Defeated")
    endFunction
endProperty

string property OutfitName
    string function get()
        return arrestVars.GetString("Clothing::Outfit::Name")
    endFunction
endProperty

Armor property OutfitHead
    Armor function get()
        return arrestVars.GetForm("Clothing::Outfit::Head") as Armor
    endFunction
endProperty

Armor property OutfitBody
    Armor function get()
        return arrestVars.GetForm("Clothing::Outfit::Body") as Armor
    endFunction
endProperty

Armor property OutfitHands
    Armor function get()
        return arrestVars.GetForm("Clothing::Outfit::Hands") as Armor
    endFunction
endProperty

Armor property OutfitFeet
    Armor function get()
        return arrestVars.GetForm("Clothing::Outfit::Feet") as Armor
    endFunction
endProperty

bool property IsOutfitConditional
    bool function get()
        return arrestVars.GetBool("Clothing::Outfit::Conditional")
    endFunction
endProperty

int property OutfitMinBounty
    int function get()
        return arrestVars.GetFloat("Clothing::Outfit::Minimum Bounty") as int
    endFunction
endProperty

int property OutfitMaxBounty
    int function get()
        return arrestVars.GetFloat("Clothing::Outfit::Maximum Bounty") as int
    endFunction
endProperty

bool property IsStripped
    bool function get()
        return arrestVars.GetBool("Jail::Stripped")
    endFunction
endProperty

bool property IsClothed
    bool function get()
        return arrestVars.GetBool("Jail::Clothed")
    endFunction
endProperty

bool property ShouldBeFrisked
    bool function get()
        if (!IsFriskingEnabled)
            return false
        endif

        bool isFriskingUnconditional    = arrestVars.GetBool("Frisking::Unconditional Frisking")
        int friskingMinBounty           = arrestVars.GetInt("Frisking::Bounty for Frisking")
        bool shouldFrisk                = isFriskingUnconditional || (!isFriskingUnconditional && Bounty >= friskingMinBounty) 

        return shouldFrisk
    endFunction
endProperty

bool property ShouldBeStripped
    bool function get()
        if (IsStrippingEnabled)
            bool stripOnEscape = arrestVars.GetBool("Escape::Should Strip Search")
            if (self.GetState() == STATE_ESCAPED && stripOnEscape)
                return true
            endif

            string strippingHandling        = arrestVars.GetString("Stripping::Handle Stripping On")
            int strippingMinBounty          = arrestVars.GetInt("Stripping::Bounty to Strip")
            int strippingMinViolentBounty   = arrestVars.GetInt("Stripping::Violent Bounty to Strip")
            int strippingMinSentence        = arrestVars.GetInt("Stripping::Sentence to Strip")
    
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
            
            LogProperty(self, "ShouldBeClothed", "\n" + \
                "ClothingHandling: " + ClothingHandling + "\n" + \
                "meetsBountyRequirements: " + meetsBountyRequirements + "\n" + \
                "meetsSentenceRequirements: " + meetsSentenceRequirements + "\n" + \
                "ClothingMaxSentence: " + ClothingMaxSentence + "\n" + \
                "Sentence: " + Sentence + "\n" + \
                "shouldClothe: " + shouldClothe + "\n" \
            )

            return shouldClothe
        endif
    
        return false
    endFunction
endProperty



ReferenceAlias property CaptorRef auto
; RealisticPrisonAndBounty_CellDoorRef property CellDoorRef auto

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

    arrestVars.SetFloat("Jail::Time of Imprisonment", CurrentTime)
endFunction

function SetupJailVars()
    arrestVars.SetBool("Jail::Infamy Enabled", config.IsInfamyEnabled(Hold))
    arrestVars.SetFloat("Jail::Infamy Recognized Threshold", config.GetInfamyRecognizedThreshold(Hold))
    arrestVars.SetFloat("Jail::Infamy Known Threshold", config.GetInfamyKnownThreshold(Hold))
    arrestVars.SetFloat("Jail::Infamy Gained Daily from Current Bounty", config.GetInfamyGainedDailyFromArrestBounty(Hold))
    arrestVars.SetFloat("Jail::Infamy Gained Daily", config.GetInfamyGainedDaily(Hold))
    arrestVars.SetFloat("Jail::Bounty Exchange", config.GetJailBountyExchange(Hold))
    arrestVars.SetFloat("Jail::Bounty to Sentence", config.GetJailBountyToSentence(Hold))
    arrestVars.SetFloat("Jail::Minimum Sentence", config.GetJailMinimumSentence(Hold))
    arrestVars.SetFloat("Jail::Maximum Sentence", config.GetJailMaximumSentence(Hold))
    arrestVars.SetFloat("Jail::Cell Search Thoroughness", config.GetJailCellSearchThoroughness(Hold))
    arrestVars.SetString("Jail::Cell Lock Level", config.GetJailCellDoorLockLevel(Hold))
    arrestVars.SetBool("Jail::Fast Forward", config.IsJailFastForwardEnabled(Hold))
    arrestVars.SetFloat("Jail::Day to Fast Forward From", config.GetJailFastForwardDay(Hold))
    arrestVars.SetString("Jail::Handle Skill Loss", config.GetJailHandleSkillLoss(Hold))
    arrestVars.SetFloat("Jail::Day to Start Losing Skills", config.GetJailDayToStartLosingSkills(Hold))
    arrestVars.SetFloat("Jail::Chance to Lose Skills", config.GetJailChanceToLoseSkillsDaily(Hold))
    arrestVars.SetFloat("Jail::Recognized Criminal Penalty", config.GetJailRecognizedCriminalPenalty(Hold))
    arrestVars.SetFloat("Jail::Known Criminal Penalty", config.GetJailKnownCriminalPenalty(Hold))
    arrestVars.SetFloat("Jail::Bounty to Trigger Infamy", config.GetJailBountyToTriggerCriminalPenalty(Hold))
    arrestVars.SetBool("Release::Release Fees Enabled", config.IsJailReleaseFeesEnabled(Hold))
    arrestVars.SetFloat("Release::Chance for Release Fees Event", config.GetReleaseChanceForReleaseFeesEvent(Hold))
    arrestVars.SetFloat("Release::Bounty to Owe Fees", config.GetReleaseBountyToOweFees(Hold))
    arrestVars.SetFloat("Release::Release Fees from Arrest Bounty", config.GetReleaseReleaseFeesFromBounty(Hold))
    arrestVars.SetFloat("Release::Release Fees Flat", config.GetReleaseReleaseFeesFlat(Hold))
    arrestVars.SetFloat("Release::Days Given to Pay Release Fees", config.GetReleaseDaysGivenToPayReleaseFees(Hold))
    arrestVars.SetBool("Release::Item Retention Enabled", config.IsItemRetentionEnabledOnRelease(Hold))
    arrestVars.SetFloat("Release::Bounty to Retain Items", config.GetReleaseBountyToRetainItems(Hold))
    arrestVars.SetBool("Release::Redress on Release", config.IsAutoDressingEnabledOnRelease(Hold))
    arrestVars.SetFloat("Escape::Escape Bounty from Current Arrest", config.GetEscapedBountyFromCurrentArrest(Hold))
    arrestVars.SetFloat("Escape::Escape Bounty Flat", config.GetEscapedBountyFlat(Hold))
    arrestVars.SetBool("Escape::Allow Surrendering", config.IsSurrenderEnabledOnEscape(Hold))
    arrestVars.SetBool("Escape::Should Frisk Search", config.ShouldFriskOnEscape(Hold))
    arrestVars.SetBool("Escape::Should Strip Search", config.ShouldStripOnEscape(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Impersonation", config.GetChargeBountyForImpersonation(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Enemy of Hold", config.GetChargeBountyForEnemyOfHold(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Stolen Items", config.GetChargeBountyForStolenItems(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Stolen Item", config.GetChargeBountyForStolenItemFromItemValue(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Contraband", config.GetChargeBountyForContraband(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Cell Key", config.GetChargeBountyForCellKey(Hold))
    arrestVars.SetBool("Frisking::Allow Frisking", config.IsFriskingEnabled(Hold))
    arrestVars.SetBool("Frisking::Unconditional Frisking", config.IsFriskingUnconditional(Hold))
    arrestVars.SetFloat("Frisking::Bounty for Frisking", config.GetFriskingBountyRequired(Hold))
    arrestVars.SetFloat("Frisking::Frisking Thoroughness", config.GetFriskingThoroughness(Hold))
    arrestVars.SetBool("Frisking::Confiscate Stolen Items", config.IsFriskingStolenItemsConfiscated(Hold))
    arrestVars.SetBool("Frisking::Strip if Stolen Items Found", config.IsFriskingStripSearchWhenStolenItemsFound(Hold))
    arrestVars.SetFloat("Frisking::Stolen Items Required for Stripping", config.GetFriskingStolenItemsRequiredForStripping(Hold))
    arrestVars.SetBool("Stripping::Allow Stripping", config.IsStrippingEnabled(Hold))
    arrestVars.SetString("Stripping::Handle Stripping On", config.GetStrippingHandlingCondition(Hold))
    arrestVars.SetInt("Stripping::Bounty to Strip", config.GetStrippingMinimumBounty(Hold))
    arrestVars.SetInt("Stripping::Violent Bounty to Strip", config.GetStrippingMinimumViolentBounty(Hold))
    arrestVars.SetInt("Stripping::Sentence to Strip", config.GetStrippingMinimumSentence(Hold))
    arrestVars.SetBool("Stripping::Strip when Defeated", config.IsStrippedOnDefeat(Hold))
    arrestVars.SetFloat("Stripping::Stripping Thoroughness", config.GetStrippingThoroughness(Hold))
    arrestVars.SetBool("Clothing::Allow Clothing", config.IsClothingEnabled(Hold))
    arrestVars.SetString("Clothing::Handle Clothing On", config.GetClothingHandlingCondition(Hold))
    arrestVars.SetFloat("Clothing::Maximum Bounty to Clothe", config.GetClothingMaximumBounty(Hold))
    arrestVars.SetFloat("Clothing::Maximum Violent Bounty to Clothe", config.GetClothingMaximumViolentBounty(Hold))
    arrestVars.SetFloat("Clothing::Maximum Sentence to Clothe", config.GetClothingMaximumSentence(Hold))
    arrestVars.SetBool("Clothing::Clothe when Defeated", config.IsClothedOnDefeat(Hold))
    arrestVars.SetString("Clothing::Outfit", config.GetClothingOutfit(Hold))

    ; Outfit
    arrestVars.SetString("Clothing::Outfit::Name", config.GetClothingOutfit(Hold))
    arrestVars.SetForm("Clothing::Outfit::Head", config.GetOutfitPart(Hold, "Head"))
    arrestVars.SetForm("Clothing::Outfit::Body", config.GetOutfitPart(Hold, "Body"))
    arrestVars.SetForm("Clothing::Outfit::Hands", config.GetOutfitPart(Hold, "Hands"))
    arrestVars.SetForm("Clothing::Outfit::Feet", config.GetOutfitPart(Hold, "Feet"))
    arrestVars.SetBool("Clothing::Outfit::Conditional", config.IsClothingOutfitConditional(Hold))
    arrestVars.SetFloat("Clothing::Outfit::Minimum Bounty", config.GetClothingOutfitMinimumBounty(Hold))
    arrestVars.SetFloat("Clothing::Outfit::Maximum Bounty", config.GetClothingOutfitMaximumBounty(Hold))

    ; Dynamic Vars
    int arrestParams = arrestVars.GetObject("Arrest::Arrest Params")
    int sentenceOverride = JMap.getInt(arrestParams, "Sentence")
    bool hasSentenceOverride = JMap.hasKey(arrestParams, "Sentence")
    arrestVars.SetForm("Arrest::Arrest Faction", config.GetFaction(Hold))
    arrestVars.SetFloat("Jail::Sentence", int_if(hasSentenceOverride, sentenceOverride, (BountyNonViolent + GetViolentBountyConverted()) / BountyToSentence))
    arrestVars.SetFloat("Jail::Time of Imprisonment", CurrentTime)
    arrestVars.SetBool("Jail::Jailed", true)
    arrestVars.SetInt("Jail::Cell Door Old Lock Level", CellDoor.GetLockLevel())
    arrestVars.SetForm("Jail::Cell Door", GetNearestDoor(Arrestee, 200))

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

    arrestVars.SetFloat("Arrest::Bounty Non-Violent", _bountyNonViolent)
    arrestVars.SetFloat("Arrest::Bounty Violent", _bountyViolent)
    arrestVars.SetFloat("Jail::Sentence", (_bountyNonViolent + GetViolentBountyConverted()) / BountyToSentence)

    ClearBounty(ArrestFaction)
endFunction

function UpdateSentenceFromBounty()
    int _bountyNonViolent    = ArrestFaction.GetCrimeGoldNonViolent()
    int _bountyViolent       = ArrestFaction.GetCrimeGoldViolent()

    arrestVars.SetFloat("Arrest::Bounty Non-Violent", BountyNonViolent + _bountyNonViolent)
    arrestVars.SetFloat("Arrest::Bounty Violent", BountyViolent + _bountyViolent)
    arrestVars.SetFloat("Jail::Sentence", (BountyNonViolent + GetViolentBountyConverted()) / BountyToSentence)

    ClearBounty(ArrestFaction)
endFunction

; Get the bounty from storage and add it into active bounty for this faction.
function RevertBounty()
    ArrestFaction.SetCrimeGold(BountyNonViolent)
    ArrestFaction.SetCrimeGoldViolent(BountyViolent)

    ; Should we clear it from storage vars?
    ; config.SetArrestVarInt("Arrest::Bounty Non-Violent", 0)
    ; config.SetArrestVarInt("Arrest::Bounty Violent", 0)
endFunction

int function GetCellDoorLockLevel()
    string configuredLockLevel = arrestVars.GetString("Jail::Cell Lock Level")
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
    int infamyGainedFlat                    = arrestVars.GetFloat("Jail::Infamy Gained Daily") as int
    float infamyGainedFromCurrentBounty     = arrestVars.GetFloat("Jail::Infamy Gained Daily from Current Bounty")

    ; floor(7000 * percent(1.44) + 40 = 7000 * 0.0144 + 40 = 100.8 + 40 = 140.8)
    ; <=> floor(140.8) = 140
    return floor((Bounty * percent(infamyGainedFromCurrentBounty)) + infamyGainedFlat)
endFunction

bool function IncreaseSentence(int daysToIncreaseBy, bool shouldAffectBounty = false)
    int previousSentence = Sentence
    int newSentence = Sentence + Max(0, daysToIncreaseBy) as int
    arrestVars.SetFloat("Jail::Sentence", newSentence)

    if (shouldAffectBounty)
        arrestVars.SetFloat("Arrest::Bounty Non-Violent", BountyNonViolent + (daysToIncreaseBy * BountyToSentence))
    endif

    config.NotifyJail("Your sentence has been increased by " + daysToIncreaseBy + " days")
    config.NotifyJail("Your bounty has also increased by " + (daysToIncreaseBy * BountyToSentence), condition = shouldAffectBounty)

    return newSentence == previousSentence + daysToIncreaseBy
endFunction

bool function DecreaseSentence(int daysToDecreaseBy, bool shouldAffectBounty = false)
    int previousSentence = Sentence
    int newSentence = Sentence - Max(0, daysToDecreaseBy) as int
    arrestVars.SetFloat("Jail::Sentence", newSentence)

    if (shouldAffectBounty)
        arrestVars.SetFloat("Arrest::Bounty Non-Violent", BountyNonViolent - (daysToDecreaseBy * BountyToSentence))
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
    Debug(self, "ShowArrestVars", "\n" + Hold + " Arrest Vars: " + GetContainerList(arrestVars.GetContainer()))
endFunction

function ShowArrestParams()
    int arrestParams = arrestVars.GetObject("Arrest::Arrest Params")
    int arrestParamsObj = JMap.getObj(arrestVars.GetContainer(), "Arrest::Arrest Params")
    int arrestParamsBV = JMap.getInt(arrestVars.GetContainer(), "Arrest::Bounty Violent")
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

    Debug(self, "ShowSentenceInfo", "\n" + Hold + " Sentence: { \n\t" + \
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
        arrestVars.SetForm("Jail::Worn Outfit::Head", headClothing)
        arrestVars.SetForm("Jail::Worn Outfit::Body", bodyClothing)
        arrestVars.SetForm("Jail::Worn Outfit::Hands", handsClothing)
        arrestVars.SetForm("Jail::Worn Outfit::Feet", feetClothing)
    endif

    undressedActor.EquipItem(headClothing)
    undressedActor.EquipItem(bodyClothing)
    undressedActor.EquipItem(handsClothing)
    undressedActor.EquipItem(feetClothing)
endFunction

bool function AlreadyHasWornOutfit()
    return  arrestVars.GetForm("Jail::Worn Outfit::Head") || \
            arrestVars.GetForm("Jail::Worn Outfit::Body") || \
            arrestVars.GetForm("Jail::Worn Outfit::Hands") || \
            arrestVars.GetForm("Jail::Worn Outfit::Feet")
endFunction

function FriskActor(Actor actorToFrisk)
    float friskingThoroughness = arrestVars.GetFloat("Frisking::Frisking Thoroughness")
    Debug(self, "FriskActor", "Frisked Actor: " + actorToFrisk)

endFunction

function StripActor(Actor actorToStrip)
    float strippingThoroughness = arrestVars.GetFloat("Stripping::Stripping Thoroughness")

    ; Determine what to strip based on thoroughness
    if (strippingThoroughness >= 100.0)
        ; Strip naked, ask to spread cheeks, etc...
    
    elseif (strippingThoroughness >= 80.0)
    
    elseif (strippingThoroughness >= 60.0)
    
    elseif (strippingThoroughness >= 40.0)

    elseif (strippingThoroughness >= 20.0)
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
    Debug(self, "StripActor", "Stripped Actor: " + actorToStrip)

    actorToStrip.RemoveAllItems()
    OnUndressed(actorToStrip)
endFunction

event OnJailedBegin(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnJailedBegin", "Starting jailing process...")
    SetupJailVars()
    GotoState("Jailed")
    TriggerImprisonment()
endEvent


event OnJailedEnd(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnJailedEnd", "Ending jailing process... (Released, Escaped?)")
    arrestVars.Delete()
endEvent

state Jailed
    event OnBeginState()
        Debug(self, "OnBeginState", "Jailed state begin")

        ; Keep updating while in jail
        LastUpdate = Utility.GetCurrentGameTime()
        RegisterForSingleUpdateGameTime(1.0)
    endEvent

    event OnFriskBegin(Actor friskSearchPerformer, Actor actorToFrisk)
        ; Happens when the actor is beginning to be frisked
    endEvent

    event OnFriskEnd(Actor friskSearchPerformer, Actor friskedActor)
        ; Happens when the actor has been frisked
        if (IsStrippingEnabled)
            ; We dont use ShouldBeStripped since it contains bounty and sentence conditions,
            ; here we already know we want the actor to be stripped because of the Frisking condition,
            ; so we only need to check if stripping is enabled
            int stolenItemsFound = 0 ; Logic to be determined
            bool shouldStripSearchStolenItemsFound  = arrestVars.GetBool("Frisking::Strip if Stolen Items Found")
            int stolenItemsRequiredToStrip          = arrestVars.GetInt("Frisking::Stolen Items Required for Stripping")
            bool meetsStolenItemsCriteriaToStrip    = stolenItemsFound >= stolenItemsRequiredToStrip

            if (shouldStripSearchStolenItemsFound && meetsStolenItemsCriteriaToStrip)
                StripActor(friskedActor)
            endif

        endif
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
            ; Make noise to attract guards attention,
            ; if the guard sees the door open, goto Escaped state
            GotoState("Escaping")
            ; Actor nearestGuard = GetNearestActor(config.Player, 200)
            ; Actor captor = arrestVars.GetForm("Arrest::Arresting Guard") as Actor
            Actor captor = arrestVars.GetForm("Arrest::Arresting Guard") as Actor
            CaptorRef.RegisterForLOS(captor, Arrestee)

            captor.SetAlert()
            Debug(self, "OnCellDoorOpen", "Got Actor: " + captor)
            CaptorRef.ForceRefTo(captor)
        endif
    endEvent

    event OnCellDoorClosed(ObjectReference _cellDoor, Actor whoClosed)

    endEvent

    event OnGuardSeesPrisoner(Actor akGuard)
        Debug(self, "OnGuardSeesPrisoner", akGuard + " is seeing " + Arrestee + ", but the prisoner is in jail.")
    endEvent

    event OnUpdateGameTime()
        ; Check if sentence is served, if so, get out of this state
        ; Check if the actor has escaped, if so, go to that state (might be better to leave this for a door event OnOpen or something...)

        ; float timeSinceLastUpdate = CurrentTime - LastUpdate
        Debug(self, "OnUpdateGameTime", "{ timeSinceLastUpdate: "+ TimeSinceLastUpdate +", CurrentTime: "+ CurrentTime +", LastUpdate: "+ LastUpdate +" }")

        ;/
            if (CurrentTime - TimeOfImprisonment) - LastUpdate >= 1 
        /;

        ; ObjectReference jailCellDoorRef = Game.FindClosestReferenceOfTypeFromRef(config.DoorRef, JailCell, 50.0)
        ; Debug(self, "OnBeginState", "Found cell door: " + jailCellDoorRef)
 
        UpdateSentenceFromBounty()
        ShowSentenceInfo()

        if (IsInfamyEnabled)
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

    function TriggerImprisonment()
        Debug(self, "TriggerImprisonment", "Jailed state begin")
        ; Begin Jailed process, Actor is arrested and jailed
        ; Switch timescale to prison timescale
        config.IncrementStat(Hold, "Times Jailed")

        if (JailCell)
            CellDoor.SetOpen(false)
            CellDoor.Lock()
        endif

        if (ShouldBeFrisked)
            
        endif

        if (ShouldBeStripped)
            StripActor(Arrestee)

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

        ; CellDoorRef.ForceRefTo(CellDoor)
        
        ; Debug(self, "OnBeginState", "DoorRef: " + config.DoorRef + ", DoorRef.Type: " + config.DoorRef.GetType() + ", JailCellMarker: " + JailCell + ", Found cell door: " + jailCellDoorRef)
    endFunction
endState

;/
    This state represents the scenario where the prisoner
    is trying to escape, but hasn't been seen yet.
/;
state Escaping
    event OnBeginState()

    endEvent

    event OnUpdateGameTime()

    endEvent

    event OnGuardSeesPrisoner(Actor akGuard)
        Debug(self, "OnGuardSeesPrisoner", akGuard + " is seeing " + Arrestee)
        akGuard.SetAlert()
        akGuard.StartCombat(Arrestee)
        GotoState("Escaped")
        TriggerEscape()
    endEvent

    event OnCellDoorOpen(ObjectReference _cellDoor, Actor whoOpened)

    endEvent

    event OnCellDoorClosed(ObjectReference _cellDoor, Actor whoClosed)
        if (whoClosed == Arrestee)
            ;/ 
                If the prisoner closed the door, that means that it has been lockpicked or unlocked with the key
                Maybe make a guard suspicion system that checks if the door is unlocked, and locks it when he passes by (optionally increasing the sentence for unlocking the door)
            /;
            Key cellKey = _cellDoor.GetKey()
            if (Arrestee.GetItemCount(cellKey) > 0)
                ; Arrestee has the key, lock the door
                _cellDoor.Lock()
            endif

            bool isArresteeInsideCell = IsActorNearReference(Arrestee, JailCell)

            if (isArresteeInsideCell)
                Debug(self, "OnCellDoorClosed", Arrestee + " is inside the cell.")
                GotoState("Jailed") ; Revert to Jailed since we have not been found escaping yet
            endif
            float distanceFromMarkerToDoor = JailCell.GetDistance(CellDoor)
            Debug(self, "OnCellDoorClosed", "Distance from marker to cell door: " + distanceFromMarkerToDoor)
        endif
    endEvent

    event OnEscapeFail()
        UpdateSentence()
    endEvent

    event OnEndState()
        Debug(self, "OnEndState", "Escaping state end")
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

;/
    This state represents the scenario where the prisoner
    is trying to escape and has been seen, or has escaped successfully (before transitioning to the Free state)
/;
state Escaped
    event OnBeginState()
        TimeOfEscape = CurrentTime
        Debug(self, "OnBeginState", "Set Time of Escape to " + TimeOfEscape)
        Debug(self, "OnBeginState", "Impossible to go back to cell when it reaches " + ((TimeOfEscape + 20) / 0.04166666666666666666666666666667))
    endEvent

    event OnGuardSeesPrisoner(Actor akGuard)
        Debug(self, "OnGuardSeesPrisoner", akGuard + " is seeing " + Arrestee + " but the prisoner has already been seen escaping.")
        CaptorRef.UnregisterForLOS(akGuard, config.Player)
    endEvent

    event OnCellDoorClosed(ObjectReference _cellDoor, Actor whoClosed)
        if (whoClosed == Arrestee)
            bool isArresteeInsideCell = IsActorNearReference(Arrestee, JailCell)

            Actor captor = arrestVars.GetForm("Arrest::Arresting Guard") as Actor
            if (captor.IsInCombat() && isArresteeInsideCell)
                captor.StopCombat()
                Arrestee.StopCombatAlarm()
                _cellDoor.SetOpen(false)
                _cellDoor.Lock()

                UpdateSentence()
                UpdateTimeOfImprisonment() ; Start the sentence from this point
                config.NotifyJail("Your sentence in " + Hold + " was set to " + Sentence + " days in jail")
                ShowArrestVars()

                if (ShouldBeStripped)
                    StripActor(Arrestee)
        
                elseif (ShouldBeClothed && !ActorHasClothing(Arrestee))
                    ; Only handle clothing here when not stripped, which means the Actor did not have any clothing
                    SetJailOutfit(Arrestee, includeFeetClothingOnDefaultOutfit = Utility.RandomInt(0, 3) == 0) ; 25% Chance to include feet clothing
                    OnClothed(Arrestee)
                endif

                GotoState(STATE_JAILED)
            endif

        endif
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

    function TriggerEscape()
        Debug(self, "TriggerEscape", "Escaped state begin")
        arrestVars.SetBool("Jail::Jailed", false)
        config.IncrementStat(Hold, "Times Escaped")
        Game.IncrementStat("Jail Escapes")

        int escapeBountyGotten = floor((BountyNonViolent * percent(EscapeBountyFromCurrentArrest))) + EscapeBounty

        config.NotifyJail("You have gained " + escapeBountyGotten + " Bounty in " + Hold + " for Escaping")
        RevertBounty()
        AddEscapedBounty()
    endFunction
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

event OnEscortToJailEnd()
    ; Happens when the Actor should be imprisoned after being arrested and upon arriving at the jail. (called from Arrest)
endEvent

event OnTeleportToJail(bool inCell)
    ; Happens when the Actor is teleported to the jail after being arrested
    if (ShouldBeFrisked && !ShouldBeStripped)
        OnFriskBegin(none, Arrestee)
        FriskActor(Arrestee)
        OnFriskEnd(none, Arrestee)
    endif

    if (ShouldBeStripped)
        OnStripBegin(none, Arrestee)
        StripActor(Arrestee)
        OnStripEnd(none, Arrestee)
    endif
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
    if (whoOpened == config.Player && config.Player != Arrestee)
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
    Debug(self, "OnCellDoorClosed", "Locked Cell Door with a " + arrestVars.GetString("Jail::Cell Door Lock Level") + " ("+ GetCellDoorLockLevel() +") " + "lock level")
    _cellDoor.SetLockLevel(GetCellDoorLockLevel())
    _cellDoor.Lock()
    ; CellDoorRef.Clear()
    Debug(self, "OnCellDoorClosed", "Locked Cell Door with a " + arrestVars.GetString("Jail::Cell Door Lock Level") + " ("+ GetCellDoorLockLevel() +") " + "lock level")
endEvent

; Placeholders for State events
event OnEscapeFail()
    Error(self, "OnEscapeFail", "Not currently Escaping, invalid call!")
endEvent

event OnGuardSeesPrisoner(Actor akGuard)
        
endEvent

function TriggerEscape()
    Error(self, "TriggerEscape", "Not currently Escaping, invalid call!")
endFunction

function TriggerImprisonment()
    Error(self, "TriggerImprisonment", "Not currently jailed, invalid call!")
endFunction
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

string property CurrentState
    string function get()
        return self.GetState()
    endFunction
endProperty

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
        return TimeOfImprisonment + (gameHour * 24 * arrestVars.Sentence)
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
        if (arrestVars.IsStripped) ; Already stripped
            return false
        endif

        if (IsStrippingEnabled)
            bool stripOnEscape = arrestVars.GetBool("Escape::Should Strip Search")
            if (Prisoner.IsEscapee() && stripOnEscape)
                return true
            endif

            string strippingHandling        = arrestVars.GetString("Stripping::Handle Stripping On")
            int strippingMinBounty          = arrestVars.GetInt("Stripping::Bounty to Strip")
            int strippingMinViolentBounty   = arrestVars.GetInt("Stripping::Violent Bounty to Strip")
            int strippingMinSentence        = arrestVars.GetInt("Stripping::Sentence to Strip")
    
            bool meetsBountyRequirements = (BountyNonViolent >= strippingMinBounty) || (BountyViolent >= strippingMinViolentBounty)
            bool meetsSentenceRequirements = arrestVars.Sentence >= strippingMinSentence
            bool shouldStrip =  (strippingHandling == "Unconditionally") || \
                                (strippingHandling == "Minimum Bounty" && meetsBountyRequirements) || \
                                (strippingHandling == "Minimum Sentence" && meetsSentenceRequirements)
            
            ; LogProperty(self, "ShouldBeStripped", "\n" + \
            ;     "strippingHandling: " + strippingHandling + "\n" + \
            ;     "strippingMinBounty: " + strippingMinBounty + "\n" + \
            ;     "strippingMinViolentBounty: " + strippingMinViolentBounty + "\n" + \
            ;     "strippingMinSentence: " + strippingMinSentence + "\n" + \
            ;     "meetsBountyRequirements: " + meetsBountyRequirements + "\n" + \
            ;     "meetsSentenceRequirements: " + meetsSentenceRequirements + "\n" + \
            ;     "shouldStrip: " + shouldStrip + "\n" \
            ; )

            return shouldStrip
        endif
    
        return false
    endFunction
endProperty

bool property ShouldItemsBeRetained
    bool function get()
        bool itemRetentionEnabled = arrestVars.GetBool("Release::Item Retention Enabled")
        if (!itemRetentionEnabled)
            return false
        endif

        int minBountyToRetainItems = arrestVars.GetInt("Release::Bounty to Retain Items")
        return arrestVars.Bounty >= minBountyToRetainItems
    endFunction
endProperty

bool property ShouldBeClothed
    bool function get()
        if (IsClothingEnabled)
            bool meetsBountyRequirements = (BountyNonViolent <= ClothingMaxBounty) && (BountyViolent <= ClothingMaxBountyViolent)
            bool meetsSentenceRequirements = arrestVars.Sentence <= ClothingMaxSentence
            bool shouldClothe = (ClothingHandling == "Unconditionally") || \
                                (ClothingHandling == "Maximum Bounty" && meetsBountyRequirements) || \
                                (ClothingHandling == "Maximum Sentence" && meetsSentenceRequirements)
            
            ; LogProperty(self, "ShouldBeClothed", "\n" + \
            ;     "ClothingHandling: " + ClothingHandling + "\n" + \
            ;     "meetsBountyRequirements: " + meetsBountyRequirements + "\n" + \
            ;     "meetsSentenceRequirements: " + meetsSentenceRequirements + "\n" + \
            ;     "ClothingMaxSentence: " + ClothingMaxSentence + "\n" + \
            ;     "Sentence: " + arrestVars.Sentence + "\n" + \
            ;     "shouldClothe: " + shouldClothe + "\n" \
            ; )

            return shouldClothe
        endif
    
        return false
    endFunction
endProperty



RealisticPrisonAndBounty_CaptorRef property CaptorRef auto
RealisticPrisonAndBounty_PrisonerRef property Prisoner auto

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
    arrestVars.SetFloat("Jail::Sentence", (BountyNonViolent + GetViolentBountyConverted()) / BountyToSentence)
    arrestVars.SetFloat("Jail::Time of Imprisonment", CurrentTime)
    arrestVars.SetBool("Jail::Jailed", true)
    arrestVars.SetForm("Jail::Cell Door", GetNearestJailDoorOfType(GetJailBaseDoorID(arrestVars.Hold), Arrestee, 10000))
    arrestVars.SetInt("Jail::Cell Door Old Lock Level", arrestVars.CellDoor.GetLockLevel())
    arrestVars.SetForm("Jail::Teleport Release Location", config.GetJailTeleportReleaseMarker(arrestVars.Hold))
    arrestVars.SetForm("Jail::Prisoner Items Container", config.GetJailPrisonerItemsContainer(arrestVars.Hold))

    ; ; inventation time
    arrestVars.SetObject("Jail::Prisoner Equipped Items", JArray.object())

    Debug(self, "SetupJailVars", "Found Cell Door: " + arrestVars.CellDoor)

    OverrideInfamy(700)

    Debug(self, "SetupJailVars", "Finished setting up jail variables...")
endFunction

function OverrideInfamy(int value)
    config.IncrementStat(arrestVars.Hold, "Infamy Gained", value) ; To fix with an override function, since it keeps adding each time we are jailed
    Debug(self, "OverrideInfamy", "Overriden infamy for " + arrestVars.Hold +" with a value of: " + value)
endFunction

int function GetViolentBountyConverted()
    Debug(self, "GetViolentBountyConverted", "Violent Bounty Exchanged: " + floor(BountyViolent * (100 / BountyExchange)))
    Debug(self, "GetViolentBountyConverted", "Violent Bounty: " + BountyViolent)
    Debug(self, "GetViolentBountyConverted", "Bounty Exchange: " + BountyExchange)
    return floor(BountyViolent * (100 / BountyExchange))
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

function ShowArrestVars()
    Debug(self, "ShowArrestVars", "\n" + Hold + " Arrest Vars: " + GetContainerList(arrestVars.GetHandle()))
endFunction

function ShowArrestParams()
    int arrestParams = arrestVars.GetObject("Arrest::Arrest Params")
    int arrestParamsObj = JMap.getObj(arrestVars.GetHandle(), "Arrest::Arrest Params")
    int arrestParamsBV = JMap.getInt(arrestVars.GetHandle(), "Arrest::Bounty Violent")
    bool isObject = JValue.isMap(arrestParamsObj)
    Debug(self, "ShowArrestParams (id: "+ arrestParamsObj +", isObject: "+ isObject +", arrestParamsBV: "+ arrestParamsBV +")", "\n" + Hold + " Arrest Params: " + GetContainerList(arrestParams))
endFunction

event OnJailedBegin(string eventName, string strArg, float numArg, Form sender)
    SetupJailVars()
    Prisoner.ForceRefTo(arrestVars.Arrestee)
    GotoState(STATE_JAILED)
    TriggerImprisonment()
endEvent

event OnJailedEnd(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnJailedEnd", "Ending jailing process... (Released, Escaped?)")
    arrestVars.Clear()
endEvent

state Jailed
    event OnBeginState()
        Debug(self, "OnBeginState", CurrentState + " state begin")

        ; First jail update
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
                Prisoner.Strip()
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
            Prisoner.Clothe()
        endif

        Debug(self, "OnUndressed", "undressedActor: " + undressedActor)
    endEvent

    event OnClothed(Actor clothedActor, RealisticPrisonAndBounty_Outfit prisonerOutfit)
        ; Do anything that needs to be done after the actor has been stripped and clothed.
        Debug(self, "OnClothed", "clothedActor: " + clothedActor)

    endEvent

    event OnCellDoorOpen(ObjectReference _cellDoor, Actor whoOpened)
        if (whoOpened == Arrestee)
            ; arrestVars.SetForm("Jail::Cell Door", _cellDoor)
            ; Make noise to attract guards attention,
            ; if the guard sees the door open, goto Escaped state
            _cellDoor.CreateDetectionEvent(Arrestee, 300)
            GotoState("Escaping")
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

    event OnEscapeFail()
        if (ShouldBeStripped)
            Prisoner.Strip()

        elseif (ShouldBeClothed && !ActorHasClothing(Arrestee))
            ; Only handle clothing here when not stripped, which means the Actor did not have any clothing
            Prisoner.Clothe()
        endif

        Prisoner.UpdateSentence()
        Prisoner.TriggerCrimimalPenalty()
        Prisoner.SetTimeOfImprisonment() ; Start the sentence from this point
    endEvent

    event OnSentenceChanged(Actor akPrisoner, int oldSentence, int newSentence, bool hasSentenceIncreased, bool bountyAffected)
        if (akPrisoner != config.Player)
            ; Prisoner is an NPC
            return
        endif
        
        if (hasSentenceIncreased)
            int daysIncreased = newSentence - oldSentence
            config.NotifyJail("Your sentence was extended by " + daysIncreased + " days")

            if (ShouldBeStripped)
                ; Strip since the sentence got extended
                ; StartGuardWalkToCellToStrip()
                Prisoner.Strip()

            elseif (ShouldBeFrisked)
                Prisoner.Frisk()
            endif

        else
            int daysDecreased = oldSentence - newSentence
            config.NotifyJail("Your sentence was reduced by " + daysDecreased + " days")
            ; config.NotifyJail("Your bounty has also decreased by " + (daysDecreased * BountyToSentence), condition = bountyAffected)
        endif

        ; config.NotifyJail("Your sentence in " + arrestVars.Hold + " was set to " + arrestVars.Sentence + " days in jail")
    endEvent

    event OnUpdateGameTime()
        Debug(self, "OnUpdateGameTime", "{ timeSinceLastUpdate: "+ TimeSinceLastUpdate +", CurrentTime: "+ CurrentTime +", LastUpdate: "+ LastUpdate +" }")
        
        if (Prisoner.HasActiveBounty())
            ; Update any active bounty the prisoner may have while in jail, and add it to the sentence
            Prisoner.UpdateSentenceFromCurrentBounty()
        endif

        if (IsInfamyEnabled)
            Prisoner.UpdateInfamy()
        endif

        if (SentenceServed)
            GotoState(STATE_RELEASED)
        endif

        

        Prisoner.ShowSentenceInfo()
        ; arrestVars.List("Stripping")
        ; arrestVars.List("Jail")
        ; arrestVars.ListOverrides("Stripping")
        Prisoner.ShowActorVars()

        LastUpdate = Utility.GetCurrentGameTime()
        ; Keep updating while in jail
        RegisterForSingleUpdateGameTime(1.0)
    endEvent

    event OnEndState()
        Debug(self, "OnEndState", CurrentState + " state end")
        ; Terminate Jailed process, Actor should be released by now.
        ; Revert to normal timescale
    endEvent
endState

;/
    This state represents the scenario where the prisoner
    is trying to escape, but hasn't been seen yet.
/;
state Escaping
    event OnBeginState()
        Debug(self, "OnBeginState", CurrentState + " state begin")
    endEvent

    event OnUpdateGameTime()
        ; Prisoner is trying to escape, but they are still inside the prison,
        ; infamy should still be updated
        if (IsInfamyEnabled)
            Prisoner.UpdateInfamy()
        endif

        LastUpdate = Utility.GetCurrentGameTime()
        RegisterForSingleUpdateGameTime(1.0)
    endEvent

    event OnGuardSeesPrisoner(Actor akGuard)
        Debug(self, "OnGuardSeesPrisoner", akGuard + " is seeing " + Arrestee)
        akGuard.SetAlert()
        akGuard.StartCombat(Arrestee)
        GotoState("Escaped")
        TriggerEscape()
    endEvent

    event OnCellDoorOpen(ObjectReference _cellDoor, Actor whoOpened)
        Debug(self, "OnCellDoorOpen", "Cell door open")
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
            float distanceFromMarkerToDoor = JailCell.GetDistance(arrestVars.CellDoor)
            Debug(self, "OnCellDoorClosed", "Distance from marker to cell door: " + distanceFromMarkerToDoor)
        endif
        Debug(self, "OnCellDoorClosed", "Cell door closed")
    endEvent

    event OnEscapeFail()

    endEvent

    event OnEndState()
        Debug(self, "OnEndState", CurrentState + " state end")
        ; Terminate Escaped process, Actor should have escaped by now.
    endEvent
endState

;/
    This state represents the scenario where the prisoner
    is trying to escape and has been seen, or has escaped successfully (before transitioning to the Free state)
/;
state Escaped
    event OnBeginState()
        Debug(self, "OnBeginState", CurrentState + " state begin")
        Prisoner.FlagAsEscapee()
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

                GotoState(STATE_JAILED)
                OnEscapeFail()

                ShowArrestVars()
            endif
        endif
    endEvent

    event OnUndressed(Actor undressedActor)
        ; Actor should be undressed at this point
        if (ShouldBeClothed)
            Prisoner.Clothe()
        endif

        Debug(self, "OnUndressed", "undressedActor: " + undressedActor)
    endEvent

    event OnClothed(Actor clothedActor, RealisticPrisonAndBounty_Outfit prisonerOutfit)
        ; Do anything that needs to be done after the actor has been stripped and clothed.
        Debug(self, "OnClothed", "clothedActor: " + clothedActor)

    endEvent

    event OnUpdateGameTime()
        ; Prisoner is escaping, but they are still inside the prison,
        ; infamy should still be updated
        if (IsInfamyEnabled)
            Prisoner.UpdateInfamy()
        endif

        LastUpdate = Utility.GetCurrentGameTime()
        RegisterForSingleUpdateGameTime(1.0)
    endEvent

    event OnEndState()
        Debug(self, "OnEndState", CurrentState + " state end")
    endEvent
endState

state Released
    event OnBeginState()
        Debug(self, "OnBeginState", CurrentState + " state begin")
        ; Begin Release process, Actor is arrested and not yet free
        arrestVars.CellDoor.SetOpen()
        if (arrestVars.ArrestType == arrest.ARREST_TYPE_TELEPORT_TO_CELL)
            if (!ShouldItemsBeRetained)
                Prisoner.GiveItemsBack()
            endif

            Prisoner.MoveToReleaseLocation()
        endif

        GotoState(STATE_FREE)
    endEvent

    event OnEndState()
        ; Terminate Release process, Actor should be free at this point
        Debug(self, "OnEndState", CurrentState + " state end")
        arrest.GotoState("")
        arrestVars.Clear()
    endEvent
endState

state Free
    event OnBeginState()
        Debug(self, "OnBeginState", CurrentState + " state begin")
        ; Begin Free process, Actor is not arrested and is Free
        arrestVars.Clear()
    endEvent

    event OnEndState()
        Debug(self, "OnEndState", CurrentState + " state end")
        ; Terminate Free process, Processing after Actor is free should be done by now.
    endEvent
endState

event OnEscortToJailEnd()
    ; Happens when the Actor should be imprisoned after being arrested and upon arriving at the jail. (called from Arrest)
endEvent

event OnFriskBegin(Actor friskSearchPerformer, Actor actorToFrisk)
    ; Happens when the actor is beginning to be frisked
    Debug(self, "OnFriskBegin", CurrentState + " event invoked")
endEvent

event OnFriskEnd(Actor friskSearchPerformer, Actor friskedActor)
    ; Happens when the actor has been frisked
    Debug(self, "OnFriskEnd", CurrentState + " event invoked")
endEvent

event OnStripBegin(Actor stripSearchPerformer, Actor actorToStrip)
    ; Happens when the actor is about to be stripped
    Debug(self, "OnStripBegin", CurrentState + " event invoked")
endEvent

event OnStripEnd(Actor stripSearchPerformer, Actor strippedActor)
    ; Happens when the actor has been stripped
    Debug(self, "OnStripEnd", CurrentState + " event invoked")
endEvent

event OnEscortToCellBegin(Actor escortActor, Actor escortedActor)
    ; Happens when the actor is being escorted to their cell
    Debug(self, "OnEscortToCellBegin", CurrentState + " event invoked")
endEvent

event OnEscortToCellEnd(Actor escortActor, Actor escortedActor)
    ; Happens when the actor has been escorted to their cell
    Debug(self, "OnEscortToCellEnd", CurrentState + " event invoked")
endEvent

event OnEscortFromCellBegin(Actor escortActor, Actor escortedActor, ObjectReference destination)
    ; Happens when the actor is being escorted from their cell to the destination
    Debug(self, "OnEscortFromCellBegin", CurrentState + " event invoked")
endEvent

event OnEscortFromCellEnd(Actor escortActor, Actor escortedActor, ObjectReference destination)
    ; Happens when the actor has been escorted from their cell to the destination
    Debug(self, "OnEscortFromCellEnd", CurrentState + " event invoked")
endEvent

event OnActorCuffed(Actor cuffedActor, bool hands, bool feet)
    ; Happens when the actor has been cuffed (hands bound, maybe feet?)
    Debug(self, "OnActorCuffed", CurrentState + " event invoked")
endEvent

event OnActorUncuffed(Actor uncuffedActor, bool hands, bool feet)
    ; Happens when the actor has been uncuffed (hands unbound, maybe feet?)
    Debug(self, "OnActorUncuffed", CurrentState + " event invoked")
endEvent

event OnUndressed(Actor undressedActor)
    Debug(self, "OnUndressed", CurrentState + " event invoked")
endEvent

event OnClothed(Actor clothedActor, RealisticPrisonAndBounty_Outfit prisonerOutfit)
    ; Do anything that needs to be done after the actor has been stripped and clothed.
    Debug(self, "OnClothed", CurrentState + " event invoked")
endEvent

event OnCellDoorLocked(ObjectReference _cellDoor, Actor whoLocked)
    Debug(self, "OnCellDoorLocked", CurrentState + " event invoked")
endEvent

event OnCellDoorUnlocked(ObjectReference _cellDoor, Actor whoUnlocked)
    Debug(self, "OnCellDoorUnlocked", CurrentState + " event invoked")
endEvent

event OnCellDoorOpen(ObjectReference _cellDoor, Actor whoOpened)
    ; If the cell door was opened by the player, and they are not jailed, this must mean that they lockpicked the door either just because or to get someone out of jail.
    if (whoOpened == config.Player && config.Player != Arrestee)
        Faction jailFaction = config.GetFaction(config.GetCurrentPlayerHoldLocation())
        ; Add bounty for lockpicking / breaking someone out of jail if they are witnessed
        ; if (witnessedCrime)
        jailFaction.ModCrimeGold(2000)
        Debug(self, "OnCellDoorOpen", "jailFaction: " + jailFaction + ", bounty: " + jailFaction.GetCrimeGold())
    endif
    Debug(self, "OnCellDoorOpen", CurrentState + " event invoked")
endEvent

event OnCellDoorClosed(ObjectReference _cellDoor, Actor whoOpened)
    Debug(self, "OnCellDoorClosed", CurrentState + " event invoked")
endEvent

; Placeholders for State events
event OnEscapeFail()
    Error(self, "OnEscapeFail", "Not currently Escaping, invalid call!")
endEvent

event OnGuardSeesPrisoner(Actor akGuard)
    Debug(self, "OnGuardSeesPrisoner", CurrentState + " event invoked")
endEvent

event OnSentenceChanged(Actor akPrisoner, int oldSentence, int newSentence, bool hasIncreased, bool bountyAffected)
    Debug(self, "OnSentenceChanged", CurrentState + " event invoked")
endEvent

function TriggerEscape()
    if (CurrentState != STATE_ESCAPED)
        Error(self, "TriggerEscape", "Not currently Escaping, invalid call!")
        return
    endif

    Debug(self, "TriggerEscape", "Escaped state begin")
    arrestVars.SetBool("Jail::Jailed", false)
    config.IncrementStat(Hold, "Times Escaped")
    Game.IncrementStat("Jail Escapes")

    int escapeBountyGotten = floor((BountyNonViolent * percent(EscapeBountyFromCurrentArrest))) + EscapeBounty

    config.NotifyJail("You have gained " + escapeBountyGotten + " Bounty in " + Hold + " for escaping")
    Prisoner.RevertBounty()
    Prisoner.AddEscapeBounty()
endFunction

function TriggerImprisonment()
    if (CurrentState != STATE_JAILED)
        Error(self, "TriggerImprisonment", "Not currently jailed, invalid call!")
        return
    endif

    Debug(self, "TriggerImprisonment", "Triggered Imprisonment")
    float startBench = StartBenchmark()
    ; Begin Jailed process, Actor is arrested and jailed
    ; Switch timescale to prison timescale
    config.IncrementStat(Hold, "Times Jailed")

    ; Trigger infamy penalty, only if infamy is enabled
    Prisoner.TriggerCrimimalPenalty()

    if (JailCell)
        arrestVars.CellDoor.SetOpen(false)
        arrestVars.CellDoor.Lock()
    endif

    if (ShouldBeFrisked)
        Prisoner.Frisk()
    endif

    if (ShouldBeStripped)
        Prisoner.Strip()

    elseif (ShouldBeClothed && Prisoner.IsNaked())
        ; Only handle clothing here when not stripped, which means the Actor did not have any clothing
        Prisoner.Clothe()
    endif
    ShowArrestVars()


    ; Prisoner.UpdateSentence()
    Prisoner.SetTimeOfImprisonment() ; Start the sentence from this point

    int currentLongestSentence = config.GetStat(Hold, "Longest Sentence")
    config.SetStat(Hold, "Longest Sentence", int_if (currentLongestSentence < Sentence, Sentence, currentLongestSentence))
    ; Prisoner.ShowJailInfo()
    ; Prisoner.ShowOutfitInfo()
    ; Prisoner.ShowHoldStats()
    ; ShowArrestParams()
    ; ShowArrestVars()

    config.NotifyJail("Your sentence in " + Hold + " was set to " + arrestVars.Sentence + " days in jail")
    EndBenchmark(startBench, "TriggerImprisonment")
    
endFunction

function MovePrisonerToCell()
    Prisoner.MoveToCell()
endFunction

; Temporary - Testing
function StartEscortToCell()
    Actor guard                     = arrestVars.Captor
    Actor _prisoner                 = arrestVars.Arrestee
    ObjectReference jailCellDoor    = arrestVars.CellDoor
    ObjectReference _jailCell       = arrestVars.JailCell

    Game.SetPlayerAIDriven()
    guard.MoveTo(_jailCell)
    jailCellDoor.SetOpen()
    
    guard.EnableAI(false)
    _prisoner.PathToReference(_jailCell, 1.0)
    jailCellDoor.SetOpen(false)
    jailCellDoor.Lock()
    Game.SetPlayerAIDriven(false)
    guard.EnableAI()
endFunction

function StartTeleportToCell()
    arrestVars.Arrestee.MoveTo(arrestVars.JailCell)
endFunction

function StartGuardWalkToCellToStrip()
    Actor guard                     = arrestVars.Captor
    Actor thePrisoner               = arrestVars.Arrestee
    ObjectReference jailCellDoor    = arrestVars.CellDoor
    ObjectReference _jailCell        = arrestVars.JailCell

    _jailCell.MoveTo(guard) ; Put a temporary marker on the guard's location

    guard.PathToReference(jailCellDoor, 1.0)
    jailCellDoor.SetOpen()
    Game.SetPlayerAIDriven() ; Disable player controls
    guard.PathToReference(thePrisoner, 1.0)
    Prisoner.Strip()
    guard.PathToReference(jailCellDoor, 1.0)
    jailCellDoor.SetOpen(false)
    jailCellDoor.Lock()
    Game.SetPlayerAIDriven(false)
    guard.PathToReference(_jailCell, 1.0)
    _jailCell.MoveTo(thePrisoner)
endFunction

bool function AssignJailCell(Actor akPrisoner)
    ObjectReference randomJailCell = config.GetRandomJailMarker(hold)
    Debug(self, "AssignJailCell", "jail cell: " + randomJailCell)

    if (akPrisoner == config.Player)
        if (arrestVars.JailCell)
            Debug(self, "AssignJailCell", "A jail cell has already been assigned to " + akPrisoner + ": " + arrestVars.JailCell)
            return true
        endif

        arrestVars.SetForm("Jail::Cell", randomJailCell) ; Assign cell to Player
        Debug(self, "AssignJailCell", "Set up new Jail Cell for " + akPrisoner + ": " + arrestVars.JailCell)
        return arrestVars.JailCell != none

    else
        string jailCellId = "["+ akPrisoner.GetFormID() +"]Jail::Cell"
        Form npcJailCell = arrestVars.GetForm(jailCellId)
        if (npcJailCell)
            Debug(self, "AssignJailCell", "A jail cell has already been assigned to " + akPrisoner + ": " + npcJailCell)
            return true
        endif

        arrestVars.SetForm(jailCellId, randomJailCell) ; Assign cell to NPC
        Debug(self, "AssignJailCell", "Set up new Jail Cell for " + akPrisoner + ": " + npcJailCell)
        return arrestVars.GetForm(jailCellId) != none
    endif

    return false
endFunction
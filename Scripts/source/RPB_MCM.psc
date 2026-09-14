Scriptname RPB_MCM extends SKI_ConfigBase  

import RPB_Utility
import RPB_Config
import RPB_Memory
import RPB_Data

; ==========================================================
;                     Script References
; ==========================================================

RPB_API __api
RPB_API property API
    RPB_API function get()
        if (__api)
            return __api
        endif

        __api = RPB_API.GetSelf()
        return __api
    endFunction
endProperty

RPB_Config property Config
    RPB_Config function get()
        return API.Config
    endFunction
endProperty

; ==============================================================================
; Constants
; ==============================================================================

bool property IS_DEBUG      = false autoreadonly
bool property ENABLE_TRACE  = false autoreadonly

; ==============================================================================
; Cached Option
int property CACHED_OPTION_INDEX    = 0 autoreadonly
int property CACHED_OPTION_NAME     = 1 autoreadonly

; ==============================================================================
; Error Codes
int property GENERAL_ERROR     = -1500000 autoreadonly
int property ARRAY_NOT_EXIST   = -1500100 autoreadonly
int property OPTION_NOT_EXIST  = -1500200 autoreadonly
int property INVALID_VALUE     = -1500300 autoreadonly

; ==============================================================================
; MCM Option Flags
int property OPTION_ENABLED  = 0x00 autoreadonly
int property OPTION_DISABLED = 0x01 autoreadonly

; ==============================================================================
; Value Types
int property TYPE_NO_VALUE  = 0 autoreadonly
int property TYPE_NONE      = 1 autoreadonly
int property TYPE_INT       = 2 autoreadonly
int property TYPE_FLOAT     = 3 autoreadonly
int property TYPE_FORM      = 4 autoreadonly
int property TYPE_OBJECT    = 5 autoreadonly
int property TYPE_STRING    = 6 autoreadonly

; ==============================================================================

int property OUTFIT_COUNT = 10 autoreadonly

; ==========================================================
;                        Properties
; ==========================================================

string[] property PrisonSkillHandlingOptions
    string[] function get()
        return String_Explode( \
            "All Skills|" + \
            "All Stat Skills (Health, Stamina, Magicka)|" + \
            "All Perk Skills|" + \
            "1x Random Stat Skill|" + \
            "1x Random Perk Skill|" + \
            "Random" \
            , asDelimiter = "|" \
        )
    endFunction
endProperty

string[] property EscapeHandlingOptions
    string[] function get()
        return String_Explode( \
            "Bounty," + \
            "Sentence," + \
            "Bounty + Sentence," + \
            "Bounty (Conditionally)," + \
            "Sentence (Conditionally)," + \
            "Bounty || Sentence (Conditionally OR)," + \
            "Bounty && Sentence (Conditionally AND)" \
        )
    endFunction
endProperty

string[] property UndressingHandlingOptions
    string[] function get()
        return String_Explode( \
            "Minimum Bounty," + \
            "Minimum Sentence," + \
            "Unconditionally" \
        )
    endFunction
endProperty

string[] property ClothingHandlingOptions
    string[] function get()
        return String_Explode( \
            "Maximum Bounty," + \
            "Maximum Sentence," + \
            "Unconditionally" \
        )
    endFunction
endProperty

string[] property ClothingOutfits
    string[] function get()
        string buildString = ""

        int i = 0
        while (i < OUTFIT_COUNT)
            int id = (i + 1) ; The outfit's id

            string outfitName = string_if ( \ 
                self.OptionHasValue("Outfit " + id + "::Name", "Clothing"), \ 
                self.GetOptionValueString("Outfit "+ id +"::Name", "Clothing"), \
                self.GetOptionDefaultString("Outfit "+ id +"::Name") \
            )

            buildString += outfitName
            buildString += string_if (i < (OUTFIT_COUNT - 1), ",")

            i += 1
        endWhile
        
        return String_Explode(buildString)
    endFunction
endProperty

string[] property LockLevels
    string[] function get()
        return RPB_Utility.GetLockLevels()
    endFunction
endProperty

string[] property SkillNames
    string[] function get()
        return RPB_Utility.GetAllSkillNames()
    endFunction
endProperty

string[] property Skills
    string[] function get()
        return RPB_Utility.GetAllSkills()
    endFunction
endProperty

string[] property Holds
    string[] function get()
        return API.Config.Holds
    endFunction
endProperty

; ==========================================================
;                           Presets
; ==========================================================

;/
    Every bucket a preset can target: the fixed pages (General/Skills/Clothing) plus every Hold.
    Single source of truth for the Presets page's Scope checklist, RegisterPages(), and SavePreset/LoadPreset.
/;
string[] function GetPresetBuckets()
    return String_Explode( \
        "General," + \
        "Skills," + \
        "Clothing," + \
        String_Implode(Holds) + "," \
    )
endFunction

;/ The non-Hold subset of GetPresetBuckets() - used to render the Presets page's "Pages" group separately from "Holds". /;
string[] function GetPresetPageBuckets()
    return String_Explode("General,Skills,Clothing,")
endFunction

string[] function GetExistingPresets()
    int fileListObj = FastMap_FromDirectory(Preset_GetDirectory(), Preset_Extension())
    int fileList    = FastMap_Keys(fileListObj)

    return RPB_Memory.FastArray_ToStringArray(fileList)
endFunction

;/
    Resolves the bucket's config key in mcm.json - Hold pages share one config template, keyed
    "Hold", not each Hold's own name.
/;
string function GetBucketConfigKey(string asBucket)
    int i = 0
    while (i < Holds.Length)
        if (Holds[i] == asBucket)
            return "Hold"
        endif
        i += 1
    endWhile

    return asBucket
endFunction

;/
    Retrieves every real, declared option key for @asBucket straight from mcm.json - independent
    of render/touch state (unlike optionsFromKeyToIdMap, which only ever contains keys from options
    that have actually been rendered this session).

    int?    @aiOptionsObj: An already-loaded RPB_Data.MCM_GetOptionObject() result, to avoid a fresh
        full-file read+parse of mcm.json when resolving several buckets in a row (see RegisterPages/
        SavePreset). Loaded fresh if not given, so this stays usable standalone.

    returns (string[]): The bucket's option keys, or none if the bucket has no config.
/;
string[] function GetBucketOptionKeys(string asBucket, int aiOptionsObj = 0)
    int optionsObj = aiOptionsObj

    if (!optionsObj)
        optionsObj = RPB_Data.MCM_GetOptionObject()
    endif

    int pageObj = FastMap_GetObject(optionsObj, self.GetBucketConfigKey(asBucket))

    if (!pageObj)
        return none
    endif

    return FastMap_KeysAsPapyrusArray(pageObj)
endFunction

;/
    Registers every preset bucket's real, declared option keys (per mcm.json, via
    GetBucketOptionKeys - not just whatever's been touched this session) with RPB_Registry, so a
    loaded preset's keys can be validated against what's actually live right now - a key that's no
    longer a real option for that bucket (renamed/removed since the preset was saved) gets skipped,
    not blindly applied. Called every OnConfigOpen, so the registered content is always current.
/;
function RegisterPages()
    string[] buckets = self.GetPresetBuckets()
    int optionsObj   = RPB_Data.MCM_GetOptionObject() ; loaded once, not once per bucket

    int i = 0
    while (i < buckets.Length)
        string bucket       = buckets[i]
        string[] bucketKeys = self.GetBucketOptionKeys(bucket, optionsObj)

        ; RPB_Registry.HasContent() checks membership via FastMap_HasKey(), so the registered
        ; content must be a FastMap (JMap), not a plain FastArray of key names.
        int registrantContent = FastMap("<string>")

        if (bucketKeys)
            int j = 0
            while (j < bucketKeys.Length)
                FastMap_SetInt(registrantContent, bucketKeys[j], 1)
                j += 1
            endWhile
        endif

        RPB_Registry.RegisterContent(RPB_Registry.AsPresetRegistrantKey(bucket), registrantContent)
        i += 1
    endWhile
endFunction

;/
    Resolves the *effective* current value (the touched value if present, else this bucket's
    declared default from mcm.json) for every real option key in @asBucket, independent of whether
    that page has actually been rendered/visited this session - optionsValueMap only ever contains
    explicitly-touched keys (see SavePreset), so reading it alone would silently skip anything left
    at its default.

    Deliberately does NOT go through GetOptionDefaultBool/Int/Float/String or
    GetOptionValueTypeFromConfig - both are hard-coupled to CurrentPage (unusable for a bucket that
    isn't the page currently open) and/or independently flagged as buggy elsewhere in this file.
    Reuses OptionHasValue/GetOptionValue{Bool,Int,Float,String}(key, page) instead, which already
    accept an explicit page, and the existing IsPropertyValueOfTypeBool(optionMap, "Default")
    int-vs-bool heuristic (also page-independent, since it only inspects the passed-in option map).

    string  @asBucket: The bucket (page or Hold name) to resolve.
    int?    @aiOptionsObj: An already-loaded RPB_Data.MCM_GetOptionObject() result - see
        GetBucketOptionKeys. Loaded fresh (once, not twice) if not given.

    returns (int): FastMap<string> - "Category::Option" -> effective value, one entry per real option key.
/;
int function GetBucketEffectiveValues(string asBucket, int aiOptionsObj = 0)
    int optionsObj = aiOptionsObj

    if (!optionsObj)
        optionsObj = RPB_Data.MCM_GetOptionObject()
    endif

    string[] optionKeys = self.GetBucketOptionKeys(asBucket, optionsObj)
    int snapshot         = FastMap("<string>")

    if (!optionKeys)
        return snapshot
    endif

    int pageObj = FastMap_GetObject(optionsObj, self.GetBucketConfigKey(asBucket))

    int i = 0
    while (i < optionKeys.Length)
        string optionKey = optionKeys[i]
        int optionMap    = FastMap_GetObject(pageObj, optionKey)

        if (FastMap_HasKey(optionMap, "Default"))
            int defaultType = FastMap_ValueType(optionMap, "Default")
            bool hasValue   = self.OptionHasValue(optionKey, asBucket)

            if (defaultType == TYPE_INT && self.IsPropertyValueOfTypeBool(optionMap, "Default"))
                FastMap_SetInt(snapshot, optionKey, bool_if(hasValue, self.GetOptionValueBool(optionKey, asBucket), FastMap_GetInt(optionMap, "Default") as bool) as int)

            elseif (defaultType == TYPE_INT || defaultType == TYPE_FLOAT)
                FastMap_SetFloat(snapshot, optionKey, float_if(hasValue, self.GetOptionValueFloat(optionKey, asBucket), FastMap_GetFloat(optionMap, "Default")))

            elseif (defaultType == TYPE_STRING)
                FastMap_SetString(snapshot, optionKey, string_if(hasValue, self.GetOptionValueString(optionKey, asBucket), FastMap_GetString(optionMap, "Default")))
            endif
        endif

        i += 1
    endWhile

    return snapshot
endFunction

;/
    Populates optionsDefaultValueMap for every real option key on CurrentPage, in one pass (one
    RPB_Data.MCM_GetOptionObject() read, one loop) - fixes GetOptionToggleState/GetOptionMenuValue/
    GetOptionDefaultBool&co. returning a wrong false/0/"" for any option nobody's touched yet.

    optionsDefaultValueMap was previously only ever populated by LoadDefaults(), called exactly
    once from OnConfigInit() (which itself fires once ever per save) for whatever page happened to
    be CurrentPage at that single moment - never comprehensively populated for every page. This is
    called once per page visit (see OnPageReset) instead, using the same single-mcm.json-read
    discipline already proven for the preset resolver (GetBucketEffectiveValues) rather than the
    old, per-key-chatty LoadOptionValues an earlier round tried and reverted for cost reasons.

    Since every Hold page shares one "Hold" config template (GetBucketConfigKey), populating
    defaults once for any Hold page already covers every other Hold page's identical keys too -
    tracked in __warmedDefaultShapes so a repeat visit to an already-warmed shape (any Hold, once
    any Hold has been visited) skips the mcm.json read entirely instead of redoing it every visit.
/;
;/ FastMap<bool> - which GetBucketConfigKey() shapes have already been refreshed this session /; int __warmedDefaultShapes

function RefreshOptionDefaultsForCurrentPage()
    string configKey = self.GetBucketConfigKey(CurrentPage)

    if (!__warmedDefaultShapes)
        __warmedDefaultShapes = FastMap("<string>", retain = true)
    endif

    if (FastMap_HasKey(__warmedDefaultShapes, configKey))
        return
    endif

    int optionsObj       = RPB_Data.MCM_GetOptionObject() ; loaded once, not once per bucket
    string[] optionKeys  = self.GetBucketOptionKeys(CurrentPage, optionsObj)

    if (!optionKeys)
        return
    endif

    int pageObj = FastMap_GetObject(optionsObj, configKey)

    int i = 0
    while (i < optionKeys.Length)
        string optionKey = optionKeys[i]
        int optionMap    = FastMap_GetObject(pageObj, optionKey)

        if (FastMap_HasKey(optionMap, "Default"))
            int defaultType = FastMap_ValueType(optionMap, "Default")

            if (defaultType == TYPE_INT && self.IsPropertyValueOfTypeBool(optionMap, "Default"))
                self.SetOptionDefaultBool(optionKey, FastMap_GetInt(optionMap, "Default") as bool)

            elseif (defaultType == TYPE_INT || defaultType == TYPE_FLOAT)
                self.SetOptionDefaultFloat(optionKey, FastMap_GetFloat(optionMap, "Default"))

            elseif (defaultType == TYPE_STRING)
                self.SetOptionDefaultString(optionKey, FastMap_GetString(optionMap, "Default"))
            endif
        endif

        i += 1
    endWhile

    FastMap_SetInt(__warmedDefaultShapes, configKey, 1)
endFunction

;/
    Copies one bucket's current effective values into another, same-shaped bucket (e.g. Hold to
    Hold - Eastmarch into Haafingar). Refuses to copy between buckets of different shape (e.g. a
    Hold into General) - GetBucketConfigKey() resolves each bucket to its mcm.json config template,
    and this stays forward-compatible with the future Hold/Prison MCM decoupling for free, since a
    new Prison shape would just be another distinct config template.

    Reuses GetBucketEffectiveValues() (the same resolver presets use) as the source and
    Preset_ApplyBucket() (already registrant-validated and type-correct) to write it - no new
    validation logic needed.

    string  @asSrcBucket: The bucket to copy from.
    string  @asDstBucket: The bucket to copy into.

    returns (bool): false if the copy was refused (different shape), true otherwise.
/;
bool function CopyBucketOptions(string asSrcBucket, string asDstBucket)
    if (self.GetBucketConfigKey(asSrcBucket) != self.GetBucketConfigKey(asDstBucket))
        Debug("RPB_MCM::CopyBucketOptions", "Cannot copy " + asSrcBucket + " into " + asDstBucket + " - different shape.")
        return false
    endif

    int srcValues = self.GetBucketEffectiveValues(asSrcBucket)
    Preset_ApplyBucket(asDstBucket, srcValues, self.GetPageObject(optionsValueMap, asDstBucket))

    return true
endFunction

;/
    Saves every given bucket's current effective values (touched-or-default, via
    GetBucketEffectiveValues) into one preset file. Appends the preset extension automatically if
    @asPresetFile doesn't already have it.

    string      @asPresetFile: The preset file name (with or without the .rpbp extension).
    string[]    @akBuckets: The buckets to save (e.g. "General", a Hold name, ...).
/;
function SavePreset(string asPresetFile, string[] akBuckets)
    string presetFile = asPresetFile

    if (!String_EndsWith(presetFile, Preset_Extension()))
        presetFile += Preset_Extension()
    endif

    int bucketsData = FastMap("<string>")
    int optionsObj  = RPB_Data.MCM_GetOptionObject() ; loaded once, not once per bucket

    int i = 0
    while (i < akBuckets.Length)
        string bucket = akBuckets[i]
        FastMap_SetObject(bucketsData, bucket, self.GetBucketEffectiveValues(bucket, optionsObj))
        i += 1
    endWhile

    Preset_Save(bucketsData, presetFile)
    self.SetTrackedPreset(presetFile, akBuckets)
endFunction

;/
    Loads a preset file and applies every given bucket that's actually present in the file.
    A given bucket missing from the file is skipped and logged, not treated as an error.

    string      @asPresetFile: The preset file to load.
    string[]    @akBuckets: The buckets to apply from the loaded file, if present.
/;
function LoadPreset(string asPresetFile, string[] akBuckets)
    int presetData = Preset_Load(asPresetFile)

    if (presetData == PRESET_INVALID_FILE() || presetData == PRESET_NOT_FOUND())
        return
    endif

    int appliedBuckets = FastArray("<string>")

    int i = 0
    while (i < akBuckets.Length)
        string bucket = akBuckets[i]

        if (FastMap_HasKey(presetData, bucket))
            Preset_ApplyBucket(bucket, FastMap_GetObject(presetData, bucket), self.GetPageObject(optionsValueMap, bucket))
            FastArray_AddString(appliedBuckets, bucket)
        else
            Debug("RPB_MCM::LoadPreset", "Checked bucket not found in preset " + asPresetFile + ": " + bucket)
        endif

        i += 1
    endWhile

    self.SetTrackedPreset(asPresetFile, FastArray_ToStringArray(appliedBuckets))
endFunction

; ==========================================================
;              Presets - tracked (last saved/loaded)
; ==========================================================

;/
    Persisted (survives MCM close and game save/reload, same as optionsValueMap's own backing
    container) record of the most recently saved-to or loaded-from preset, and a snapshot of the
    buckets involved at that moment - lets the Presets page show which preset is "active" and
    whether anything's changed since.
/;
;/ FastMap<string> - "name" -> string, "buckets" -> FastMap<bucket, snapshot> /; int __trackedPreset

;/
    Which tracked buckets have had any option set since the current baseline was captured -
    HasTrackedPresetChanged() only needs to resolve/compare buckets that show up here, instead of
    every tracked bucket on every check. See MarkBucketPossiblyDirty().
/;
;/ FastMap<bool> /; int __trackedPresetDirtyBuckets

;/
    Records @asPresetFile and @akBuckets as the tracked preset/baseline - called after a
    successful Save (every checked bucket) or Load (only the buckets actually found-and-applied).
    Re-derives the snapshot fresh from live state via GetBucketEffectiveValues rather than reusing
    whatever was written/read, so it always matches what's actually live right now.
/;
function SetTrackedPreset(string asPresetFile, string[] akBuckets)
    __trackedPreset = delete(__trackedPreset)
    __trackedPreset = FastMap("<string>", retain = true)

    FastMap_SetString(__trackedPreset, "name", asPresetFile)

    int bucketsSnapshot = FastMap("<string>")
    int optionsObj      = RPB_Data.MCM_GetOptionObject() ; loaded once, not once per bucket

    int i = 0
    while (i < akBuckets.Length)
        string bucket = akBuckets[i]
        FastMap_SetObject(bucketsSnapshot, bucket, self.GetBucketEffectiveValues(bucket, optionsObj))
        i += 1
    endWhile

    FastMap_SetObject(__trackedPreset, "buckets", bucketsSnapshot)

    ; Fresh baseline - nothing's dirty relative to it yet.
    __trackedPresetDirtyBuckets = delete(__trackedPresetDirtyBuckets)
    __trackedPresetDirtyBuckets = FastMap("<string>", retain = true)
endFunction

;/
    Marks @asPage dirty relative to the tracked preset's baseline, if it's actually one of the
    tracked buckets - called from every SetOptionValue{Bool,Int,Float,String} so
    HasTrackedPresetChanged() knows which tracked buckets might need re-checking, without having to
    blindly re-resolve all of them. No-ops immediately if nothing's tracked or @asPage isn't a
    tracked bucket - cheap even for MCM interactions completely unrelated to Presets.

    string  @asPage: The page an option was just set on ("" resolves to CurrentPage, same as
        GetPageObject).
/;
function MarkBucketPossiblyDirty(string asPage)
    if (!__trackedPreset)
        return
    endif

    string page = asPage

    if (page == "")
        page = CurrentPage
    endif

    int trackedBuckets = FastMap_GetObject(__trackedPreset, "buckets")

    if (!FastMap_HasKey(trackedBuckets, page))
        return
    endif

    if (!__trackedPresetDirtyBuckets)
        __trackedPresetDirtyBuckets = FastMap("<string>", retain = true)
    endif

    FastMap_SetInt(__trackedPresetDirtyBuckets, page, 1)
endFunction

;/
    Key-by-key, type-by-type equality check between two GetBucketEffectiveValues()-shaped
    FastMap<string> objects. JContainers has no built-in deep-equality call.
/;
bool function BucketValuesEqual(int apA, int apB)
    if (FastMap_Size(apA) != FastMap_Size(apB))
        return false
    endif

    string[] keys = FastMap_KeysAsPapyrusArray(apA)

    int i = 0
    while (i < keys.Length)
        string _key = keys[i]

        if (!FastMap_HasKey(apB, _key))
            return false
        endif

        int valueType = FastMap_ValueType(apA, _key)

        if (valueType != FastMap_ValueType(apB, _key))
            return false
        endif

        if (valueType == TYPE_INT && FastMap_GetInt(apA, _key) != FastMap_GetInt(apB, _key))
            return false
        elseif (valueType == TYPE_FLOAT && FastMap_GetFloat(apA, _key) != FastMap_GetFloat(apB, _key))
            return false
        elseif (valueType == TYPE_STRING && FastMap_GetString(apA, _key) != FastMap_GetString(apB, _key))
            return false
        endif

        i += 1
    endWhile

    return true
endFunction

;/
    Whether anything's changed in any tracked bucket since the last Save/Load. Only resolves/
    compares buckets MarkBucketPossiblyDirty() actually flagged - if nothing's been touched since
    the baseline was captured, this returns immediately with no resolving at all (confirmed the
    actual cost driver of a 6-10s Presets-page load: fully re-resolving every tracked bucket on
    every single visit, even when nothing had changed).
/;
bool function HasTrackedPresetChanged()
    if (!__trackedPreset)
        return false
    endif

    if (!__trackedPresetDirtyBuckets || FastMap_Size(__trackedPresetDirtyBuckets) == 0)
        return false
    endif

    int bucketsSnapshot  = FastMap_GetObject(__trackedPreset, "buckets")
    string[] dirtyBuckets = FastMap_KeysAsPapyrusArray(__trackedPresetDirtyBuckets)
    int optionsObj        = RPB_Data.MCM_GetOptionObject() ; loaded once, not once per bucket

    int i = 0
    while (i < dirtyBuckets.Length)
        string bucket = dirtyBuckets[i]

        if (FastMap_HasKey(bucketsSnapshot, bucket))
            int snapshotValues = FastMap_GetObject(bucketsSnapshot, bucket)
            int currentValues  = self.GetBucketEffectiveValues(bucket, optionsObj)

            if (!self.BucketValuesEqual(snapshotValues, currentValues))
                return true
            endif
        endif

        i += 1
    endWhile

    return false
endFunction

;/
    "" if nothing is tracked yet; otherwise the tracked preset's name (extension stripped) plus
    " (Changed)" if HasTrackedPresetChanged().
/;
string function GetTrackedPresetDisplayName()
    if (!__trackedPreset)
        return ""
    endif

    string fileName = FastMap_GetString(__trackedPreset, "name")
    string extension = Preset_Extension()

    if (String_EndsWith(fileName, extension))
        fileName = StringUtil.Substring(fileName, 0, StringUtil.GetLength(fileName) - StringUtil.GetLength(extension))
    endif

    if (self.HasTrackedPresetChanged())
        return fileName + " (Changed)"
    endif

    return fileName
endFunction

;/
    Retrieves the page object from the parent container (containing all page objects).

    FastMap     @parentContainer: The parent container.
    string?     @page: The page name, null for the current page.
    string?     @objectFnType: The data type of the page object.

    returns (FastMap): The page object for the specified page.

/;
int function GetPageObject(int parentContainer, string page = "", string objectFnType = "<string>")
    if (page == "")
        page = CurrentPage
    endif

    int pageObject = FastMap_GetObject(parentContainer, page)

    if (!pageObject)
        pageObject = FastMap_SetObject(parentContainer, page, FastMap(objectFnType))
        ; Debug("MCM::GetPageObject", "object: " + pageObject + ", page: " + page + ", type: " + objectFnType + ", Is IntMap: " + JValue.isIntegerMap(pageObject))
    endif

    return pageObject
endFunction

; ==========================================================


;/
    Retrieves the index in the array where the value matches @_key.

    string[]    @_array: The array to check the index of.
    string      @_key: The value to search in the array.

    returns (int): The index of @_key in the array.
/;
int function GetOptionIndexFromKey(string[] _array, string _key) global
    int internalContainer = FastArray_FromStringArray(_array)
    return FastArray_FindString(internalContainer, _key)
endFunction

;/
    Checks if @asCategory is part of @asOptionName.
    
    string  @asOptionName: The name of the option to check.
    string  @asOptionCategory: The category of the option.

    returns (bool): true if the option is part of the category, false otherwise.
/;
bool function IsOptionInCategory(string asOptionName, string asCategory) global
    return StringUtil.Find(asOptionName, asCategory) != -1
endFunction

;/
    Checks if the option is of specificity @optionSpecificity.

    string  @option: The option to check
    string  @optionSpecificity: The option's specificity (e.g: option's property name)

    returns (bool): Whether @option is of the specified specificity.
/;
bool function IsOptionOfSpecificity(string option, string optionSpecificity) global
    return StringUtil.Find(option, optionSpecificity) != -1
endFunction

int __clothingOutfitsMap ; FastMap<string, Map<string>>
function AddOutfitPiece(string outfitId, string outfitBodyPart, Armor outfitObject)
    if (!outfitObject)
        return
    endif

    ; Outfit Map
    __clothingOutfitsMap = Object_CreateIfNotExists(__clothingOutfitsMap, FastMap("<string>", retain = true))

    ; Outfit - Identifiers
    FastMap_SetObject(__clothingOutfitsMap, "Identifiers", FastMap("<string>"), condition = !FastMap_HasKey(__clothingOutfitsMap, "Identifiers"))

    ; Outfit - Body Parts
    FastMap_SetObject(__clothingOutfitsMap, "Body Parts", FastMap("<string>"), condition = !FastMap_HasKey(__clothingOutfitsMap, "Body Parts"))

    string outfitPieceKey = outfitId + "::" + outfitBodyPart
    self.SetOptionInputValue(outfitPieceKey, outfitObject.GetName())
    
    int outfitIdentifiers   = FastMap_GetObject(__clothingOutfitsMap, "Identifiers")
    int outfitBodyParts     = FastMap_GetObject(__clothingOutfitsMap, "Body Parts")

    int outfitIndex = RPB_MCM_Clothing.GetOutfitIndex(outfitId)
    string outfitName = self.ClothingOutfits[outfitIndex]
    Debug("MCM::AddOutfitPiece", "self.ClothingOutfits: " + self.ClothingOutfits)

    FastMap_SetString(outfitIdentifiers, outfitName, outfitId)
    FastMap_SetForm(outfitBodyParts, outfitPieceKey, outfitObject)

    Debug("MCM::AddOutfitPiece", "outfitId: " + outfitId + ", outfitIndex: " + outfitIndex + ", outfitObject: " + outfitObject + ", outfitName: " + outfitName)
    Debug("MCM::AddOutfitPiece", "Outfit Container: "+ GetContainerList(__clothingOutfitsMap))
    ; Debug("AddOutfitPiece", "Added Outfit Piece: " + outfitObject.GetName() + " (FormID: " + outfitObject.GetFormID() + ") to Body Part: " + outfitBodyPart)
endFunction

bool function OutfitHasBodyParts(string outfitId)
    string[] bodyParts  = String_Explode("Head,Body,Hands,Feet")
    int bodyPartsObject = FastMap_GetObject(__clothingOutfitsMap, "Body Parts")

    bool hasBodyPart = false

    int i = 0
    while (i < bodyParts.Length)
        if (FastMap_HasKey(bodyPartsObject, outfitId + "::" + bodyParts[i]))
            hasBodyPart = true
        endif
        i += 1
    endWhile

    return hasBodyPart
endFunction

;/
    Removes an outfit body part from the Outfit specified by its id.

    string  @outfitId: The id of the Outfit.
    string  @outfitBodyPart: The body part of this outfit (Head, Body, Hands, Feet).
/;
function RemoveOutfitPiece(string outfitId, string outfitBodyPart)
    string outfitPieceKey = outfitId + "::" + outfitBodyPart
    self.SetOptionInputValue(outfitPieceKey, "")

    int bodyPartsObject   = FastMap_GetObject(__clothingOutfitsMap, "Body Parts")
    int identifiersObject = FastMap_GetObject(__clothingOutfitsMap, "Identifiers")

    FastMap_RemoveKey(bodyPartsObject, outfitPieceKey)

    if (!OutfitHasBodyParts(outfitId))
        string outfitIdentifier = FastMap_KeyFromValueString(identifiersObject, outfitPieceKey)
        FastMap_RemoveKey(identifiersObject,  outfitIdentifier)
    endif
    ; Armor outfitObject = FastMap_GetForm(__clothingOutfitsMap, outfitPieceKey) as Armor
    ; Debug("RemoveOutfitPiece", "Removed Outfit Piece: " + outfitObject.GetName() + " (FormID: " + outfitObject.GetFormID() +") from Body Part: " + outfitBodyPart)
endFunction

;/
    Returns the Outfit body part for this Outfit through its id.

    string  @outfitId: The id of the Outfit.
    string  @outfitBodyPart: The body part of this outfit (Head, Body, Hands, Feet).

    returns (Armor): The outfit body part for this Outfit.
/;
Armor function GetOutfitPart(string outfitId, string outfitBodyPart)
    return FastMap_GetForm( \ 
        FastMap_GetObject(__clothingOutfitsMap, "Body Parts"), \ 
        (outfitId + "::" + outfitBodyPart) \ 
    ) as Armor
endFunction

;/
    Returns the outfit id from its name.

    string  @outfitName: The name of the outfit as set up in the name field through the MCM.
    returns: The outfit's id.
/;
string function GetOutfitIdentifier(string outfitName)
    return FastMap_GetString( \ 
        FastMap_GetObject(__clothingOutfitsMap, "Identifiers"), \ 
        outfitName \
    )
endFunction

function SetOutfitName(string outfitId, string outfitName)
    int identifiersObject    = FastMap_GetObject(__clothingOutfitsMap, "Identifiers")
    string currentOutfitName = FastMap_KeyFromValueString(identifiersObject, outfitId)

    bool keyExists = FastMap_HasKey(identifiersObject, currentOutfitName)

    ; Debug("MCM::SetOutfitName", "keyExists: "+ keyExists)
    ; Debug("MCM::SetOutfitName", "[Before] Outfit Identifiers: "+ GetContainerList(identifiersObject))

    if (keyExists)
        FastMap_RemoveKey(identifiersObject, currentOutfitName)
    endif

    FastMap_SetString(identifiersObject, outfitName, outfitId)
    ; Debug("MCM::SetOutfitName", "[After] Outfit Identifiers: "+ GetContainerList(identifiersObject))
endFunction

string _currentRenderedCategory
string property CurrentRenderedCategory
    string function get()
        return _currentRenderedCategory
    endFunction
endProperty

function SetRenderedCategory(string categoryName)
    _currentRenderedCategory = categoryName
endFunction

;/
    Returns the option's name without the category associated with it.

    e.g: Stripping::Allow Stripping as the option will return "Allow Stripping"
/;
string function GetOptionNameNoCategory(string option) global
    int startIndex = StringUtil.Find(option, "::") + 2 ; +2 to skip double colon, start after Category::
    return StringUtil.Substring(option, startIndex)
endFunction

;/
    Returns the option's category without its name.

    e.g: Stripping::Allow Stripping as the option will return "Stripping"
/;
string function GetOptionCategory(string optionWithCategory) global
    int len = StringUtil.Find(optionWithCategory, "::") ; Outfit 1::Equipped Outfit
    return StringUtil.Substring(optionWithCategory, 0, len) ; Outfit 1
endFunction

bool function IsHoldCurrentPage()
    int i = 0
    while (i < Config.Holds.Length)
        if (CurrentPage == Config.Holds[i])
            return true
        endif
        i += 1
    endWhile
    return false
endFunction

function InitializePages()
    string PAGE_SEPARATOR = " ,"
    Pages = String_Explode( \ 
        "Stats," + \
        PAGE_SEPARATOR + \
        "General," + \
        "Skills," + \
        "Clothing," + \
        PAGE_SEPARATOR + \
        String_Implode(Holds) + "," + \
        PAGE_SEPARATOR + \
        "Presets," + \
        PAGE_SEPARATOR + \
        "Maintenance," + \
        "Debug" \
    )
endFunction

;/
    Sets a dependency on an option in order to determine its state (flag).
    
    string  @option: The option to set the dependency on
    bool    @dependency: The condition this option must pass in order to have its state be ON (OFF if false)
    bool?   @storePersistently: Whether to save the state of the option in the save
/;
function SetOptionDependencyBool(string option, bool dependency, bool storePersistently = true)
    string optionKey = self.GetOptionAsStored(option)
    int optionId     = self.GetOptionID(optionKey)
    int flag         = int_if (dependency, OPTION_FLAG_NONE, OPTION_FLAG_DISABLED)

    parent.SetOptionFlags(optionId, flag)

    if (storePersistently)
        self.SetOptionState(optionKey, flag)
    endif
endFunction

; ============================================================
; Option Getters
; ============================================================

;/
    Gets a toggle option's state.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the state from.

    returns [bool]:    The option's state.
/;
bool function GetOptionToggleState(string option, string page = "")
    if (self.OptionHasValue(option, page))
        return self.GetOptionValueBool(option, page)
    else
        return self.GetOptionDefaultBool(option)
    endif
endFunction

;/
    Gets a slider option's value.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the value from.

    returns [float]:    The option's value.
/;
float function GetOptionSliderValue(string option, string page = "")
    if (self.OptionHasValue(option, page))
        return self.GetOptionValueFloat(option, page)
    else
        ; Debug("MCM::GetOptionSliderValue", "option: " + option + ", default content: " + GetContainerList(optionsDefaultValueMap))
        return self.GetOptionDefaultFloat(option)
    endif
endFunction

;/
    Gets a menu option's value.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the value from.

    returns [string]:    The option's value.
/;
string function GetOptionMenuValue(string option, string page = "")
    if (self.OptionHasValue(option, page))
        ; Debug("MCM::GetOptionMenuValue", "option: " + option + ", value: " + self.GetOptionValueString(option, page))
        return self.GetOptionValueString(option, page)
    else
        return self.GetOptionDefaultString(option)
    endif
endFunction

;/
    Gets an input option's value.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the value from.

    returns [string]:    The option's value.
/;
string function GetOptionInputValue(string option, string page = "")
    if (self.OptionHasValue(option, page))
        return self.GetOptionValueString(option, page)
    else
        return self.GetOptionDefaultString(option)
    endif
endFunction

;/
    Sets a slider's multiple options with just a single call.

    float   @minRange: The minimum value for this slider
    float   @maxRange: The maximum value for this slider
    float   @intervalSteps: The value used to determine how much to increment or decrement by each time.
    float   @defaultValue: The slider's default value. (Hotkey: R)
    float   @startValue: The slider's start value, the one that is shown when seeing this option for the first time.
/;
function SetSliderOptions(float minRange, float maxRange, float intervalSteps = 1.0, float defaultValue = 1.0, float startValue = 1.0)
    SetSliderDialogRange(minRange, maxRange)
    SetSliderDialogInterval(intervalSteps)
    SetSliderDialogDefaultValue(defaultValue)
    SetSliderDialogStartValue(startValue)
endFunction

;/
    Gets the identifier of an option like it is stored.

    string  @optionKey: The key of the option
    string? @page: The page where the option is located, CurrentPage is used if null.

    returns (string): The constructed string of how the option is stored.
/;
string function GetOptionAsStored(string optionKey, string page = "")
    return optionKey

    if (page == "")
        return CurrentPage + "/" + optionKey
    else
        return page + "/" + optionKey
    endif
endFunction

int function GetPageObjectFromIDToKey(int parentContainer, string page = "")
    if (page == "")
        page = CurrentPage
    endif

    int pageObject = FastMap_GetObject(parentContainer, page)

    if (!pageObject)
        pageObject = FastMap_SetObject(parentContainer, page, FastMap("<int>"))
    endif


    Debug("MCM::GetPageObjectFromIDToKey", "object: " + pageObject)
    return pageObject
endFunction

;/
    Sets a toggle option on or off based on its state.

    string  @_key: The key of the option of which to change the state.
    bool?   @storePersistently: Whether to store the value in internal storage.
/;
function ToggleOption(string _key, bool storePersistently = true)
    string optionKey = self.GetOptionAsStored(_key)
    int optionId     = self.GetOptionID(optionKey)
    bool option      = bool_if (self.OptionHasValue(_key), self.GetOptionValueBool(_key), self.GetOptionDefaultBool(_key))

    parent.SetToggleOptionValue(optionId, !option)

    if (storePersistently)
        self.SetOptionValueBool(_key, !option)
    endif

    Debug("MCM::ToggleOption", "Set new value of " + !option + " for " + _key + "(OptionKey: "+ optionKey +")" + "(option_id: "+ optionId +")", true)
    ; Trace("MCM::ToggleOption", "Set new value of " + !option + " for " + _key + "(OptionKey: "+ optionKey +")" + "(option_id: "+ optionId +")", true)
endFunction

; ==========================================================
;                 Presets - Scope checklist (ephemeral)
; ==========================================================

;/
    Ephemeral scratch storage for the Presets page's Scope checklist - deliberately NOT part of
    optionsValueMap (not real, persisted MCM option storage). Reset every time the Presets page
    renders, so leaving and returning to the page always starts from a blank, all-unchecked slate.
/;
;/ FastMap<bool> /; int __presetScopeChecked

function ResetPresetScopeChecked()
    __presetScopeChecked = delete(__presetScopeChecked)
    __presetScopeChecked = FastMap("<string>", retain = true)
endFunction

bool function IsPresetBucketChecked(string asBucket)
    if (!__presetScopeChecked)
        return false
    endif

    return FastMap_GetInt(__presetScopeChecked, asBucket) as bool
endFunction

;/
    Sets a Scope checklist bucket's checked state and updates the toggle widget to match.
    Ephemeral only - never touches optionsValueMap.

    string  @asBucket: The bucket name (matches GetPresetBuckets()).
    int     @aiOptionId: The toggle option's native id, to update its displayed state.
    bool    @abChecked: The value to set.
/;
function SetPresetBucketChecked(string asBucket, int aiOptionId, bool abChecked)
    if (!__presetScopeChecked)
        self.ResetPresetScopeChecked()
    endif

    FastMap_SetInt(__presetScopeChecked, asBucket, abChecked as int)
    parent.SetToggleOptionValue(aiOptionId, abChecked)
endFunction

;/
    Ephemeral cache of the exact item list shown in a Menu-type dialog (keyed by option, e.g.
    "Save::menuSavePreset"), captured at OnOptionMenuOpen-time and read back at
    OnOptionMenuAccept-time instead of recomputing it (which risks the accept-time list - e.g. a
    fresh directory listing - drifting from what the player actually saw and clicked on, silently
    mismatching menuIndex to the wrong item).
/;
;/ FastMap<string[]> /; int __presetMenuOptionsCache

function SetPresetMenuOptionsCache(string asOption, string[] akOptions)
    if (!__presetMenuOptionsCache)
        __presetMenuOptionsCache = FastMap("<string>", retain = true)
    endif

    FastMap_SetObject(__presetMenuOptionsCache, asOption, FastArray_FromStringArray(akOptions))
endFunction

;/ Returns none if nothing was cached for @asOption (e.g. accept fired without a matching open). /;
string[] function GetPresetMenuOptionsCache(string asOption)
    if (!__presetMenuOptionsCache)
        return none
    endif

    int cached = FastMap_GetObject(__presetMenuOptionsCache, asOption)

    if (!cached)
        return none
    endif

    return FastArray_ToStringArray(cached)
endFunction

; Option Rendering Functions
; ============================================================

;/
    Adds a header option displaying the passed in text
    and changing the current rendered category to the key.

    string  @text: The text to display on the header option
    string  @_key: The key to set the current category to
    int     @flags: The header option's flags
/;
function AddOptionCategoryKey(string text, string _key, int flags = 0)
    _currentRenderedCategory = _key
    AddHeaderOption(text, flags)
endFunction

;/
    Adds a header option displaying the passed in text
    and setting the current rendered category.

    string  @text: The text to display on the header option
    int     @flags: The header option's flags
/;
function AddOptionCategory(string text, int flags = 0)
    _currentRenderedCategory = text
    AddHeaderOption(text, flags)
endFunction

; ============================================================
; Option Rendering Support - collapsed exists-then-get resolvers
; ============================================================

;/
    Every AddOption*Key function below used to call OptionHasState()+GetOptionState() and
    OptionHasValue()+GetOptionValue{Bool,Float,String}() - two Papyrus-level calls each, both pairs
    resolving the SAME (map, page) page-object twice in a row for data nothing could have changed
    in between. These Resolve* functions do the same net resolution (stored value if present, else
    the caller's own fallback) in one call and one page-object lookup instead of two of each -
    collapsing redundant work at the source, not adding a caching layer on top of it (that was
    already tried elsewhere in this file and measured worse - see TROUBLESHOOTING_NOTES.md). Every
    real page in this MCM renders through these, so this is deliberately a hot path.
/;
int function ResolveOptionFlags(string optionKey, int defaultFlags)
    int pageObject = self.GetPageObject(optionsStateMap, "")

    if (FastMap_HasKey(pageObject, optionKey))
        return FastMap_GetInt(pageObject, optionKey)
    endif

    return defaultFlags
endFunction

bool function ResolveOptionValueBool(string optionKey, int defaultValueOverride)
    int pageObject = self.GetPageObject(optionsValueMap, "")

    if (FastMap_HasKey(pageObject, optionKey))
        return FastMap_GetInt(pageObject, optionKey) as bool
    endif

    if (defaultValueOverride > -1)
        return defaultValueOverride as bool
    endif

    return self.GetOptionDefaultBool(optionKey)
endFunction

float function ResolveOptionValueFloat(string optionKey, float defaultValueOverride)
    int pageObject = self.GetPageObject(optionsValueMap, "")

    if (FastMap_HasKey(pageObject, optionKey))
        return FastMap_GetFloat(pageObject, optionKey)
    endif

    if (defaultValueOverride > -1.0)
        return defaultValueOverride
    endif

    return self.GetOptionDefaultFloat(optionKey)
endFunction

string function ResolveOptionValueString(string optionKey, string defaultValueOverride)
    int pageObject = self.GetPageObject(optionsValueMap, "")

    if (FastMap_HasKey(pageObject, optionKey))
        return FastMap_GetString(pageObject, optionKey)
    endif

    if (defaultValueOverride != "")
        return defaultValueOverride
    endif

    return self.GetOptionDefaultString(optionKey)
endFunction

;/
    Adds and renders a Toggle Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.
    int         @defaultValueOverride: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionToggleKey(string displayedText, string _key, int defaultValueOverride = -1, int defaultFlags = 0)
    int optionId

    string optionKey = CurrentRenderedCategory + "::" + _key

    int flags   = self.ResolveOptionFlags(optionKey, defaultFlags)
    bool value  = self.ResolveOptionValueBool(optionKey, defaultValueOverride)

    optionId = AddToggleOption(displayedText, value, flags)

    if (!self.OptionExists(optionKey))
        self.RegisterOption(optionKey, optionId)
    endif

    return optionId
endFunction

int function AddOptionToggle(string text, int defaultValueOverride = -1, int defaultFlags = 0)
    return AddOptionToggleKey(text, text, defaultValueOverride, defaultFlags)
endFunction

;/
    Adds and renders a Text Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.
    string       @defaultValueOverride: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionTextKey(string displayedText, string _key, string defaultValueOverride = "", int defaultFlags = 0)
    int optionId

    string optionKey = CurrentRenderedCategory + "::" + _key

    int flags      = self.ResolveOptionFlags(optionKey, defaultFlags)
    string value   = self.ResolveOptionValueString(optionKey, defaultValueOverride)

    optionId = AddTextOption(displayedText, value, flags)

    if (!self.OptionExists(optionKey))
        self.RegisterOption(optionKey, optionId)
    endif

    return optionId
endFunction

int function AddOptionText(string text, string defaultValueOverride = "", int defaultFlags = 0)
    return AddOptionTextKey(text, text, defaultValueOverride, defaultFlags)
endFunction

;/
    Adds and renders a Stat Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.

    returns:    The Option's ID.
/;
int function AddOptionStatKey(string displayedText, string _key, int defaultValueOverride = -1, string formatString = "{0}", int defaultFlags = 0)
    ; string optionKey = CurrentRenderedCategory + "::" + _key ; Whiterun::Current Bounty

    ; int value = Config.actorVars.Get("[20]" + optionKey) ; [20]Whiterun::Current Bounty
    ; int optionId = AddTextOption(displayedText, value + " " + formatString, defaultFlags)

    ; if (!self.OptionExists(optionKey))
    ;     self.RegisterOption(optionKey, optionId)
    ; endif

    ; Trace("MCM:AddOptionStatKey", "Option Key: " + optionKey + ", Value: " + value + ", Option ID: " + optionId)
    ; return optionId
endFunction


int function AddOptionStat(string text, int defaultValueOverride = -1, string formatString = "{0}", int defaultFlags = 0)
    return AddOptionStatKey(text, text, defaultValueOverride, formatString, defaultFlags)
endFunction

;/
    Adds and renders a Slide Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.
    float       @defaultValue: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionSliderKey(string displayedText, string _key, string formatString = "{0}", float defaultValueOverride = -1.0, int defaultFlags = 0)
    int optionId

    string optionKey = CurrentRenderedCategory + "::" + _key

    int flags    = self.ResolveOptionFlags(optionKey, defaultFlags)
    float value  = self.ResolveOptionValueFloat(optionKey, defaultValueOverride)

    optionId = AddSliderOption(displayedText, value, formatString, flags)

    if (!self.OptionExists(optionKey))
        ; DebugWithArgs("MCM::AddOptionSliderKey", "displayedText: " + displayedText + ", key: " + _key, "Option does not exist!")
        self.RegisterOption(optionKey, optionId)
    endif

    ; Debug("MCM::AddOptionSliderKey", "Option Key: " + optionKey + ", Value: " + value + ", Option ID: " + optionId + ", Has State: " + optionHasState + ", Has Value: " + optionHasValue)

    ; if (optionKey == "General::Infamy Decay (Update Interval)" || optionKey == "General::InfamyNotifications")
    ;     Debug("MCM::AddOptionSliderKey", "Option Key: " + optionKey + ", Default: " + self.GetOptionDefaultFloat(optionKey) + ", Value: " + self.GetOptionValueFloat(optionKey))
    ;     Debug("MCM::AddOptionSliderKey", "Defaults Content: " + GetContainerList(optionsDefaultValueMap))
    ;     Debug("MCM::AddOptionSliderKey", "Value Content: " + GetContainerList(optionsValueMap))
    ;     Debug("MCM::AddOptionSliderKey", "Key to ID: " + GetContainerList(optionsFromKeyToIdMap))
    ;     Debug("MCM::AddOptionSliderKey", "ID To Key: " + GetContainerList(optionsFromIdToKeyMap))
    ; endif

    return optionId
endFunction

int function AddOptionSlider(string text, string formatString = "{0}", float defaultValueOverride = -1.0, int defaultFlags = 0)
    return AddOptionSliderKey(text, text, formatString, defaultValueOverride, defaultFlags)
endFunction

;/
    Adds and renders a Menu Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.
    string      @defaultValue: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionMenuKey(string displayedText, string _key, string defaultValueOverride = "", int defaultFlags = 0)
    int optionId

    string optionKey = CurrentRenderedCategory + "::" + _key

    int flags      = self.ResolveOptionFlags(optionKey, defaultFlags)
    string value   = self.ResolveOptionValueString(optionKey, defaultValueOverride)

    optionId = AddMenuOption(displayedText, value, flags)

    if (!self.OptionExists(optionKey))
        self.RegisterOption(optionKey, optionId)
    endif

    return optionId
endFunction

int function AddOptionMenu(string text, string defaultValueOverride = "", int defaultFlags = 0)
    return AddOptionMenuKey(text, text, defaultValueOverride, defaultFlags)
endFunction

;/
    Adds and renders an Input Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the input.
    string      @_key: The key to be used to set values to and from storage.
    string      @defaultValue: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionInputKey(string displayedText, string _key, string defaultValueOverride = "-", int defaultFlags = 0)
    int optionId

    string optionKey = CurrentRenderedCategory + "::" + _key

    int flags      = self.ResolveOptionFlags(optionKey, defaultFlags)
    string value   = self.ResolveOptionValueString(optionKey, defaultValueOverride)

    optionId = AddInputOption(displayedText, value, flags)

    if (!self.OptionExists(optionKey))
        self.RegisterOption(optionKey, optionId)
    endif

    return optionId
endFunction

int function AddOptionInput(string text, string defaultValueOverride = "", int defaultFlags = 0)
    return AddOptionInputKey(text, text, defaultValueOverride, defaultFlags)
endFunction

; ============================================================
; Option Setters
; ============================================================

;/
    Sets a slider option's value.

    string      @option: The name of the option to be changed.
    float       @value: The new value for the option.
    string      @formatString: The format string used when displaying the option.
/;
function SetOptionSliderValue(string option, float value, string formatString = "{0}", string page = "")
    string optionKey = self.GetOptionAsStored(option, page)
    int optionId     = self.GetOptionID(optionKey)

    ; Change the value of the slider option
    parent.SetSliderOptionValue(optionId, value, formatString)
    
    ; Store the value
    self.SetOptionValueFloat(option, value, page)

    ; Trace("SetOptionSliderValue", "Set new value of " + self.GetOptionValueFloat(option) + " for " + option + " (option_id: " + optionId + ")", true)
endFunction

;/
    Sets a menu option's value.

    string      @option: The name of the option to be changed.
    string      @value: The new value for the option.
    string?     @page: The page where this Option is located, if null, the current page will be used.
/;
function SetOptionMenuValue(string option, string value, string page = "")
    string optionKey = self.GetOptionAsStored(option, page)
    int optionId     = self.GetOptionID(optionKey)
    
    ; Change the value of the menu option
    parent.SetMenuOptionValue(optionId, value)

    ; Store the value
    self.SetOptionValueString(option, value, page)

    ; Debug("MCM::SetOptionMenuValue", "Set new value of " + value + " for " + string_if (page != "", page + "/") + option + " (option_id: " + optionId + ")")
endFunction

;/
    Sets an input option's value.

    string      @option: The name of the option to be changed.
    string      @value: The new value for the option.
/;
function SetOptionInputValue(string option, string value, string page = "")
    string optionKey = self.GetOptionAsStored(option, page)
    int optionId     = self.GetOptionID(optionKey)

    ; Change the value of the input option
    parent.SetInputOptionValue(optionId, value)

    ; Store the value
    self.SetOptionValueString(option, value, page)

    ; Trace("SetOptionInputValue", "Set new value of " + value + " for " + option + " (option_id: " + optionId + ")")
endFunction

; ============================================================================
; Event Handling
; ============================================================================
event OnConfigInit()
    Debug("MCM::OnConfigInit", "Firing")

    ModName = RPB_Data.MCM_GetRootPropertyOfTypeString("Config", "Name")

    self.InitializePages()
    self.InitializeOptions()
    self.RegisterEvents()
    self.LoadDefaults()
endEvent

event OnConfigOpen()
    if (Object_IsIntMap(optionsFromIdToKeyMap))
        ; Repair a save whose optionsFromIdToKeyMap was persisted as a JIntMap by old code (should be a JMap - see InitializeOptions()).
        ; OnConfigInit only fires once ever per save, so fixing InitializeOptions() alone can't retroactively repair a save that already ran it under the old, wrong type.
        Debug("MCM::OnConfigOpen", "Repairing optionsFromIdToKeyMap - was created as a JIntMap by old code, recreating as a JMap")
        optionsFromIdToKeyMap = FastMap("<string>")
        FastMap_SetObject(generalContainer, "options/id/from-id-to-key", optionsFromIdToKeyMap)
    endif

    self.MCM() ; Idempotently ensure the option-storage maps are valid every time the menu opens

    self.InitializePages()
    self.SetHardcodedDefaults()

    self.RegisterPages()

endEvent

string property RPB_CurrentPage auto

string property CurrentPageConfig
    string function get()
        if (self.IsHoldCurrentPage())
            ; Debug("MCM::CurrentPageConfig", CurrentPage + " ->Hold")
            return "Hold"
        endif

        return CurrentPage
    endFunction
endProperty

event OnPageReset(string page)
    self.RefreshOptionDefaultsForCurrentPage() ; before any page's Render() - HandleDependencies() etc. need real defaults, not a cache that's only ever been warmed for whatever page was current at OnConfigInit

    RPB_MCM_Skills.Render(self)
    RPB_MCM_Holds.Render(self)
    RPB_MCM_General.Render(self)
    RPB_MCM_Clothing.Render(self)
    RPB_MCM_Debug.Render(self)
    RPB_MCM_Stats.Render(self)
    RPB_MCM_Presets.Render(self)

    ; Debug("MCM::OnPageReset", "Content: " + GetContainerList(optionsValueMap))

    ; int jintTest = JMap.object()
    ; JValue.retain(jintTest, "RPB_MEMORY")

    ; int jintTestInPage = self.GetPageObjectFromIDToKey(jintTest, page)
    ; Debug("("+ page +") MCM::OnPageReset", "jintTestInPage: " + jintTestInPage + ", content: " + GetContainerList(jintTestInPage))

    ; JMap.setInt(self.GetPageObject(optionsFromKeyToIdMap, page), "Arrest::Guaranteed Payable Bounty", 1798)
    ; JIntMap.setStr(jintTestInPage, 1798, "Arrest::Guaranteed Payable Bounty")

    ; Debug("("+ page +") MCM::OnPageReset", "Object (From ID to Key): " + self.GetPageObjectFromIDToKey(jintTest, page))
    ; Debug("("+ page +") MCM::OnPageReset", "Object (From Key to ID): " + self.GetPageObject(optionsFromKeyToIdMap, page))

    ; Debug("("+ page +") MCM::OnPageReset", "Option Map (From ID to Key): " + GetContainerList(self.GetPageObjectFromIDToKey(jintTest, page)))
    ; Debug("("+ page +") MCM::OnPageReset", "Option Map (From Key to ID): " + GetContainerList(self.GetPageObject(optionsFromKeyToIdMap, page)))

    ; Debug("MCM::OnPageReset", "Option Map (From ID to Key): " + GetContainerList(optionsFromIdToKeyMap))
    ; Debug("MCM::OnPageReset", "Option Map (From Key to ID): " + GetContainerList(optionsFromKeyToIdMap))
    if (page == "Debug")
        MCM()

    elseif (page == "Presets")
        ; Was dumping the entire optionsValueMap/optionsDefaultValueMap trees as strings on every
        ; Presets page reset - the actual cause of the Presets page feeling slow to open (this was
        ; gated specifically to page == "Presets", not a hook every page shares), and it only got
        ; worse as the preset redesign's full-snapshot Loads grew optionsValueMap larger.
        ; Debug("RPB_MCM::OnPageReset", "optionsValueMap: " + GetContainerList(optionsValueMap) + "\n" + "optionsDefaultValueMap: " + GetContainerList(optionsDefaultValueMap))
    endif
endEvent

;/
    Fires from a RegisterForSingleUpdate() scheduled by a page's Render() - see
    RPB_MCM_Holds.Render()/OnDeferredDependencyUpdate() for why: SkyUI doesn't reliably apply
    SetOptionFlags visually when called in the same pass as the options it targets were just
    created in - works fine as a later, separate call (e.g. on click), not immediately after
    Render(). Each page module guards its own deferred handler against having navigated away by
    the time this fires.
/;
event OnUpdate()
    RPB_MCM_Holds.OnDeferredDependencyUpdate(self)
endEvent

event OnOptionHighlight(int option)
    RPB_MCM_Skills.OnHighlight(self, option)
    RPB_MCM_Holds.OnHighlight(self, option)
    RPB_MCM_General.OnHighlight(self, option)
    RPB_MCM_Clothing.OnHighlight(self, option)
    RPB_MCM_Debug.OnHighlight(self, option)
    RPB_MCM_Stats.OnHighlight(self, option)
    RPB_MCM_Sentence.OnHighlight(self, option)
    RPB_MCM_Presets.OnHighlight(self, option)
endEvent

event OnOptionDefault(int option)
    RPB_MCM_Skills.OnDefault(self, option)
    RPB_MCM_Holds.OnDefault(self, option)
    RPB_MCM_General.OnDefault(self, option)
    RPB_MCM_Clothing.OnDefault(self, option)
    RPB_MCM_Debug.OnDefault(self, option)
    RPB_MCM_Stats.OnDefault(self, option)
    RPB_MCM_Sentence.OnDefault(self, option)
    RPB_MCM_Presets.OnDefault(self, option)
endEvent

event OnOptionSelect(int option)
    RPB_MCM_Skills.OnSelect(self, option)
    RPB_MCM_Holds.OnSelect(self, option)
    RPB_MCM_General.OnSelect(self, option)
    RPB_MCM_Clothing.OnSelect(self, option)
    RPB_MCM_Debug.OnSelect(self, option)
    RPB_MCM_Stats.OnSelect(self, option)
    RPB_MCM_Sentence.OnSelect(self, option)
    RPB_MCM_Presets.OnSelect(self, option)
endEvent

event OnOptionSliderOpen(int option)
    RPB_MCM_Skills.OnSliderOpen(self, option)
    RPB_MCM_Holds.OnSliderOpen(self, option)
    RPB_MCM_General.OnSliderOpen(self, option)
    RPB_MCM_Clothing.OnSliderOpen(self, option)
    RPB_MCM_Debug.OnSliderOpen(self, option)
    RPB_MCM_Stats.OnSliderOpen(self, option)
    RPB_MCM_Sentence.OnSliderOpen(self, option)
    RPB_MCM_Presets.OnSliderOpen(self, option)
endEvent

event OnOptionSliderAccept(int option, float value)
    RPB_MCM_Skills.OnSliderAccept(self, option, value)
    RPB_MCM_Holds.OnSliderAccept(self, option, value)
    RPB_MCM_General.OnSliderAccept(self, option, value)
    RPB_MCM_Clothing.OnSliderAccept(self, option, value)
    RPB_MCM_Debug.OnSliderAccept(self, option, value)
    RPB_MCM_Stats.OnSliderAccept(self, option, value)
    RPB_MCM_Sentence.OnSliderAccept(self, option, value)
    RPB_MCM_Presets.OnSliderAccept(self, option, value)
endEvent

event OnOptionMenuOpen(int option)
    RPB_MCM_Skills.OnMenuOpen(self, option)
    RPB_MCM_Holds.OnMenuOpen(self, option)
    RPB_MCM_General.OnMenuOpen(self, option)
    RPB_MCM_Clothing.OnMenuOpen(self, option)
    RPB_MCM_Debug.OnMenuOpen(self, option)
    RPB_MCM_Stats.OnMenuOpen(self, option)
    RPB_MCM_Sentence.OnMenuOpen(self, option)
    RPB_MCM_Presets.OnMenuOpen(self, option)
endEvent

event OnOptionMenuAccept(int option, int index)
    RPB_MCM_Skills.OnMenuAccept(self, option, index)
    RPB_MCM_Holds.OnMenuAccept(self, option, index)
    RPB_MCM_General.OnMenuAccept(self, option, index)
    RPB_MCM_Clothing.OnMenuAccept(self, option, index)
    RPB_MCM_Debug.OnMenuAccept(self, option, index)
    RPB_MCM_Stats.OnMenuAccept(self, option, index)
    RPB_MCM_Sentence.OnMenuAccept(self, option, index)
    RPB_MCM_Presets.OnMenuAccept(self, option, index)
endEvent

event OnOptionInputOpen(int option)
    RPB_MCM_Skills.OnInputOpen(self, option)
    RPB_MCM_Holds.OnInputOpen(self, option)
    RPB_MCM_General.OnInputOpen(self, option)
    RPB_MCM_Clothing.OnInputOpen(self, option)
    RPB_MCM_Debug.OnInputOpen(self, option)
    RPB_MCM_Stats.OnInputOpen(self, option)
    RPB_MCM_Sentence.OnInputOpen(self, option)
    RPB_MCM_Presets.OnInputOpen(self, option)
endEvent

event OnOptionInputAccept(int option, string inputValue)
    RPB_MCM_Skills.OnInputAccept(self, option, inputValue)
    RPB_MCM_Holds.OnInputAccept(self, option, inputValue)
    RPB_MCM_General.OnInputAccept(self, option, inputValue)
    RPB_MCM_Clothing.OnInputAccept(self, option, inputValue)
    RPB_MCM_Debug.OnInputAccept(self, option, inputValue)
    RPB_MCM_Stats.OnInputAccept(self, option, inputValue)
    RPB_MCM_Sentence.OnInputAccept(self, option, inputValue)
    RPB_MCM_Presets.OnInputAccept(self, option, inputValue)
endEvent

function SerializeOptions()
    Object_WriteData(generalContainer, "generalContainer.txt")
    ; miscVars.serialize("root", "miscVars_all.txt")
endFunction

; ============================================================================
;                               Option Functions
; ============================================================================

; Handling of options with additional behavior other than setting value,
; such as setting additional variables based on the Option.
event OnSliderOptionChanged(string eventName, string optionName, float optionValue, Form sender)
    if (optionName == "Bounty for Actions::Trespassing")
        Game.SetGameSettingInt("iCrimeGoldTrespass", optionValue as int)

        int settingValue = Game.GetGameSettingInt("iCrimeGoldTrespass")
        Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Assault")
        Game.SetGameSettingInt("iCrimeGoldAttack", optionValue as int)
        
        int settingValue = Game.GetGameSettingInt("iCrimeGoldAttack")
        Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Murder")
        Game.SetGameSettingInt("iCrimeGoldMurder", optionValue as int)
        
        int settingValue = Game.GetGameSettingInt("iCrimeGoldMurder")
        Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Theft")
        Game.SetGameSettingFloat("fCrimeGoldSteal", optionValue)
        
        float settingValue = Game.GetGameSettingFloat("fCrimeGoldSteal")
        Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Pickpocketing")
        Game.SetGameSettingInt("iCrimeGoldPickpocket", optionValue as int)
        
        int settingValue = Game.GetGameSettingInt("iCrimeGoldPickpocket")
        Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Horse Theft")
        
    elseif (optionName == "Bounty for Actions::Disturbing the Peace")

    endif
endEvent

function RegisterEvents()
    self.RegisterForModEvent("RPB_SliderOptionChanged", "OnSliderOptionChanged")
endFunction

;/
    Loads all of the option's properties from the config file.

    This function does not handle sanitizing user input, 
    as such, any input should be sanitized through the use of ValidateOption().
/;
function LoadOptionProperties(string asOption)
    self.LoadPropertyForOption(asOption, "Minimum")
    self.LoadPropertyForOption(asOption, "Maximum")
    self.LoadPropertyForOption(asOption, "Steps")
    self.LoadPropertyForOption(asOption, "Default")
endFunction

;/
    Validates all options that need validation, ensuring they follow a specific rule set.

    As such, any options that should have rules such as having its value less than / greater than
    or equal to another option, or a specific value, should be set here.

    For options not present in the MCM config file, this function is also used to assign default values for them through
    EnsureOptionValueGreaterThanOrEqualTo()
/;
function ValidateOption(string asOption)
    if (asOption == "General::Timescale" || \
        asOption == "General::TimescalePrison" || \
        asOption == "General::Arrest Elude Warning Time" || \
        asOption == "Infamy::Infamy Recognized Threshold" || \
        asOption == "Infamy::Infamy Known Threshold" || \
        asOption == "Frisking::Frisk Search Thoroughness" || \
        asOption == "Frisking::Minimum No. of Stolen Items Required" || \
        asOption == "Stripping::Minimum Sentence to Strip" || \
        asOption == "Stripping::Strip Search Thoroughness" || \
        asOption == "Jail::Bounty to Sentence" || \
        asOption == "Jail::Minimum Sentence" || \
        asOption == "Jail::Maximum Sentence" || \
        asOption == "Jail::Release Time (Minimum Hour)" || \
        asOption == "Jail::Release Time (Maximum Hour)" || \
        asOption == "Jail::Day to Fast Forward From" || \
        asOption == "Jail::Day to Start Losing Skills (Stat)" || \
        asOption == "Jail::Day to Start Losing Skills (Perk)" || \
        asOption == "Release::Minimum Bounty to Retain Items" || \
        asOption == "Escape::Escape Bounty (Bounty Condition)" || \
        asOption == "Escape::Escape Bounty (Sentence Condition)" || \
        asOption == "Clothing::Maximum Sentence to Clothe" \
    )
        EnsureOptionIsNotOfType(asOption, TYPE_STRING)
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 1)
    endif

; ============================================================
;                            Skills
; ============================================================

;                             Stats
; ============================================================

    if (asOption == "Deleveling::Health" || \
        asOption == "Deleveling::Stamina" || \
        asOption == "Deleveling::Magicka" \
        )
        EnsureOptionIsOfType(asOption, TYPE_INT)
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 1, asValuePropertyType = "Steps")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 0, asValuePropertyType = "Minimum")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 15, asValuePropertyType = "Maximum")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 0, asValuePropertyType = "Default")

    elseif (asOption == "Level Caps::Health" || \
            asOption == "Level Caps::Stamina" || \
            asOption == "Level Caps::Magicka" \
        )
        EnsureOptionIsOfType(asOption, TYPE_INT)
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 1, asValuePropertyType = "Steps")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 0, asValuePropertyType = "Minimum")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 15, asValuePropertyType = "Maximum")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 0, asValuePropertyType = "Default")

;                             Perks
; ============================================================
    
    elseif ( \ 
        String_StartsWith(asOption, "Deleveling::") && \
        !String_StartsWith(asOption, "Deleveling::Health") && \
        !String_StartsWith(asOption, "Deleveling::Stamina") && \
        !String_StartsWith(asOption, "Deleveling::Magicka") \
    )
        EnsureOptionIsOfType(asOption, TYPE_INT)
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 1, asValuePropertyType = "Steps")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 0, asValuePropertyType = "Minimum")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 10, asValuePropertyType = "Maximum")
        EnsureOptionValueLessThanOrEqualTo(asOption, 100, asValuePropertyType = "Maximum")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 0, asValuePropertyType = "Default")

    elseif ( \ 
        String_StartsWith(asOption, "Level Caps::") && \ 
        !String_StartsWith(asOption, "Level Caps::Health") && \
        !String_StartsWith(asOption, "Level Caps::Stamina") && \
        !String_StartsWith(asOption, "Level Caps::Magicka") \
    )
        EnsureOptionIsOfType(asOption, TYPE_INT)
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 1, asValuePropertyType = "Steps")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 0, asValuePropertyType = "Minimum")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 10, asValuePropertyType = "Maximum")
        EnsureOptionValueLessThanOrEqualTo(asOption, 100, asValuePropertyType = "Maximum")
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 0, asValuePropertyType = "Default")
    endif

; ============================================================

    if (asOption == "Frisking::Frisk Search Thoroughness" || \ 
        asOption == "Stripping::Strip Search Thoroughness" \ 
    )
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 1)
        EnsureOptionValueLessThanOrEqualTo(asOption, 10)
    endif

    if (asOption == "Arrest::Maximum Payable Bounty (Chance)" || \ 
        asOption == "Jail::Maximum Payable Bounty (Chance)" || \
        asOption == "Jail::Chance to Lose Skills (Stat)" || \
        asOption == "Jail::Chance to Lose Skills (Perk)" \
    )
        EnsureOptionValueLessThanOrEqualTo(asOption, 100)
    endif

    if (asOption == "Jail::Release Time (Minimum Hour)" || \ 
        asOption == "Jail::Release Time (Maximum Hour)" \ 
    )
        EnsureOptionValueLessThanOrEqualTo(asOption, 24)
        EnsureOptionValueLessThanOptionValue( \ 
            asOptionOneKey  = "Jail::Release Time (Minimum Hour)", \ 
            asOptionTwoKey  = "Jail::Release Time (Maximum Hour)", \ 
            afValueToSet    = self.GetOptionValueFloat("Jail::Release Time (Maximum Hour)") - 1, \
            asValuePropertyType = "Maximum" \ 
        )
    endif

endFunction

function ValidateOptions()
    int obj         = FastMap_Keys(optionsDefaultValueMap) ; JArray& (string[])
    int optionCount = FastArray_Size(obj)

    int validatedOptions = 0

    int optionIndex = 0
    while (optionIndex < optionCount)
        string optionKey = FastArray_GetString(obj, optionIndex)

        self.ValidateOption(optionKey)
        validatedOptions += 1
        optionIndex += 1
    endWhile

    ; Debug("MCM::ValidateOptions", "Validated " + validatedOptions + " options.")
endFunction

bool function IsValidPropertyType(string asPropertyType)
    return \
        asPropertyType == "Minimum" || \
        asPropertyType == "Maximum" || \
        asPropertyType == "Default" || \
        asPropertyType == "Steps" 
endFunction

string[] function GetPropertyTypes()
    return String_Explode("Minimum,Maximum,Default,Steps")
endFunction

;/
    JMap&   @apOptionMap: The map containing the option's properties.
    string  @asPropertyType: The property to determine the value type of.

    returns (int): The value type of the specified property.
/;
int function DeterminePropertyValueType(int apOptionMap, string asPropertyType)
    int valueType = FastMap_ValueType(apOptionMap, asPropertyType)

    if (valueType == TYPE_OBJECT)
        ; Property specified is a dependency property, process it accordingly.
        int dependencyObject            = FastMap_GetObject(apOptionMap, asPropertyType)
        string dependencyOptionKey      = FastArray_GetString(dependencyObject, 0)
        int dependencyOptionValueType   = FastMap_ValueType(optionsDefaultValueMap, dependencyOptionKey) ; Might change, since default option may not be defined yet

        ; Since all default number options are stored as float, determine here if it's float or int
        if (dependencyOptionValueType == TYPE_FLOAT)
            float originalValue     = FastMap_GetFloat(optionsDefaultValueMap, dependencyOptionKey)
            float fractionalPart    = originalValue - math.floor(originalValue)

            if (fractionalPart == 0.0)
                return TYPE_INT
            endif

            return TYPE_FLOAT
        endif
        
        return dependencyOptionValueType
            
    elseif (valueType == TYPE_FLOAT || valueType == TYPE_INT || valueType == TYPE_STRING)
        ; Simple property value type, just return it
        return valueType
    endif

    Error("There was an error determining the value type of the property.")
    DebugError("MCM::GetOptionValueTypeFromConfig", "[Property Type: "+ asPropertyType +"] There was an error determining the value type of the property.")
endFunction

; TODO: Check for dependency options value types
; TODO: Fix error, number dependency options are always considered float, even if they should be int (should be fixed with DeterminePropertyValueType())
int function GetOptionValueTypeFromConfig(string asOptionKey, bool abVerifyEveryProperty = true, string asReturnedPropertyTypeIfNotAllEqual = "")
    int optionsObj  = RPB_Data.MCM_GetOptionObject()
    int pageObj     = FastMap_GetObject(optionsObj, CurrentPageConfig)
    int optionMap   = FastMap_GetObject(pageObj, asOptionKey) ; JMap&

    ;/ 
        Check what properties it has,
        Assume that, if 4 properties exist, it is a number option,
        since those are: Minimum, Maximum, Default, Steps (and Minimum, Maximum only exist for number options).

        If there's only one property (Default), check whether it is of type string or bool.
    /;
    int propertyCount = FastMap_Size(optionMap)

    if (asOptionKey == "Infamy::Infamy Recognized Threshold")
        Debug("MCM::GetOptionValueTypeFromConfig", "Property Count: " + propertyCount)
    endif

    if (propertyCount == 4) ; Assuming Number Option
        int minimumPropertyValueType = self.DeterminePropertyValueType(optionMap, "Minimum")
        int maximumPropertyValueType = self.DeterminePropertyValueType(optionMap, "Maximum")
        int defaultPropertyValueType = self.DeterminePropertyValueType(optionMap, "Default")
        int stepsPropertyValueType   = self.DeterminePropertyValueType(optionMap, "Steps")

        DebugWithArgs( \ 
            "MCM::GetOptionValueTypeFromConfig",  "asOptionKey: " + asOptionKey, \ 
            "Value Types: \n" + \ 
            "\t - minimumPropertyValueType: " + minimumPropertyValueType + "\n" + \
            "\t - maximumPropertyValueType: " + maximumPropertyValueType + "\n" + \
            "\t - defaultPropertyValueType: " + defaultPropertyValueType + "\n" + \
            "\t - stepsPropertyValueType: " + stepsPropertyValueType + "\n" \
        )

        if (abVerifyEveryProperty)
            bool arePropertiesOfSameType = \
                minimumPropertyValueType == maximumPropertyValueType == \
                defaultPropertyValueType == stepsPropertyValueType

            if (arePropertiesOfSameType)
                return minimumPropertyValueType ; They are all the same, doesn't matter which to return
            else
                ; Return the value type specified, if it wasn't specified or is invalid, return the Minimum value type
                string propertyType = \
                    string_if ( \
                    self.IsValidPropertyType(asReturnedPropertyTypeIfNotAllEqual), \
                    asReturnedPropertyTypeIfNotAllEqual, "Minimum" \
                )

                int returnedValueType = FastMap_ValueType(optionMap, propertyType)

                ; if (returnedValueType == TYPE_OBJECT)
                ;     ; Selected property is a dependency, not a value, get its value.
                ;     int dependencyObject            = JMap.getObj(optionMap, propertyType)
                ;     string dependencyOptionKey      = JArray.getStr(dependencyObject, 0)
                ;     int dependencyOptionValueType   = JMap.valueType(optionsDefaultValueMap, dependencyOptionKey) ; Might change, since default option may be undefined still

                ;     return dependencyOptionValueType

                ;     ; ; Get the dependency property's value
                ;     ; if (dependencyOptionValueType == TYPE_FLOAT || dependencyOptionValueType == TYPE_INT)
                ;     ;     float dependencyOptionValue = self.GetNumberOptionPropertyValue(dependencyOptionKey, propertyType)
                ;     ;     float offset = JArray.getFlt(dependencyObject, 1)
                ;     ;     bool hasOffset = (offset as bool)

                ;     ;     float finalOptionValue = float_if (hasOffset, (dependencyOptionValue + offset), dependencyOptionValue)
                ;     ;     return dependencyOptionValueType

                ;     ; elseif (dependencyOptionValueType == TYPE_STRING)
                ;     ;     string dependencyOptionValue = self.GetStringOptionPropertyValue(dependencyOptionKey, propertyType)
                ;     ;     return dependencyOptionValueType
                ;     ; endif

                ; endif

                Warn("The option ["+ asOptionKey +"] is most likely an invalid option, since not all property value types are the same!")
                DebugWarn("MCM::GetOptionValueTypeFromConfig", "[returned value type: "+ returnedValueType +"] ["+ propertyType +"] The option ["+ asOptionKey +"] is most likely an invalid option, since not all property value types are the same!")
                return returnedValueType
            endif
        endif

        return minimumPropertyValueType

    elseif (propertyCount == 1) ; String or Bool option
        string propertyType     = FastMap_GetNthKey(optionMap, 0)
        int propertyValueType   = FastMap_ValueType(optionMap, propertyType)

        return propertyValueType
    endif

    Error("There was an error retrieving the property value type of option [" + asOptionKey + "], make sure the option has a valid configuration!")
    DebugError("MCM::GetOptionValueTypeFromConfig", "There was an error retrieving the property value type of option [" + asOptionKey + "], make sure the option has a valid configuration!")
endFunction

;/
    Loads all options with the specified property type from the config file.
/;
function LoadOptionValues(string asPropertyType)
    int optionsObj  = RPB_Data.MCM_GetOptionObject()
    int pageObj     = FastMap_GetObject(optionsObj, CurrentPageConfig)
    int optionCount = FastMap_Size(pageObj)

    int optionIndex = 0
    bool continue   = false

    while (optionIndex < optionCount)
        string optionKey                = FastMap_GetNthKey(pageObj, optionIndex) ; Current Option Key
        int optionMap                   = FastMap_GetObject(pageObj, optionKey) ; JMap&
        bool hasPropertySpecified       = FastMap_HasKey(optionMap, asPropertyType)

        if (!hasPropertySpecified)
            ; Determine if it's a string or bool option, if so, we shouldn't error, otherwise we should.
            bool hasMinimum = FastMap_HasKey(optionMap, "Minimum")
            bool hasMaximum = FastMap_HasKey(optionMap, "Maximum")
            bool hasSteps   = FastMap_HasKey(optionMap, "Steps")
            bool hasDefault = FastMap_HasKey(optionMap, "Default")
            bool hasNumberOptionProperties = hasMinimum && hasMaximum && hasSteps
            
            if (!hasNumberOptionProperties)
                ; String or Bool option
                Error("There was an error loading the option " + optionKey + ", there is no property to read!", !hasDefault)
                DebugError("MCM::LoadOptionValues", "There was an error loading the option " + optionKey + ", there is no property to read!", !hasDefault)
                continue = true
            endif
            
            if (!continue)
                Error("There was an error loading the "+ asPropertyType +" value for option [" + optionKey + "].")
                DebugError("MCM::LoadOptionValues", "There was an error loading the "+ asPropertyType +" value for option [" + optionKey + "].")
            endif
            continue = true
        endif

        if (!continue)
            bool hasDependency = FastMap_ValueType(optionMap, asPropertyType) == TYPE_OBJECT

            if (hasDependency)
                int propertyObject              = FastMap_GetObject(optionMap, asPropertyType)
                string dependencyOptionKey      = FastArray_GetString(propertyObject, 0) ; [0] = Dependency Option
                int dependencyOptionValueType   = self.GetOptionValueTypeFromConfig(dependencyOptionKey)

                if (dependencyOptionValueType == TYPE_FLOAT || dependencyOptionValueType == TYPE_INT)
                    ; If of type int, cast it to float
                    float offset                = FastArray_GetFloat(propertyObject, 1) ; [1] = Option Offset
                    bool hasOffset              = (offset as bool)
                    float dependencyOptionValue = self.GetOptionSliderValue(dependencyOptionKey)
                    float updatedValue          = float_if (hasOffset, (dependencyOptionValue + offset), dependencyOptionValue)
                    self.SetNumberOptionPropertyValue(optionKey, asPropertyType, updatedValue)
                endif

            else
                bool isBool     = self.IsPropertyValueOfTypeBool(optionMap, asPropertyType)
                bool isFloat    = FastMap_ValueType(optionMap, asPropertyType) == TYPE_FLOAT
                bool isInteger  = FastMap_ValueType(optionMap, asPropertyType) == TYPE_INT
                bool isString   = FastMap_ValueType(optionMap, asPropertyType) == TYPE_STRING

                if (isBool)
                    bool optionValue = FastMap_GetInt(optionMap, asPropertyType) as bool
                    self.SetBoolOptionPropertyValue(optionKey, asPropertyType, optionValue)
                    DebugWithArgs("MCM::LoadOptionValues", asPropertyType, "[bool] Setting ["+ optionKey + "] " + asPropertyType +" Value to: " + optionValue)

                elseif (isInteger)
                    int optionValue = FastMap_GetInt(optionMap, asPropertyType) ; int|bool
                    self.SetNumberOptionPropertyValue(optionKey, asPropertyType, optionValue)
                    DebugWithArgs("MCM::LoadOptionValues", asPropertyType, "[int] Setting ["+ optionKey + "] " + asPropertyType +" Value to: " + optionValue)

                elseif (isFloat)
                    float optionValue = FastMap_GetFloat(optionMap, asPropertyType) ; int|float
                    self.SetNumberOptionPropertyValue(optionKey, asPropertyType, optionValue)
                    DebugWithArgs("MCM::LoadOptionValues", asPropertyType, "[float] Setting ["+ optionKey + "] " + asPropertyType +" Value to: " + optionValue)

                elseif (isString)
                    string optionValue = FastMap_GetString(optionMap, asPropertyType) ; string
                    self.SetStringOptionPropertyValue(optionKey, asPropertyType, optionValue)
                    DebugWithArgs("MCM::LoadOptionValues", asPropertyType, "[string] Setting ["+ optionKey + "] " + asPropertyType +" Value to: " + optionValue)
                endif
            endif
        endif

        continue = false
        optionIndex += 1
    endWhile
endFunction

function LoadDefaults()
    self.LoadOptionValues("Default")
endFunction

function LoadMinimums()
    self.LoadOptionValues("Minimum")
endFunction

function LoadMaximums()
    self.LoadOptionValues("Maximum")
endFunction

function LoadSteps()
    self.LoadOptionValues("Steps")
endFunction

;/
    Sets the value for a specific property of a string option.
/;
function SetStringOptionPropertyValue(string asOptionKey, string asProperty, string asValue)
    if (asProperty == "Default")
        self.SetOptionDefaultString(asOptionKey, asValue)
    endif
endFunction

;/
    Sets the value for a specific property of a bool option.
/;
function SetBoolOptionPropertyValue(string asOptionKey, string asProperty, bool abValue)
    if (asProperty == "Default") ; bool only has Default property for now
        self.SetOptionDefaultBool(asOptionKey, abValue)
    endif
endFunction

;/
    Sets the value for a specific property of a number option.
/;
function SetNumberOptionPropertyValue(string asOptionKey, string asProperty, float afValue)
    if (asProperty == "Minimum")
        self.SetOptionMinimum(asOptionKey, afValue)

    elseif (asProperty == "Maximum")
        self.SetOptionMaximum(asOptionKey, afValue)

    elseif (asProperty == "Default")
        self.SetOptionDefaultFloat(asOptionKey, afValue)

    elseif (asProperty == "Steps")
        self.SetOptionSteps(asOptionKey, afValue)
    endif
endFunction

bool function GetBoolOptionPropertyValue(string asOptionKey, string asPropertyType)
    if (asPropertyType == "Default")
        self.GetOptionDefaultBool(asOptionKey)
    endif
    
    Error("There was an error retrieving the "+ asPropertyType +" value of option " + asOptionKey)
    DebugError("MCM::GetBoolOptionPropertyValue", "[bool] There was an error retrieving the "+ asPropertyType +" value of option " + asOptionKey)
    return -1
endFunction


float function GetNumberOptionPropertyValue(string asOptionKey, string asProperty)
    if (asProperty == "Minimum")
        self.GetOptionMinimum(asOptionKey)

    elseif (asProperty == "Maximum")
        self.GetOptionMaximum(asOptionKey)

    elseif (asProperty == "Default")
        self.GetOptionDefaultFloat(asOptionKey)

    elseif (asProperty == "Steps")
        self.GetOptionSteps(asOptionKey)
    endif

    return -1
endFunction

string function GetStringOptionPropertyValue(string asOptionKey, string asProperty)
    if (asProperty == "Default")
        return self.GetOptionDefaultString(asOptionKey)
    endif

    return none
endFunction


;/
    Determines if an integer option is of type bool,
    this must be done because both ints and bools are represented
    as ints internally.

    JMap&   @apOptionMap: The map containing the option's properties
    string  @asPropertyType: The type to check from the property

    returns (bool): Whether this option is of type bool or not.
/;
bool function IsPropertyValueOfTypeBool(int apOptionMap, string asPropertyType)
    bool isInteger = FastMap_ValueType(apOptionMap, asPropertyType) == TYPE_INT

    if (isInteger)
        int propertyCount   = FastMap_Size(apOptionMap)
        int optionValue     = FastMap_GetInt(apOptionMap, asPropertyType) ; int|bool

        ; Since int options usually have 4 properties, and bools only have one (Default),
        ; it's safe to assume that if it only has that one property, it is a bool option.
        ; If the values are only 0 or 1, and it meets the one property criteria, it most likely is a bool option.
        bool isBool = (propertyCount == 1) && (asPropertyType == "Default") && (optionValue == 0 || optionValue == 1)
        
        return isBool
    endif

    return false
endFunction

;/
    Internal helper function to load options with their respective
    property values.

    Property types include: Default, Minimum, Maximum, Steps

    string  @asOptionKey: The key of the option
    string  @asPropertyType: The type of property to load the values into the option
    JMap&   @apOptionObject: The object containing the option's properties
/;
function __internal_loadPropertyForOption( \
    string asOptionKey, \
    string asPropertyType, \
    int apOptionObject \
)
    int optionMap           = apOptionObject; JMap&
    int propertyValueType   = FastMap_ValueType(optionMap, asPropertyType)

    if (propertyValueType == TYPE_INT)
        int optionValue = FastMap_GetInt(optionMap, asPropertyType)
        self.SetNumberOptionPropertyValue(asOptionKey, asPropertyType, optionValue)
        DebugWithArgs("MCM::LoadPropertyForOption", "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, "[int] Setting "+ asPropertyType +" Value to: " + optionValue)

    elseif (propertyValueType == TYPE_FLOAT)
        float optionValue = FastMap_GetFloat(optionMap, asPropertyType)
        self.SetNumberOptionPropertyValue(asOptionKey, asPropertyType, optionValue)
        DebugWithArgs("MCM::LoadPropertyForOption", "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, "[float] Setting "+ asPropertyType +" Value to: " + optionValue)

    elseif (propertyValueType == TYPE_STRING)
        string optionValue = FastMap_GetString(optionMap, asPropertyType)
        self.SetStringOptionPropertyValue(asOptionKey, asPropertyType, optionValue)
        DebugWithArgs("MCM::LoadPropertyForOption", "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, "[string] Setting "+ asPropertyType +" Value to: " + optionValue)

    elseif (propertyValueType == TYPE_FORM)
        Form optionValue = FastMap_GetForm(optionMap, asPropertyType)


    elseif (propertyValueType == TYPE_OBJECT)
        ; Handle children object nesting
        int optionValue = FastMap_GetObject(optionMap, asPropertyType)

    else
        Error("There was an error determining the value type of the option " + "[" + asOptionKey + "].")
        DebugError("MCM::LoadPropertyForOption", "There was an error determining the value type of the option " + "[" + asOptionKey + "].")
    endif
endFunction

;/
    Internal helper function to load options with their respective
    property values when they have a dependency requirement.

    Property types include: Default, Minimum, Maximum, Steps

    string  @asOptionKey: The key of the option
    string  @asPropertyType: The type of property to load the values into the option
    JArray& @apDependencyObject: The object containing the dependency option's relevant properties to modify the option
/;
function __internal_loadPropertyForOptionWithDependency( \
    string asOptionKey, \
    string asPropertyType, \
    int apDependencyObject \
)
    int dependencyObject            = apDependencyObject; JArray& (Dependency Array)
    string dependencyOptionKey      = FastArray_GetString(dependencyObject, 0) ; [0] = Dependency Option

    Debug("MCM::LoadPropertyForOption", "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType + ", dependencyObject: " + GetContainerList(dependencyObject))

    ; Get the dependency value type from the default value of the dependency option.
    ; The default option must first be initialized for this to work.
    int dependencyOptionValueType   = FastMap_ValueType(optionsDefaultValueMap, dependencyOptionKey)

    ; Assume the Option is of the same type as the Dependency Option
    if (dependencyOptionValueType == TYPE_INT)
        int dependencyOptionValue = self.GetOptionSliderValue(dependencyOptionKey) as int
        int offset      = FastArray_GetInt(dependencyObject, 1) ; [1] = Option Offset
        bool hasOffset  = (offset as bool)

        int finalOptionValue = int_if (hasOffset, (dependencyOptionValue + offset), dependencyOptionValue)
        self.SetNumberOptionPropertyValue(asOptionKey, asPropertyType, finalOptionValue)
        DebugWithArgs( \
            "MCM::LoadPropertyForOption", \ 
            "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, \ 
            "[int] [depends on: "+ dependencyOptionKey + " (value: "+ dependencyOptionValue +")" +"] Setting "+ asPropertyType +" Value to: " + finalOptionValue \
        )

    elseif (dependencyOptionValueType == TYPE_FLOAT)
        float dependencyOptionValue = self.GetOptionSliderValue(dependencyOptionKey)
        float offset    = FastArray_GetFloat(dependencyObject, 1) ; [1] = Option Offset
        bool hasOffset  = (offset as bool)

        float finalOptionValue = float_if (hasOffset, (dependencyOptionValue + offset), dependencyOptionValue)
        self.SetNumberOptionPropertyValue(asOptionKey, asPropertyType, finalOptionValue)
        DebugWithArgs( \
            "MCM::LoadPropertyForOption", \ 
            "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, \ 
            "[float] [depends on: "+ dependencyOptionKey + " (value: "+ dependencyOptionValue +")" +"] Setting "+ asPropertyType +" Value to: " + finalOptionValue \
        )
    elseif (dependencyOptionValueType == TYPE_STRING)
        string dependencyOptionValue = self.GetOptionMenuValue(dependencyOptionKey)
        self.SetStringOptionPropertyValue(asOptionKey, asPropertyType, dependencyOptionValue)
        DebugWithArgs( \
            "MCM::LoadPropertyForOption", \ 
            "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, \ 
            "[string] [depends on: "+ dependencyOptionKey + " (value: "+ dependencyOptionValue +")" +"] Setting "+ asPropertyType +" Value to: " + dependencyOptionValue \
        )
    elseif (dependencyOptionValueType == TYPE_FORM)

    elseif (dependencyOptionValueType == TYPE_OBJECT)

    else
        Error("There was an error determining the value type of the dependency option " + dependencyOptionKey)
        DebugError("MCM::LoadPropertyForOption", "There was an error determining the value type of the dependency option " + dependencyOptionKey)
    endif
endFunction

;/
    Loads an option with its respective property value.

    string  @asOptionKey: The key of the option
    string  @asPropertyType: The type of property to load the values into the option
/;
function LoadPropertyForOption(string asOptionKey, string asPropertyType)
    int optionsObj      = RPB_Data.MCM_GetOptionObject()
    int pageObj         = self.GetPageObject(optionsObj, CurrentPageConfig) ; TODO: Add asPage parameter
    bool isObject       = FastMap_ValueType(pageObj, asOptionKey) == TYPE_OBJECT ; object type (All options are comprised of an object)
    bool isValidOption  = isObject

    ; Debug("MCM::LoadPropertyForOption", "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType + ", PageObject: " + GetContainerList(pageObj))

    ; Debug("MCM::LoadPropertyForOption", "optionsObj: " + GetContainerList(optionsObj) + ", pageObj: " + GetContainerList(pageObj))

    if (!isValidOption)
        DebugError("MCM::LoadPropertyForOption", "The option " + asOptionKey + " does not exist!")
        Error("The option " + asOptionKey + " does not exist!")
        return
    endif

    int optionMap           = FastMap_GetObject(pageObj, asOptionKey) ; JMap&
    bool propertyExists     = FastMap_HasKey(optionMap, asPropertyType)

    Debug("MCM::LoadPropertyForOption", "optionMap: " + GetContainerList(optionMap) + ", asPropertyType: " + asPropertyType + ", propertyExists: " + propertyExists)

    if (!propertyExists)
        DebugError("MCM::LoadPropertyForOption", "There was an error loading the property " + asPropertyType + " for the option " + asOptionKey)
        Error("There was an error loading the property " + asPropertyType + " for the option " + asOptionKey)
        return
    endif

    int propertyValueType   = FastMap_ValueType(optionMap, asPropertyType)
    bool hasDependency      = (propertyValueType == TYPE_OBJECT)

    Debug("MCM::LoadPropertyForOption", "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType + ", propertyValueType: " + propertyValueType + ", hasDependency: " + hasDependency)

    if (hasDependency)
        int dependencyObject = FastMap_GetObject(optionMap, asPropertyType) ; JArray& (Dependency Array)
        __internal_loadPropertyForOptionWithDependency(asOptionKey, asPropertyType, dependencyObject)
        return
    else
        __internal_loadPropertyForOption(asOptionKey, asPropertyType, optionMap)
        return
    endif

    DebugError("MCM::LoadPropertyForOption", "There was an unknown error loading the property " + asPropertyType + " for option " + asOptionKey)
    Error("There was an unknown error loading the property " + asPropertyType + " for option " + asOptionKey)
endFunction

; ============================================================================
;                             Validation Functions
; ============================================================================

function EnsureOptionValueComparison(string asOptionKey, string asValuePropertyType, float afConditionValue, string asComparisonOperator = "<", float afValueToSet = 0.0, string asCallerName = "")
    float updatedValue
    float value
    bool condition

    if (asValuePropertyType == "Default")
        value = self.GetOptionDefaultFloat(asOptionKey)
        
    elseif (asValuePropertyType == "Current")
        value = self.GetOptionValueFloat(asOptionKey)

    elseif (asValuePropertyType == "Minimum")
        value = self.GetOptionMinimum(asOptionKey)

    elseif (asValuePropertyType == "Maximum")
        value = self.GetOptionMaximum(asOptionKey)

    elseif (asValuePropertyType == "Steps")
        value = self.GetOptionSteps(asOptionKey)
    endif

    if (asComparisonOperator == "<")
        condition = (value < afConditionValue)

    elseif (asComparisonOperator == ">") ; Ensure option is less than or equal to
        condition = (value > afConditionValue)

    elseif (asComparisonOperator == "<=") ; Ensure option is greater than but not equal to
        condition = (value <= afConditionValue)

    elseif (asComparisonOperator == ">=") ; Ensure option is less than but not equal to
        condition = (value >= afConditionValue)

    elseif (asComparisonOperator == "==") ; Ensure option is not equal to
        condition = (value == afConditionValue)

    elseif (asComparisonOperator == "!=") ; Ensure option is equal to
        condition = (value != afConditionValue)
    endif


    if (condition)
        float newValue

        if (asComparisonOperator == "<")
            newValue = float_if (afValueToSet, max(afConditionValue, afValueToSet), afConditionValue)
    
        elseif (asComparisonOperator == ">")
            newValue = float_if (afValueToSet, min(afConditionValue, afValueToSet), afConditionValue)
    
        elseif (asComparisonOperator == "<=")
            newValue = float_if (afValueToSet, max(afConditionValue, afValueToSet), afConditionValue)
    
        elseif (asComparisonOperator == ">=")
            newValue = float_if (afValueToSet, min(afConditionValue, afValueToSet), afConditionValue)
    
        elseif (asComparisonOperator == "==")
    
        elseif (asComparisonOperator == "!=")

        endif

        if (asValuePropertyType == "Default")
            self.SetOptionDefaultFloat(asOptionKey, newValue)
            
        elseif (asValuePropertyType == "Current")
            self.SetOptionValueFloat(asOptionKey, newValue)
    
        elseif (asValuePropertyType == "Minimum")
            self.SetOptionMinimum(asOptionKey, newValue)
    
        elseif (asValuePropertyType == "Maximum")
            self.SetOptionMaximum(asOptionKey, newValue)
    
        elseif (asValuePropertyType == "Steps")
            self.SetOptionSteps(asOptionKey, newValue)
        endif
    
        updatedValue = newValue
    endif

    Error("Validation failed for the "+ asValuePropertyType +" Property for Option [" + asOptionKey + "]!", (updatedValue as bool))
    DebugError(asCallerName, "["+ asValuePropertyType +"] Validation failed for Option [" + asOptionKey + "], setting value to " + updatedValue + ".", (updatedValue as bool))
endFunction

function EnsureOptionNotNull(string asOptionKey, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionNotNull", "Function called but there's no implementation!")
endFunction

function EnsureOptionIsNull(string asOptionKey, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionIsNull", "Function called but there's no implementation!")
endFunction

function EnsureOptionIsOfType(string asOptionKey, int aiOptionValueType, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionIsOfType", "Function called but there's no implementation!")
endFunction

function EnsureOptionIsNotOfType(string asOptionKey, int aiOptionValueType, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionIsNotOfType", "Function called but there's no implementation!")
endFunction

function EnsureOptionValueEqualTo(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionValueEqualTo", "Function called but there's no implementation!")
endFunction

function EnsureOptionValueNotEqualTo(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionValueNotEqualTo", "Function called but there's no implementation!")
endFunction

function EnsureOptionValueLessThan(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    EnsureOptionValueComparison(asOptionKey, asValuePropertyType, afConditionValue, ">=", afValueToSet, "MCM::EnsureOptionValueLessThan")
endFunction

function EnsureOptionValueLessThanOrEqualTo(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    if (self.IsValidPropertyType(asValuePropertyType))
        EnsureOptionValueComparison(asOptionKey, asValuePropertyType, afConditionValue, ">", afValueToSet, "MCM::EnsureOptionValueLessThanOrEqualTo")
        return
    endif

    string[] propertyTypes = self.GetPropertyTypes()
    int typeIndex = 0
    while (typeIndex < propertyTypes.Length)
        EnsureOptionValueComparison(asOptionKey, propertyTypes[typeIndex], afConditionValue, ">", afValueToSet, "MCM::EnsureOptionValueLessThanOrEqualTo")
        typeIndex += 1
    endWhile
endFunction

function EnsureOptionValueGreaterThan(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    EnsureOptionValueComparison(asOptionKey, asValuePropertyType, afConditionValue, "<=", afValueToSet, "MCM::EnsureOptionValueGreaterThan")
endFunction

function EnsureOptionValueGreaterThanOrEqualTo(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    if (self.IsValidPropertyType(asValuePropertyType))
        EnsureOptionValueComparison(asOptionKey, asValuePropertyType, afConditionValue, "<", afValueToSet, "MCM::EnsureOptionValueGreaterThanOrEqualTo")
        return
    endif

    string[] propertyTypes = self.GetPropertyTypes()
    int typeIndex = 0
    while (typeIndex < propertyTypes.Length)
        EnsureOptionValueComparison(asOptionKey, propertyTypes[typeIndex], afConditionValue, "<", afValueToSet, "MCM::EnsureOptionValueGreaterThanOrEqualTo")
        typeIndex += 1
    endWhile
endFunction

function EnsureOptionValueLessThanOptionValue(string asOptionOneKey, string asOptionTwoKey, float afValueToSet = 0.0, string asValuePropertyType = "")
    float propertyTwoValue

    if (asValuePropertyType == "Default")
        propertyTwoValue = self.GetOptionDefaultFloat(asOptionTwoKey)
        
    elseif (asValuePropertyType == "Current")
        propertyTwoValue = self.GetOptionValueFloat(asOptionTwoKey)

    elseif (asValuePropertyType == "Minimum")
        propertyTwoValue = self.GetOptionMinimum(asOptionTwoKey)

    elseif (asValuePropertyType == "Maximum")
        propertyTwoValue = self.GetOptionMaximum(asOptionTwoKey)

    elseif (asValuePropertyType == "Steps")
        propertyTwoValue = self.GetOptionSteps(asOptionTwoKey)
    endif

    EnsureOptionValueComparison(asOptionOneKey, asValuePropertyType, propertyTwoValue, ">=", afValueToSet, "MCM::EnsureOptionValueLessThanOptionValue")
endFunction

function EnsureOptionValueLessThanOrEqualToOptionValue(string asOptionOneKey, string asOptionTwoKey, float afValueToSet = 0.0, string asValuePropertyType = "")
    float propertyTwoValue

    if (asValuePropertyType == "Default")
        propertyTwoValue = self.GetOptionDefaultFloat(asOptionTwoKey)
        
    elseif (asValuePropertyType == "Current")
        propertyTwoValue = self.GetOptionValueFloat(asOptionTwoKey)

    elseif (asValuePropertyType == "Minimum")
        propertyTwoValue = self.GetOptionMinimum(asOptionTwoKey)

    elseif (asValuePropertyType == "Maximum")
        propertyTwoValue = self.GetOptionMaximum(asOptionTwoKey)

    elseif (asValuePropertyType == "Steps")
        propertyTwoValue = self.GetOptionSteps(asOptionTwoKey)
    endif

    EnsureOptionValueComparison(asOptionOneKey, asValuePropertyType, propertyTwoValue, ">", afValueToSet, "MCM::EnsureOptionValueLessThanOrEqualToOptionValue")
endFunction

function EnsureOptionValueGreaterThanOptionValue(string asOptionOneKey, string asOptionTwoKey, float afValueToSet = 0.0, string asValuePropertyType = "")
    float propertyTwoValue

    if (asValuePropertyType == "Default")
        propertyTwoValue = self.GetOptionDefaultFloat(asOptionTwoKey)
        
    elseif (asValuePropertyType == "Current")
        propertyTwoValue = self.GetOptionValueFloat(asOptionTwoKey)

    elseif (asValuePropertyType == "Minimum")
        propertyTwoValue = self.GetOptionMinimum(asOptionTwoKey)

    elseif (asValuePropertyType == "Maximum")
        propertyTwoValue = self.GetOptionMaximum(asOptionTwoKey)

    elseif (asValuePropertyType == "Steps")
        propertyTwoValue = self.GetOptionSteps(asOptionTwoKey)
    endif

    EnsureOptionValueComparison(asOptionOneKey, asValuePropertyType, propertyTwoValue, "<=", afValueToSet, "MCM::EnsureOptionValueGreaterThanOptionValue")
endFunction

function EnsureOptionValueGreaterThanOrEqualToOptionValue(string asOptionOneKey, string asOptionTwoKey, float afValueToSet = 0.0, string asValuePropertyType = "")
    float propertyTwoValue

    if (asValuePropertyType == "Default")
        propertyTwoValue = self.GetOptionDefaultFloat(asOptionTwoKey)
        
    elseif (asValuePropertyType == "Current")
        propertyTwoValue = self.GetOptionValueFloat(asOptionTwoKey)

    elseif (asValuePropertyType == "Minimum")
        propertyTwoValue = self.GetOptionMinimum(asOptionTwoKey)

    elseif (asValuePropertyType == "Maximum")
        propertyTwoValue = self.GetOptionMaximum(asOptionTwoKey)

    elseif (asValuePropertyType == "Steps")
        propertyTwoValue = self.GetOptionSteps(asOptionTwoKey)
    endif

    EnsureOptionValueComparison(asOptionOneKey, asValuePropertyType, propertyTwoValue, "<", afValueToSet, "MCM::EnsureOptionValueGreaterThanOrEqualToOptionValue")
endFunction

; ============================================================================

function InitializeOptions()
; ============================================================================
;                                   Values
; ============================================================================
    optionsValueMap         = FastMap("<string>") ; To hold each option's value

; ============================================================================
;                                   ID's
; ============================================================================
    optionsFromKeyToIdMap   = FastMap("<string>")     ; Identify options from key to id
    optionsFromIdToKeyMap   = FastMap("<string>")     ; Identify options from id to key (page name -> per-page IntMap, built on demand via GetPageObject; the top-level container itself must be a string-keyed JMap like its sibling above, not a JIntMap)

; ============================================================================
;                                State (Flags)
; ============================================================================
    optionsStateMap         = FastMap("<string>") ; To hold each option's state (Enabled, Disabled)

; ============================================================================
;                               Default Values
; ============================================================================
    optionsDefaultValueMap  = FastMap("<string>") ; Default values for options

; ============================================================================
;                              Min/Max/Step Values
; ============================================================================
    optionsMinimumValueMap  = FastMap("<string>") ; Minimum values for options
    optionsMaximumValueMap  = FastMap("<string>") ; Maximum values for options
    optionsStepsValueMap    = FastMap("<string>") ; Interval Steps values for options

    ; Persist the Options and assign them to a general container (this will persist the child objects)
    generalContainer = FastMap("<string>")
    Object_Retain(generalContainer, "RPB_MCM01")

    FastMap_SetObject(generalContainer, "options/value", optionsValueMap)
    FastMap_SetObject(generalContainer, "options/state", optionsStateMap)
    FastMap_SetObject(generalContainer, "options/default", optionsDefaultValueMap)
    FastMap_SetObject(generalContainer, "options/minimum", optionsMinimumValueMap)
    FastMap_SetObject(generalContainer, "options/maximum", optionsMaximumValueMap)
    FastMap_SetObject(generalContainer, "options/steps", optionsStepsValueMap)
    FastMap_SetObject(generalContainer, "options/id/from-key-to-id", optionsFromKeyToIdMap)
    FastMap_SetObject(generalContainer, "options/id/from-id-to-key", optionsFromIdToKeyMap)
endFunction


int optionsValueMap         ; Holds the value for all options
int optionsStateMap         ; Holds the state for all options (enabled, disabled)
int optionsDefaultValueMap  ; Holds the default values for all options
int optionsMinimumValueMap  ; Holds the minimum values for all options
int optionsMaximumValueMap  ; Holds the maximum values for all options
int optionsStepsValueMap    ; Holds the interval steps (how much to increment, or decrement by) values for all options
int optionsFromKeyToIdMap   ; Holds the identifier to identify an option from Key to ID
int optionsFromIdToKeyMap   ; Holds the identifier to identify an option from ID to Key
int generalContainer        ; Holds every option container and persists them

function MCM()
    optionsValueMap         = Object_CreateIfNotExists(optionsValueMap,         FastMap("<string>",   retain = true))
    optionsStateMap         = Object_CreateIfNotExists(optionsStateMap,         FastMap("<string>",   retain = true))
    optionsDefaultValueMap  = Object_CreateIfNotExists(optionsDefaultValueMap,  FastMap("<string>",   retain = true))
    optionsMinimumValueMap  = Object_CreateIfNotExists(optionsMinimumValueMap,  FastMap("<string>",   retain = true))
    optionsMaximumValueMap  = Object_CreateIfNotExists(optionsMaximumValueMap,  FastMap("<string>",   retain = true))
    optionsStepsValueMap    = Object_CreateIfNotExists(optionsStepsValueMap,    FastMap("<string>",   retain = true))
    optionsFromKeyToIdMap   = Object_CreateIfNotExists(optionsFromKeyToIdMap,   FastMap("<string>",   retain = true))
    optionsFromIdToKeyMap   = Object_CreateIfNotExists(optionsFromIdToKeyMap,   FastMap("<string>",   retain = true))
    __clothingOutfitsMap    = Object_CreateIfNotExists(__clothingOutfitsMap,    FastMap("<string>",   retain = true))
endFunction

;/
    Sets predefined default values for options that should not be user configurable.
/;
function SetHardcodedDefaults()
    self.SetOptionDefaultString("Outfit 1::Name", "Outfit 1")
    self.SetOptionDefaultString("Outfit 2::Name", "Outfit 2")
    self.SetOptionDefaultString("Outfit 3::Name", "Outfit 3")
    self.SetOptionDefaultString("Outfit 4::Name", "Outfit 4")
    self.SetOptionDefaultString("Outfit 5::Name", "Outfit 5")
    self.SetOptionDefaultString("Outfit 6::Name", "Outfit 6")
    self.SetOptionDefaultString("Outfit 7::Name", "Outfit 7")
    self.SetOptionDefaultString("Outfit 8::Name", "Outfit 8")
    self.SetOptionDefaultString("Outfit 9::Name", "Outfit 9")
    self.SetOptionDefaultString("Outfit 10::Name", "Outfit 10")
endFunction

; ============================================================================
;                             Option Setters/Getters
; ============================================================================

;/
    Retrieves the option key specified from its option id.

    int     @optionId: The option id to retrieve the key from.
    bool?   @includePageInKey: Whether to include the page name and delimiter in the returned key.

    returns: The option's key.
 /;
 string function GetKeyFromOption(int optionId, bool includePageInKey = true)
    int pageObject = self.GetPageObject(optionsFromIdToKeyMap, CurrentPage)
    string optionKey = FastIntMap_GetString(pageObject, optionId)


    if (!includePageInKey)
        int indexOfDelimiter = StringUtil.Find(optionKey, "/")
        return StringUtil.Substring(optionKey, indexOfDelimiter + 1)
    endif

    return optionKey
endFunction

;/
    Retrieves the option specified by the key.

    string  @optionKey: The key to retrieve the option from.
    returns: The option's id.
 /;
int function GetOptionID(string optionKey)
    int pageObject = self.GetPageObject(optionsFromKeyToIdMap, CurrentPage)
    ; Debug("GetOptionID", "optionKey: " + optionKey + ", content: " + GetContainerList(pageObject))
    return FastMap_GetInt(pageObject, optionKey)
endFunction

;/
    Sets the value of a bool-type option.

    string  @asOptionKey: The key of the option.
    bool    @value: The value to assign to this option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function SetOptionValueBool(string optionKey, bool value, string page = "")
    ; options/value/Whiterun/Stripping::Allow Stripping
    FastMap_SetInt(self.GetPageObject(optionsValueMap, page), optionKey, value as int)
    self.MarkBucketPossiblyDirty(page)

    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; JMap.setInt(optionsValueMap, optionAsStored, value as int)
endFunction

;/
    Sets the value of an int option.

    string  @asOptionKey: The key of the option.
    int     @value: The value to assign to this option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function SetOptionValueInt(string optionKey, int value, string page = "")
    FastMap_SetInt(self.GetPageObject(optionsValueMap, page), optionKey, value)
    self.MarkBucketPossiblyDirty(page)

    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; JMap.setInt(optionsValueMap, optionAsStored, value)
endFunction

;/
    Sets the value of a float option.

    string  @asOptionKey: The key of the option.
    float   @value: The value to assign to this option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function SetOptionValueFloat(string optionKey, float value, string page = "")
    FastMap_SetFloat(self.GetPageObject(optionsValueMap, page), optionKey, value)
    self.MarkBucketPossiblyDirty(page)

    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; JMap.setFlt(optionsValueMap, optionAsStored, value)
endFunction

;/
    Sets the value of a string option.

    string  @asOptionKey: The key of the option.
    string  @value: The value to assign to this option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function SetOptionValueString(string optionKey, string value, string page = "")
    FastMap_SetString(self.GetPageObject(optionsValueMap, page), optionKey, value)

    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; JMap.setStr(optionsValueMap, optionAsStored, value)
    ; Debug("MCM::SetOptionValueString", "Setting " + optionAsStored + ": " + value)
endFunction

;/
    Checks if the option exists in storage.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
bool function OptionExists(string optionKey, string page = "")
    return FastMap_HasKey(self.GetPageObject(optionsFromKeyToIdMap, page), optionKey)
    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; return JMap.hasKey(optionsFromKeyToIdMap, optionAsStored)
endFunction

;/
    Checks if the option has any value associated with it.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
bool function OptionHasValue(string optionKey, string page = "")
    return FastMap_HasKey(self.GetPageObject(optionsValueMap, page), optionKey)

    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; return JMap.hasKey(optionsValueMap, optionAsStored)
endFunction

;/
    Checks if the option has any state associated with it (Enabled, Disabled).

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
bool function OptionHasState(string optionKey, string page = "")
    return FastMap_HasKey(self.GetPageObject(optionsStateMap, page), optionKey)
    
    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; return JMap.hasKey(optionsStateMap, optionAsStored)
endFunction

;/
    Registers an option in storage.
    Both the Option Key and Option ID are stored in order
    to identify the option in both ways.

    string  @asOptionKey: The key of the option.
    int     @optionId: The ID of the option at the time of render.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function RegisterOption(string optionKey, int optionId, string page = "")
    ; For bi-directional identification (option-key to option-id and option-id to option-key)
    FastMap_SetInt(self.GetPageObject(optionsFromKeyToIdMap, page), optionKey, optionId)
    FastIntMap_SetString(self.GetPageObject(optionsFromIdToKeyMap, page, "<int>"), optionId, optionKey)
endFunction

;/
    Sets an option's state value

    string  @asOptionKey: The key of the option.
    int     @optionState: The state to assign to the option (Enabled, Disabled).
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function SetOptionState(string optionKey, int optionState, string page = "")
    FastMap_SetFloat(self.GetPageObject(optionsStateMap, page), optionKey, optionState)

    ; JMap.setInt(optionsStateMap, optionKey, optionState)
endFunction

;/
    Retrieves the value of a bool option.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
bool function GetOptionValueBool(string optionKey, string page = "")
    return FastMap_GetInt(self.GetPageObject(optionsValueMap, page), optionKey) as bool

    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; return FastMap_GetInt(optionsValueMap, optionAsStored) as bool
endFunction

;/
    Retrieves the value of an int option.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
int function GetOptionValueInt(string optionKey, string page = "")
    ; Debug("MCM::GetOptionValueInt", "Getting " + optionKey + " from page " + page + " = " + FastMap_GetInt(self.GetPageObject(optionsValueMap, page), optionKey))
    return FastMap_GetInt(self.GetPageObject(optionsValueMap, page), optionKey)
    
    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; return FastMap_GetInt(optionsValueMap, optionAsStored)
endFunction

;/
    Retrieves the value of a float option.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
float function GetOptionValueFloat(string optionKey, string page = "")
    ; Debug("MCM::GetOptionValueFloat", "Getting " + optionKey + " from page " + page + " = " + FastMap_GetFloat(self.GetPageObject(optionsValueMap, page), optionKey))
    return FastMap_GetFloat(self.GetPageObject(optionsValueMap, page), optionKey)

    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; return FastMap_GetFloat(optionsValueMap, optionAsStored)
endFunction

;/
    Retrieves the value of a string option.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
string function GetOptionValueString(string optionKey, string page = "")
    return FastMap_GetString(self.GetPageObject(optionsValueMap, page), optionKey)

    int pageObject = self.GetPageObject(optionsValueMap, page)
    ; string value = FastMap_GetString(pageObject, optionKey)

    ; Debug("MCM::SetOptionValueString", "Getting " + optionKey + " from page " + page + " = " + value)

    return FastMap_GetString(pageObject, optionKey)

    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; return FastMap_GetString(optionsValueMap, optionAsStored)
endFunction

;/
    Retrieves the current state of the option.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
int function GetOptionState(string optionKey, string page = "")
    return FastMap_GetInt(self.GetPageObject(optionsStateMap, page), optionKey)

    ; string optionAsStored = self.GetOptionAsStored(optionKey, page)
    ; return FastMap_GetInt(optionsStateMap, optionAsStored)
endFunction

;/
    Sets the default value of a bool option.

    string  @asOptionKey: The key of the option.
    bool    @value: The value to set.
/;
function SetOptionDefaultBool(string optionKey, bool value)
    FastMap_SetInt(optionsDefaultValueMap, optionKey, value as int)
endFunction

;/
    Sets the default value of an int option.

    string  @asOptionKey: The key of the option.
    int     @value: The value to set.
/;
function SetOptionDefaultInt(string optionKey, int value)
    FastMap_SetInt(optionsDefaultValueMap, optionKey, value)
endFunction

;/
    Sets the default value of a float option.

    string  @asOptionKey: The key of the option.
    float   @value: The value to set.
/;
function SetOptionDefaultFloat(string optionKey, float value)
    FastMap_SetFloat(optionsDefaultValueMap, optionKey, value)
endFunction
;/
    Sets the default value of a string option.

    string  @asOptionKey: The key of the option.
    string  @value: The value to set.
/;
function SetOptionDefaultString(string optionKey, string value)
    FastMap_SetString(optionsDefaultValueMap, optionKey, value)
endFunction

;/
    Retrieves the default value of a bool option.

    string  @asOptionKey: The key of the option.
/;
bool function GetOptionDefaultBool(string optionKey)
    return FastMap_GetInt(optionsDefaultValueMap, optionKey) as bool
endFunction

;/
    Retrieves the default value of an int option.

    string  @asOptionKey: The key of the option.
/;
int function GetOptionDefaultInt(string optionKey)
    return FastMap_GetInt(optionsDefaultValueMap, optionKey)
endFunction

;/
    Retrieves the default value of a float option.

    string  @asOptionKey: The key of the option.
/;
float function GetOptionDefaultFloat(string optionKey)
    return FastMap_GetFloat(optionsDefaultValueMap, optionKey)
endFunction

;/
    Retrieves the default value of a string option.

    string  @asOptionKey: The key of the option.
/;
string function GetOptionDefaultString(string optionKey)
    return FastMap_GetString(optionsDefaultValueMap, optionKey)
endFunction

;/
    Sets the minimum value of an option.

    string  @asOptionKey: The key of the option.
    float   @value: The value to set
/;
function SetOptionMinimum(string optionKey, float value)
    FastMap_SetFloat(optionsMinimumValueMap, optionKey, value)
endFunction

;/
    Sets the maximum value of an option.

    string  @asOptionKey: The key of the option.
    float   @value: The value to set
/;
function SetOptionMaximum(string optionKey, float value)
    FastMap_SetFloat(optionsMaximumValueMap, optionKey, value)
endFunction

;/
    Sets the interval steps value of an option (how much to increment or decrement by each step).

    string  @asOptionKey: The key of the option.
    float   @value: The value to set
/;
function SetOptionSteps(string optionKey, float value)
    FastMap_SetFloat(optionsStepsValueMap, optionKey, value)
endFunction

;/
    Retrieves the minimum value of an option.

    string  @asOptionKey: The key of the option.
/;
float function GetOptionMinimum(string optionKey)
    return FastMap_GetFloat(optionsMinimumValueMap, optionKey)
endFunction

;/
    Retrieves the maximum value of an option.

    string  @asOptionKey: The key of the option.
/;
float function GetOptionMaximum(string optionKey)
    return FastMap_GetFloat(optionsMaximumValueMap, optionKey)
endFunction

;/
    Retrieves the interval steps value of an option.

    string  @asOptionKey: The key of the option.
/;
float function GetOptionSteps(string optionKey)
    return FastMap_GetFloat(optionsStepsValueMap, optionKey)
endFunction

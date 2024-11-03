Scriptname RPB_MCM_Clothing hidden

import RPB_Utility
import RPB_Memory
import RPB_MCM

bool function ShouldHandleEvent(RPB_MCM mcm) global
    return mcm.CurrentPage == "Clothing"
endFunction

function Render(RPB_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    float bench = StartBenchmark()
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)

    HandleDependencies(mcm)

    EndBenchmark(bench, mcm.CurrentPage + " page loaded -")
endFunction

function RenderOutfitOptions(RPB_MCM mcm, int aiOutfitNumber) global
    mcm.AddOptionCategory("Outfit " + aiOutfitNumber)
    mcm.AddOptionInput("Name", "Outfit " + aiOutfitNumber)
    mcm.AddOptionText("Equipped Outfit", "Click to Copy")
    mcm.AddEmptyOption()
    mcm.AddOptionInput("Head", "")
    mcm.AddOptionInput("Body", "")
    mcm.AddOptionInput("Hands", "")
    mcm.AddOptionInput("Feet", "")
    ; mcm.AddOptionInput("Underwear (Top)", "")
    ; mcm.AddOptionInput("Underwear (Bottom)", "")

    mcm.AddOptionToggle("Conditional Outfit")
    ; mcm.AddOptionInputKey(" Strictly Wearable If Bounty Within", "BountyCondition", "2500-6000")
    ; mcm.AddTextOption("", "STRICTLY WEARABLE IF BOUNTY WITHIN", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Minimum Bounty", "{0} Bounty", 0.0)
    mcm.AddOptionSlider("Maximum Bounty", "{0} Bounty", 0.0)

    mcm.AddEmptyOption()
endFunction

function Left(RPB_MCM mcm) global
    mcm.AddOptionCategory("Configuration")
    mcm.AddOptionToggleKey("Do you have a nude body mod installed?", "NudeBodyModInstalled")
    mcm.AddOptionToggleKey("Do you have a wearable underwear mod installed?", "UnderwearModInstalled", defaultFlags = mcm.OPTION_DISABLED)

    mcm.AddEmptyOption()

    int i = 1
    int outfitNumber = 1
    while (i <= mcm.OUTFIT_COUNT / 2)
        if (i > 1)
            outfitNumber = outfitNumber + 2
        endif

        RenderOutfitOptions(mcm, outfitNumber)
        i += 1
    endWhile

endFunction

function Right(RPB_MCM mcm) global
    mcm.AddOptionCategory("Item Slots")
    mcm.AddOptionSlider("Underwear (Top)", "Slot {0}")
    mcm.AddOptionSlider("Underwear (Bottom)", "Slot {0}")

    mcm.AddEmptyOption()

    int i = 6
    int outfitNumber = 2

    while (i <= mcm.OUTFIT_COUNT)
        if (i > 6) ; 6 is actually Outfit 2, since we start at 2 and this is the Even column, so 6=2, 7=4, 8=6, 9=8, 10=10
            outfitNumber = outfitNumber + 2
        endif

        RenderOutfitOptions(mcm, outfitNumber)
        i += 1
    endWhile

endFunction

function HandleDependencies(RPB_MCM mcm) global

    ; ==========================================================
    ;                         CONFIGURATION
    ; ==========================================================

    bool nudeBodyModInstalled  = mcm.GetOptionToggleState("Configuration::NudeBodyModInstalled")
    bool underwearModInstalled = mcm.GetOptionToggleState("Configuration::UnderwearModInstalled")

    mcm.SetOptionDependencyBool("Configuration::UnderwearModInstalled",     nudeBodyModInstalled)
    mcm.SetOptionDependencyBool("Item Slots::Underwear (Top)",              nudeBodyModInstalled && underwearModInstalled)
    mcm.SetOptionDependencyBool("Item Slots::Underwear (Bottom)",           nudeBodyModInstalled && underwearModInstalled)

    ; ==========================================================
    ;                         OUTFITTING
    ; ==========================================================

    int i = 1
    while (i <= mcm.OUTFIT_COUNT)
        string outfitCategory = "Outfit " + i
        bool conditionalOutfit = mcm.GetOptionToggleState(outfitCategory + "::Conditional Outfit")
        mcm.SetOptionDependencyBool(outfitCategory + "::Minimum Bounty", conditionalOutfit)
        mcm.SetOptionDependencyBool(outfitCategory + "::Maximum Bounty", conditionalOutfit)
        i += 1
    endWhile

endFunction

function HandleSliderOptionDependency(RPB_MCM mcm, string option, float value) global

    ; ==========================================================
    ;                          OUTFITTING
    ; ==========================================================
    
    int i = 0
    while (i <= mcm.OUTFIT_COUNT)
        string outfitCategory = "Outfit " + i
        if (option == outfitCategory + "::Minimum Bounty")
            string formatString = "{0} Bounty"
            float bountyConditionMaximum = mcm.GetOptionSliderValue(outfitCategory + "::Maximum Bounty")

            if (bountyConditionMaximum < value)
                mcm.SetOptionSliderValue(outfitCategory + "::Maximum Bounty", value, formatString)
            endif

        elseif (option == outfitCategory + "::Maximum Bounty")
            string formatString = "{0} Bounty"
            float bountyConditionMinimum = mcm.GetOptionSliderValue(outfitCategory + "::Minimum Bounty")

            if (bountyConditionMinimum > value)
                mcm.SetOptionSliderValue(outfitCategory + "::Minimum Bounty", value, formatString)
            endif
        endif
        i += 1
    endWhile
endFunction

function LoadSliderOptions(RPB_MCM mcm, string option, float currentSliderValue) global
    mcm.LoadOptionProperties(option)
    mcm.ValidateOption(option)

    float minRange      = mcm.GetOptionMinimum(option)
    float maxRange      = mcm.GetOptionMaximum(option)
    float intervalSteps = mcm.GetOptionSteps(option)
    float defaultValue  = mcm.GetOptionDefaultFloat(option)

    defaultValue = min(defaultValue, maxRange)
    float startValue = float_if (currentSliderValue > mcm.GENERAL_ERROR, currentSliderValue, defaultValue)
    mcm.SetSliderOptions(minRange, maxRange, intervalSteps, defaultValue, startValue)
endFunction

; =====================================================
;                        Helpers
; =====================================================

;/
    string  @outfitId: The ID of the Outfit.

    returns (int): The index of the Outfit.
/;
int function GetOutfitIndex(string outfitId) global
    return (StringUtil.Substring(outfitId, StringUtil.GetLength("Outfit") + 1) as int) - 1
endFunction

;/
    Retrieves the valid slot mask(s) for the specified body part.
    If a body part has multiple, then they will be returned instead.
    
    string  @asBodyPart: The body part to retrieve the slot mask from (Head, Body, Hands, Feet).

    returns (int): The slot mask(s) for the specified body part.
/;
int function GetSlotMaskForBodyPart(string asBodyPart) global
    if (asBodyPart == "Head")
        return BitwiseExpr("0x00000001 | 0x00000002 | 0x00001000 | 0x00002000")

    elseif (asBodyPart == "Body")
        return BitwiseExpr("0x00000004 | 0x00000002 | 0x00001000")

    elseif (asBodyPart == "Hands")
        return 0x00000008

    elseif (asBodyPart == "Feet")
        return 0x00000080
    endif

    return 0
endFunction

;/
    Checks if two slot masks overlap each other.

    int     @aiSlotMaskOne: The first slot mask.
    int     @aiSlotMaskTwo: The second slot mask.

    returns (bool): true if the slot masks overlap, false otherwise.
/;
bool function HasSlotMaskOverlap(int aiSlotMaskOne, int aiSlotMaskTwo) global
    ; Perform a bitwise AND to identify overlapping slots
    ; Check if there’s any overlap by comparing to 0
    ; Debug("MCM::Clothing::HasSlotMaskOverlap", aiSlotMaskOne + " & " + aiSlotMaskTwo + " = " + BitwiseExpr(aiSlotMaskOne + " & " + aiSlotMaskTwo))
    return BitwiseExpr(aiSlotMaskOne + " & " + aiSlotMaskTwo) != 0
endFunction

Armor function GetActorEquippedClothingForBodyPart(Actor akActor, string asBodyPart) global
    int slotMask = GetSlotMaskForBodyPart(asBodyPart)
    return akActor.GetWornForm(slotMask) as Armor
endFunction

bool function IsValidClothingForBodyPart(string asBodyPart, int aiSlotMask) global
    int validSlotMask = GetSlotMaskForBodyPart(asBodyPart)
    return BitwiseExpr(validSlotMask + " & " + aiSlotMask) == aiSlotMask
endFunction

function AddOutfit(RPB_MCM mcm, string outfitId, Armor headClothing, Armor bodyClothing, Armor handsClothing, Armor feetClothing) global
    ; if body overrides head (shares slots, remove head, since body will take up its slot)
    if (bodyClothing == headClothing)
        headClothing = none
    endif

    ; Set each outfit part's name in the input fields for the outfit
    mcm.SetOptionInputValue(outfitId + "::Head", headClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Body", bodyClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Hands", handsClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Feet", feetClothing.GetName())

    ; Add each clothing piece to this outfit (store persistently into the outfit list)
    mcm.AddOutfitPiece(outfitId, "Head", headClothing)
    mcm.AddOutfitPiece(outfitId, "Body", bodyClothing)
    mcm.AddOutfitPiece(outfitId, "Hands", handsClothing)
    mcm.AddOutfitPiece(outfitId, "Feet", feetClothing)

    Trace("MCM::Clothing::AddOutfit", "headClothing: " + headClothing + ", bodyClothing: " + bodyClothing + ", handsClothing: " + handsClothing + ", feetClothing: " + feetClothing)
    Trace("MCM::Clothing::AddOutfit", "Slot Masks [headClothing: " + headClothing.GetSlotMask() + ", bodyClothing: " + bodyClothing.GetSlotMask() + ", handsClothing: " + handsClothing.GetSlotMask() + ", feetClothing: " + feetClothing.GetSlotMask() + "]")
endFunction

;/
    UNUSED FOR NOW

    Ensures the outfit is valid.
/;
function EnsureValidOutfit(RPB_MCM mcm, string outfitId) global
    string[] parts = String_Explode("Head,Body,Hands,Feet")

    int i = 0
    while (i < parts.Length)
        string bodyPart = parts[i]
        Armor part = mcm.GetOutfitPart(outfitId, bodyPart)

        if (!part)
            mcm.RemoveOutfitPiece(outfitId, bodyPart)
            Debug("MCM::Clothing::EnsureValidOutfit", "("+ outfitId +") Removed " + bodyPart)
        endif

        i += 1
    endWhile
endFunction

function EquipOutfitOnActor(RPB_MCM mcm, Actor akActor, string outfitId, bool unequipAllItems = true) global
    Armor bodyPartHead  = mcm.GetOutfitPart(outfitId, "Head")
    Armor bodyPartBody  = mcm.GetOutfitPart(outfitId, "Body")
    Armor bodyPartHands = mcm.GetOutfitPart(outfitId, "Hands")
    Armor bodyPartFeet  = mcm.GetOutfitPart(outfitId, "Feet")

    string actorName = akActor.GetActorBase().GetName()

    if (unequipAllItems)
        akActor.UnequipAll()
    endif

    if (bodyPartHead != none)
        akActor.EquipItem(bodyPartHead, false, abSilent = true)
        Debug("MCM::Clothing::EquipOutfitOnActor", "Equipped " + bodyPartHead.GetName() + " from " + outfitId + "::Head" + " on " + actorName)
    endif

    if (bodyPartBody != none)
        akActor.EquipItem(bodyPartBody, false, abSilent = true)
        Debug("MCM::Clothing::EquipOutfitOnActor", "Equipped " + bodyPartBody.GetName() + " from " + outfitId + "::Body" + " on " + actorName)
    endif
    
    if (bodyPartHands != none)
        akActor.EquipItem(bodyPartHands, false, abSilent = true)
        Debug("MCM::Clothing::EquipOutfitOnActor", "Equipped " + bodyPartHands.GetName() + " from " + outfitId + "::Hands" + " on " + actorName)
    endif

    if (bodyPartFeet != none)
        akActor.EquipItem(bodyPartFeet, false, abSilent = true)
        Debug("MCM::Clothing::EquipOutfitOnActor", "Equipped " + bodyPartFeet.GetName() + " from " + outfitId + "::Feet" + " on " + actorName)
    endif

endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RPB_MCM mcm, string option) global

    ; ==========================================================
    ;                        CONFIGURATION
    ; ==========================================================

    if (option == "Configuration::NudeBodyModInstalled")
        mcm.SetInfoText("Determines if you have a nude body mod installed, meaning the Player as well as the NPC's can be naked.\n" + \
            "Check this if you have a nude body mod installed, such as CBBE or UNP for females, and Schlongs of Skyrim for males.\n" + \
            "The mod will take this option into consideration when performing various tasks. " + \ 
            "For the best immersion, do not check this if you don't have a nude body mod.")

    elseif (option == "Configuration::UnderwearModInstalled")
        mcm.SetInfoText("Determines if you have a wearable underwear mod, that is, any mod that is capable of having the Player as well as the NPC's wear underwear.\n" + \
            "Check this if you have a wearable underwear mod installed, the underwear must be an equipable piece of clothing.\n" + \
            "The mod will take this option into consideration when being stripped off in jail. " + \ 
            "For the best immersion, do not check this if you don't have a wearable underwear mod.")

    ; ==========================================================
    ;                        ITEM SLOTS
    ; ==========================================================

    elseif (option == "Item Slots::Underwear (Top)")
        mcm.SetInfoText("Configure which slot the top piece of the underwear takes.\n" + \
            "This underwear piece is usually reserved for females. However, if your underwear mod makes use of this for males, you can freely use it.\n" + \
            "This is very important as the mod's logic will fail if you configure the incorrect slot.")

    elseif (option == "Item Slots::Underwear (Bottom)")
        mcm.SetInfoText("Configure which slot the bottom piece of the underwear takes.\n" + \ 
            "This is very important as the mod's logic will fail if you configure the incorrect slot.")
    
    ; ==========================================================
    ;                           OUTFITS
    ; ==========================================================

    elseif (IsOptionInCategory(option, "Outfit"))
        string outfitId = GetOptionCategory(option)
        if (option == outfitId + "::Name")
            mcm.SetInfoText("Sets the name for " + outfitId)

        elseif (option == outfitId + "::Equipped Outfit")
            mcm.SetInfoText("Copy the clothing you're currently wearing into this outfit ("+ outfitId +")")

        elseif (option == outfitId + "::Head")
            mcm.SetInfoText("Sets the head piece of the outfit.\nOnly FormIDs are accepted, use the console to retrieve the ID of the piece you want.\n" + \
                "Leave blank if you don't want any headwear for this outfit.\n" + \
                "e.g: help 'Fur Helmet'")

        elseif (option == outfitId + "::Body")
            mcm.SetInfoText("Sets the body piece of the outfit.\nOnly FormIDs are accepted, use the console to retrieve the ID of the piece you want.\n" + \
                "Leave blank if you don't want any body clothing for this outfit.\n" + \
                "e.g: help 'Fur Armor'")

        elseif (option == outfitId + "::Hands")
            mcm.SetInfoText("Sets the hands piece of the outfit.\nOnly FormIDs are accepted, use the console to retrieve the ID of the piece you want.\n" + \
                "Leave blank if you don't want any hand clothing for this outfit.\n" + \
                "e.g: help 'Fur Gloves'")

        elseif (option == outfitId + "::Feet")
            mcm.SetInfoText("Sets the feet piece of the outfit.\nOnly FormIDs are accepted, use the console to retrieve the ID of the piece you want.\n" + \
                "Leave blank if you don't want any footwear for this outfit.\n" + \
                "e.g: help 'Fur Boots'")

        elseif (option == outfitId + "::Conditional Outfit")
            mcm.SetInfoText("Determines if this outfit must meet a bounty condition in order to be worn.")

        elseif (option == outfitId + "::Minimum Bounty")
            mcm.SetInfoText("The minimum bounty required in order to be able to wear this outfit.")

        elseif (option == outfitId + "::Maximum Bounty")
            mcm.SetInfoText("The maximum bounty required in order to be able to wear this outfit.\n" + \ 
            "Note: if this value is the same as Minimum Bounty, there will be no Maximum Bounty condition and the only condition is applied to Minimum Bounty.\n" + \ 
            "e.g: Minimum Bounty: 1000 and Maximum Bounty: 1000, if you have 1000 or more bounty, you will be capable of wearing this outfit.\n" + \ 
            "However, if Maximum Bounty was set at 1100, you would need to have 1000 or more bounty but less than 1100.")
        endif

    endif
endFunction

function OnOptionDefault(RPB_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RPB_MCM mcm, string option) global
    string optionKey = mcm.CurrentPage + "::" + option

    Debug("Clothing::OnOptionSelect", "Option: " + option, true)

    ; Avoid toggle options for this type of option
    if (IsOptionOfSpecificity(option, "Equipped Outfit"))
        string outfitId = GetOptionCategory(option)
        Actor player = Game.GetFormEx(0x14) as Actor
        OnOutfitCopyActorEquippedClothing(mcm, outfitId, player)
    endif

    mcm.ToggleOption(option)
    HandleDependencies(mcm)
endFunction

function OnOptionSliderOpen(RPB_MCM mcm, string option) global
    float sliderOptionValue = mcm.GetOptionSliderValue(option)
    LoadSliderOptions(mcm, option, sliderOptionValue)
    ; Debug("OnOptionSliderOpen", "Option: " + option + ", Value: " + sliderOptionValue)
endFunction

function OnOptionSliderAccept(RPB_MCM mcm, string option, float value) global
    string formatString = "{0}"

    ; ==========================================================
    ;                 CONFIGURATION / OUTFITTING
    ; ==========================================================

    if (option == "Item Slots::Underwear (Top)")
        formatString = "Slot {0}"

    elseif (option == "Item Slots::Underwear (Bottom)")
        formatString = "Slot {0}"

    elseif (IsOptionOfSpecificity(option, "Minimum Bounty"))
        formatString = "{0} Bounty"

    elseif (IsOptionOfSpecificity(option, "Maximum Bounty"))
        formatString = "{0} Bounty"

    endif

    ; Handle any slider option that depends on the current option being set
    HandleSliderOptionDependency(mcm, option, value)

    mcm.SetOptionSliderValue(option, value, formatString)
endFunction

function OnOptionMenuOpen(RPB_MCM mcm, string option) global

endFunction

function OnOptionMenuAccept(RPB_MCM mcm, string option, int menuIndex) global

endFunction

function OnOptionColorOpen(RPB_MCM mcm, string option) global
    
endFunction

function OnOptionColorAccept(RPB_MCM mcm, string option, int color) global
    
endFunction

function OnOptionInputOpen(RPB_MCM mcm, string option) global
    string inputOptionValue = mcm.GetOptionInputValue(option)
    mcm.SetInputDialogStartText(inputOptionValue)

    Debug("Clothing::OnOptionInputOpen", "Option: " + option, true)

    if (IsOptionInCategory(option, "Outfit") && !IsOptionInCategory(option, "Name") && !IsOptionInCategory(option, "BountyCondition"))
        string outfitId     = GetOptionCategory(option)
        string bodyPartName = GetOptionNameNoCategory(option)  ; bodyPartName = Head, Body, Hands, Feet
        Armor outfitPiece   = mcm.GetOutfitPart(outfitId, bodyPartName) ; Outfit 1::Body
        Debug("OnOptionInputOpen", "Outfit Piece: " + outfitPiece.GetName() + ", FormID: " + outfitPiece.GetFormID() + ", Slot Mask: " + outfitPiece.GetSlotMask())
    endif

    Trace("OnOptionInputOpen", "GetOptionInputValue("+  option +") = " + mcm.GetOptionInputValue(option, mcm.CurrentPage))
endFunction

function OnOptionInputAccept(RPB_MCM mcm, string option, string inputValue) global
    Debug("MCM::Clothing::OnOptionInputAccept", "Option: " + option + ", inputValue: " + inputValue)

    bool isOutfitBodyPartOption = IsOptionInCategory(option, "Outfit") && !IsOptionInCategory(option, "Name") && !IsOptionInCategory(option, "BountyCondition")
    bool isOutfitNameOption     = !isOutfitBodyPartOption && IsOptionInCategory(option, "Outfit") && IsOptionInCategory(option, "Name")

    if (isOutfitBodyPartOption)
        string outfitId     = GetOptionCategory(option) ; Outfit 1, Outfit 2, etc.
        string bodyPartName = GetOptionNameNoCategory(option)

        ; Get Outfit piece
        int formId = ParseInt(inputValue)
        Armor bodyPartPiece = Game.GetFormEx(formId) as Armor

        if (!bodyPartPiece && inputValue != "")
            Debug("MCM::Clothing::OnOptionInputAccept", "Body part does not exist!")
            Debug.MessageBox("Body part does not exist!")
            return
        endif

        if (inputValue == "")
            string outfitBodyPartName = GetOptionNameNoCategory(option)
            OnOutfitPieceRemove(mcm, outfitId, outfitBodyPartName)
            return
        endif

        if (IsValidClothingForBodyPart(bodyPartName, bodyPartPiece.GetSlotMask()))
            string outfitBodyPartName = GetOptionNameNoCategory(option)
            OnOutfitPieceAdd(mcm, outfitId, outfitBodyPartName, bodyPartPiece)
        else
            Debug("OnOptionInputAccept", "Outfit piece " + bodyPartPiece.GetName() + " is of the wrong type for " + bodyPartName + "!")
            Debug.MessageBox("Outfit piece " + bodyPartPiece.GetName() + " is of the wrong type for " + bodyPartName + "!")
            return
        endif

    elseif (isOutfitNameOption)
        string outfitId      = GetOptionCategory(option) ; Outfit 1, Outfit 2, etc.
        string outfitOldName = mcm.GetOptionInputValue(outfitId + "::Name")
        string outfitNewName = inputValue

        OnOutfitNameChange(mcm, outfitId, outfitOldName, outfitNewName)
    else
        ; Normal input handling
        mcm.SetOptionInputValue(option, inputValue)
    endif
endFunction

function OnOptionKeymapChange(RPB_MCM mcm, string option, int keyCode, string conflictControl, string conflictName) global
    
endFunction

; =====================================================
; Outfit Event Handlers
; =====================================================

function OnOutfitPieceAdd(RPB_MCM mcm, string outfitId, string outfitBodyPartName, Armor outfitBodyPart) global
    ; Limit Hooded body parts to just BODY, and don't let HEAD pieces conflict with BODY
    int bodyPartSlotMask = outfitBodyPart.GetSlotMask()
    Armor headPiece = mcm.GetOutfitPart(outfitId, "Head")
    Armor bodyPiece = mcm.GetOutfitPart(outfitId, "Body")

    int headSlotMask = headPiece.GetSlotMask()
    int bodySlotMask = bodyPiece.GetSlotMask()

    bool isHeadOverlappingBody = (outfitBodyPartName == "Body" && HasSlotMaskOverlap(bodyPartSlotMask, headSlotMask))
    bool isBodyOverlappingHead = (outfitBodyPartName == "Head" && HasSlotMaskOverlap(bodyPartSlotMask, bodySlotMask))

    if (isHeadOverlappingBody)
        ; Remove Head piece
        mcm.RemoveOutfitPiece(outfitId, "Head")

    elseif (isBodyOverlappingHead)
        ; Remove Body piece
        mcm.RemoveOutfitPiece(outfitId, "Body")
    endif

    if (outfitBodyPart)
        mcm.AddOutfitPiece(outfitId, outfitBodyPartName, outfitBodyPart)
    else
        mcm.RemoveOutfitPiece(outfitId, outfitBodyPartName)
    endif
endFunction

function OnOutfitPieceRemove(RPB_MCM mcm, string outfitId, string outfitBodyPartName) global
    mcm.RemoveOutfitPiece(outfitId, outfitBodyPartName)
endFunction

function OnOutfitNameChange(RPB_MCM mcm, string outfitId, string outfitOldName, string outfitNewName) global
    ; Sets the outfit name for this outfit in storage
    mcm.SetOutfitName(outfitId, outfitNewName)

    ; Sets the Input option
    mcm.SetOptionInputValue(outfitId + "::Name", outfitNewName)
    ; Debug("MCM::Clothing::OnOutfitNameChanged", "Outfit ID: " + outfitId + ", Old Outfit Name: "+ outfitOldName +", New Outfit Name: " + outfitNewName)

    ; Update the Outfit for every Hold's prison that uses it
    string[] holds = mcm.Config.Holds
    int i = 0
    while (i < holds.Length)
        string holdPrisonOutfit = mcm.GetOptionMenuValue("Clothing::Outfit", page = holds[i])

        if (holdPrisonOutfit == outfitOldName)
            mcm.SetOptionMenuValue("Clothing::Outfit", outfitNewName, page = holds[i])
        endif
        i += 1
    endWhile
endFunction

function OnOutfitCopyActorEquippedClothing(RPB_MCM mcm, string outfitId, Actor akActor) global
    Armor headClothing  = GetActorEquippedClothingForBodyPart(akActor, "Head")
    Armor bodyClothing  = GetActorEquippedClothingForBodyPart(akActor, "Body")
    Armor handsClothing = GetActorEquippedClothingForBodyPart(akActor, "Hands")
    Armor feetClothing  = GetActorEquippedClothingForBodyPart(akActor, "Feet")

    ; DebugParams(headClothing + "," + bodyClothing + "," + handsClothing + "," + feetClothing, "Head, Body, Hands, Feet", "MCM::Clothing::OnOutfitCopyActorEquippedClothing")

    ; OnOutfitPieceAdd should do this, but by doing it first, the appearance is given that the task was performed faster.
    mcm.SetOptionInputValue(outfitId + "::Head", headClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Body", bodyClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Hands", handsClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Feet", feetClothing.GetName())

    OnOutfitPieceAdd(mcm, outfitId, "Head", headClothing)
    OnOutfitPieceAdd(mcm, outfitId, "Body", bodyClothing)
    OnOutfitPieceAdd(mcm, outfitId, "Hands", handsClothing)
    OnOutfitPieceAdd(mcm, outfitId, "Feet", feetClothing)
endFunction

; =====================================================
; Event Handlers
; =====================================================

function OnHighlight(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnDefault(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSelect(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderAccept(RPB_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid, false), value)
endFunction

function OnMenuOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnMenuAccept(RPB_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid, false), menuIndex)
endFunction

function OnColorOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnColorAccept(RPB_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid, false), color)
endFunction

function OnKeymapChange(RPB_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid, false), keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnInputAccept(RPB_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid, false), inputValue)
endFunction

Scriptname RealisticPrisonAndBounty_MCM_Clothing hidden

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_MCM
import PO3_SKSEFunctions

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.CurrentPage == "Clothing"
endFunction

function Render(RealisticPrisonAndBounty_MCM mcm) global
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

    ; mcm.config.AddOutfit("Outfit 1", none, Game.GetFormEx(0x3C9FE) as Armor, none, none)
    ; mcm.config.AddOutfit("Outfit 2", none, Game.GetFormEx(0x3C9FE) as Armor, none, Game.GetFormEx(0x3CA00) as Armor)
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddOptionCategory("Configuration")
    mcm.AddOptionToggleKey("Do you have a nude body mod installed?", "NudeBodyModInstalled")
    mcm.AddOptionToggleKey("Do you have a wearable underwear mod installed?", "UnderwearModInstalled", defaultFlags = mcm.OPTION_DISABLED)

    mcm.AddEmptyOption()

    int i = 1
    while (i <= mcm.OUTFIT_COUNT / 2)
        mcm.AddOptionCategory("Outfit " + i)
        mcm.AddOptionInput("Name", "Outfit " + i)
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
        i += 1
    endWhile

endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddOptionCategory("Item Slots")
    mcm.AddOptionSlider("Underwear (Top)", "Slot {0}")
    mcm.AddOptionSlider("Underwear (Bottom)", "Slot {0}")

    mcm.AddEmptyOption()

    int i = 6
    while (i <= mcm.OUTFIT_COUNT)
        mcm.AddOptionCategory("Outfit " + i)
        mcm.AddOptionInput("Name", "Outfit " + i)
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
        i += 1
    endWhile

endFunction

function HandleDependencies(RealisticPrisonAndBounty_MCM mcm) global

    ; ==========================================================
    ;                         CONFIGURATION
    ; ==========================================================

    bool nudeBodyModInstalled                  = mcm.GetOptionToggleState("Configuration::NudeBodyModInstalled")
    bool underwearModInstalled                 = mcm.GetOptionToggleState("Configuration::UnderwearModInstalled")

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
        ; mcm.SetOptionDependencyBool(outfitCategory + "::Underwear (Top)",       nudeBodyModInstalled && underwearModInstalled)
        ; mcm.SetOptionDependencyBool(outfitCategory + "::Underwear (Bottom)",    nudeBodyModInstalled && underwearModInstalled)
        mcm.SetOptionDependencyBool(outfitCategory + "::Minimum Bounty",        conditionalOutfit)
        mcm.SetOptionDependencyBool(outfitCategory + "::Maximum Bounty",        conditionalOutfit)
        i += 1
    endWhile

endFunction

function HandleSliderOptionDependency(RealisticPrisonAndBounty_MCM mcm, string option, float value) global

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

function LoadSliderOptions(RealisticPrisonAndBounty_MCM mcm, string option, float currentSliderValue) global
    float minRange = 0
    float maxRange = 100
    float intervalSteps = 1
    float defaultValue = mcm.__getFloatOptionDefault(option)

    ; ==========================================================
    ;                          ITEM SLOTS
    ; ==========================================================

    if (option == "Item Slots::Underwear (Top)")
        minRange = 44
        maxRange = 61

    elseif (option == "Item Slots::Underwear (Bottom)")
        minRange = 44
        maxRange = 61

    ; ==========================================================
    ;                          OUTFITS
    ; ==========================================================

    elseif (StringUtil.Find(option, "Minimum Bounty") != -1)
        minRange = 0
        maxRange = 100000
        intervalSteps = 100

    elseif (StringUtil.Find(option, "Maximum Bounty") != -1)
        string outfitId = GetOptionCategory(option)
        minRange = mcm.GetOptionSliderValue(outfitId + "::Minimum Bounty")
        maxRange = 100000
        intervalSteps = 100
    endif

    float startValue = float_if (currentSliderValue > mcm.GENERAL_ERROR, currentSliderValue, defaultValue)
    mcm.SetSliderOptions(minRange, maxRange, intervalSteps, defaultValue, startValue)
endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global

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

    elseif (IsSelectedOption(option, "Outfit"))
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

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionKey = mcm.CurrentPage + "::" + option

    ; Avoid toggle options for this type of option
    if (IsSelectedOption(option, "Equipped Outfit"))

        string outfitId = GetOptionCategory(option)
        mcm.Trace("OnOptionSelect", "option: " + option)
        mcm.Trace("OnOptionSelect", "outfitName: " + outfitId)

        Armor headClothing  = mcm.config.GetEquippedClothingForBodyPart("Head")
        Armor bodyClothing  = mcm.config.GetEquippedClothingForBodyPart("Body")
        Armor handsClothing = mcm.config.GetEquippedClothingForBodyPart("Hands")
        Armor feetClothing  = mcm.config.GetEquippedClothingForBodyPart("Feet")

        mcm.config.AddOutfit(outfitId, headClothing, bodyClothing, handsClothing, feetClothing)
        return
    endif

    mcm.ToggleOption(optionKey)
    HandleDependencies(mcm)
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    float sliderOptionValue = mcm.GetOptionSliderValue(option)
    LoadSliderOptions(mcm, option, sliderOptionValue)
    mcm.Debug("OnOptionSliderOpen", "Option: " + option + ", Value: " + sliderOptionValue)
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global
    string formatString = "{0}"

    ; ==========================================================
    ;                 CONFIGURATION / OUTFITTING
    ; ==========================================================

    if (option == "Item Slots::Underwear (Top)")
        formatString = "Slot {0}"

    elseif (option == "Item Slots::Underwear (Bottom)")
        formatString = "Slot {0}"

    elseif (StringUtil.Find(option, "Minimum Bounty") != -1)
        formatString = "{0} Bounty"

    elseif (StringUtil.Find(option, "Maximum Bounty") != -1)
        formatString = "{0} Bounty"

    endif

    ; Handle any slider option that depends on the current option being set
    HandleSliderOptionDependency(mcm, option, value)

    mcm.SetOptionSliderValue(option, value, formatString)
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, string option) global

endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, string option, int menuIndex) global

endFunction

function OnOptionColorOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionColorAccept(RealisticPrisonAndBounty_MCM mcm, string option, int color) global
    
endFunction

function OnOptionInputOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    string inputOptionValue = mcm.GetOptionInputValue(option)
    mcm.SetInputDialogStartText(inputOptionValue)

    if (IsSelectedOption(option, "Outfit") && !IsSelectedOption(option, "Name") && !IsSelectedOption(option, "BountyCondition"))
        string outfitId = GetOptionCategory(option)
        string bodyPartName = GetOptionNameNoCategory(option)  ; bodyPartName = Head, Body, Hands, Feet
        Armor outfitPiece = mcm.GetOutfitPart(outfitId, bodyPartName) ; Outfit 1::Body
        mcm.Debug("OnOptionInputOpen", "Outfit Piece: " + outfitPiece.GetName() + ", FormID: " + outfitPiece.GetFormID() + ", Slot Mask: " + outfitPiece.GetSlotMask())
    endif

    mcm.Trace("OnOptionInputOpen", "GetOptionInputValue("+  option +") = " + mcm.GetOptionInputValue(option, mcm.CurrentPage))
endFunction

function OnOptionInputAccept(RealisticPrisonAndBounty_MCM mcm, string option, string inputValue) global
    if (IsSelectedOption(option, "Outfit") && !IsSelectedOption(option, "Name") && !IsSelectedOption(option, "BountyCondition"))
        string bodyPartName = GetOptionNameNoCategory(option)

        ; Get armor
        int formId = StringToInt(inputValue)
        Armor bodyPart = Game.GetFormEx(formId) as Armor
        int slotMask = bodyPart.GetSlotMask()

        if (IsValidClothingForBodyPart(bodyPartName, slotMask))
            ; Add the actual form as an outfit piece
            string outfitId = GetOptionCategory(option)
            string outfitBodyPart = GetOptionNameNoCategory(option)
            mcm.AddOutfitPiece(outfitId, outfitBodyPart, bodyPart)
            mcm.Debug("OnOptionInputAccept", "bodyPart: " + bodyPart.GetFormID() + ", slotMask: " + slotMask + ", bodyPartName: " + bodyPart.GetName())
            mcm.Debug("OnOptionInputAccept", "outfitId: " + outfitId + ", outfitBodyPart: " + outfitBodyPart)
        elseif (inputValue == "")
            ; Remove clothing for this part of the outfit
            string outfitId = GetOptionCategory(option)
            string outfitBodyPart = GetOptionNameNoCategory(option)
            mcm.RemoveOutfitPiece(outfitId, outfitBodyPart)
        else
            ; Display error message, armor type is not compatible with slot or does not exist
            mcm.Debug("OnOptionInputAccept", "Body part does not exist or is of the wrong type!")
            Debug.MessageBox("Body part does not exist or is of the wrong type!")
        endif
    else
        ; Normal input handling
        mcm.SetOptionInputValue(option, inputValue)
    endif
endFunction


function OnOptionKeymapChange(RealisticPrisonAndBounty_MCM mcm, string option, int keyCode, string conflictControl, string conflictName) global
    
endFunction

; =====================================================
; Event Handlers
; =====================================================

function OnHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid), value)
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid), menuIndex)
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid), color)
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid), keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid), inputValue)
endFunction

Scriptname RPB_ConfigAlias extends ReferenceAlias  

import RPB_Utility
import RPB_Config

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
        return self.GetOwningQuest() as RPB_Config
    endFunction
endProperty

RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return Config.SceneManager
    endFunction
endProperty

function PerformSetup()
    bool registeredEvents               = Config.HandleEvents()
    bool holdLocations                  = Config.SetHoldLocations()
    bool jailTeleportReleaseLocations   = Config.SetJailTeleportReleaseLocations()
    bool jailPrisonerContainers         = Config.SetJailPrisonerContainers()
    bool prisons                        = Config.SetPrisons()

    SceneManager.SetupScenes()

    Info(\
        "==========================================================\n" + \
                        "\t\t"+ GetModName() +"\n" + \
        "==========================================================\n" + \
        "\n" + \
        "Performing initial mod setup...\n" + \
        "Registering Events: " + string_if (registeredEvents, "OK", "Failed") + "\n" + \
        "Setting Hold Locations up: " + string_if (holdLocations, "OK", "Failed") + "\n" +  \
        "Setting Jail Release Locations up: " + string_if (jailTeleportReleaseLocations, "OK", "Failed") + "\n" +  \
        "Setting Jail Containers up: " + string_if (jailPrisonerContainers, "OK", "Failed") + "\n" +  \
        "Setting Prisons up: " + string_if (prisons, "OK", "Failed") + "\n" \
    )

    if (!registeredEvents || !holdLocations || !jailTeleportReleaseLocations || !jailPrisonerContainers || !prisons)
        Debug.MessageBox("["+ GetModName() +"] One or more components of the mod have failed, some things may not work properly!")
    endif
endFunction

function PerformMaintenance()
    bool registeredEvents = Config.HandleEvents()
    bool prisons          = false;Config.SetPrisons()


    Config.MCM.InitializePages()
    ;/
        TODO: If at any point a new hold, city, jail cell, jail location etc gets added,
        we should refresh the lists and add the new content, like:
        
        miscVars.AddFormToArray("Jail::Cells[New_Hold]", Game.GetForm([New_Hold_Jail_Cell_Ref]))
    /;

    Info(\
        "==========================================================\n" + \
                        "\t\t"+ GetModName() +"\n" + \
        "==========================================================\n" + \
        "\n" + \
        "Registering Events: " + string_if (registeredEvents, "OK", "Failed") + "\n" + \
        "Registering Prisons: " + string_if (prisons, "OK", "Failed") + "\n" \
    )
    
    SceneManager.SetupScenes()

    if (!registeredEvents)
        Debug.MessageBox("["+ GetModName() +"] Failed to register events, the mod may not work at all!")
    endif

    ; Temporary, RefAliases are lost on Player Load, must find a way to rectify
    ; Config.jail.Prisoner.ForceRefTo(Config.Player)
    ; Config.NotifyJail("Prisoner: " + Config.Player + ", Ref: " + Config.jail.Prisoner)

    ; Config.miscVars.CreateStringMap("Options")
    ; Config.miscVars.CreateStringMap("Options/Flags")
    ; Config.miscVars.AddToContainer("Jail::Cells", "Jail::Cells[Teste]")
    ; Config.miscVars.AddToContainer("Options", "Jail::Cells")
    ; Config.miscVars.Serialize("Options", "OptionsContainer.txt")
    ; Config.miscVars.Serialize("root", "newRootContainer.txt")

    ; Config.miscVars.Serialize("root", "rootTest.txt")
endFunction

state Initialization
    event OnBeginState()
        RegisterForSingleUpdate(1.0)
    endEvent

    event OnUpdate()
        self.PerformSetup()
        GotoState("")
    endEvent
endState

event OnInit()
    ; Defer heavy setup calls to OnUpdate to run async
    GotoState("Initialization")
    self.RegisterHotkeys()
endEvent

event OnPlayerLoadGame()
    self.PerformMaintenance()
    self.RegisterHotkeys()
endEvent

event OnKeyDown(int keyCode)
    RPB_Config configScript = (self.GetOwningQuest() as RPB_Config)
    RPB_MCM mcm = configScript.mcm

    if (keyCode == 0x3B)    ; F1
        RPB_UIInterface uilib   = (self.GetReference() as Form) as RPB_UIInterface
        RPB_Tests unitTest      = (self.GetReference() as Form) as RPB_Tests
        
        string testName = uilib.ShowList_ReturnElement("Tests", unitTest.GetTestNames(), 0, 0)
        unitTest.ExecuteTest(testName)

    elseif (keyCode == 0x3C)    ; F2
        RPB_UIInterface uilib   = (self.GetReference() as Form) as RPB_UIInterface
        RPB_Tests unitTest      = (self.GetReference() as Form) as RPB_Tests
        RPB_MCM_02 mcm2         = RPB_Utility.GetFormFromMod(0x1F36A) as RPB_MCM_02

        string selectedHold = uilib.ShowList_ReturnElement("Set Bounty in Hold", mcm2.Holds, 0, 0)

        if (selectedHold != "")
            Actor actorToSetBountyOn = Game.GetCurrentConsoleRef() as Actor
            string desiredBounty = uilib.ShowInput(selectedHold + " - Bounty to set for " + actorToSetBountyOn.GetBaseObject().GetName())
            if (desiredBounty != "")
                string addAsViolent = uilib.ShowINput("Add Bounty as Violent?", "No")
                int holdRootObject = RPB_Data.GetRootObject(selectedHold)
                Faction crimeFaction = RPB_Data.Hold_GetCrimeFaction(holdRootObject)
                if (addAsViolent == "Yes")
                    if (actorToSetBountyOn == config.Player)
                        crimeFaction.SetCrimeGoldViolent(desiredBounty as int)
                    else
                        RPB_ActorVars.SetCrimeGold(crimeFaction, actorToSetBountyOn, desiredBounty as int)
                        int actorBounty = RPB_ActorVars.GetCrimeGoldViolent(crimeFaction, actorToSetBountyOn)                        
                        Debug("ConfigAlias::OnKeyDown", actorToSetBountyOn.GetBaseObject().GetName() + " now has " + actorBounty + " violent bounty in " + selectedHold)
                    endif
                else
                    if (actorToSetBountyOn == config.Player)
                        crimeFaction.SetCrimeGold(desiredBounty as int)
                    else
                        RPB_ActorVars.SetCrimeGold(crimeFaction, actorToSetBountyOn, desiredBounty as int)
                        int actorBounty = RPB_ActorVars.GetCrimeGold(crimeFaction, actorToSetBountyOn)                            
                        Debug("ConfigAlias::OnKeyDown", actorToSetBountyOn.GetBaseObject().GetName() + " now has " + actorBounty + " bounty in " + selectedHold)
                    endif
                endif
            endif
        endif

    elseif (keyCode == 0x3D) ; F3
        ; bool prisons          = API.Config.SetPrisons()
        ; API.MCM.ReloadDefaults()
        API.MCM.LoadDefaults()
        API.MCM.LoadMinimums()
        API.MCM.LoadMaximums()
        API.MCM.LoadSteps()

    elseif (keyCode == 0x3E) ; F4
        RPB_UIInterface uilib   = (self.GetReference() as Form) as RPB_UIInterface
        int actionArrayObj = JArray.object()
        JArray.addStr(actionArrayObj, "Don't do anything")
        JArray.addStr(actionArrayObj, "Quit to Main Menu")
        JArray.addStr(actionArrayObj, "Validate Options")

        string[] actionArray = JArray.asStringArray(actionArrayObj)

        string actionToPerform = uilib.ShowList_ReturnElement("Execute Action", actionArray, 0, 0)
        if (actionToPerform == "Quit to Main Menu")
            Game.QuitToMainMenu()
        elseif (actionToPerform == "Validate Options")
            API.MCM.ValidateOptions()
        endif
    endif

    if (keyCode == 0x41) ; F7
        ; configScript.miscVars.CreateStringMap("Options")
        ; configScript.miscVars.CreateStringMap("Options/Value")
        ; ; configScript.miscVars.CreateArray("Whiterun")
        ; ; configScript.miscVars.AddStringToArray("Whiterun", "Stripping::Allow Stripping")
        ; configScript.miscVars.AddArrayToContainer("Whiterun", "Options/Value")
        ; ; configScript.miscVars.SetStringInContainer("Stripping::Allow Stripping", "Gata", "Options/Value::Whiterun")
        ; ; configScript.miscVars.AddToContainer("Options/Value", "Whiterun")

        ; ;/
        ;     miscVars.AddOption("Arrest::Minimum Bounty to Arrest", "Options/Value", 701, 50)
        ; /;

        ; configScript.miscVars.CreateStringMap("Options/Cache")
        ; configScript.miscVars.CreateStringMap("Options/Flags")
        ; configScript.miscVars.CreateStringMap("Options/Defaults")
        ; configScript.miscVars.AddToContainer("Jail::Cells", "Jail::Cells[Teste]")
        ; ; configScript.miscVars.AddToContainer("Options", "Jail::Cells")
        ; ; configScript.miscVars.Serialize("Options", "OptionsContainer.txt")
        ; configScript.miscVars.Serialize("root", "newRootContainer.txt")
        ; configScript.miscVars.Serialize("Options/Value", "optionsValueContainer.txt")
        
        ; ;/
        ;     Create MCM Option:
        ;         Map containing each page, where the page name is the key of the map
        ;         Maps of options where their key is the name of the option and their value is the value of the option, inside the map page.
        ;         Structure: 
        ;               "Whiterun": {
        ;                     "Frisking::Allow Frisking": 1,
        ;                     "Stripping::Allow Stripping": 1
        ;                 },
        ;                 "Haafingar": {
        ;                     "Frisking::Allow Frisking": 1,
        ;                     "Stripping::Allow Stripping": 1
        ;                 },
        ;                 ...
        ; /;

        ; int optionsValueMap = JMap.object()
        ; int optionsValueWhiterun = JMap.object()
        ; JMap.setInt(optionsValueWhiterun, "Stripping::Allow Stripping", true as int)
        ; JMap.setInt(optionsValueWhiterun, "Frisking::Allow Frisking", true as int)

        ; ; int optionsValueWhiterun = JArray.object()
        ; ; JArray.addStr(optionsValueWhiterun, "Stripping::Allow Stripping")
        ; ; JArray.addStr(optionsValueWhiterun, "Frisking::Allow Frisking")
        ; JMap.setObj(optionsValueMap, "Whiterun", optionsValueWhiterun)

        ; JMap.getObj(optionsValueMap, "Whiterun")

        ; JValue.writeToFile(optionsValueMap, "optionsTest.txt")
        
        ; int i = 0
        ; while (i < configScript.miscVars.GetLengthOf("Holds"))
        ;     string hold = configScript.Holds[i]
        ;     configScript.miscVars.CreateStringMap("Options/Value/" + hold)
        ;     configScript.miscVars.CreateStringMap("Teste")
        ;     configScript.miscVars.SetInt("Stripping::Allow Stripping", true as int, "Options/Value/" + hold)
        ;     configScript.miscVars.SetInt("Frisking::Allow Frisking", true as int, "Options/Value/" + hold)
        ;     configScript.miscVars.SetString("Jail::Handle Skill Loss On", "Unconditionally", "Options/Value/" + hold)
        ;     configScript.miscVars.AddToContainer("Options/Value", "Options/Value/" + hold)
        ;     configScript.miscVars.AddToContainer("Options", "Options/Value")
        ;     configScript.miscVars.AddToContainer("Options/Value/" + hold, "Teste")
        ;     i += 1
        ; endWhile

        ; configScript.miscVars.CreateStringMap("Options/ID")
        ; int j = 0
        ; while (j < configScript.miscVars.GetLengthOf("Holds"))
        ;     string hold = configScript.Holds[j]
        ;     configScript.miscVars.CreateStringMap("Options/ID/" + hold)
        ;     configScript.miscVars.CreateStringMap("Teste")
        ;     configScript.miscVars.SetInt("Stripping::Allow Stripping", Utility.RandomInt(0,4000), "Options/ID/" + hold)
        ;     configScript.miscVars.SetInt("Frisking::Allow Frisking", Utility.RandomInt(0,4000), "Options/ID/" + hold)
        ;     configScript.miscVars.SetInt("Jail::Handle Skill Loss On", Utility.RandomInt(0,4000), "Options/ID/" + hold)
        ;     configScript.miscVars.AddToContainer("Options/ID", "Options/ID/" + hold)
        ;     configScript.miscVars.AddToContainer("Options", "Options/ID")
        ;     configScript.miscVars.AddToContainer("Options/ID/" + hold, "Teste")
        ;     j += 1
        ; endWhile

        ; configScript.miscVars.CreateStringMap("Options/State")
        ; int n = 0
        ; while (n < configScript.miscVars.GetLengthOf("Holds"))
        ;     string hold = configScript.Holds[n]
        ;     configScript.miscVars.CreateStringMap("Options/State/" + hold)
        ;     configScript.miscVars.CreateStringMap("Teste")
        ;     configScript.miscVars.SetInt("Stripping::Allow Stripping", Utility.RandomInt(0,1), "Options/State/" + hold)
        ;     configScript.miscVars.SetInt("Frisking::Allow Frisking", Utility.RandomInt(0,1), "Options/State/" + hold)
        ;     configScript.miscVars.SetInt("Jail::Handle Skill Loss On", Utility.RandomInt(0,1), "Options/State/" + hold)
        ;     configScript.miscVars.AddToContainer("Options/State", "Options/State/" + hold)
        ;     configScript.miscVars.AddToContainer("Options", "Options/State")
        ;     configScript.miscVars.AddToContainer("Options/State/" + hold, "Teste")
        ;     n += 1
        ; endWhile

        ; ; configScript.miscVars.CreateStringMap("Options/Value/Whiterun")
        ; ; configScript.miscVars.CreateStringMap("Teste")
        ; ; configScript.miscVars.SetIntInContainer("Stripping::Allow Stripping", true as int, "Options/Value/Whiterun")
        ; ; configScript.miscVars.SetIntInContainer("Frisking::Allow Frisking", true as int, "Options/Value/Whiterun")
        ; ; configScript.miscVars.SetString("Jail::Handle Skill Loss On", "Unconditionally", "Options/Value/Whiterun")
        ; ; configScript.miscVars.AddToContainer("Options", "Options/Value/Whiterun")
        ; ; configScript.miscVars.AddToContainer("Options/Value/Whiterun", "Teste")
        ; configScript.miscVars.Serialize("Options", "whiterunSerializeTest.txt")

        ; Info("["+ ModName() +"] Serializing...")
    elseif (keyCode == 0x40) ; F6
        mcm.InitializeOptions()

    elseif (keyCode == 0x3E || keyCode == 0x3D)
        mcm.SerializeOptions()
    endif
endEvent

function RegisterHotkeys()
    int keyCode     = 59 ; F1
    int F10         = 68
    int F11         = 87
    int F12         = 88
    ; Register F1 to F10
    while (keyCode <= F10)
        RegisterForKey(keyCode)
        keyCode += 1
    endWhile

    RegisterForKey(F11)
    RegisterForKey(F12)
endFunction

function Info(string logInfo, bool condition = true, bool hideCall = false) global
    if (condition)
        debug.trace(logInfo)
    endif
endfunction
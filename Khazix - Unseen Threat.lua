    local version = "1.415"
     
    --[[
            Khazix - Unseen Threat
                    Author: Draconis & xMeher
                    Version: 1.415
                    Copyright 2014
                           
            Dependency: Standalone
    --]]
     
    if myHero.charName ~= "Khazix" then return end
     
    _G.UseUpdater = true
     
    local REQUIRED_LIBS = {
            ["SxOrbwalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
            ["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
            ["Prodiction"] = "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua"
    }
     
    local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
     
    function AfterDownload()
            DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
            if DOWNLOAD_COUNT == 0 then
                    DOWNLOADING_LIBS = false
                    print("<b><font color=\"#6699FF\">Khazix - Unseen Threat:</font></b> <font color=\"#FFFFFF\">Required libraries downloaded successfully, please reload (double F9).</font>")
            end
    end
     
    for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
            if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
                    if DOWNLOAD_LIB_NAME ~= "Prodiction" then require(DOWNLOAD_LIB_NAME) end
                    if DOWNLOAD_LIB_NAME == "Prodiction" and VIP_USER then require(DOWNLOAD_LIB_NAME) end
            else
                    DOWNLOADING_LIBS = true
                    DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
                    DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
            end
    end
     
    if DOWNLOADING_LIBS then return end
     
    local UPDATE_NAME = "Khazix - Unseen Threat"
    local UPDATE_HOST = "raw.github.com"
    local UPDATE_PATH = "/meher98/BoL/master/Khazix%20-%20Unseen%20Threat.lua" .. "?rand=" .. math.random(1, 10000)
    local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
    local UPDATE_URL = "http://"..UPDATE_HOST..UPDATE_PATH
     
    function AutoupdaterMsg(msg) print("<b><font color=\"#6699FF\">"..UPDATE_NAME..":</font></b> <font color=\"#FFFFFF\">"..msg..".</font>") end
    if _G.UseUpdater then
            local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
            if ServerData then
                    local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
                    ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
                    if ServerVersion then
                            ServerVersion = tonumber(ServerVersion)
                            if tonumber(version) < ServerVersion then
                                    AutoupdaterMsg("New version available "..ServerVersion)
                                    AutoupdaterMsg("Updating, please don't press F9")
                                    DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end)  
                            else
                                    AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
                            end
                    end
            else
                    AutoupdaterMsg("Error downloading version info")
            end
    end
     
    ------------------------------------------------------
    --                       Callbacks                             
    ------------------------------------------------------
     
    function OnLoad()
            print("<b><font color=\"#6699FF\">Khazix - Unseen Threat:</font></b> <font color=\"#FFFFFF\">Good luck and have fun!</font>")
            Variables()
            Menu()
            PriorityOnLoad()
						
    end
     
    function OnTick()
            ComboKey = Settings.combo.comboKey
            HarassKey = Settings.harass.harassKey
            JungleClearKey = Settings.jungle.jungleKey
            LaneClearKey = Settings.lane.laneKey
	    EvolutionCheck()
     
            if ComboKey then
                    Combo(Target)
            end
     
            if HarassKey then
                    Harass(Target)
            end
     
            if JungleClearKey then
                    JungleClear()
            end
     
            if LaneClearKey then
                    LaneClear()
            end
     
            if Settings.ks.killSteal then
                    KillSteal()
            end
     
            if not (ComboKey or HarassKey) and IsMyHealthLow() and not Recall then
                    Heal()
            end
     
            Checks()
    end
     
    function OnDraw()
            if not myHero.dead and not Settings.drawing.mDraw then
                    if SkillW.ready and Settings.drawing.wDraw then
                            DrawCircle(myHero.x, myHero.y, myHero.z, SkillW.range, RGB(Settings.drawing.wColor[2], Settings.drawing.wColor[3], Settings.drawing.wColor[4]))
                    end
                    if SkillE.ready and Settings.drawing.eDraw then
                            DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, RGB(Settings.drawing.eColor[2], Settings.drawing.eColor[3], Settings.drawing.eColor[4]))
                    end
     
                    if SkillQ.ready and Settings.drawing.qDraw then
                            DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, RGB(Settings.drawing.qColor[2], Settings.drawing.qColor[3], Settings.drawing.qColor[4]))
                    end
     
                    if Settings.drawing.Target and Target ~= nil then
                            DrawCircle(Target.x, Target.y, Target.z, 80, ARGB(255, 10, 255, 10))
                    end
            end
    end
     
    ------------------------------------------------------
    --                       Functions                             
    ------------------------------------------------------
		
		
     
    function Combo(unit)
            if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
                    if Settings.combo.comboItems then
                            UseItems(unit)
                    end
                   
                    if Settings.combo.useW then CastW(unit) end
                    if Settings.combo.useE then CastE(unit) end
                    if Settings.combo.useQ then CastQ(unit) end
            end
    end
     
    function Harass(unit)
            if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
                    if Settings.harass.useW then CastW(unit) end
		    if Settings.harass.useQ then CastQ(unit) end
                   
            end
    end
     
    function LaneClear()
            enemyMinions:update()
            if LaneClearKey then
                    for _, minion in pairs(enemyMinions.objects) do
                            if ValidTarget(minion) and minion ~= nil then
                                    if Settings.lane.laneW and GetDistance(minion) <= SkillW.range and SkillW.ready then
                                            CastSpell(_W, minion.x, minion.z)
                                    end
                                   
                                    if Settings.lane.laneQ and GetDistance(minion) <= SkillQ.range and SkillQ.ready then
                                            CastSpell(_Q, minion)
                                            
                                    end
                                    if GetDistance(minion) <= 350 then CastItem(3074) end
                                    if GetDistance(minion) <= 350 then CastItem(3077) end
                            end              
                    end
            end
    end
     
    function JungleClear()
            if Settings.jungle.jungleKey then
                    local JungleMob = GetJungleMob()
     
                    if JungleMob ~= nil then
                            if Settings.jungle.jungleQ and GetDistance(JungleMob) <= SkillQ.range and SkillQ.ready then
                                    CastSpell(_Q, JungleMob)
                           
                            end
                            if Settings.jungle.jungleW and GetDistance(JungleMob) <= SkillW.range and SkillW.ready then
                                    CastSpell(_W, JungleMob.x, JungleMob.z)
                            end
                           
                            if GetDistance(JungleMob) <= 350 then CastItem(3074) end
                            if GetDistance(JungleMob) <= 350 then CastItem(3077) end
                    end
            end
    end
     
    function Heal()
            if myHero.mana >= 75 then
                    enemyMinions:update()
     
                    for _, minion in pairs(enemyMinions.objects) do
                            if ValidTarget(minion) and minion ~= nil then
                                    CastSpell(_W, minion.x, minion.z)
                            end
                    end
                    for _, enemy in ipairs(GetEnemyHeroes()) do
                            if ValidTarget(enemy) and enemy.visible then
                                    CastSpell(_W, enemy.x, enemy.z)
                            end
                    end
            end
    end
     
    function CastQ(unit)
            if not ComboKey then return end
            if unit ~= nil and SkillQ.ready and GetDistance(unit) <= SkillQ.range then
                     CastSpell(_Q, unit)
     
            end
    end
     
    function CastE(unit)
            if not ComboKey  then return end
            if unit ~= nil and SkillE.ready and GetDistance(unit) <= SkillE.range then
                    CastSpell(_E, unit.x, unit.z)
            end
    end
     
    function CastW(unit)
            if not ComboKey  then return end
            if unit ~= nil and GetDistance(unit) <= SkillW.range and SkillW.ready then
                    local CastPosition,     HitChance,      Position = VP:GetLineCastPosition(unit, SkillW.delay, SkillW.width, SkillW.range, SkillW.speed, myHero, true)
     
                    if HitChance >= 2 then
                            CastSpell(_W, CastPosition.x, CastPosition.z)
                    end
            end
    end
     
    function KillSteal()
            for _, enemy in ipairs(GetEnemyHeroes()) do
                    if ValidTarget(enemy) and enemy.visible then
                            local qDmg = getDmg("Q", enemy, myHero)
                            local wDmg = getDmg("W", enemy, myHero)
                            local eDmg = getDmg("E", enemy, myHero)
     
                            if enemy.health <= qDmg then
                                    CastQ(enemy)
                            elseif enemy.health <= eDmg then
                                    CastE(enemy)
                            elseif enemy.health <= wDmg then
                                    CastW(enemy)
                            elseif enemy.health <= (qDmg + eDmg) and GetDistance(enemy) <= SkillQ.range then
                                    CastE(enemy)
                                    CastQ(enemy)
                            elseif enemy.health <= (wDmg + eDmg) and GetDistance(enemy) <= SkillW.range then
                                    CastW(enemy)
                                    CastE(enemy)
                            end
     
                            if Settings.ks.autoIgnite then
                                    AutoIgnite(enemy)
                            end
                    end
            end
    end
     
    function AutoIgnite(unit)
            if ValidTarget(unit, Ignite.range) and unit.health <= getDmg("IGNITE", unit, myHero) then
                    if Ignite.ready then
                            CastSpell(Ignite.slot, unit)
                    end
            end
    end
     
    ------------------------------------------------------
    --                       Checks, menu & stuff                          
    ------------------------------------------------------
     
    function Checks()
            SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
            SkillW.ready = (myHero:CanUseSpell(_W) == READY)
            SkillE.ready = (myHero:CanUseSpell(_E) == READY)
     
            if myHero:GetSpellData(SUMMONER_1).name:find(Ignite.name) then
                    Ignite.slot = SUMMONER_1
            elseif myHero:GetSpellData(SUMMONER_2).name:find(Ignite.name) then
                    Ignite.slot = SUMMONER_2
            end
     
            Ignite.ready = (Ignite.slot ~= nil and myHero:CanUseSpell(Ignite.slot) == READY)
     
            TargetSelector:update()
            Target = GetCustomTarget()
            SxOrb:ForceTarget(Target)
     
            if VIP_USER and Settings.misc.skinList then ChooseSkin() end
            if Settings.drawing.lfc.lfc then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
    end
     
    function IsMyHealthLow()
            if myHero.health < (myHero.maxHealth * ( Settings.misc.healW / 100)) then
                    return true
            else
                    return false
            end
    end
     
    function Menu()
            Settings = scriptConfig("Khazix - Unseen Threat "..version.."", "xMeherKhazix")
     
            Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
     
            Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
            Settings.combo:addParam("useQ", "Use "..SkillQ.name.." (Q) in Combo", SCRIPT_PARAM_ONOFF, true)
            Settings.combo:addParam("useW", "Use "..SkillW.name.." (W) in Combo", SCRIPT_PARAM_ONOFF, true)
            Settings.combo:addParam("useE", "Use "..SkillE.name.." (E) in Combo", SCRIPT_PARAM_ONOFF, true)
            Settings.combo:addParam("comboItems", "Use Items in Combo", SCRIPT_PARAM_ONOFF, true)
            Settings.combo:permaShow("comboKey")
     
            Settings:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass")
            Settings.harass:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
            Settings.harass:addParam("useW", "Use "..SkillW.name.." (W) in Harass", SCRIPT_PARAM_ONOFF, true)
	    Settings.harass:addParam("useQ", "Use "..SkillQ.name.." (Q) in Harass", SCRIPT_PARAM_ONOFF, true)
            
            Settings.harass:permaShow("harassKey")
     
            Settings:addSubMenu("["..myHero.charName.."] - Lane Clear Settings", "lane")
            Settings.lane:addParam("laneKey", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
            Settings.lane:addParam("laneQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
            Settings.lane:addParam("laneW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
            
            Settings.lane:permaShow("laneKey")
     
            Settings:addSubMenu("["..myHero.charName.."] - Jungle Clear Settings", "jungle")
            Settings.jungle:addParam("jungleKey", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
            Settings.jungle:addParam("jungleQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
            Settings.jungle:addParam("jungleW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
           
            Settings.jungle:permaShow("jungleKey")
     
            Settings:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "ks")
            Settings.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
            Settings.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
            Settings.ks:permaShow("killSteal")
     
            Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")      
            Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
            Settings.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
            Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range ", SCRIPT_PARAM_ONOFF, true)
            Settings.drawing:addParam("qColor", "Draw "..SkillQ.name.." (Q) Color", SCRIPT_PARAM_COLOR, {255, 74, 26, 255})
            Settings.drawing:addParam("wDraw", "Draw "..SkillW.name.." (W) Range", SCRIPT_PARAM_ONOFF, true)
            Settings.drawing:addParam("wColor", "Draw "..SkillW.name.." (W) Color", SCRIPT_PARAM_COLOR, {255, 74, 26, 255})
            Settings.drawing:addParam("eDraw", "Draw "..SkillE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
            Settings.drawing:addParam("eColor", "Draw "..SkillE.name.." (E) Color", SCRIPT_PARAM_COLOR, {255, 74, 26, 255})
     
            Settings.drawing:addSubMenu("Lag Free Circles", "lfc") 
            Settings.drawing.lfc:addParam("lfc", "Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
            Settings.drawing.lfc:addParam("CL", "Quality", 4, 75, 75, 2000, 0)
            Settings.drawing.lfc:addParam("Width", "Width", 4, 1, 1, 10, 0)
     
            Settings:addSubMenu("["..myHero.charName.."] - Misc Settings", "misc")
            Settings.misc:addParam("skinList", "Choose your skin", SCRIPT_PARAM_LIST, 3, { "Mecha", "Guardian of the Sands", "Classic" })
						Settings.misc:addParam("healW", "Use "..SkillW.name.." (W) to Heal", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
     
     
            Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
            SxOrb:LoadToMenu(Settings.Orbwalking)
     
            TargetSelector = TargetSelector(TARGET_LESS_CAST, SkillW.range, DAMAGE_PHYSICAL, true)
            TargetSelector.name = "Khazix"
            Settings:addTS(TargetSelector)
    end
		
	function EvolutionCheck()
	
	if myHero:GetSpellData(_Q).name == "khazixqlong" then
		SkillQ.range = 375
		evolve = true
	end 
	if myHero:GetSpellData(_E).name == "khazixelong" then
		SkillE.range = 900
		evolve = true
	end 
end 
     
    function Variables()
            SkillQ = { name = "Taste Their Fear", range = 325, delay = nil, speed = nil, width = nil, evolve = false, ready = false }
            SkillW = { name = "Void Spike", range = 1000, delay = 0.225, speed = 828.5, width = 100, ready = false }
            SkillE = { name = "Leap", range = 600, delay = 0.250, speed = math.huge, width = 100, evolve = false, ready = false }
            SkillR = { name = "Void Assault", range = nil, delay = nil, speed = nil, width = nil, ready = false }
            Ignite = { name = "summonerdot", range = 600, slot = nil }
						
     
            enemyMinions = minionManager(MINION_ENEMY, SkillE.range, myHero, MINION_SORT_HEALTH_ASC)
     
            VP = VPrediction()
     
            JungleMobs = {}
            JungleFocusMobs = {}
     
            lastSkin = 0
            Recall = false
     
            if GetGame().map.shortName == "twistedTreeline" then
                    TwistedTreeline = true
            else
                    TwistedTreeline = false
            end
     
            _G.oldDrawCircle = rawget(_G, 'DrawCircle')
            _G.DrawCircle = DrawCircle2    
     
            priorityTable = {
                    AP = {
                            "Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
                            "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
                            "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
                    },
     
                    Support = {
                            "Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
                    },
     
                    Tank = {
                            "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
                            "Warwick", "Yorick", "Zac"
                    },
     
                    AD_Carry = {
                            "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
                            "Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
                    },
     
                    Bruiser = {
                            "Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
                            "Renekton", "Khazix", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
                    }
            }
     
            Items = {
                    BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
                    BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
                    DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
                    HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
                    RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
                    STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
                    TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
                    YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
                    BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
                    RND = { id = 3143, range = 275, reqTarget = false, slot = nil }
            }
     
            if not TwistedTreeline then
                    JungleMobNames = {
                            ["Wolf8.1.2"]                   = true,
                            ["Wolf8.1.3"]                   = true,
                            ["YoungLizard7.1.2"]    = true,
                            ["YoungLizard7.1.3"]    = true,
                            ["LesserWraith9.1.3"]   = true,
                            ["LesserWraith9.1.2"]   = true,
                            ["LesserWraith9.1.4"]   = true,
                            ["YoungLizard10.1.2"]   = true,
                            ["YoungLizard10.1.3"]   = true,
                            ["SmallGolem11.1.1"]    = true,
                            ["Wolf2.1.2"]                   = true,
                            ["Wolf2.1.3"]                   = true,
                            ["YoungLizard1.1.2"]    = true,
                            ["YoungLizard1.1.3"]    = true,
                            ["LesserWraith3.1.3"]   = true,
                            ["LesserWraith3.1.2"]   = true,
                            ["LesserWraith3.1.4"]   = true,
                            ["YoungLizard4.1.2"]    = true,
                            ["YoungLizard4.1.3"]    = true,
                            ["SmallGolem5.1.1"]             = true
                    }
     
                    FocusJungleNames = {
                            ["Dragon6.1.1"]                 = true,
                            ["Worm12.1.1"]                  = true,
                            ["GiantWolf8.1.1"]              = true,
                            ["AncientGolem7.1.1"]   = true,
                            ["Wraith9.1.1"]                 = true,
                            ["LizardElder10.1.1"]   = true,
                            ["Golem11.1.2"]                 = true,
                            ["GiantWolf2.1.1"]              = true,
                            ["AncientGolem1.1.1"]   = true,
                            ["Wraith3.1.1"]                 = true,
                            ["LizardElder4.1.1"]    = true,
                            ["Golem5.1.2"]                  = true,
                            ["GreatWraith13.1.1"]   = true,
                            ["GreatWraith14.1.1"]   = true
                    }
            else
                    FocusJungleNames = {
                            ["TT_NWraith1.1.1"]                     = true,
                            ["TT_NGolem2.1.1"]                      = true,
                            ["TT_NWolf3.1.1"]                       = true,
                            ["TT_NWraith4.1.1"]                     = true,
                            ["TT_NGolem5.1.1"]                      = true,
                            ["TT_NWolf6.1.1"]                       = true,
                            ["TT_Spiderboss8.1.1"]          = true
                    }              
                    JungleMobNames = {
                            ["TT_NWraith21.1.2"]            = true,
                            ["TT_NWraith21.1.3"]            = true,
                            ["TT_NGolem22.1.2"]                     = true,
                            ["TT_NWolf23.1.2"]                      = true,
                            ["TT_NWolf23.1.3"]                      = true,
                            ["TT_NWraith24.1.2"]            = true,
                            ["TT_NWraith24.1.3"]            = true,
                            ["TT_NGolem25.1.1"]                     = true,
                            ["TT_NWolf26.1.2"]                      = true,
                            ["TT_NWolf26.1.3"]                      = true
                    }
            end
     
            for i = 0, objManager.maxObjects do
                    local object = objManager:getObject(i)
                    if object and object.valid and not object.dead then
                            if FocusJungleNames[object.name] then
                                    JungleFocusMobs[#JungleFocusMobs+1] = object
                            elseif JungleMobNames[object.name] then
                                    JungleMobs[#JungleMobs+1] = object
                            end
                    end
            end
    end
     
    function SetPriority(table, hero, priority)
            for i=1, #table, 1 do
                    if hero.charName:find(table[i]) ~= nil then
                            TS_SetHeroPriority(priority, hero.charName)
                    end
            end
    end
     
    function arrangePrioritys()
            for i, enemy in ipairs(GetEnemyHeroes()) do
                    SetPriority(priorityTable.AD_Carry, enemy, 1)
                    SetPriority(priorityTable.AP,            enemy, 2)
                    SetPriority(priorityTable.Support,      enemy, 3)
                    SetPriority(priorityTable.Bruiser,      enemy, 4)
                    SetPriority(priorityTable.Tank,  enemy, 5)
            end
    end
     
    function arrangePrioritysTT()
            for i, enemy in ipairs(GetEnemyHeroes()) do
                    SetPriority(priorityTable.AD_Carry, enemy, 1)
                    SetPriority(priorityTable.AP,                    enemy, 1)
                    SetPriority(priorityTable.Support,      enemy, 2)
                    SetPriority(priorityTable.Bruiser,      enemy, 2)
                    SetPriority(priorityTable.Tank,          enemy, 3)
            end
    end
     
    function UseItems(unit)
            if unit ~= nil then
                    for _, item in pairs(Items) do
                            if item.reqTarget and GetDistance(unit) < item.range then
                                    CastItem(item.id, unit)
                            elseif not item.reqTarget then
                                    if (GetDistance(unit) - getHitBoxRadius(myHero) - getHitBoxRadius(unit)) < 50 then
                                            CastItem(item.id)
                                    end
                            end
                    end
            end
    end
     
    function getHitBoxRadius(target)
            return GetDistance(target.minBBox, target.maxBBox)/2
    end
     
    function PriorityOnLoad()
            if heroManager.iCount < 10 or (TwistedTreeline and heroManager.iCount < 6) then
                    print("<b><font color=\"#6699FF\">Khazix - Unseen Threat:</font></b> <font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
            elseif heroManager.iCount == 6 then
                    arrangePrioritysTT()
            else
                    arrangePrioritys()
            end
    end
     
    function GetJungleMob()
            for _, Mob in pairs(JungleFocusMobs) do
                    if ValidTarget(Mob, SkillQ.range) then return Mob end
            end
            for _, Mob in pairs(JungleMobs) do
                    if ValidTarget(Mob, SkillQ.range) then return Mob end
            end
    end
     
    function OnCreateObj(obj)
            if obj.valid then
                    if FocusJungleNames[obj.name] then
                            JungleFocusMobs[#JungleFocusMobs+1] = obj
                    elseif JungleMobNames[obj.name] then
                            JungleMobs[#JungleMobs+1] = obj
                    end
            end
     
            if obj.name:find("TeleportHome.troy") then
                    Recall = true
            end
    end
     
    function OnDeleteObj(obj)
            for i, Mob in pairs(JungleMobs) do
                    if obj.name == Mob.name then
                            table.remove(JungleMobs, i)
                    end
            end
            for i, Mob in pairs(JungleFocusMobs) do
                    if obj.name == Mob.name then
                            table.remove(JungleFocusMobs, i)
                    end
            end
     
            if obj.name:find("TeleportHome.troy") then
                    Recall = false
            end
    end
     
    function TrueRange()
            return myHero.range + GetDistance(myHero, myHero.minBBox)
    end
     
    -- Trees
    function GetCustomTarget()
            TargetSelector:update()        
            if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
            if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
            return TargetSelector.target
    end
     
    -- shalzuth
    function GenModelPacket(champ, skinId)
            p = CLoLPacket(0x97)
            p:EncodeF(myHero.networkID)
            p.pos = 1
            t1 = p:Decode1()
            t2 = p:Decode1()
            t3 = p:Decode1()
            t4 = p:Decode1()
            p:Encode1(t1)
            p:Encode1(t2)
            p:Encode1(t3)
            p:Encode1(bit32.band(t4,0xB))
            p:Encode1(1)--hardcode 1 bitfield
            p:Encode4(skinId)
            for i = 1, #champ do
                    p:Encode1(string.byte(champ:sub(i,i)))
            end
            for i = #champ + 1, 64 do
                    p:Encode1(0)
            end
            p:Hide()
            RecvPacket(p)
    end
     
    function ChooseSkin()
            if Settings.misc.skinList ~= lastSkin then
                    lastSkin = Settings.misc.skinList
                    GenModelPacket("Khazix", Settings.misc.skinList)
            end
    end
     
    function GetBestCircularFarmPosition(range, radius, objects)
            local BestPos
            local BestHit = 0
            for i, object in ipairs(objects) do
                    local hit = CountObjectsNearPos(object.visionPos or object, range, radius, objects)
                    if hit > BestHit then
                            BestHit = hit
                            BestPos = Vector(object)
                            if BestHit == #objects then
                                    break
                            end
                    end
            end
            return BestPos, BestHit
    end
     
    function CountObjectsNearPos(pos, range, radius, objects)
            local n = 0
            for i, object in ipairs(objects) do
                    if GetDistance(pos, object) <= radius then
                            n = n + 1
                    end
            end
            return n
    end
     
    -- Barasia, vadash, viseversa
    function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
            radius = radius or 300
            quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
            quality = 2 * math.pi / quality
            radius = radius*.92
     
            local points = {}
            for theta = 0, 2 * math.pi + quality, quality do
                    local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
                    points[#points + 1] = D3DXVECTOR2(c.x, c.y)
            end
     
            DrawLines2(points, width or 1, color or 4294967295)
    end
     
    function round(num)
            if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
    end
     
    function DrawCircle2(x, y, z, radius, color)
            local vPos1 = Vector(x, y, z)
            local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
            local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
            local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
     
            if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
                    DrawCircleNextLvl(x, y, z, radius, Settings.drawing.lfc.Width, color, Settings.drawing.lfc.CL)
            end
    end

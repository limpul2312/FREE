local CONFIG = {

  TITLE         = "@YAHIKO_CH PAKS INFORMASI",
--  MESSAGE       = "PAKS DITUTUP DAN TERBUKA LAGI PADA JAM 00.00 WIB\nPAKS WILL BE CLOSED AND OPEN AGAIN AT 00.00 WIB\n",
   MESSAGE       = "PAKS DITUTUP\nPAKS WILL BE CLOSED\n",

  TELEGRAM_USER = "\nBUY VIP:\nTG: @YAHIKO_OWN\nWA: 085138703742",
  TELEGRAM_URL  = "https://t.me/YAHIKO_OWN",
  WHATSAPP_URL  = "https://wa.me/6285138703742",


  SPAM_INTERVAL = 5.0,


  SHOW_LOG     = true,   -- print ke console
  SHOW_SCREEN  = true,   -- teks di layar
  SHOW_NOTIFY  = true,   -- LexusNotify
  SHOW_POPUP   = true,   -- popup box


  BTN_OK    = "TELEGRAM",
  BTN_CLOSE = "WHATSAPP",

  COLOR = { R = 1, G = 0.15, B = 0.15, A = 1 },
  SCALE = 1.3,
}

-- ==============================================================================
--  🔒  LOGIKA SPAM EXPIRED
-- ==============================================================================
local ExpiredLock = {}

function ExpiredLock.Spam()
  -- 1) Console log
  if CONFIG.SHOW_LOG then
    pcall(function()
      print("[YAHIKO] " .. CONFIG.MESSAGE)
    end)
  end

  -- 2) Teks di layar
  if CONFIG.SHOW_SCREEN then
    pcall(function()
      local sh = import("ScriptHelperClient")
      if sh and sh.AddOnScreenDebugMessage then
        sh.AddOnScreenDebugMessage(
          CONFIG.MESSAGE, -1, 4.5,
          CONFIG.COLOR,
          { X = CONFIG.SCALE, Y = CONFIG.SCALE }
        )
      end
    end)
  end

  -- 3) Notifikasi tambahan
  if CONFIG.SHOW_NOTIFY then
    pcall(function()
      if _G.LexusNotify then
        _G.LexusNotify(CONFIG.MESSAGE)
      end
    end)
  end

  -- 4) Popup box + 2 tombol (Telegram & WhatsApp)
  if CONFIG.SHOW_POPUP then
    pcall(function()
      local Msg = require("client.slua.logic.common.logic_common_msg_box")
      if not Msg or not Msg.Show then return end
      Msg.Show(
        2,  -- tipe 2 supaya muncul 2 tombol
        CONFIG.TITLE,
        CONFIG.MESSAGE .. "" .. CONFIG.TELEGRAM_USER,
        -- Tombol TELEGRAM
        function()
          pcall(function()
            local Web = require("client.slua.logic.url.logic_webview_sdk")
            if Web and Web.OpenURL then
              Web:OpenURL(CONFIG.TELEGRAM_URL)
            end
          end)
        end,
        -- Tombol WHATSAPP
        function()
          pcall(function()
            local Web = require("client.slua.logic.url.logic_webview_sdk")
            if Web and Web.OpenURL then
              Web:OpenURL(CONFIG.WHATSAPP_URL)
            end
          end)
        end,
        CONFIG.BTN_OK,
        CONFIG.BTN_CLOSE
      )
    end)
  end
end

function ExpiredLock.Start()
  pcall(function()
    local ok, ticker = pcall(require, "common.time_ticker")
    if ok and ticker and ticker.AddTimerLoop then
      ExpiredLock.Spam() -- langsung sekali
      ticker.AddTimerLoop(CONFIG.SPAM_INTERVAL, function()
        ExpiredLock.Spam()
      end, -1, CONFIG.SPAM_INTERVAL)
    else
      ExpiredLock.Spam()
    end
  end)
end

-- ==============================================================================
--  🎮  BRPlayerCharacterBase (class asli game — jangan diubah)
-- ==============================================================================
local BRPlayerCharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {},
  LuaEventContainer = {}
}

BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = {
  Reliable = true,
  Params = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = {
  Reliable = true,
  Params = { UEnums.EPropertyClass.Object }
}
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = {
  Reliable = true,
  Params = { UEnums.EPropertyClass.Int }
}
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = {
  Reliable = true,
  Params = { UEnums.EPropertyClass.Int }
}
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = {
  Reliable = true,
  Params = { UEnums.EPropertyClass.Bool }
}

local GameplayData = require("GameLua.GameCore.Data.GameplayData")

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
  BRPlayerCharacterBase.__super._PostConstruct(self)
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
  BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
  if Client then
    pcall(function()
      GameplayData.AddCharacter(self.Object)
    end)

    -- 🔒 Jalankan spam expired lock
    pcall(function()
      ExpiredLock.Start()
    end)
  end
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
  BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
  if Client then
    pcall(function()
      GameplayData.RemoveCharacter(self.Object)
    end)
  end
end

-- ==============================================================================
--  📦  CLASS REGISTER (fitur mod tetap dimatikan / tidak diaktifkan)
-- ==============================================================================
local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CBRPlayerCharacterBase = class(CCharacterBase, nil, BRPlayerCharacterBase)
local finalClass = require("combine_class").DeclareFeature(CBRPlayerCharacterBase, {
  { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
  { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
  { SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
  { TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
  { LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
  { FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
  { CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
  { BuildAircraftVehicleFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature" },
  { UnifiedBuildVehicleFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.UnifiedBuildVehicleFeature" },
  { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature" },
  { ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature" },
  { ParachuteSprint = "GameLua.Mod.BaseMod.GamePlay.Feature.Parachute.ParachuteSprintFeature" },
  { GeneralShowSpotFeature = "GameLua.Mod.BRMod.Gameplay.Feature.PlayerCharacterGeneralShowSpotFeature" },
  { FPPAnimMonitor = "GameLua.Mod.BaseMod.GamePlay.Feature.Player.FPPAnimMonitorFeature" },
  { FishingFeature = "GameLua.Mod.Library.GamePlay.Actor.Fishing.FishingFeature" },
  { PlayerThemeItemsFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerThemeItemsFeature" }
}, "BRPlayerCharacterBase")

_G.X3_ActivePlayerClass = finalClass
return finalClass

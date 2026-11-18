-- ==============================================================================
-- YAHIKO FREE - EXPIRED LOCK (fitur dimatikan total)
-- Spam setiap 5 detik: PAKS EXPIRED HUBUNGI OWNER @YAHIKO_OWN
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
-- SPAM EXPIRED MESSAGE — setiap 5 detik terus-menerus
-- ==============================================================================
local EXPIRED_MSG = "PAKS DI TUTUP DAN TERBUKA LAGI PADA JAM 21.30 WIB\nPAKS WILL BE CLOSED AND OPEN AGAIN AT 21.30 WIB"
local SPAM_INTERVAL = 5.0

local function ShowExpiredSpam()
  pcall(function()
    print("[YAHIKO] " .. EXPIRED_MSG)
  end)

  pcall(function()
    local sh = import("ScriptHelperClient")
    if sh and sh.AddOnScreenDebugMessage then
      sh.AddOnScreenDebugMessage(EXPIRED_MSG, -1, 4.5, {
        R = 1, G = 0.15, B = 0.15, A = 1
      }, { X = 1.3, Y = 1.3 })
    end
  end)

  pcall(function()
    if _G.LexusNotify then
      _G.LexusNotify(EXPIRED_MSG)
    end
  end)

  -- Popup juga setiap 5 detik
  pcall(function()
    local Msg = require("client.slua.logic.common.logic_common_msg_box")
    if not Msg or not Msg.Show then return end
    Msg.Show(
      1,
      "@YAHIKO_CH PAKS INFORMASI",
      EXPIRED_MSG .. "\n\nBUY VIP:\nTelegram: @YAHIKO_OWN\n WHATSAPP: 085138703742",
      function()
        pcall(function()
          local Web = require("client.slua.logic.url.logic_webview_sdk")
          if Web and Web.OpenURL then
            Web:OpenURL("https://t.me/YAHIKO_OWN")
          end
        end)
      end,
      function() end,
      "OWNER",
      "TUTUP"
    )
  end)
end

-- Spam terus-menerus setiap 5 detik
pcall(function()
  local ok, ticker = pcall(require, "common.time_ticker")
  if ok and ticker and ticker.AddTimerLoop then
    -- langsung sekali
    ShowExpiredSpam()
    -- lalu loop 5 detik
    ticker.AddTimerLoop(SPAM_INTERVAL, function()
      ShowExpiredSpam()
    end, -1, SPAM_INTERVAL)
  else
    ShowExpiredSpam()
  end
end)

-- ==============================================================================
-- CLASS REGISTER (minimal, tanpa fitur mod)
-- ==============================================================================
local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CBRPlayerCharacterBase = class(CCharacterBase, nil, BRPlayerCharacterBase)
local finalClass = require("combine_class").DeclareFeature(CBRPlayerCharacterBase, {
  {
    SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature"
  },
  {
    CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature"
  },
  {
    SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature"
  },
  {
    TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature"
  },
  {
    LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature"
  },
  {
    FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature"
  },
  {
    CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature"
  },
  {
    BuildAircraftVehicleFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature"
  },
  {
    UnifiedBuildVehicleFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.UnifiedBuildVehicleFeature"
  },
  {
    CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature"
  },
  {
    ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature"
  },
  {
    ParachuteSprint = "GameLua.Mod.BaseMod.GamePlay.Feature.Parachute.ParachuteSprintFeature"
  },
  {
    GeneralShowSpotFeature = "GameLua.Mod.BRMod.Gameplay.Feature.PlayerCharacterGeneralShowSpotFeature"
  },
  {
    FPPAnimMonitor = "GameLua.Mod.BaseMod.GamePlay.Feature.Player.FPPAnimMonitorFeature"
  },
  {
    FishingFeature = "GameLua.Mod.Library.GamePlay.Actor.Fishing.FishingFeature"
  },
  {
    PlayerThemeItemsFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerThemeItemsFeature"
  }
}, "BRPlayerCharacterBase")

_G.X3_ActivePlayerClass = finalClass
return finalClass

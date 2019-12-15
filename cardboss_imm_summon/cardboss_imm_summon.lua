local addonName = "CARDBOSS_IMM_SUMMON";
local addonNameLower = string.lower(addonName);
local addonVersion = "v0.1a";
local author = "overWrite_e9";
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];
local acutil = require('acutil');
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));

local MY_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN = BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN;

function CARDBOSS_IMM_SUMMON_ON_INIT(addon, frame)
	acutil.slashCommand("/cimm", CARDBOSS_IMM_SUMMON_PROCESS_COMMAND);
end
function CARDBOSS_IMM_SUMMON_PROCESS_COMMAND(command)
	local cmd = "";
	if #command > 0 then
		cmd = table.remove(command, 1);
	else
		local msg = "/cimm on, off, enable, disable";
		return ui.MsgBox(msg,"","Nope");
	end
	if cmd == "on" or cmd == "enable" then
		MY_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN = BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN;
		BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN = function(invItem)
			if invItem == nil then
				return;
			end
			local invFrame = ui.GetFrame("inventory");
			local itemobj = GetIES(invItem:GetObject());
			if itemobj == nil then
				return;
			end
			invFrame:SetUserValue("INVITEM_GUID", invItem:GetIESID());
			REQUEST_SUMMON_BOSS_TX();
			return;
		end
		CHAT_SYSTEM(string.format("[%s] bosscard summon replaced to IMMEDIATE_MODE.", addonName));
		return;
	elseif cmd == "off" or cmd == "disable" then
		BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN = MY_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN;
		CHAT_SYSTEM(string.format("[%s] bosscard summon replaced to NORMAL_MODE.", addonName));
		return;
	end
	CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName));
end

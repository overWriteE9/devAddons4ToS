--add: command history
local addonName = "developerconsole2";
local author = "overWrite_e9";
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];

local acutil = require("acutil");

g.historyFileLoc = "../addons/developerconsole/history.json";
if not g.loaded then
    g.history = {};
end
local hist_idx = 0;

function DEVELOPERCONSOLE_ON_INIT(addon, frame)
    acutil.slashCommand("/dev", DEVELOPERCONSOLE_TOGGLE_FRAME);
    acutil.slashCommand("/console", DEVELOPERCONSOLE_TOGGLE_FRAME);
    acutil.slashCommand("/devconsole", DEVELOPERCONSOLE_TOGGLE_FRAME);
    acutil.slashCommand("/developerconsole", DEVELOPERCONSOLE_TOGGLE_FRAME);

    acutil.setupHook(DEVELOPERCONSOLE_PRINT_TEXT, "print");
    
    --add: command history
    if not g.loaded then
        local t, err = acutil.loadJSON(g.historyFileLoc, g.history);
        if err then
          CHAT_SYSTEM("[W]developerconsole: cannot load history file. " .. g.historyFileLoc);
        else
          g.history = t;
        end
        g.loaded = true;
        hist_idx = table.maxn(g.history);
    end
    acutil.saveJSON(g.historyFileLoc, g.history);

    CLEAR_CONSOLE();
end

function DEVELOPERCONSOLE_TOGGLE_FRAME()
    ui.ToggleFrame("developerconsole");
end

function DEVELOPERCONSOLE_OPEN()
    local frame = ui.GetFrame("developerconsole");
    local textViewLog = frame:GetChild("textview_log");
    textViewLog:ShowWindow(1);

    local devconsole = ui.GetFrame("developerconsole");
    devconsole:ShowTitleBar(0);
    --devconsole:ShowTitleBarFrame(1);
    devconsole:ShowWindow(0);
    devconsole:SetSkinName("chat_window");
    devconsole:ShowWindow(1);
    --devconsole:Resize(800, 500);

    local input = devconsole:GetChild("input");
    if input ~= nil then
        input:Move(0, 0);
        input:SetOffset(10, 450);
        --input:ShowWindow(1);
        --input:Resize(675, 40);
        --input:SetGravity(ui.LEFT, ui.CENTER);
    end

    local executeButton = devconsole:GetChild("execute");
    if executeButton ~= nil then
        --executeButton:Resize(100, 40);
        executeButton:SetOffset(690, 450);
        executeButton:SetText("Execute");
    end

    local debugUIButton = devconsole:GetChild("debugUI");
    if debugUIButton ~= nil then
        --debugUIButton:Resize(100, 40);
        debugUIButton:SetOffset(690, 405);
        debugUIButton:SetText("Debug UI");
    end

    local clearButton = devconsole:GetChild("clearConsole");
    if clearButton ~= nil then
        clearButton:Resize(100, 40);
        clearButton:SetOffset(690, 360);
        clearButton:SetText("Clear");
    end

    local textlog = devconsole:GetChild("textview_log");
    if textlog ~= nil then
        --textlog:Resize(675, 435);
        textlog:SetOffset(10, 10);
    end

    devconsole:Invalidate();

    --ui.SysMsg("input: " .. input:GetX() .. " " .. input:GetY() .. " " .. input:GetWidth() .. " " .. input:GetHeight());
    --ui.SysMsg("execute: " .. executeButton:GetX() .. " " .. executeButton:GetY() .. " " .. executeButton:GetWidth() .. " " .. executeButton:GetHeight());
    --ui.SysMsg("debugUI: " .. debugUIButton:GetX() .. " " .. debugUIButton:GetY() .. " " .. debugUIButton:GetWidth() .. " " .. debugUIButton:GetHeight());
    --ui.SysMsg("textlog: " .. textlog:GetX() .. " " .. textlog:GetY() .. " " .. textlog:GetWidth() .. " " .. textlog:GetHeight());
end

function DEVELOPERCONSOLE_CLOSE()
end

function TOGGLE_UI_DEBUG()
    debug.ToggleUIDebug();
end

function CLEAR_CONSOLE()
    local frame = ui.GetFrame("developerconsole");

    if frame ~= nil then
        local textlog = frame:GetChild("textview_log");

        if textlog ~= nil then
            tolua.cast(textlog, "ui::CTextView");
            textlog:Clear();
            textlog:AddText("Developer Console", "white_16_ol");
            textlog:AddText("Enter command and press execute!", "white_16_ol");
        end
    end
end

function DEVELOPERCONSOLE_PRINT_TEXT(text)
    if text == nil or text == "" then
        return;
    end

    local frame = ui.GetFrame("developerconsole");
    local textlog = frame:GetChild("textview_log");

    if textlog ~= nil then
        tolua.cast(textlog, "ui::CTextView");
        textlog:AddText(text, "white_16_ol");
    end
end

function DEVELOPERCONSOLE_ENTER_KEY(frame, control, argStr, argNum)
    local textlog = frame:GetChild("textview_log");

    if textlog ~= nil then
        tolua.cast(textlog, "ui::CTextView");

        local editbox = frame:GetChild("input");

        if editbox ~= nil then
            tolua.cast(editbox, "ui::CEditControl");
            local commandText = editbox:GetText();

            if commandText ~= nil and commandText ~= "" then
                local s = "[Execute] " .. commandText;
                textlog:AddText(s, "white_16_ol");
                local f = assert(loadstring(commandText));
                local status, error = pcall(f);

                if not status then
                    textlog:AddText(tostring(error), "white_16_ol");
                end
                
                --add: command history
                table.insert(g.history, commandText);
                if table.maxn(g.history) > 300 then
                    table.remove(g.history, 1);
                end
                acutil.saveJSON(g.historyFileLoc, g.history);
                hist_idx = table.maxn(g.history);
            end
        end
    end
end

--add: command history
function DEVELOPERCONSOLE_HISTORY_BACK()
    local editbox = ui.GetFrame("developerconsole"):GetChild("input");
    tolua.cast(editbox, "ui::CEditControl");
    hist_idx = hist_idx - 1;
    if hist_idx < 1 then
        hist_idx = 1;
        return;
    end
    editbox:SetText(g.history[hist_idx]);
end
function DEVELOPERCONSOLE_HISTORY_FORWARD()
    local editbox = ui.GetFrame("developerconsole"):GetChild("input");
    tolua.cast(editbox, "ui::CEditControl");
    hist_idx = hist_idx + 1;
    if hist_idx > table.maxn(g.history) then
        editbox:SetText("");
        hist_idx = table.maxn(g.history);
        return;
    end
    editbox:SetText(g.history[hist_idx]);
end

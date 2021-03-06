--アドオン名（大文字）
local addonName = "TBLEW";
local addonNameLower = string.lower(addonName);
local addonVersion = "v0.4e";
--作者名
local author = "overWrite_e9";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];

--設定ファイル保存先
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

--ライブラリ読み込み
local acutil = require('acutil');

--デフォルト設定
if not g.loaded then
  g.settings = {
    --有効/無効
    enable = true,
    --デバッグ用
    debuggy = false,
    --フレーム表示場所
    position = {
      x = 1160,
      y = 8
    },
    --表示透明度
    alphaPercent = 20,
    --チャットで報告機能
    chatReport = false
  };
end

--グローバル記憶用変数
local eTeamNames = {};
local redrawFlag = false;
local shutChat = false;

--lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));

function TBLEW_SAVE_SETTINGS()
  local t, err = acutil.saveJSON(g.settingsFileLoc, g.settings);
--[[
  if err then
    CHAT_SYSTEM(string.format(
      "[%s] %s を開くことができません{nl}" ..
      "  Hint: ToSインストールフォルダ下のaddonsフォルダに{nl}" ..
      "  %s という名前のフォルダを作成すると設定ファイルが作成されるかも",
      addonName, g.settingsFileLoc, addonNameLower
    ));
  end
]]
end

--マップ読み込み時処理（1度だけ）
function TBLEW_ON_INIT(addon, frame)
  g.addon = addon;
  g.frame = frame;

  frame:ShowWindow(0);
  
  --スラッシュコマンド
  acutil.slashCommand("/tew", TBLEW_PROCESS_COMMAND_TEW);
  acutil.slashCommand("/mmm", TBLEW_PROCESS_COMMAND_MMM);

  if not g.loaded then
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
    if err then
      --設定ファイル読み込み失敗時処理
      CHAT_SYSTEM(string.format(
        "[%s] %s を開くことができません{nl}" ..
        "  Hint: ToSインストールフォルダ下の addons フォルダに{nl}" ..
        "  %s という名前のフォルダを作成すると設定ファイルが作成されるかも",
        addonName, g.settingsFileLoc, addonNameLower
      ));
    else
      --設定ファイル読み込み成功時処理
      g.settings = t;
    end
    g.loaded = true;
  end
    
  --Moveではうまくいかないので、OffSetを使用する…
  frame:Move(0, 0);
  frame:SetOffset(g.settings.position.x, g.settings.position.y);

  --設定ファイル保存処理
  TBLEW_SAVE_SETTINGS();

  --コンテキストメニュー
  frame:SetEventScript(ui.RBUTTONDOWN, "TBLEW_CONTEXT_MENU");

  --ドラッグ
  frame:SetEventScript(ui.LBUTTONUP, "TBLEW_END_DRAG");
  
  --TBLマップ以外では作動させない(邪魔なので)
  if world.IsPVPMap() == false then
    frame:ShowWindow(0);
    return;
  else
    TBLEW_MAIN();
  end
  
end

--メイン処理
function TBLEW_MAIN()
  local frame = g.frame;
  
  --アドオンが無効状態なら、何もしない
  if g.settings.enable == false then
    frame:ShowWindow(0);
    return;
  end

  --再表示処理
  frame:ShowWindow(1);
  
  --Moveではうまくいかないので、OffSetを使用する…
  frame:Move(0, 0);
  frame:SetOffset(g.settings.position.x, g.settings.position.y);

  --フレーム初期化処理
  TBLEW_INIT_FRAME(frame);
  
  --チャットで報告機能
  if redrawFlag == false then
    TBLEW_CHATREPORT();
  end
end

--フレーム描画
function TBLEW_INIT_FRAME(frame)
  --XMLに記載するとデザイン調整時にクライアント再起動が必要になるため、luaに書き込むことをオススメする
  --フレーム初期化処理
  local rtTitle = frame:CreateOrGetControl("picture", "tblewtitle", 34, 0, 200, 20);
  
  local picJobIcon = {};
  local rtTeamName = {};
  local rtLvRank = {};
  local rtMaxHP = {};
  
  picJobIcon[1] = frame:CreateOrGetControl("picture", "tblewjobicon1", 16, 24, 40, 40);
  rtTeamName[1] = frame:CreateOrGetControl("richtext", "tblewteamname1", 56, 24, 180, 20);
  rtLvRank[1] = frame:CreateOrGetControl("richtext", "tblewlvrank1", 56, 44, 180, 20);
  rtMaxHP[1] = frame:CreateOrGetControl("richtext", "tblewmaxhp1", 16, 64, 236, 18);
  
  picJobIcon[2] = frame:CreateOrGetControl("picture", "tblewjobicon2", 16, 86, 40, 40);
  rtTeamName[2] = frame:CreateOrGetControl("richtext", "tblewteamname2", 56, 86, 180, 20);
  rtLvRank[2] = frame:CreateOrGetControl("richtext", "tblewlvrank2", 56, 106, 180, 20);
  rtMaxHP[2] = frame:CreateOrGetControl("richtext", "tblewmaxhp2", 16, 126, 236, 18);
  
  picJobIcon[3] = frame:CreateOrGetControl("picture", "tblewjobicon3", 16, 148, 40, 40);
  rtTeamName[3] = frame:CreateOrGetControl("richtext", "tblewteamname3", 56, 148, 180, 20);
  rtLvRank[3] = frame:CreateOrGetControl("richtext", "tblewlvrank3", 56, 168, 180, 20);
  rtMaxHP[3] = frame:CreateOrGetControl("richtext", "tblewmaxhp3", 16, 188, 236, 18);
  
  local rtInformation = frame:CreateOrGetControl("richtext", "tblewinfobox", 16, 210, 236, 40);

  local alpha = string.format("%02x", math.floor((100 - g.settings.alphaPercent) / 100 * 255));
  for i = 1, 3 do
    tolua.cast(picJobIcon[i], "ui::CPicture");
    picJobIcon[i]:SetEnableStretch(1);
    picJobIcon[i]:SetImage("c_warrior_templar");
    picJobIcon[i]:SetColorTone(alpha.."FFFFFF");
    rtTeamName[i]:SetColorTone(alpha.."FF0000");
    rtLvRank[i]:SetColorTone(alpha.."FFFFFF");
    rtMaxHP[i]:SetColorTone(alpha.."FF9933");
  end
  rtInformation:SetColorTone(alpha.."AAFFFF");
  
  --情報を表示しないと枠が見えないので、仮表示
  rtTitle:SetText("{s19}{ds}TBL. 対戦相手の情報{/}{/}");
  rtTeamName[1]:SetText("{s17}{ol}TeamNameチーム名_１{/}{/}");
  rtLvRank[1]:SetText("{s17}LV. 999, Rank. {#EF2244}999{/}位{/}");
  --rtMaxHP[1]:SetText("{s17}Std HP = {#FF9900}262144{/}{/}");
  rtTeamName[2]:SetText("{s17}{ol}TeamNameチーム名_２{/}{/}");
  rtLvRank[2]:SetText("{s17}{#556655}LV. ∞, ランク圏外{/}{/}");
  --rtMaxHP[2]:SetText("{s17}Std HP = {#FF9900}65536{/}{/}");
  rtTeamName[3]:SetText("{s17}{ol}TeamNameチーム名_３{/}{/}");
  rtLvRank[3]:SetText("{s17}{#556655}LV. ∞, ランク圏外{/}{/}");
  --rtMaxHP[3]:SetText("{s17}Std HP = {#FF9900}12768{/}{/}");
  rtInformation:SetText("{s15}" .. addonName .. " " .. addonVersion .. "{nl}yourTeamName: " .. GETMYFAMILYNAME() .. "{/}");
  
  --描画のみのフラグが立っていたらここまでで終了
  if redrawFlag == true then
    redrawFlag = false;
    return;
  end
  
  --PVPゲームリストが１つもない場合は何もしない
  if session.worldPVP.GetPublicGameCount() < 1 then
    shutChat = true;
    return;
  else
    shutChat = false;
  end
  
  --自分の名前(チーム名)のチェック用
  local myName = GETMYFAMILYNAME();
  local myTeam = 0;
  local enemyTeam = 0;
  eTeamNames = {};
  
  --PVPゲームリストの上から参照し、自分の対戦相手を確認する
  local cnt = session.worldPVP.GetPublicGameCount();
  cnt = math.min(cnt, 10);
  
  if g.settings.debuggy then
    CHAT_SYSTEM("TBLリスト読み込み開始 : cnt = " .. cnt);
  end
  
  --PVPゲームリストの内容を確認する
  for i = 0, cnt - 1 do
    --ゲームの内容を取得
    local info = session.worldPVP.GetPublicGameByIndex(i);
    
    --チーム1(左), チーム2(右)
    local teamVec = {};
    teamVec[1] = info:CreateTeamInfo(1);
    teamVec[2] = info:CreateTeamInfo(2);

    local memberCnt = math.min(teamVec[1]:GetCount(), teamVec[2]:GetCount());
    
    --チームメンバーの内容を確認
    for j = 0, memberCnt - 1 do
      local pcinfo1 = teamVec[1]:GetByIndex(j);
      local pcinfo2 = teamVec[2]:GetByIndex(j);
      local name1 = pcinfo1:GetFamilyName();
      local name2 = pcinfo2:GetFamilyName();

      if g.settings.debuggy then
        CHAT_SYSTEM(string.format("%s [vs] %s", name1, name2));
      end

      --メンバーに自分が入っていたら検索完了フラグを立て、内側のループを抜ける
      if name1 == myName then
        myTeam = 1;
        break;
      end
      
      if name2 == myName then
        myTeam = 2;
        break;
      end  
    end

    --検索完了フラグが立っていたら、現在の情報で対戦相手を確定する
    if myTeam ~= 0 then
      --相手チームの情報のみ参照
      enemyTeam = 3 - myTeam;

      if g.settings.debuggy then
        CHAT_SYSTEM(string.format("team : my = %d ene = %d", myTeam, enemyTeam));
      end
      
      local enemyCnt = teamVec[enemyTeam]:GetCount();

      --相手チームの情報から必要なものを取り出して表示
      for j = 0, enemyCnt - 1 do
        local pcinfo = teamVec[enemyTeam]:GetByIndex(j);
        local vsIcon = pcinfo.jobID;
        local vsTeamName = pcinfo:GetFamilyName();
        local vsLevel = "LV. " .. pcinfo.level;
        local vsRank = " nil ";
        
        if pcinfo.rank == 0 then
          vsRank = ", {#556655}ランク圏外{/}";
        elseif pcinfo.rank > 50 then
          vsRank = ", Rank. {b}" .. pcinfo.rank .. "{/}位";
        elseif pcinfo.rank > 10 and pcinfo.rank <= 50 then
          vsRank = ", Rank. {#FFBB33}{b}" .. pcinfo.rank .. "{/}{/}位";
        elseif pcinfo.rank <= 10 then
          vsRank = ", Rank. {#FF0000}{b}" .. pcinfo.rank .. "{/}{/}位";
        else
          vsRank = ", {#556655}取得不能{/}";
        end

        if g.settings.debuggy then
          CHAT_SYSTEM(
            tostring(pcinfo) .. "{nl}" ..
            pcinfo.jobID .. "{nl}" ..
            pcinfo:GetFamilyName() .. "{nl}" ..
            pcinfo.level .. "{nl}" ..
            pcinfo.rank
          );
        end
        
        local jj = j + 1;

        picJobIcon[jj]:SetImage(GET_JOB_ICON(vsIcon));
        rtTeamName[jj]:SetText("{s17}{ol}" .. vsTeamName .. "{/}{/}");
        rtLvRank[jj]:SetText("{s17}" .. vsLevel .. vsRank .. "{/}");
        
        eTeamNames[jj] = {};
        eTeamNames[jj][1] = vsTeamName;
        eTeamNames[jj][2] = vsIcon;
        eTeamNames[jj][3] = vsLevel;
        if pcinfo.rank == 0 then
          eTeamNames[jj][4] = "ランク圏外";
        else
          eTeamNames[jj][4] = pcinfo.rank .. "位";
        end
        
      end
      
      --相手のMaxHPを取得して表示する(順番が毎回バラバラなのでキャラと結びつけることができない)
      --local teamInfo = session.mission.GetTeam(enemyTeam);
      --local teamList = teamInfo:GetPCList();
      --local arycnt = teamList:size();
      --for i = 0, arycnt - 1 do
      --  local pcInfo = teamList:at(i);
      --  local ii = i + 1;
      --  rtMaxHP[ii]:SetText("{s17}Std HP = {#FF9900}" .. pcInfo.mhp .. "{/}{/}");
      --  eTeamNames[ii][5] = pcInfo.mhp;
      --end

      return;
    end
  end

  --この時点で検索完了フラグが立っていない = 見つからない場合は何もせず終了
  if myTeam == 0 then
    rtInformation:SetText("{s15}{#FF0000}エラー：自分の名前がTBLリストに見当たらない{/}{/}");
    return;
  end

end

--チャットで報告機能
function TBLEW_CHATREPORT()
  --相手チーム情報を取得できていないか、チャットで報告機能が無効なら何もしない
  if #eTeamNames < 1 or g.settings.chatReport == false then
    return;
  end
  
  --描画のみで処理が中断されている場合は何もしない
  if shutChat == true then
    return;
  end

  --チャットで送信する文字列配列
  local chatStrs = {};
  chatStrs[1] = "失踪 (取得できません)";
  chatStrs[2] = "失踪 (取得できません)";
  chatStrs[3] = "失踪 (取得できません)";
  chatStrs[4] = "失踪 (取得できません)";
  chatStrs[5] = "失踪 (取得できません)";

  --文字列を構成していく
  for i = 1, #eTeamNames do
    local targetJob = GetClassByType("Job", eTeamNames[i][2]);
    chatStrs[i] = string.format(
      "[%d]%s(%s) %s %s",
      i,
      targetJob.Name,
      eTeamNames[i][1],
      eTeamNames[i][3],
      eTeamNames[i][4]
    );
  end

  --チャット送信(Party)
  if #eTeamNames <= 3 then
    ui.Chat("/p " .. chatStrs[1]);
    ui.Chat("/p " .. chatStrs[2]);
    ui.Chat("/p " .. chatStrs[3]);
    
  elseif #eTeamNames > 3 then
    for i = 1, #eTeamNames do
      ui.Chat("/p " .. chatStrs[i]);
    end
  end

end

--コンテキストメニュー表示処理
function TBLEW_CONTEXT_MENU(frame, msg, clickedGroupName, argNum)
  local context = ui.CreateContextMenu("TBLEW_RBTN", addonName, 0, 0, 330, 100);
  ui.AddContextMenuItem(context, "非表示", "TBLEW_TOGGLE_FRAME()");
  if g.settings.enable == false then
    ui.AddContextMenuItem(context, "自動表示有効化", "TBLEW_TOGGLE_ENABLED(true)");
  else
    ui.AddContextMenuItem(context, "自動表示無効化", "TBLEW_TOGGLE_ENABLED(false)");
  end
  ui.AddContextMenuItem(context, "* RequestPublicGameList()", "TBLEW_REQ_PUB_LIST()");
  ui.AddContextMenuItem(context, "* TBLEW_MAIN()", "TBLEW_MAIN()");

  context:Resize(330, context:GetHeight());
  ui.OpenContextMenu(context);
end

--表示非表示切り替え処理
function TBLEW_TOGGLE_FRAME()
  if g.frame:IsVisible() == 0 then
    --非表示->表示
    g.frame:ShowWindow(1);
  else
    --表示->非表示
    g.frame:ShowWindow(0);
  end

  TBLEW_SAVE_SETTINGS();
end

--自動表示有効化切り替え処理
function TBLEW_TOGGLE_ENABLED(enabled)
  if enabled then
    g.settings.enable = true;
    CHAT_SYSTEM(string.format("[%s] TBLEWを有効化しました, 次回参加時から自動表示", addonName));
    TBLEW_SAVE_SETTINGS();
    return;
  else
    g.settings.enable = false;
    CHAT_SYSTEM(string.format("[%s] TBLEWを無効化, /tew enableを発行するまで永続停止", addonName));
    g.frame:ShowWindow(0);
    TBLEW_SAVE_SETTINGS();
    return;
  end
end

--公開ゲームリストの更新を要求
function TBLEW_REQ_PUB_LIST()
  worldPVP.RequestPublicGameList();
  if g.settings.debuggy then
    CHAT_SYSTEM("TBLEW_REQ_PUB_LIST:GameCount = " .. session.worldPVP.GetPublicGameCount());
  else
    session.worldPVP.GetPublicGameCount();
  end
end

--フレーム場所保存処理
function TBLEW_END_DRAG()
  g.settings.position.x = g.frame:GetX();
  g.settings.position.y = g.frame:GetY();
  TBLEW_SAVE_SETTINGS();
end

--チャットコマンド処理 /tew
function TBLEW_PROCESS_COMMAND_TEW(command)
  local cmd = "";

  if #command > 0 then
    cmd = string.lower(table.remove(command, 1));
  else
    local msg =
      "TBL enemy who?{nl}    /tew show, /tew on … 表示する{nl}" ..
      "    /tew hide, /tew off … 非表示にする{nl}" ..
      "    /tew enable … アドオン有効化{nl}    /tew disable … アドオン無効化{nl}" ..
      "    ※無効化すると、/tew enableを発行するまでTBL中でも表示されなくなる{nl}" ..
      "    ※位置調整は一般MAPで/tew show→ドラッグ→/tew hideするとやりやすい{nl}" ..
      "    /tew alpha 透明度[%] … フレーム表示透過設定 10％～90％の範囲(初期値20％)";
    CHAT_SYSTEM(msg);
  end

  if cmd == "show" or cmd == "on" then
    --描画のみ行う
    redrawFlag = true;
    --フレーム描画
    TBLEW_MAIN();
    --表示
    CHAT_SYSTEM(string.format("[%s] TBLEWを表示しました", addonName));
    return;
  elseif cmd == "hide" or cmd == "off" then
    --非表示
    CHAT_SYSTEM(string.format("[%s] TBLEWを非表示にしました", addonName));
    g.frame:ShowWindow(0);
    return;
  elseif cmd == "enable" then
    --有効化
    TBLEW_TOGGLE_ENABLED(true);
    return;
  elseif cmd == "disable" then
    --無効化
    TBLEW_TOGGLE_ENABLED(false);
    return;
  elseif cmd == "reload" then
    TBLEW_MAIN_ON_AFTER_RELOADPUBGAME();
    return;
  elseif cmd == "debuggy" then
    if g.settings.debuggy == false then
      g.settings.debuggy = true;
      CHAT_SYSTEM(string.format("[%s] デバッグモードをONにしました", addonName));
    else
      g.settings.debuggy = false;
      CHAT_SYSTEM(string.format("[%s] デバッグモードOFFにしました", addonName));
    end
    TBLEW_SAVE_SETTINGS();
    return;
  end

  --表示透明度の設定
  if cmd == "alpha" then
    cmd = table.remove(command, 1);
    local alpha = tonumber(cmd);
    if alpha ~= nil then
      --値を10～90の範囲に
      g.settings.alphaPercent = math.max(math.min(alpha, 90), 10);
      CHAT_SYSTEM(string.format("[%s] 透過値を %s に設定しました", addonName, g.settings.alphaPercent));
      TBLEW_SAVE_SETTINGS();
      --描画のみ行う
      redrawFlag = true;
      --フレーム描画
      TBLEW_MAIN();
      return;
    end
  end
  
  --チャットで報告機能
  if cmd == "report" or cmd == "chat" then
    cmd = table.remove(command, 1);
    if cmd == "on" then
      g.settings.chatReport = true;
      TBLEW_SAVE_SETTINGS();
      CHAT_SYSTEM(string.format("[%s] チャットで報告機能をONにしました", addonName));
      return;
    elseif cmd == "off" then
      g.settings.chatReport = false;
      TBLEW_SAVE_SETTINGS();
      CHAT_SYSTEM(string.format("[%s] チャットで報告機能をOFFにしました", addonName));
      return;
    end
  end
  
  CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName));
  local msg =
    "TBL enemy who?{nl}    /tew show, /tew on … 表示する{nl}" ..
    "    /tew hide, /tew off … 非表示にする{nl}" ..
    "    /tew enable … アドオン有効化{nl}    /tew disable … アドオン無効化{nl}" ..
    "    ※無効化すると、/tew enableを発行するまでTBL中でも表示されなくなる{nl}" ..
    "    ※位置調整は一般MAPで/tew show→ドラッグ→/tew hideするとやりやすい{nl}" ..
    "    /tew alpha 透明度[%] … フレーム表示透過設定 10％～90％の範囲(初期値20％)";
  CHAT_SYSTEM(msg);
end

--チャットコマンド処理 /mmm
function TBLEW_PROCESS_COMMAND_MMM(command)
  local cmd = "";

  if #command > 0 then
    cmd = table.remove(command, 1);
  else
    local msg = "[TBL enemy who?]{nl}    /mmm 1～5 ・・・ チームの装備確認{nl}    /mmm 6～10 ・・・ 相手チームの装備確認";
    CHAT_SYSTEM(msg);
    return;
  end

  local num = tonumber(cmd);

  if num == nil then
    local msg = "[TBL enemy who?]{nl}    /mmm 1～5 ・・・ チームの装備確認{nl}    /mmm 6～10 ・・・ 相手チームの装備確認";
    CHAT_SYSTEM(msg);
    return;
  end
  
  --Partyメンバーがいない場合何もしない
  local myParty = session.party.GetPartyInfo();
  if myParty == nil then
    local msg = "[TBL enemy who?]パーティーメンバーが存在しません";
    CHAT_SYSTEM(msg);
    return;
  end

  if num > -1 and num <= 5 then

    --数字が1-5、つまり自分のチームの場合
    local memList = session.party.GetPartyMemberList();
    local memCount = memList:Count();
    
    if memCount < 1 then
      local msg = "[TBL enemy who?]パーティーメンバーが存在しません";
      CHAT_SYSTEM(msg);
      return;
    end
    
    --名前リスト参考用
    local msgMembers = "";
    for i = 0, memCount - 1 do
      local memInfo = memList:Element(i);
      msgMembers = msgMembers .. "[" .. (i + 1) .. "] : " .. memInfo:GetName() .. "{nl}";
    end
    
    --指定した番号の情報が無い場合は終了
    if memCount < num or num < 1 then
      local msg = "[TBL enemy who?]指定された番号 [" .. num .. "] のメンバーは存在しないか取得できていません{nl}";
      CHAT_SYSTEM(msg .. msgMembers);
      return;
    end
    
    local memberRef = memList:Element(num - 1);
    ui.Chat("/memberinfo " .. memberRef:GetName());
  
  elseif num > 5 and num <= 11 then
  
    --数字が6-10、つまり相手のチームの場合
    num = num - 5;
    
    if #eTeamNames < 1 then
      local msg = "[TBL enemy who?]相手パーティーメンバーが取得できていません";
      CHAT_SYSTEM(msg);
      return;
    end
    
    --名前リスト参考用
    local memCount = #eTeamNames;
    local msgMembers = "";
    for i = 1, memCount do
      msgMembers = msgMembers .. "[" .. (i + 5) .. "] : " .. eTeamNames[i][1] .. "{nl}";
    end
    
    --指定した番号の相手の情報が無い場合は終了
    if #eTeamNames < num then
      local msg = "[TBL enemy who?]指定された番号 [" .. (num + 5) .. "] の相手メンバーは存在しないか取得できていません";
      CHAT_SYSTEM(msg .. msgMembers);
      return;
    end
    
    ui.Chat("/memberinfo " .. eTeamNames[num][1]);
    
  end
  
end

----------------------------------------------------------------
----------------------------------------------------------------
--イベント処理用
----------------------------------------------------------------
----------------------------------------------------------------

function TBLEW_MAIN_ON_AFTER_RELOADPUBGAME()
  --公開ゲームリストの取得
  TBLEW_REQ_PUB_LIST();
  
  --メイン処理を呼ぶ
  TBLEW_MAIN();
end
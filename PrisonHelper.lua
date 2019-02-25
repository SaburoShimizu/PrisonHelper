local errr, SE = pcall(require, 'lib.samp.events')
assert(errr, 'Library SAMP Events not found')

local errr, inicfg = pcall(require,  'inicfg')
assert(errr, 'Library INI cfg not found')

local res = pcall(require, "lib.moonloader")
assert(res, 'Library lib.moonloader not found')

local errr, sf = pcall(require, 'sampfuncs')
assert(errr, 'Library Sampfuncs not found')

local errr, rkeys = pcall(require, 'rkeys')
assert(errr, 'Library rKeys not found')

local errr, vkeys = pcall(require, 'vkeys')
assert(errr, 'Library vKeys not found')

local lanes = require('lanes').configure()
local errr, encoding = pcall(require, 'encoding')
assert(errr, 'Library Encoding not found')

local errr, imgui = pcall(require, 'imgui')
assert(errr, 'Library Imgui not found')

local errr, imadd = pcall(require, 'imgui_addons')
assert(errr, 'Library Imgui Addons not found')

local errr, pie = pcall(require, 'imgui_piemenu2')
assert(errr, 'Library Pie Menu not found')

local errr, notf = pcall(import, 'imgui_notf.lua')
assert(errr, 'Library Imgui Notification not found')

encoding.default = 'CP1251'
u8 = encoding.UTF8


script_name('Way_Of_Life_Helper')
script_version('2.0.2')
script_author('Saburo Shimizu')



picups = {
	['Clotch'] = 58, -- Пикап магазина одежды
    avtosalon = {
		[1] = 92, -- Пикап магазина одежды
		[2] = 91, -- Пикап магазина одежды
        [3] = 90, -- Пикап магазина одежды
    },
}

getgunses = {
  [1] = 100, -- LSPD
  [2] = 99, -- FBI
  [3] = 28, -- SWAT
  [4] = 37, -- ВВС
  [5] = 57, -- Army LV
  [6] = 56, -- Army SF
  [7] = 218, -- Meria
  [8] = 225 -- Pra-vo
}





dhelp = [[{FF7000}/wolgun - {d5dedd}Взять оружие с любого места
{FF7000}/getjob - {d5dedd}Взять пикап с трудоустройством с любого места
{FF7000}/swatgun - {d5dedd}Автоматически взять оружие
{FF7000}/getstat - {d5dedd}Принудительная проверка статистики
{FF7000}/wolhelp - {d5dedd}Помощь по скрипту
{FF7000}/wolreload - {d5dedd}Перезагрузка скрипта
{FF7000}/wolmenu - {d5dedd}Меню скрипта
{FF7000}/woltp - {d5dedd}Меню с телепортами
{FF7000}/tpfind - {d5dedd}Телепорт к игроку


{FF0000} Дополнительные настройки в INI файле]]


-- INI FILES

local inicfg = require 'inicfg'


-- INI FILES

local default = {
  WOL = {
    org = true;
    autogun = true;
    mvd = true;
    gun = 140;
    aupd = true;
    wolpass = 0;
    wolalogin = false;
  }
}

local restore = {
  WOL = {
    org = true;
    autogun = true;
    mvd = true;
    gun = 140;
    aupd = true;
    wolpass = 0;
    wolalogin = false;
  }
}

local ini = inicfg.load(default, 'Way_Of_Life_Helper.ini')

wol = ini.WOL


local tpfindresult = false
local teg = '{FF0000}[WolHelper] {FFFFFF}'
local sw, sh = getScreenResolution()
local orgs = nil
local getstat = false
local swatgun = false
local naambs = 0

imgui.Process = false
local btn_size = imgui.ImVec2(-0.1, 0)
local scriptmenu = imgui.ImBool(false)
local imguifaq = imgui.ImBool(false)
local tporg = imgui.ImBool(false)
local picupsimgui = imgui.ImBool(false)

local imguiautogun = imgui.ImBool(wol.autogun)
local imguimvd = imgui.ImBool(wol.mvd)
local imguiaupd = imgui.ImBool(wol.aupd)
local imguiaulog = imgui.ImBool(wol.wolalogin)
local imguiautoinv = imgui.ImBool(wol.org)
local imguipass = imgui.ImBuffer(256)
imguipass.v = wol.wolpass






function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  local ip = sampGetCurrentServerAddress()

  if ip:find('176.32.36.103') or ip:find('176.32.39.159') then activ = true sampAddChatMessage('{FF0000}AutoInvite {FFFFFF}для {00FF00}Way Of Life и After Life {01A0E9}загружен', - 1) sampAddChatMessage(teg ..'/wolhelp - команды скрипта. Версия скрипта: {d5dedd}' ..thisScript().version, - 1) sampAddChatMessage(teg ..'Если ваша статистика не была проверена автоматически введите {FF7000}/getstat', -1) if wol.mvd then if script.find('MVDhelper Era') then script.find('MVDhelper Era'):unload() end end else thisScript():unload() end

  if aupd == true then apdeit() end
  imgui.ShowCursor = scriptmenu.v or imguifaq.v or tporg.v or picupsimgui.v
  imgui.Process = true
  sampRegisterChatCommand('swatgun', function(nambs) if #nambs ~= 0 and nambs ~= ' ' then naambs = nambs swatgun = true else sampAddChatMessage(teg ..'Вы введи неправильно команду. {FF7000}/swatgun [0-1]', -1) end end)
  sampRegisterChatCommand('wolgun', function() sampSendPickedUpPickup(getgunses[orgs]) end)
  sampRegisterChatCommand('getjob', function() sampSendPickedUpPickup(168) end)
  sampRegisterChatCommand('getstat', function() getstat = true sampSendChat('/mm') end)
  sampRegisterChatCommand('wolhelp', function() sampShowDialog(132131, 'WOL Help', dhelp, 'Ok!', _, 0) end)
  sampRegisterChatCommand('wolreload', function() thisScript():reload() end)
  sampRegisterChatCommand('wolmenu', function() scriptmenu.v = true end)
  sampRegisterChatCommand('woltp', function() tporg.v = true end)
  sampRegisterChatCommand('tpfind', function(res) sampSendChat('/find '..res) tpfindresult = true end)

  if not doesFileExist('moonloader\\config\\Way_Of_Life_Helper.ini') then inicfg.save(default, 'Way_Of_Life_Helper.ini') sampAddChatMessage(teg ..'Ini файл был создан.', - 1) end

  while true do
    -- LOAD PARAMS
    wol = ini.WOL
    aupd = wol.aupd
    adownload = wol.adownload
    org = wol.org
    hide = wol.hide
    autogun = wol.autogun
    mvd = wol.mvd
    gun = wol.gun
    wolpass = wol.wolpass
    wolalogin = wol.wolalogin
    wait(0)
  end
end

function checkmenu()
	local my_dialoges = {
		{
			title = string.format('My stat: %s', stat and 'Вкл' or 'Выкл')
		}
	}
end

function menu()
	checkmenu()
	submenus_show(my_dialoges, 'Ebat', 'Ok', 'Ne ok!', 'Nozad')
	if stat == false then stat = true else stat = false end
end


function pickupid(model)
  local poolPtr = sampGetPickupPoolPtr()
  local ptwo = readMemory(poolPtr, 4, 0)
  if ptwo > 0 then
    ptwo = poolPtr + 0x4
    local pthree = poolPtr + 0xF004
    for id = 1, 4096 do
      local pfive = readMemory(ptwo + id * 4, 4, false)
      if pfive < 0 or pfive > 0 then
        pfive = readMemory(pthree + id * 20, 4, false)
        if pfive == 353 then
          return id
        end
      end
    end
  end
end



function getorg(orges)
  if orges:find('LSPD') then return 1 end
  if orges:find('FBI') then return 2 end
  if orges:find('S.W.A.T') then return 3 end
  if orges:find('ВВС') then return 4 end
  if orges:find('Army LV') then return 5 end
  if orges:find('Army SF') then return 6 end
  if orges:find('Мэрия') then return 7 end
  if orges:find('Правительство') then return 8 end
end



function SE.onServerMessage(color, text)
  if text:find('.+Вы успешно авторизовались!') then getstat = true sampSendChat('/mm') end
end

function SE.onShowDialog(dialogId, style, title, button1, button2, text)

  if wolalogin == true then
    if title == '{AEFFFF}Авторизация' then
      if text:find('.+Попыток: %d+ из %d+.+') then
        sampAddChatMessage(teg ..'Вы ввели неправильно пароль. Для смены пароля введите /wolpass', - 1)
      else
        sampSendDialogResponse(dialogId, 1, - 1, wolpass)
      end
    end
  end

  if activ then
    if title == '{FFFFFF}RolePlay Тест | Вопрос {FFC100}№1' then sampSendDialogResponse(dialogId, 1, - 1, '2') end
    if title == '{FFFFFF}RolePlay Тест | Вопрос {FFC100}№2' then sampSendDialogResponse(dialogId, 1, - 1, '4') end
    if title == '{FFFFFF}RolePlay Тест | Вопрос {FFC100}№3' then sampSendDialogResponse(dialogId, 1, - 1, '1') end
    if title == '{FFFFFF}RolePlay Тест | Вопрос {FFC100}№4' then sampSendDialogResponse(dialogId, 1, - 1, '1') end
    if title == '{FFFFFF}RolePlay Тест | Вопрос {FFC100}№5' then sampSendDialogResponse(dialogId, 1, - 1, '3') end
    if title == '{FFFFFF}RolePlay Тест | Вопрос {FFC100}№6' then sampSendDialogResponse(dialogId, 1, - 1, '2') end
    if title == '{FFFFFF}RolePlay Тест | Вопрос {FFC100}№7' then sampSendDialogResponse(dialogId, 1, - 1, '4') lua_thread.create(function() wait(500) getstat = true sampSendChat('/mm') end) end
  end

  if getstat == true then
    if title:find('{AEFFFF}Игровой уровень: %d+ | Очки опыта: %d+ из %d+') then
      sampSendDialogResponse(5051, 1, 0, _)
      return false
    end
    if title:find('{33AA33}Статистика игрового аккаунта:{ffffff} .+') then
      warn = text:match('.+(%d+)/.+Уровень Преступлений:.+')
      orges = text:match('.+Организация:.+%{ffffff}(.+)Ранг:.+')
      orgs = getorg(orges)
      getstat = false
      if warn ~= '0' then sampAddChatMessage(teg ..'Ваша организация: '..orges, -1) sampAddChatMessage(teg ..'На вашем аккаунте имеется {FF7000}' ..warn ..' {FFFFFF}варн(а). Рекомендуем снять для избежания бана!', - 1) return false
      else
        sampAddChatMessage(teg ..'Ваш аккаунт чист. Ваша организация: '..orges ..'.', -1)
				return false
      end
    end
  end

  if swatgun == true then
    if title == 'Комплекты « SWAT » San Andreas' then for i = 0, gun * 4 do sampSendDialogResponse(dialogId, tonumber(naambs), -1, -1) end swatgun = false end
  end

  if autogun == true and title:find('Набор.+') and dialogId == 5051 then
    sampSendDialogResponse(dialogId, 1, 0, 1)
    for i = 0, gun do
      sampSendDialogResponse(dialogId, 1, 3, 1)
      sampSendDialogResponse(dialogId, 1, 4, 1)
      sampSendDialogResponse(dialogId, 1, 5, 1)
      sampSendDialogResponse(dialogId, 1, 6, 1)
    end
  end
end

--ОБНОВА

function apdeit()
    async_http_request('GET', 'https://raw.githubusercontent.com/SaburoShimizu/WOL/master/WOLVER', nil --[[параметры запроса]],
        function(resp) -- вызовется при успешном выполнении и получении ответа
			local suk = resp.text
            newvers = suk:match('Version = (.+), URL.+') if newvers > thisScript().version then sampAddChatMessage(teg ..'Обнаружено обновление до v.{FF0000}'..newvers ..'{01A0E9}. Для обновления используйте /wolmenu', - 1) elseif newvers == thisScript().version then sampAddChatMessage(teg..'У вас актуальная версия скрипта.', - 1) elseif newvers < thisScript().version then sampAddChatMessage(teg..'У вас тестовая версия скрипта.', - 1) end
            print('Проверка обновления')
        end,
        function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
            print(err)
            sampAddChatMessage(teg ..'Ошибка поиска версии. Попробуйте позже.', - 1)
    end)
end



function updates()
    async_http_request('GET', 'https://raw.githubusercontent.com/SaburoShimizu/WOL/master/WolHelper.lua', nil --[[параметры запроса]],
        function(respe) -- вызовется при успешном выполнении и получении ответа
            if #respe.text > 0 then
                f = io.open(getWorkingDirectory() ..'/WolHelper.lua', 'wb')
                f:write(u8:decode(respe.text))
                f:close()
                sampAddChatMessage(teg ..'Обновление успешно скачалось. Скрипт перезапуститься автоматически', - 1)
                thisScript():reload()
            else
                sampAddChatMessage(teg ..'Ошибка обновления. Попробуйте позже', - 3)
            end
            print('Установка обновления скрипта')
        end,
        function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
            print(err)
            sampAddChatMessage(teg ..'Ошибка обновления. Попробуйте позже.', - 1)
    end)
end

function imgui.OnDrawFrame()
	imgui.ShowCursor = scriptmenu.v or imguifaq.v or tporg.v or picupsimgui.v
    if scriptmenu.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Настройки WolHelper', scriptmenu, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.MenuBar)
        if imgui.BeginMenuBar() then
            if imgui.BeginMenu(u8'Меню скрипта') then
                if imgui.MenuItem(u8'Перезагрузить') then
					showCursor(false, false)
                    thisScript():reload()
                end
                if imgui.MenuItem(u8'Выключить') then
					showCursor(false, false)
                    thisScript():unload()
                end
                imgui.EndMenu()
            end
            if imgui.BeginMenu(u8'Обновление') then
                if imgui.MenuItem(u8'Проверка обновления') then
                    apdeit()
                end
                if imgui.MenuItem(u8'Принудительно обновиться') then
                    updates()
                end
                imgui.EndMenu()
            end
            if imgui.BeginMenu(u8'Функции') then
                if imgui.MenuItem(u8'ТП меню') then
                    tporg.v = true
					scriptmenu.v = false
                end
                if imgui.MenuItem(u8'Меню пикапов') then
					picupsimgui.v = true
					scriptmenu.v = false
                end
                if imgui.MenuItem(u8'Взять оружие') then
					if orgs ~= nil then sampSendPickedUpPickup(getgunses[orgs]) else sampAddChatMessage(teg ..'Организация не определена', -1) end
					scriptmenu.v = false
                end
                if imgui.MenuItem(u8'Трудоустройство') then
					sampSendPickedUpPickup(168)
					scriptmenu.v = false
                end
                if imgui.MenuItem(u8'Проверка статистики') then
					getstat = true sampSendChat('/mm')
                end
                imgui.EndMenu()
            end
            if imgui.BeginMenu('F.A.Q') then
                if imgui.MenuItem(u8'Показать F.A.Q') then
                    imguifaq.v = true
                    scriptmenu.v = false
                end
                imgui.EndMenu()
            end
            imgui.EndMenuBar()
			imgui.Text(u8'Автоматическое обновление')
			imgui.SameLine(365)
	        imadd.ToggleButton('ainv##6', imguiaupd)
			wol.aupd = imguiaupd.v
			imgui.Text(u8'Автоинвайт')
			imgui.SameLine(365)
	        imadd.ToggleButton('ainv##6', imguiautoinv)
			wol.org = imguiautoinv.v
			imgui.Text(u8'Автоган')
			imgui.SameLine(365)
	        imadd.ToggleButton('autogun##6', imguiautogun)
			wol.autogun = imguiautogun.v
			imgui.Text(u8'Выключать MVD helper')
			imgui.SameLine(365)
	        imadd.ToggleButton('mvd##6', imguimvd)
			wol.mvd = imguimvd.v
			imgui.Text(u8'Автологин')
			imgui.SameLine(365)
	        imadd.ToggleButton('alogin##6', imguiaulog)
			wol.wolalogin = imguiaulog.v
			if imguiaulog.v then
				imgui.InputText(u8'Введите пароль', imguipass)
				imgui.Text(u8'Текущий пароль: '..wol.wolpass)
				wol.wolpass = u8:decode(imguipass.v)
			end
			imgui.Spacing()
			imgui.Separator()
			imgui.Spacing()
			if imgui.MenuItem(u8'Сохранить настройки в INI') then inicfg.save(default, 'Way_Of_Life_Helper.ini') sampAddChatMessage(teg ..'Настройки сохранены', -1) end
			if imgui.MenuItem(u8'Сбросить настройки INI') then inicfg.save(restore, 'Way_Of_Life_Helper.ini') sampAddChatMessage(teg ..'Настройки сброшены', -1) end
        end
        imgui.End()
    end
    if imguifaq.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'F.A.Q', imguifaq, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoSavedSettings)
        imgui.CenterTextColoredRGB(dhelp)
		if isKeyJustPressed(0x1B) or isKeyJustPressed(0x08) or isKeyJustPressed(0x0D) then imguifaq.v = false end
        imgui.End()
    end
	if tporg.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        --imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'ТП меню', tporg, imgui.WindowFlags.AlwaysAutoResize)
		if isCharInAnyCar(PLAYER_PED) then
			if imgui.CollapsingHeader(u8'ТП (с авто)') then
				if imgui.MenuItem(u8'Мэрия') then setCharCoordinates(PLAYER_PED, 1476, -1708, 14) tporg.v = false end
			end
		end
		if imgui.CollapsingHeader(u8'ТП в организации') then
			if imgui.MenuItem(u8'LSPD') then sampSendPickedUpPickup(103) tporg.v = false end
			if imgui.MenuItem(u8'Мэрия') then sampSendPickedUpPickup(198) tporg.v = false end
			if imgui.MenuItem(u8'Мэрия (сзади)') then sampSendPickedUpPickup(200) tporg.v = false end
			if imgui.MenuItem(u8'Правительство') then sampSendPickedUpPickup(212) tporg.v = false end
			if imgui.MenuItem(u8'S.W.A.T') then sampSendPickedUpPickup(24) tporg.v = false end
			if imgui.MenuItem(u8'FBI') then sampSendPickedUpPickup(181) tporg.v = false end
			if imgui.MenuItem(u8'SFPD') then sampSendPickedUpPickup(112) tporg.v = false end
			if imgui.MenuItem(u8'СВ (Склад)') then sampSendPickedUpPickup(223) tporg.v = false end
			if imgui.MenuItem(u8'ВВС (Склад)') then sampSendPickedUpPickup(35) tporg.v = false end
			if imgui.MenuItem(u8'ВВС (Штаб)') then sampSendPickedUpPickup(38) tporg.v = false end
			if imgui.MenuItem(u8'ВВС (Казарма)') then sampSendPickedUpPickup(32) tporg.v = false end
			if imgui.MenuItem(u8'LVPD') then sampSendPickedUpPickup(172) tporg.v = false end
			if imgui.MenuItem(u8'LCN') then sampSendPickedUpPickup(183) tporg.v = false end
			if imgui.MenuItem(u8'RM') then sampSendPickedUpPickup(184) tporg.v = false end
			if imgui.MenuItem(u8'Yakuza') then sampSendPickedUpPickup(179) tporg.v = false end
			if imgui.MenuItem(u8'Hitmans (В инте нельзя)') then setCharCoordinates(PLAYER_PED, -2240, 2351, 5) tporg.v = false end
		end
		if imgui.CollapsingHeader(u8'ТП из организации') then
			if imgui.MenuItem(u8'LSPD') then sampSendPickedUpPickup(104) tporg.v = false end
			if imgui.MenuItem(u8'Мэрия') then sampSendPickedUpPickup(201) tporg.v = false end
			if imgui.MenuItem(u8'Мэрия (сзади)') then sampSendPickedUpPickup(199) tporg.v = false end
			if imgui.MenuItem(u8'Правительство') then sampSendPickedUpPickup(213) tporg.v = false end
			if imgui.MenuItem(u8'S.W.A.T') then sampSendPickedUpPickup(25) tporg.v = false end
			if imgui.MenuItem(u8'FBI') then sampSendPickedUpPickup(180) tporg.v = false end
			if imgui.MenuItem(u8'SFPD') then sampSendPickedUpPickup(111) tporg.v = false end
			if imgui.MenuItem(u8'СВ (Склад)') then sampSendPickedUpPickup(224) tporg.v = false end
			if imgui.MenuItem(u8'ВВС (Склад)') then sampSendPickedUpPickup(36) tporg.v = false end
			if imgui.MenuItem(u8'ВВС (Штаб)') then sampSendPickedUpPickup(39) tporg.v = false end
			if imgui.MenuItem(u8'ВВС (Казарма)') then sampSendPickedUpPickup(33) tporg.v = false end
			if imgui.MenuItem(u8'LVPD') then sampSendPickedUpPickup(173) tporg.v = false end
			if imgui.MenuItem(u8'LCN') then sampSendPickedUpPickup(182) tporg.v = false end
			if imgui.MenuItem(u8'RM') then sampSendPickedUpPickup(177) tporg.v = false end
			if imgui.MenuItem(u8'Yakuza') then sampSendPickedUpPickup(178) tporg.v = false end
		end
		if imgui.CollapsingHeader(u8'ТП по метке') then
			local result, posX, posY, posZ = getTargetBlipCoordinates()
			local positionX, positionY, positionZ = getCharCoordinates(PLAYER_PED)
			if result then
				imgui.Text(u8(string.format('Координаты метки: %d, %d, %d', posX, posY, posZ)))
				if imgui.MenuItem(u8'Телепортироваться по метке') then
					local result, posX, posY, posZ = getTargetBlipCoordinatesFixed()
					setCharCoordinates(PLAYER_PED, posX, posY, posZ)
				end
		 	else
				imgui.Text(u8'Ошибка! Метка не стоит на карте') end
			imgui.Text(u8(string.format('Ваши координаты: %d, %d, %d', positionX, positionY, positionZ)))
		end
		imgui.End()
	end
	if picupsimgui.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        --imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Меню пикапов', picupsimgui, imgui.WindowFlags.AlwaysAutoResize)
		if imgui.MenuItem(u8'Смена скина') then sampSendPickedUpPickup(picups['Clotch']) picupsimgui.v = false end
		if imgui.CollapsingHeader(u8'Автосалоны') then
			if imgui.MenuItem(u8'Автосалон A класса (SF)') then sampSendPickedUpPickup(picups.avtosalon[1]) picupsimgui.v = false end
			if imgui.MenuItem(u8'Автосалон B класса (SF)') then sampSendPickedUpPickup(picups.avtosalon[2]) picupsimgui.v = false end
			if imgui.MenuItem(u8'Автосалон Nope класса (LS)') then sampSendPickedUpPickup(picups.avtosalon[3]) picupsimgui.v = false end
		end
		if imgui.CollapsingHeader(u8'Взять ган') then
			if imgui.MenuItem(u8'LSPD') then sampSendPickedUpPickup(getgunses[1]) picupsimgui.v = false end
			if imgui.MenuItem(u8'FBI') then sampSendPickedUpPickup(getgunses[2]) picupsimgui.v = false end
			if imgui.MenuItem(u8'SWAT') then sampSendPickedUpPickup(getgunses[3]) picupsimgui.v = false end
			if imgui.MenuItem(u8'ВВС') then sampSendPickedUpPickup(getgunses[4]) picupsimgui.v = false end
			if imgui.MenuItem(u8'Army LV') then sampSendPickedUpPickup(getgunses[5]) picupsimgui.v = false end
			if imgui.MenuItem(u8'Army SF') then sampSendPickedUpPickup(getgunses[6]) picupsimgui.v = false end
			if imgui.MenuItem(u8'Мэрия') then sampSendPickedUpPickup(getgunses[7]) picupsimgui.v = false end
			if imgui.MenuItem(u8'Правительство') then sampSendPickedUpPickup(getgunses[8]) picupsimgui.v = false end
		end
		imgui.End()
	end
end


function SE.onSetCheckpoint(position, radius)
    --if tpfindresult and position.z < 50 then print(string.format('X: %d, Y: %d, Z: %d', position.x, position.y, position.z)) end
    if tpfindresult and position.z < 500 then
        setCharCoordinates(PLAYER_PED, position.x, position.y, position.z)
        print(string.format('X: %d, Y: %d, Z: %d', position.x, position.y, position.z))
        tpfindresult = false
    elseif tpfindresult and position.z > 500 then
        sampAddChatMessage(teg ..'Возможно игрок находится в инте. Нажмите {FF7000}Y{FFFFFF} для продолжения или {FF7000}N{FFFFFF} для отклонения', - 1)
        rkeys.registerHotKey({vkeys.VK_Y}, true, function() setCharCoordinates(PLAYER_PED, position.x, position.y, position.z)
            print(string.format('X: %d, Y: %d, Z: %d', position.x, position.y, position.z))
            rkeys.unRegisterHotKey({vkeys.VK_Y})
        rkeys.unRegisterHotKey({vkeys.VK_N}) end)
        rkeys.registerHotKey({vkeys.VK_N}, true, function()
            sampAddChatMessage(teg ..'Отклонено', - 1)
            rkeys.unRegisterHotKey({vkeys.VK_Y})
        rkeys.unRegisterHotKey({vkeys.VK_N}) end)
        tpfindresult = false
    end
end




















































function ShowHelpMarker(text)
	imgui.SameLine()
    imgui.TextDisabled("(?)")
    if (imgui.IsItemHovered()) then
        imgui.SetTooltip(u8(text))
    end
end



local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end



function async_http_request(method, url, args, resolve, reject)
	local request_lane = lanes.gen('*', {package = {path = package.path, cpath = package.cpath}}, function()
		local requests = require 'requests'
		local ok, result = pcall(requests.request, method, url, args)
		if ok then
			result.json, result.xml = nil, nil -- cannot be passed through a lane
			return true, result
		else
			return false, result -- return error
		end
	end)
	if not reject then reject = function() end end
	lua_thread.create(function()
		local lh = request_lane()
		while true do
			local status = lh.status
			if status == 'done' then
				local ok, result = lh[1], lh[2]
				if ok then resolve(result) else reject(result) end
				return
			elseif status == 'error' then
				return reject(lh[1])
			elseif status == 'killed' or status == 'cancelled' then
				return reject(status)
			end
			wait(0)
		end
	end)
end



function getTargetBlipCoordinatesFixed()
    local bool, x, y, z = getTargetBlipCoordinates(); if not bool then return false end
    requestCollision(x, y); loadScene(x, y, z)
    local bool, x, y, z = getTargetBlipCoordinates()
    return bool, x, y, z
end


function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

apply_custom_style()

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


script_author('Saburo Shimizu')
script_version('1.5.0')
script_properties("work-in-pause")



--test = imgui.ImBool(true)

local btn_size = imgui.ImVec2(-0.1, 0)

local offsendchat = nil
local offfastmenuchat = nil
local sw, sh = getScreenResolution()
local rep = false
local fftt = false
local prisontime = false
local URL = nil
local systime = 0
local aupd = nil
local teg = '{FF7000}[PrisonHelper] {01A0E9}'
local fcolor = '{01A0E9}'
local stupd = false
local prisonpedid = nil
local prisonpedname = nil
local paydayinformer = lua_thread.create_suspended(function() pdinf() end)


default = {
    prison = {
        hour = 0,
        fasttime = true,
        aupd = true,
        fastmenu = false,
        paydayhelp = false,
        grafiktime = false,
        astoverlay = false,
		Xovers = 500,
		Yovers = 500,
		mouse = true
    }
}

local ini = inicfg.load(default, 'PrisonHelper.ini')

pris = ini.prison
fasttime = pris.fasttime
hour = pris.hour
aupd = pris.aupd
grafiktime = pris.grafiktime
fastmenu = pris.fastmenu
InfoX = pris.Xovers
InfoY = pris.Yovers



imgui.Process = false
grafeks = imgui.ImBool(false)
prishelp = imgui.ImBool(false)
imguilec = imgui.ImBool(false)
fastmenus = imgui.ImBool(false)
prisonmenu = imgui.ImBool(false)
jbsuka = imgui.ImBuffer(256)



local raspchat = imgui.ImBool(fasttime)
local overllay = imgui.ImBool(pris.astoverlay)
local mish = imgui.ImBool(pris.mouse)
local grafintime = imgui.ImBool(pris.grafiktime)
local nappayday = imgui.ImBool(pris.paydayhelp)
local fastmennu = imgui.ImBool(pris.fastmenu)
local avtoobnova = imgui.ImBool(pris.aupd)



rasp = [[		{FF0000}Понедельник - Пятница

{FF7000}07:00 - 09:00 - {d5dedd}Подъем, завтрак и уборка камер
{FF7000}09:00 - 10:00 - {d5dedd}Свободное время
{FF7000}10:00 - 12:00 - {d5dedd}Готовка еды и уборка двора
{FF7000}12:00 - 13:00 - {d5dedd}Обед
{FF7000}13:00 - 14:00 - {d5dedd}Свободное время
{FF7000}14:00 - 16:00 - {d5dedd}Готовка еды и уборка двора
{FF7000}16:00 - 17:00 - {d5dedd}Тренировка в зале
{FF7000}17:00 - 18:00 - {d5dedd}Ужин
{FF7000}18:00 - 19:00 - {d5dedd}Свободное время
{FF7000}19:00 - 20:00 - {d5dedd}Уборка всей тюрьмы
{FF7000}20:00 - 07:00 - {d5dedd}Отбой

		{FF0000}Суббота - Воскресенье

{FF7000}07:00 - 09:00 {d5dedd}- Подъем, завтрак и уборка камер
{FF7000}09:00 - 10:00 {d5dedd}- Свободное время
{FF7000}10:00 - 13:00 {d5dedd}- Готовка еды и уборка двора
{FF7000}13:00 - 14:00 {d5dedd}- Обед
{FF7000}14:00 - 15:00 {d5dedd}- Свободное время
{FF7000}15:00 - 17:00 {d5dedd}- Готовка еды и уборка двора
{FF7000}17:00 - 19:00 {d5dedd}- Тренировка в зале
{FF7000}19:00 - 20:00 {d5dedd}- Ужин
{FF7000}20:00 - 21:00 {d5dedd}- Свободное время
{FF7000}21:00 - 22:00 {d5dedd}- Уборка всей тюрьмы
{FF7000}22:00 - 07:00 {d5dedd}- Отбой

{FF0000}Закрыть окно: Backspace, Enter, ESC]]

ph = [[{FF7000}/jd{d5dedd} - открыть/закрыть камеру (jaildoor)
{FF7000}/panel{d5dedd} - РП открыть панель управления камерамаи/двором
{FF7000}/prisonreload{d5dedd} - Перезагружает скрипт
{FF7000}/cam{d5dedd} - РП просмотр камер
{FF7000}/prisonsettime{d5dedd} - Настройка времени скрипта
{FF7000}/уведомления{d5dedd} - Отключить/включить уведомления о графике (сохраняется в ini файле)
{FF7000}/prisonoverlay{d5dedd} - Включить/выключить оверлей (без сохранения в INI)
{FF7000}/prisonoverlaypos{d5dedd} - Настройка позиции оверлея (Требуется перезапуск после ввода)
{FF7000}/prisonmenu{d5dedd} - Настройки скрипта
{01A0E9}Весь функционал скрипта находится в Быстром Меню (ПКМ + G)

{FF0000}Закрыть окно: Backspace, Enter, ESC]]



function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
	if sampGetCurrentServerName('SA-MP') then local start = false while start == false do wait(0) if sampGetCurrentServerName() ~= 'SA-MP' then start = true end end end
	wait(5000)
	if sampGetCurrentServerName():find('Advance.+') or sampGetCurrentServerName():find('.+Advance.+') then print('Идёт загрузка скрипта.') else print('Скрипт не предназначен для данного сервера') print(sampGetCurrentServerName()) thisScript():unload() end
    if aupd == true then apdeit() end
    -- register commands
    sampRegisterChatCommand("jd", jd)
	sampRegisterChatCommand("график", function() grafeks.v = not grafeks.v end)
	sampRegisterChatCommand("prisonhelp", function() prishelp.v = not prishelp.v end)
	sampRegisterChatCommand("режим", function() imguilec.v = not imguilec.v end)
	sampRegisterChatCommand("prisonoverlay", overlaysuka)
	sampRegisterChatCommand("prisonoverlaypos", overlaypos)
    sampRegisterChatCommand("prisonreload", reloader)
    sampRegisterChatCommand("prisonupdate", updates)
    sampRegisterChatCommand("prisonver", apdeit)
    sampRegisterChatCommand("cam", cam)
    sampRegisterChatCommand("panel", panel)
    sampRegisterChatCommand('prisonmenu', function() prisonmenu.v = not prisonmenu.v end)
    sampRegisterChatCommand("уведомления", function() sampAddChatMessage(fasttime and 'Уведомления выключены. Для включения введите {FF7000}/уведомления' or 'Уведомления включены. Для выключения введите {FF7000}/уведомления', 0x01A0E9) pris.fasttime = not pris.fasttime inicfg.save(default, 'PrisonHelper') end)
    sampRegisterChatCommand("prisonsetime", function() prisontime = true sampSendChat('/c 60') end)


    sampAddChatMessage(teg..'Успешно загружен. Версия: {ff7000}' ..thisScript().version, - 1)
	imgui.Process = true
	print('Скрипт успешно загружен.')

    if pris.fasttime == true then lua_thread.create(napominalka) sampAddChatMessage(teg ..'Уведомления графика тюрьмы {00FF00}включены', - 1) end
    if pris.grafiktime == true then sampAddChatMessage(teg ..'Уведомления графика тюрьмы в /c 60 {00FF00}включены', - 1) end
    if pris.paydayhelp == true and paydayinformer:status() == 'suspended' or paydayinformer:status() == 'dead' then paydayinformer:run() end

if pris.fastmenu then
    rkeys.registerHotKey({vkeys.VK_RBUTTON, vkeys.VK_G}, true, function ()
        local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        if result then local res, id = sampGetPlayerIdByCharHandle(ped); if res then name = sampGetPlayerNickname(id) prisonpedid, prisonpedname = id, name; fastmenus.v = true end end
    end)
end

rkeys.registerHotKey({vkeys.VK_MENU, vkeys.VK_OEM_5}, true, function()
	if offsendchat ~= nil then offsendchat:terminate() sampAddChatMessage(teg ..'Зачитка лекции остановлена', - 1) offsendchat = nil end
	if offfastmenuchat ~= nil then offfastmenuchat:terminate() sampAddChatMessage(teg ..'Работа биндера остановлена', - 1) offfastmenuchat = nil end
end)

    while true do
        wait(0)
        local ini = inicfg.load(default, 'PrisonHelper.ini')
        pris = ini.prison
        fasttime = pris.fasttime
        -- Загрузка времени
        local dt = os.date("*t"); systime = dt.hour dt.hour = dt.hour - pris.hour
        local dt = os.date("*t", os.time(dt))
    end
end

function warnotm(id)
    sampSendChat('Так! Пытаемся взломать замок?')
    wait(500)
    sampSendChat('Я это заберу.')
    wait(500)
    sampSendChat('/me забрал у заключённого отмычку')
    wait(500)
    sampSendChat('/jaildoor')
    wait(250)
    sampSendChat('/jaildoor')
    wait(1000)
    sampSendChat('/do Отмычка в руке.')
    wait(1000)
    sampSendChat('/me убрал отмычку в карман')
    wait(1000)
    sampSendChat('/do Отмычка в кармане.')
    wait(1000)
    sampSendChat('Зключённый №' ..id ..', Вам вынесено камерное предупреждение за попытку взлома замка.')
    wait(2000)
    sampSendChat('При последующих попытках я буду вынужден надеть на Вас наручники.')
    pluswarn(id)
    --wait(100)
    --sampSendChat('В данный момент у вас ' ..checkwarn(sampGetPlayerNickname(id)) ..' предупреждений')
end

function otm()
    sampSendChat('Так! Пытаемся взломать замок?')
    wait(500)
    sampSendChat('Я это заберу.')
    wait(500)
    sampSendChat('/me забрал у заключённого отмычку')
    wait(500)
    sampSendChat('/jaildoor')
    wait(250)
    sampSendChat('/jaildoor')
    wait(1000)
    sampSendChat('/do Отмычка в руке.')
    wait(1000)
    sampSendChat('/me убрал отмычку в карман')
    wait(1000)
    sampSendChat('/do Отмычка в кармане.')
    wait(2000)
    sampSendChat('/n /key в наручниках - Non RP.')
end

function jd()
    lua_thread.create(function()
        sampSendChat('/me протянулся к поясному держателю, затем достал ключ от камеры')
        wait(250)
        sampSendChat('/me открыл/закрыл камеру, затем повесил ключ назад')
        sampSendChat('/jaildoor')
    end)
end

function cam()
    sampSendChat('/me подошёл к панели и начал смотреть в мониторы')
    sampSendChat('/jailcam')
end

function panel()
    sampSendChat('/me подошёл к панели и нажал на кнопку открытия/закрытия камер на пульте')
    sampSendChat('/jaildoor')
end

function reloader()
    lua_thread.create(function()
        sampAddChatMessage('PrisonHelper {01A0E9}будет перезагружен через 1 секунду.', 0xFF7000)
        wait(1000)
        showCursor(false, false)
        script.this:reload()
    end)
end

function reshotka(id)
    sampSendChat('Заключённый №'..id ..'.')
    wait(1000)
    sampSendChat('Вам вынесено камерное предупреждение за то, что вы гремите решёткой камеры.')
    wait(1000)
    sampSendChat('При последующем выносе предупреждения я буду вынужден надеть на Вас наручники.')
    wait(1000)
    sampSendChat('/n По РП с наручниками за спиной ты не можешь бить по решётке. Если замечу - залью ЖБ за NonRP.')
    pluswarn(id)
    --wait(1000)
    --sampSendChat('В данный момент у вас ' ..checkwarn(sampGetPlayerNickname(id)) ..' предупреждений')
end

function uncuff(id)
    sampSendChat('/do Наручники на человеке.')
    wait(1000)
    sampSendChat('/me просунул руку через решётку')
    wait(1000)
    sampSendChat('/me расстегнул наручники')
    wait(1000)
    sampSendChat('/uncuff ' ..id)
    wait(1000)
    sampSendChat('/me высунул руки из решётки')
    wait(1000)
    sampSendChat('/me повесил наручники на пояс')
end

function cuff(id)
    sampSendChat('/do На поясном держателе висят наручники.')
    wait(1000)
    sampSendChat('/me снял наручники с поясного держателя')
    wait(1000)
    sampSendChat('/me просунул руки через решётку')
    wait(1000)
    sampSendChat('/me надел наручники на руки преступника и застегнул их')
    wait(1000)
    sampSendChat('/cuff ' ..id)
    wait(1000)
    sampSendChat('/me высунул руки из решётки')
end

function warn(id)
    sampSendChat('Здравствуйте, заключённый №' ..id..'.')
    wait(1000 )
    sampSendChat('Вам вынесено предупреждение за нарушение внутреннего порядка.')
    wait(1000)
    sampSendChat('/me достав КПК из кармана штанов, ввёл логин и пароль в базе данных')
    wait(1000)
    sampSendChat('/me зашёл в раздел "предупреждения заключённых"')
    wait(1000)
    sampSendChat('/me ввёл номер заключённого, стоящего напротив, затем выдал предупреждение')
    wait(1000)
    sampSendChat('/do Предупреждение выдано.')
    wait(1000)
    sampSendChat('/me убрал КПК в карман')
    pluswarn(id)
    --wait(1000)
    --sampSendChat('В данный момент у вас ' ..checkwarn(sampGetPlayerNickname(id)) ..' предупреждений')
end

function unwarn(id)
    sampSendChat('Заключённый №'..id..', я снимаю с Вас последнее выданное предупреждение.')
    wait(1000)
    sampSendChat('Но это не значит, что я не выдам его снова, если Вы будете нарушать режим.')
    wait(1000)
    sampSendChat('/me достав КПК из кармана штанов, ввёл логин и пароль в базе данных')
    wait(1000)
    sampSendChat('/me зашёл в раздел "предупреждения заключённых"')
    wait(1000)
    sampSendChat('/me ввёл номер заключённого, стоящего напротив, затем удалил предупреждение')
    wait(1000)
    sampSendChat('/do Предупреждение удалено.')
    wait(1000)
    sampSendChat('/me убрал КПК в карман')
    minuswarn(id, sampGetPlayerNickname(id))
end

function unwarnall(id)
    sampSendChat('Заключённый №'..id..', я снимаю с Вас последние выданные предупреждения.')
    wait(1000 )
    sampSendChat('Но это не значит, что я не выдам его снова, если Вы будете нарушать режим.')
    wait(1000 )
    sampSendChat('/me достав КПК из кармана штанов, ввёл логин и пароль в базе данных')
    wait(1000 )
    sampSendChat('/me зашёл в раздел "предупреждения заключённых"')
    wait(1000 )
    sampSendChat('/me ввёл номер заключённого, стоящего напротив, затем удалил предупреждения')
    wait(1000 )
    sampSendChat('/do Предупреждения удалены.')
    wait(1000 )
    sampSendChat('/me убрал КПК в карман')
    minusallwarn(id, sampGetPlayerNickname(id))
end

function privet(id)
    sampSendChat('Здравствуйте, заключённый №' ..id..'.')
    wait(2000)
    sampSendChat('Чем я могу Вам помочь?')
end

function stol(id)
    sampSendChat('Заключённый №' ..id ..', немедленно слезьте со стола!')
    wait(1000)
    sampSendChat('В противном случае я буду вынужден применить резиновую дубинку или резиновые пули!')
end

function stoladv()
    sampSendChat('Товарищ адвокат. Прошу Вас слезть со стола.')
    wait(1000)
    sampSendChat('В противном случае я буду вынужден заставить Вас сделать это.')
end

function kpz(id)
    sampSendChat('Заключённый №' ..id ..', Вы посажены в одиночную камеру без шанса на выход.')
    wait(1000)
    sampSendChat('Если же Вы попытаетесь взломать замок, я надену на Вас наручники.')
end

function kpzvrem(id)
    sampSendChat('Заключённый №' ..id ..', Вы посажены в одиночную камеру на две минуты.')
    wait(1000)
    sampSendChat('Если же Вы попытаетесь взломать замок - я продлю время вашего нахождения в камере.')
    wait(1000)
    sampSendChat('Или же надену на Вас наручники, если и это не поможет.')
    wait(1000)
    sampSendChat('/do Наручники на человеке.')
    wait(1000)
    sampSendChat('/me просунул руку через решётку')
    wait(1000)
    sampSendChat('/me расстегнул наручники')
    wait(1000)
    sampSendChat('/uncuff ' ..id)
    wait(1000)
    sampSendChat('/me высунул руки из решётки')
    wait(1000)
    sampSendChat('/me повесил наручники на пояс')
end

function kpzkon(id)
    sampSendChat('Заключённый №' ..id ..', время Вашего нахождения в одиночной камере подошло к концу.')
    wait(1000)
    sampSendChat('/me протянулся к поясному держателю, затем достал ключ от камеры')
    wait(250)
    sampSendChat('/me открыл/закрыл камеру, затем повесил ключ назад')
    sampSendChat('/jaildoor')
    wait(1000)
    sampSendChat('Можете выходить из камеры, но больше не нарушайте.')
    minuswarn(id, sampGetPlayerNickname(id))
end

function vremnach()
    sampSendChat('/s Внимание, заключённые. Сейчас будет объявлено свободное время.')
    wait(6000)
    sampSendChat('/s Прошу всех заключённых выйти из камер после их открытия.')
    wait(6000)
    sampSendChat('/s Напоминаю: любое нарушение внутреннего режима будет пресекаться...')
    wait(6000)
    sampSendChat('/s ...грубой физической силой. Охрана тюрьмы вправе использовать...')
    wait(6000)
    sampSendChat('/s ...резиновые дубинки или резиновые пули для сохранения режима тюрьмы.')
    wait(6000)
    sampSendChat('/s Помните: относитесь к людям хорошо, и они ответят Вам тем же.')
    wait(6000)
    sampSendChat('/s Спасибо.')
end

function vremkon()
    sampSendChat('/s Внимание, заключённые. Свободное время подошло к концу.')
    wait(6000)
    sampSendChat('/s Прошу всех заключённых разойтись по камерам, соблюдая внутренний режим тюрьмы.')
    wait(6000)
    sampSendChat('/s Напоминаю: любое нарушение внутреннего режима будет пресекаться...')
    wait(6000)
    sampSendChat('/s ...грубой физической силой. Охрана тюрьмы вправе использовать...')
    wait(6000)
    sampSendChat('/s ...резиновые дубинки или резиновые пули для сохранения режима тюрьмы.')
    wait(6000)
    sampSendChat('/s Помните: относитесь к людям хорошо, и они ответят Вам тем же.')
    wait(6000)
    sampSendChat('/s Спасибо.')
end

function sportnach()
    sampSendChat('/s Внимание, заключённые. Сейчас объявлено занятие спортом в спортзале.')
    wait(6000)
    sampSendChat('/s Прошу всех заключёных пройти в спортзал.')
    wait(6000)
    sampSendChat('/s Напоминаю: любое нарушение внутреннего режима будет пресекаться... ')
    wait(6000)
    sampSendChat('/s ...грубой физической силой. Охрана тюрьмы вправе использовать... ')
    wait(6000)
    sampSendChat('/s ...резиновые дубинки или резиновые пули для сохранения режима тюрьмы. ')
    wait(6000)
    sampSendChat('/s Помните: относитесь к людям хорошо, и они ответят Вам тем же. ')
    wait(6000)
    sampSendChat('/s Спасибо. ')
end

function sportkon()
    sampSendChat('/s Внимание, заключённые. Занятие спортом в спортзале подошло к концу.')
    wait(6000)
    sampSendChat('/s Прошу всех заключённых пройти на кухню для готовки ужина.')
    wait(6000)
    sampSendChat('/s Напоминаю: любое нарушение внутреннего режима будет пресекаться... ')
    wait(6000)
    sampSendChat('/s ...грубой физической силой. Охрана тюрьмы вправе использовать... ')
    wait(6000)
    sampSendChat('/s ...резиновые дубинки или резиновые пули для сохранения режима тюрьмы. ')
    wait(6000)
    sampSendChat('/s Помните: относитесь к людям хорошо, и они ответят Вам тем же. ')
    wait(6000)
    sampSendChat('/s Спасибо.')
end

function ubornach(vib)
    if vib == 0 then sampSendChat('/s Внимание, заключённые. Объявлено время уборки двора и готовки еды.') elseif vib == 1 then sampSendChat('/s Внимание, заключённые. Объявлено время уборки двора.') end
    wait(6000)
		if vib == 0 then sampSendChat('/s Прошу всех заключённых пройти либо на кухню, либо во внутренний двор.') elseif vib == 1 then sampSendChat('/s Прошу всех заключённых пройти во внутренний двор.') end
    wait(6000)
    sampSendChat('/s Напоминаю: любое нарушение внутреннего режима будет пресекаться... ')
    wait(6000)
    sampSendChat('/s ...грубой физической силой. Охрана тюрьмы вправе использовать... ')
    wait(6000)
    sampSendChat('/s ...резиновые дубинки или резиновые пули для сохранения режима тюрьмы. ')
    wait(6000)
    sampSendChat('/s Помните: относитесь к людям хорошо, и они ответят Вам тем же. ')
    wait(6000)
    sampSendChat('/s Спасибо.')
end

function uborkon(vib)
    if vib == 0 then sampSendChat('/s Внимание, заключённые. Время уборки и готовки еды подошло к концу.') elseif vib == 1 then sampSendChat('Внимание, заключённые. Время уборки подошло к концу.') end
    wait(6000)
    sampSendChat('/s Прошу всех заключённых пройти на кухню для обеда.')
    wait(6000)
    sampSendChat('/s Напоминаю: любое нарушение внутреннего режима будет пресекаться... ')
    wait(6000)
    sampSendChat('/s ...грубой физической силой. Охрана тюрьмы вправе использовать... ')
    wait(6000)
    sampSendChat('/s ...резиновые дубинки или резиновые пули для сохранения режима тюрьмы. ')
    wait(6000)
    sampSendChat('/s Помните: относитесь к людям хорошо, и они ответят Вам тем же. ')
    wait(6000)
    sampSendChat('/s Спасибо.')
end

function uzhinnach()
    sampSendChat('/s Внимание, заключённые. Сейчас объявлено время готовки ужина.')
    wait(6000)
    sampSendChat('/s Прошу всех заключённых пройти на кухню для готовки ужина.')
    wait(6000)
    sampSendChat('/s Напоминаю: любое нарушение внутреннего режима будет пресекаться... ')
    wait(6000)
    sampSendChat('/s ...грубой физической силой. Охрана тюрьмы вправе использовать... ')
    wait(6000)
    sampSendChat('/s ...резиновые дубинки или резиновые пули для сохранения режима тюрьмы. ')
    wait(6000)
    sampSendChat('/s Помните: относитесь к людям хорошо, и они ответят Вам тем же. ')
    wait(6000)
    sampSendChat('/s Спасибо.')
end

function uzhinkon()
    sampSendChat('/s Внимание, заключённые. Время ужина подошло к концу. Объявлено свободное время.')
    wait(6000)
    sampSendChat('/s Прошу всех заключённых заняться своими делами. Вы можете быть везде кроме внутреннего двора.')
    wait(6000)
    sampSendChat('/s Напоминаю: любое нарушение внутреннего режима будет пресекаться... ')
    wait(6000)
    sampSendChat('/s ...грубой физической силой. Охрана тюрьмы вправе использовать... ')
    wait(6000)
    sampSendChat('/s ...резиновые дубинки или резиновые пули для сохранения режима тюрьмы. ')
    wait(6000)
    sampSendChat('/s Помните: относитесь к людям хорошо, и они ответят Вам тем же. ')
    wait(6000)
    sampSendChat('/s Спасибо.')
end

function obednach()
    sampSendChat('/s Внимание, заключённые. Объявлено время обеда.')
    wait(6000)
    sampSendChat('/s Прошу всех заключённых пройти на кухню для готовки обеда.')
    wait(6000)
    sampSendChat('/s Напоминаю: любое нарушение внутреннего режима будет пресекаться... ')
    wait(6000)
    sampSendChat('/s ...грубой физической силой. Охрана тюрьмы вправе использовать... ')
    wait(6000)
    sampSendChat('/s ...резиновые дубинки или резиновые пули для сохранения режима тюрьмы. ')
    wait(6000)
    sampSendChat('/s Помните: относитесь к людям хорошо, и они ответят Вам тем же. ')
    wait(6000)
    sampSendChat('/s Спасибо.')
end

function obedkon()
    sampSendChat('/s Внимание, заключённые. Объявлено свободное время.')
    wait(6000)
    sampSendChat('/s Прошу всех заключённых заняться своими делами. Вы можете быть везде кроме внутреннего двора.')
    wait(6000)
    sampSendChat('/s Напоминаю: любое нарушение внутреннего режима будет пресекаться... ')
    wait(6000)
    sampSendChat('/s ...грубой физической силой. Охрана тюрьмы вправе использовать... ')
    wait(6000)
    sampSendChat('/s ...резиновые дубинки или резиновые пули для сохранения режима тюрьмы. ')
    wait(6000)
    sampSendChat('/s Помните: относитесь к людям хорошо, и они ответят Вам тем же. ')
    wait(6000)
    sampSendChat('/s Спасибо.')
end

function SendReport(args)
    lua_thread.create(function()
        rep = true
        sampSendChat('/mn')
        sampSendDialogResponse(27, 1, 5, - 1)
        sampSendDialogResponse(80, 1, - 1, args)
        wait(1200)
        rep = false
    end)
end

function SendReportDialog(id, name, args)
	lua_thread.create(function()
		rep = true
		sampSendChat('/mn')
		sampSendDialogResponse(27, 1, 5, - 1)
		sampSendDialogResponse(80, 1, - 1, name..'['..id..'] '..args)
		wait(1200)
		rep = false
	end)
end


function SE.onShowDialog(dialogId, style, title, button1, button2, text)
  if prisontime == true then
    if text:find('.+Текущее время:.+%{3399FF}%d+:%d+.+') then dtime = text:match('.+Текущее время.+%{3399FF}(%d+):%d+.+') pris.hour = systime - dtime inicfg.save(default, 'PrisonHelper')
      sampAddChatMessage('Время сохранено. Время от МСК: {FF7000}' ..pris.hour, 0x01A0E9)
    end
  end
  if title:find('.+Точное время') and pris.grafiktime then graf = grafiktimes() sampAddChatMessage(graf, 0x01A0E9) end
  if dialogId == 80 and rep == true -- РЕПОРТ
  then return false
  end

  if dialogId == 27 and rep == true -- РЕПОРТ
  then return false
  end
end




function apdeit()
    async_http_request('GET', 'https://raw.githubusercontent.com/SaburoShimizu/PrisonHelper/master/PrisonHelperVer', nil --[[параметры запроса]],
        function(resp) -- вызовется при успешном выполнении и получении ответа
            newvers = resp.text:match('Version = (.+), URL.+') if newvers > thisScript().version then sampAddChatMessage(teg ..'Обнаружено обновление до v.{FF0000}'..newvers ..'{01A0E9}. Для обновления используйте /prisonmenu', - 1) elseif newvers == thisScript().version then sampAddChatMessage(teg..'У вас актуальная версия скрипта.', - 1) elseif newvers < thisScript().version then sampAddChatMessage(teg..'У вас тестовая версия скрипта.', - 1) end
            print('Проверка обновления')
        end,
        function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
            print(err)
            sampAddChatMessage(teg ..'Ошибка поиска версии. Попробуйте позже.', - 1)
    end)
end



function updates()
    async_http_request('GET', 'https://raw.githubusercontent.com/SaburoShimizu/PrisonHelper/master/PrisonHelper.lua', nil --[[параметры запроса]],
        function(respe) -- вызовется при успешном выполнении и получении ответа
            if #respe.text > 0 then
                f = io.open(getWorkingDirectory() ..'/PrisonHelper.lua', 'wb')
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



function checkwarn(name)
	if varns[name] ~= nil then return varns[name] else return 0 end
end

function pdinf()
	sampAddChatMessage(teg..'Напоминание о PayDay: {00FF00}включено', -1)
	while true do wait(0)
		dt = os.date('*t'); dt.min = dt.min; dt.sec = dt.sec
		if dt.min == 55 and dt.sec == 10 then sampAddChatMessage('[TimeInChat] {D5DEDD}До PayDay осталось 5 минут. Не выходите в АФК', 0x01A0E9) wait(1000) end
		if dt.min == 59 and dt.sec == 10 then sampAddChatMessage('[TimeInChat] {D5DEDD}До PayDay осталась 1 минута. Не выходите в АФК', 0x01A0E9) wait(1000) end
	end
end

function pluswarn(id)
	id = tonumber(id)
	local name = sampGetPlayerNickname(id)
	if varns[name] ~= nil then varns[name] = varns[name] + 1 else varns[name] = 1 end
	checkwarn(name)
	notf.addNotification(string.format('Выдано предупреждение заключённому\n\nНик: %s[%d]\nПредупреждения: %d', name, id, varns[name]), 8)
end

function minuswarn(id, name)
	if varns[name] ~= nil and varns[name] > 0 then varns[name] = varns[name] - 1 else varns[name] = nil end
	checkwarn(name)
	notf.addNotification(string.format('Снято предупреждение заключённого\n\nНик: %s[%d]\nПредупреждения: %d', name, id, varns[name]), 8)
end

function minusallwarn(id, name)
	if varns[name] ~= nil and varns[name] > 0 then varns[name] = 0 else varns[name] = nil end
	checkwarn(name)
	notf.addNotification(string.format('Сняты все предупреждения\nзаключённого\n\nНик: %s[%d]\nПредупреждения: %d', name, id, varns[name]), 8)
end

varns = {}

function overlaysuka()
	pris.astoverlay = not pris.astoverlay
	sampAddChatMessage(string.format('%s %s',teg, pris.astoverlay and 'Оверлей включён' or 'Оверлей выключен'), -1)
end


function overlaypos()
    lua_thread.create(function()
        sampAddChatMessage(teg ..'Для применения нажмите {FF7000}Enter', - 1)
        robotet = true
		showCursor(true, true)
		while robotet == true do
            wait(0)
            InfoX, InfoY = getCursorPos()
            if isKeyDown(VK_RETURN) then robotet = false end
        end
		wait(500)
		pris.Xovers = InfoX
		pris.Yovers = InfoY
		inicfg.save(default, 'PrisonHelper')
		showCursor(false, false)
        print('X: '..InfoX ..' Y: '..InfoY)
		imgui.Process = false
		imgui.Process = true
    end)
end


function imgui.OnDrawFrame()
    if pris.mouse then
        imgui.ShowCursor = not pris.astoverlay or grafeks.v or prishelp.v or imguilec.v or prisonmenu.v or fastmenus.v
    else
        imgui.ShowCursor = not pris.astoverlay and not grafeks.v and not prishelp.v or imguilec.v or prisonmenu.v or fastmenus.v
    end


    if prisonmenu.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Настройки PrisonHelper', prisonmenu, imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.AlwaysAutoResize)
        imgui.Text(u8'Расписание в чате') ShowHelpMarker('Показывает график по расписанию в чате')
        imgui.SameLine(365)
        imadd.ToggleButton('raspchat##1', raspchat)
        pris.fasttime = raspchat.v
        imgui.Text(u8'Оверлей') ShowHelpMarker('Показывает график и время')
        imgui.SameLine(365)
        imadd.ToggleButton('Overlay##2', overllay)
        pris.astoverlay = overllay.v
        imgui.Text(u8'Мышка в /график и /prisonhelp') ShowHelpMarker('В /prisonhelp и /график будет\nактивироваться мышка')
        imgui.SameLine(365)
        imadd.ToggleButton('mish##3', mish)
        pris.mouse = mish.v
        imgui.Text(u8'Уведомления графика в /c 60') ShowHelpMarker('При вводе /c 60 будет выводиться график в чат')
        imgui.SameLine(365)
        imadd.ToggleButton('grafintime##4', grafintime)
        pris.grafiktime = grafintime.v
        imgui.Text(u8'Напоминание о PayDay') ShowHelpMarker('За 5 и за 1 минуту будет сообщение о PayDay')
        imgui.SameLine(365)
        imadd.ToggleButton('nappayday##5', nappayday)
        pris.paydayhelp = nappayday.v
        imgui.Text(u8'Быстрое меню (ПКМ + G)') ShowHelpMarker('Меню взаимодействия с игроком.')
        imgui.SameLine(365)
        imadd.ToggleButton('fastmennu##6', fastmennu)
        pris.fastmenu = fastmennu.v
        if imgui.Button(u8'Информация о скрипте', btn_size) then prisonmenu.v = false; prishelp.v = true end
        if imgui.Button(u8'Автонастройка времени', btn_size) then prisontime = true; sampSendChat('/c 60') end
        if imgui.Button(u8'Сохранить в INI файл', btn_size) then inicfg.save(default, 'PrisonHelper') sampAddChatMessage(teg ..'Все настройки сохранены в INI файл', - 1) end
        if imgui.Button(u8'Перезапустить скрипт', btn_size) then sampAddChatMessage(teg ..'Началась перезагрузка. Скрипт запустится через {FF7000}5 сек.', - 1) prisonmenu.v = false showCursor(false, false) thisScript():reload() end
        imgui.Text('\n')
        if imgui.CollapsingHeader(u8'Обновление. Текущая версия скрипта: '..thisScript().version) then
            imgui.Text(u8'Автообновление скрипта') ShowHelpMarker('При запуске игры будет поиск обновлений скрипта')
            imgui.SameLine(365)
            imadd.ToggleButton('avtoobnova##6', avtoobnova)
            pris.aupd = avtoobnova.v
            if imgui.MenuItem(u8'Проверить версию') then apdeit() end
            if imgui.MenuItem(u8'Принудительно обновить') then updates() end
            if imgui.MenuItem(u8'Сохранить в INI') then inicfg.save(default, 'PrisonHelper') sampAddChatMessage(teg ..'Все настройки сохранены в INI файл', - 1) end
        end
        imgui.End()
    end


    if pris.astoverlay then
        --imgui.ShowCursor = false
        imgui.SetNextWindowPos(imgui.ImVec2(InfoX, InfoY), _, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(220, 52), imgui.Cond.FirstUseEver)
        imgui.Begin('Overlay', _, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.AlwaysAutoResize)
        --imgui.ShowCursor = false
        grafek = grafiktimesoverlay()
        imgui.Text(u8(grafek)) -- простой текст внутри этого окна
        imgui.Text(u8('Время: ' ..os.date('%H:%M:%S'))) -- простой текст внутри этого окна
        imgui.End() -- конец окна
    end


    if pris.fastmenu then
        if fastmenus.v then
			local id, name = prisonpedid, prisonpedname
            imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
            imgui.Begin(u8(string.format('%s[%d] Преды: %d', name, id, checkwarn(name))), fastmenus, imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.AlwaysAutoResize)
            if imgui.CollapsingHeader(u8'Обычные (Без команд)') then
                if imgui.MenuItem(u8'Привет') then offfastmenuchat = lua_thread.create(function() privet(id) end) fastmenus.v = false end
                if imgui.MenuItem(u8'Предупреждение') then offfastmenuchat = lua_thread.create(function() warn(id) end) fastmenus.v = false end
                if imgui.MenuItem(u8'Снять предупреждение') then offfastmenuchat = lua_thread.create(function() unwarn(id) end) fastmenus.v = false end
                if imgui.MenuItem(u8'Снять все предупреждения') then offfastmenuchat = lua_thread.create(function() unwarnall(id) end) fastmenus.v = false end
                if imgui.MenuItem(u8'Отмычка') then offfastmenuchat = lua_thread.create(function() otm(id) end) fastmenus.v = false end
                if imgui.MenuItem(u8'Отмычка (Предупреждение)') then offfastmenuchat = lua_thread.create(function() warnotm(id) end) fastmenus.v = false end
                if imgui.MenuItem(u8'Решётка (Предупреждение)') then offfastmenuchat = lua_thread.create(function() reshotka(id) end) fastmenus.v = false end
                if imgui.MenuItem(u8'Стол') then offfastmenuchat = lua_thread.create(function() stol(id) end) fastmenus.v = false end
                if imgui.MenuItem(u8'Стол (Адвокат)') then offfastmenuchat = lua_thread.create(function() stoladv(id) end) fastmenus.v = false end
            end
            if imgui.CollapsingHeader(u8'Команды') then
                if imgui.MenuItem('/cuff') then offfastmenuchat = lua_thread.create(function() cuff(id) end) fastmenus.v = false end
                if imgui.MenuItem('/uncuff') then offfastmenuchat = lua_thread.create(function() uncuff(id) end) fastmenus.v = false end
                if imgui.MenuItem('/hold') then sampProcessChatInput('/hold '..id) fastmenus.v = false end
                if imgui.MenuItem('/jd') then offfastmenuchat = lua_thread.create(function() jd() end) fastmenus.v = false end
            end
            if imgui.CollapsingHeader(u8'КПЗ') then
                if imgui.MenuItem(u8'КПЗ') then offfastmenuchat = lua_thread.create(function() kpz(id) end) fastmenus.v = false end
                if imgui.MenuItem(u8'КПЗ - врем') then offfastmenuchat = lua_thread.create(function() kpzvrem(id) end) fastmenus.v = false end
                if imgui.MenuItem(u8'КПЗ - кон') then offfastmenuchat = lua_thread.create(function() kpzvrem(id) end) fastmenus.v = false end
            end
            if imgui.CollapsingHeader(u8'Быстрый репорт (Нон рп)') then
                if imgui.MenuItem(u8'ДМ КПЗ') then SendReport(string.format('%s[%d] ДМит в КПЗ', name, id)) fastmenus.v = false end
                if imgui.MenuItem(u8'Сбивы анимаций') then SendReport(string.format('%s[%d] сбивает анимации в КПЗ', name, id)) fastmenus.v = false end
                if imgui.MenuItem(u8'АФК от /hold') then SendReport(string.format('%s[%d] AFK от /hold', name, id)) fastmenus.v = false end
                if imgui.MenuItem(u8'Нон РП анимации') then SendReport(string.format('%s[%d] НРП анимации', name, id)) fastmenus.v = false end
                if imgui.MenuItem(u8'Нон РП поведение') then SendReport(string.format('%s[%d] НРП поведение', name, id)) fastmenus.v = false end
            end
            if imgui.CollapsingHeader(u8'Быстрый репорт (Чат)') then
                if imgui.MenuItem(u8'Оскорбления / маты') then SendReport(string.format('%s[%d] оск + маты', name, id)) fastmenus.v = false end
                if imgui.MenuItem(u8'Флуд') then SendReport(string.format('%s[%d] флуд', name, id)) fastmenus.v = false end
                if imgui.MenuItem(u8'НРП /me') then SendReport(string.format('%s[%d] НРП /me', name, id)) fastmenus.v = false end
            end
            if imgui.CollapsingHeader(u8'Быстрый репорт (Своя причина)') then
				imgui.Text(u8'Вводите только причину жалобы.')
				imgui.Text(u8'Ник и ID будут автоматически отправлены.\n')
				imgui.InputText(u8'Введите текст жалобы', jbsuka)
				imgui.Text(name..'['..id..'] '..jbsuka.v)
				if imgui.MenuItem(u8'Отправить жалобу (x2 Enter)') then if #jbsuka.v >1 and jbsuka.v ~= '' and jbsuka.v ~= ' ' and jbsuka.v ~= '  ' then sampAddChatMessage(jbsuka.v, -1) else sampAddChatMessage(teg..'Вы ничего не ввели', -1) end end --SendReportDialog(id, name, u8:decode(jbsuka.v)) jbsuka.v = nil fastmenus.v = false end
				if isKeyJustPressed(VK_RETURN) then SendReportDialog(id, name, u8:decode(jbsuka.v)) jbsuka.v = nil fastmenus.v = false end
			end
            imgui.End()
        end
    end


    if grafeks.v then
        if isKeyJustPressed(0x1B) or isKeyJustPressed(0x08) or isKeyJustPressed(0x0D) then grafeks.v = false end
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'График тюрьмы', grafeks, imgui.WindowFlags.NoSavedSettings)
        imgui.CenterTextColoredRGB(rasp)
        imgui.End()
    end

    if prishelp.v then
        if isKeyJustPressed(0x1B) or isKeyJustPressed(0x08) or isKeyJustPressed(0x0D) then prishelp.v = false end
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(530, 450), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Помощь по PrisonHelper', prishelp, imgui.WindowFlags.NoSavedSettings)
        imgui.CenterTextColoredRGB(ph)
        imgui.End()
    end


    if imguilec.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'[PrisonHelper] Лекции для заключённых', imguilec, imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.AlwaysAutoResize)
        if imgui.CollapsingHeader(u8'1. Время') then
            if imgui.MenuItem(u8'Время начало', btn_size) then offsendchat = lua_thread.create(function() vremnach() end) imguilec.v = false end
            if imgui.MenuItem(u8'Время конец', btn_size) then offsendchat = lua_thread.create(function() vremkon() end) imguilec.v = false end
        end
        if imgui.CollapsingHeader(u8'2. Уборка') then
            if imgui.MenuItem(u8'Уборка и завтрак начало', btn_size) then offsendchat = lua_thread.create(function() ubornach(0) end) imguilec.v = false end
            if imgui.MenuItem(u8'Уборка и завтрак конец', btn_size) then offsendchat = lua_thread.create(function() uborkon(0) end) imguilec.v = false end
            if imgui.MenuItem(u8'Уборка всей тюрьмы начало', btn_size) then offsendchat = lua_thread.create(function() ubornach(1) end) imguilec.v = false end
            if imgui.MenuItem(u8'Уборка всей тюрьмы конец', btn_size) then offsendchat = lua_thread.create(function() uborkon(1) end) imguilec.v = false end
        end
        if imgui.CollapsingHeader(u8'3. Спортзал') then
            if imgui.MenuItem(u8'Спорзал начало', btn_size) then offsendchat = lua_thread.create(function() sportnach() end) imguilec.v = false end
            if imgui.MenuItem(u8'Спорзал конец', btn_size) then offsendchat = lua_thread.create(function() sportkon() end) imguilec.v = false end
        end
        if imgui.CollapsingHeader(u8'4. Ужин') then
            if imgui.MenuItem(u8'Ужин начало', btn_size) then offsendchat = lua_thread.create(function() uzhinnach() end) imguilec.v = false end
            if imgui.MenuItem(u8'Ужин конец', btn_size) then offsendchat = lua_thread.create(function() uzhinkon() end) imguilec.v = false end
        end
        if imgui.CollapsingHeader(u8'5. Обед') then
            if imgui.MenuItem(u8'Обед начало', btn_size) then offsendchat = lua_thread.create(function() obednach() end) imguilec.v = false end
            if imgui.MenuItem(u8'Обед конец', btn_size) then offsendchat = lua_thread.create(function() obedkon() end) imguilec.v = false end
        end
        imgui.End()
    end
end






































function ShowHelpMarker(text)
	imgui.SameLine()
    imgui.TextDisabled("(?)")
    if (imgui.IsItemHovered()) then
        imgui.SetTooltip(u8(text))
    end
end


function napominalka()
	while true do wait(0)
		local dt = os.date("*t"); systime = dt.hour dt.hour = dt.hour - pris.hour
		local dt = os.date("*t", os.time(dt))
		-- Напоминание о расписании КПЗ
		if dt.wday == 1 or dt.wday == 7 then -- Суббота - Воскресенье
			if dt.hour == 22 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Отбой', 0x01A0E9) wait(1000) end
			if dt.hour == 7 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Подъем, завтрак и уборка камер', 0x01A0E9) wait(1000) end
			if dt.hour == 9 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Свободное время', 0x01A0E9) wait(1000) end
			if dt.hour == 10 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Готовка еды и уборка двора', 0x01A0E9) wait(1000) end
			if dt.hour == 13 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Обед', 0x01A0E9) wait(1000) end
			if dt.hour == 14 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Свободное время', 0x01A0E9) wait(1000) end
			if dt.hour == 15 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Уборка двора и готовка еды', 0x01A0E9) wait(1000) end
			if dt.hour == 17 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Тренировка в зале', 0x01A0E9) wait(1000) end
			if dt.hour == 19 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Ужин', 0x01A0E9) wait(1000) end
			if dt.hour == 20 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Свободное время', 0x01A0E9) wait(1000) end
			if dt.hour == 21 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Уборка всей тюрьмы', 0x01A0E9) wait(1000) end
		elseif dt.wday > 1 and dt.wday < 7 then -- Понедельник - Пятница
			if dt.hour == 20 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Отбой. Разогнать по камерам', 0x01A0E9) wait(1000) end
			if dt.hour == 7 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Подъем, завтрак и уборка камер', 0x01A0E9) wait(1000) end
			if dt.hour == 9 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Свободное время', 0x01A0E9) wait(1000) end
			if dt.hour == 10 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Готовка еды и уборка двора', 0x01A0E9) wait(1000) end
			if dt.hour == 12 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Обед', 0x01A0E9) wait(1000) end
			if dt.hour == 13 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Свободное время', 0x01A0E9) wait(1000) end
			if dt.hour == 14 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Уборка двора и готовка еды', 0x01A0E9) wait(1000) end
			if dt.hour == 16 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Тренировка в зале', 0x01A0E9) wait(1000) end
			if dt.hour == 17 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Ужин', 0x01A0E9) wait(1000) end
			if dt.hour == 18 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Свободное время', 0x01A0E9) wait(1000) end
			if dt.hour == 19 and dt.min == 1 and dt.sec == 1 then sampAddChatMessage('[Расписание] {d5dedd}Уборка всей тюрьмы', 0x01A0E9) wait(1000) end
		end
	end
end


function grafiktimes()
	local dt = os.date("*t"); systime = dt.hour dt.hour = dt.hour - pris.hour
	local dt = os.date("*t", os.time(dt))
	-- Напоминание о расписании КПЗ
	if dt.wday == 1 or dt.wday == 7 then -- Суббота - Воскресенье
		if dt.hour >= 22 and dt.hour <= 6 then graf = '[Расписание] {d5dedd}Отбой' return graf end
		if dt.hour >= 7 and dt.hour <= 8 then graf = '[Расписание] {d5dedd}Подъем, завтрак и уборка камер' return graf end
		if dt.hour == 9 then graf = '[Расписание] {d5dedd}Свободное время' return graf end
		if dt.hour >= 10 and dt.hour <= 12 then graf = '[Расписание] {d5dedd}Готовка еды и уборка двора' return graf end
		if dt.hour == 13 then graf = '[Расписание] {d5dedd}Обед' return graf end
		if dt.hour == 14 then graf = '[Расписание] {d5dedd}Свободное время' return graf end
		if dt.hour >= 15 and dt.hour <= 16 then  graf = '[Расписание] {d5dedd}Уборка двора и готовка еды' return graf end
		if dt.hour >= 17 and dt.hour <= 18 then graf = '[Расписание] {d5dedd}Тренировка в зале' return graf end
		if dt.hour == 19 then graf = '[Расписание] {d5dedd}Ужин' return graf end
		if dt.hour == 20 then graf = '[Расписание] {d5dedd}Свободное время' return graf end
		if dt.hour == 21 then graf = '[Расписание] {d5dedd}Уборка всей тюрьмы' return graf end
	elseif dt.wday > 1 and dt.wday < 7 then -- Понедельник - Пятница
		if dt.hour >= 20 and dt.hour <= 6 then graf = '[Расписание] {d5dedd}Отбой. Разогнать по камерам' return graf end
		if dt.hour >= 7 and dt.hour <= 8 then graf = '[Расписание] {d5dedd}Подъем, завтрак и уборка камер' return graf end
		if dt.hour == 9 then graf = '[Расписание] {d5dedd}Свободное время' return graf end
		if dt.hour >= 10 and dt.hour <= 11 then graf = '[Расписание] {d5dedd}Готовка еды и уборка двора' return graf end
		if dt.hour == 12 then graf = '[Расписание] {d5dedd}Обед' return graf end
		if dt.hour == 13 then graf = '[Расписание] {d5dedd}Свободное время' return graf end
		if dt.hour >= 14 and dt.hour <= 15 then graf = '[Расписание] {d5dedd}Уборка двора и готовка еды' return graf end
		if dt.hour == 16 then graf = '[Расписание] {d5dedd}Тренировка в зале' return graf end
		if dt.hour == 17 then graf = '[Расписание] {d5dedd}Ужин' return graf end
		if dt.hour == 18 then graf = '[Расписание] {d5dedd}Свободное время' return graf end
		if dt.hour >= 19 and dt.hour < 22 then graf = '[Расписание] {d5dedd}Уборка всей тюрьмы' return graf end
	end
end

function grafiktimesoverlay()
	local dt = os.date("*t"); systime = dt.hour dt.hour = dt.hour - pris.hour
	local dt = os.date("*t", os.time(dt))
	-- Напоминание о расписании КПЗ
	if dt.wday == 1 or dt.wday == 7 then -- Суббота - Воскресенье
		if dt.hour >= 22 and dt.hour <= 6 then graf = 'Отбой' return graf end
		if dt.hour >= 7 and dt.hour <= 8 then graf = 'Подъем, завтрак и уборка камер' return graf end
		if dt.hour == 9 then graf = 'Свободное время' return graf end
		if dt.hour >= 10 and dt.hour <= 12 then graf = 'Готовка еды и уборка двора' return graf end
		if dt.hour == 13 then graf = 'Обед' return graf end
		if dt.hour == 14 then graf = 'Свободное время' return graf end
		if dt.hour >= 15 and dt.hour <= 16 then  graf = 'Уборка двора и готовка еды' return graf end
		if dt.hour >= 17 and dt.hour <= 18 then graf = 'Тренировка в зале' return graf end
		if dt.hour == 19 then graf = 'Ужин' return graf end
		if dt.hour == 20 then graf = 'Свободное время' return graf end
		if dt.hour == 21 then graf = 'Уборка всей тюрьмы' return graf end
	elseif dt.wday > 1 and dt.wday < 7 then -- Понедельник - Пятница
		if dt.hour >= 20 and dt.hour <= 6 then graf = 'Отбой. Разогнать по камерам' return graf end
		if dt.hour >= 7 and dt.hour <= 8 then graf = 'Подъем, завтрак и уборка камер' return graf end
		if dt.hour == 9 then graf = 'Свободное время' return graf end
		if dt.hour >= 10 and dt.hour <= 11 then graf = 'Готовка еды и уборка двора' return graf end
		if dt.hour == 12 then graf = 'Обед' return graf end
		if dt.hour == 13 then graf = 'Свободное время' return graf end
		if dt.hour >= 14 and dt.hour <= 15 then graf = 'Уборка двора и готовка еды' return graf end
		if dt.hour == 16 then graf = 'Тренировка в зале' return graf end
		if dt.hour == 17 then graf = 'Ужин' return graf end
		if dt.hour == 18 then graf = 'Свободное время' return graf end
		if dt.hour >= 19 and dt.hour < 22 then graf = 'Уборка всей тюрьмы' return graf end
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


function submenus_show(menu, caption, select_button, close_button, back_button)
	select_button, close_button, back_button = select_button or 'Select', close_button or 'Close', back_button or 'Back'
	prev_menus = {}
	function display(menu, id, caption)
		local string_list = {}
		for i, v in ipairs(menu) do
			table.insert(string_list, type(v.submenu) == 'table' and v.title .. '  >>' or v.title)
		end
		sampShowDialog(id, caption, table.concat(string_list, '\n'), select_button, (#prev_menus > 0) and back_button or close_button, sf.DIALOG_STYLE_LIST)
		repeat
			wait(0)
			local result, button, list = sampHasDialogRespond(id)
			if result then
				if button == 1 and list ~= -1 then
					local item = menu[list + 1]
					if type(item.submenu) == 'table' then -- submenu
						table.insert(prev_menus, {menu = menu, caption = caption})
						if type(item.onclick) == 'function' then
							item.onclick(menu, list + 1, item.submenu)
						end
						return display(item.submenu, id + 1, item.submenu.title and item.submenu.title or item.title)
					elseif type(item.onclick) == 'function' then
						local result = item.onclick(menu, list + 1)
						if not result then return result end
						return display(menu, id, caption)
					end
				else -- if button == 0
					if #prev_menus > 0 then
						local prev_menu = prev_menus[#prev_menus]
						prev_menus[#prev_menus] = nil
						return display(prev_menu.menu, id - 1, prev_menu.caption)
					end
					return false
				end
			end
		until result
	end
	return display(menu, 31337, caption or menu.title)
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

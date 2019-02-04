local SE = require 'lib.samp.events'
local inicfg = require 'inicfg'
dlstatus = require('moonloader').download_status
require('lib.moonloader')
local sf = require 'sampfuncs'
local lanes = require('lanes').configure()
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8


script_author('Saburo Shimizu')
script_version('1.3.6')
script_properties("work-in-pause")


fftt = false
prisontime = false
URL = nil
systime = 0
aupd = nil
teg = '{FF7000}[PrisonHelper] {01A0E9}'
fcolor = '{01A0E9}'
kpzblyat = lua_thread.create_suspended(function() submenus_show(spisoc_lec, teg..'Лекции', 'Ok', 'Ne ok!', 'Nozad') end)
fastmenuthread = lua_thread.create_suspended(function() fastmenufunc() end)
paydayinformer = lua_thread.create_suspended(function() pdinf() end)


default = {
    prison = {
        hour = 0,
        fasttime = true,
        aupd = true,
        adownload = false,
        fastmenu = false,
        paydayhelp = false,
        grafiktime = false
    }
}

local ini = inicfg.load(default, 'PrisonHelper.ini')

pris = ini.prison
fasttime = pris.fasttime
hour = pris.hour
aupd = pris.aupd
adownload = pris.adownload
fastmenu = pris.fastmenu
grafiktime = pris.grafiktime

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
{FF7000}22:00 - 07:00 {d5dedd}- Отбой]]


ph = [[{FF7000}/jd{d5dedd} - открыть/закрыть камеру (jaildoor)
{FF7000}/panel{d5dedd} - РП открыть панель управления камерамаи/двором
{FF7000}/prisonreload{d5dedd} - Перезагружает скрипт
{FF7000}/cam{d5dedd} - РП просмотр камер
{FF7000}/prisonsettime{d5dedd} - Настройка времени скрипта
{FF7000}/уведомления{d5dedd} - Отключить/включить уведомления о графике (сохраняется в ini файле)
{FF7000}/привет{d5dedd} - Спросить что нужно заключённому
{FF7000}/куф{d5dedd} - Нацепить на заключённого наручники через решётку
{FF7000}/ункуф{d5dedd} - Снять наручники с заключённого через решётку
{FF7000}/кпз{d5dedd} - Сказать заключённому о камере
{FF7000}/кпз-врем{d5dedd} - Сказать заключённому о камере (2 минуты)
{FF7000}/варн{d5dedd} - Предупреждение о камере
{FF7000}/нарушение{d5dedd} - РП диалог + РП дубинка (неактив)
{FF7000}/график{d5dedd} - расписание работы тюрьмы
{FF7000}/решётка{d5dedd} - предупреждение о громыхании решёткой
{FF7000}/отмычка{d5dedd} - РП сбой взлома камер
{FF7000}/отмычка-варн{d5dedd} - РП сбой взлома камер и предупреждение о наручниках
{FF7000}/стол{d5dedd} - Приказ заключённому слезть со стола
{FF7000}/режим{d5dedd} - Лекции для заключённых
{FF7000}/prisonmenu{d5dedd} - Настройки скрипта]]


spisoc_lec = {
    {
        title = fcolor ..'1. Время',
        submenu = {
            title = teg ..'Время',
            {
                title = fcolor ..'Время начало',
                onclick = function() vremnach() end
            },
            {
                title = fcolor ..'Время конец',
                onclick = function() vremkon() end
            },
        }
    },
    {
        title = fcolor ..'2. Уборка',
        submenu = {
            title = teg ..'Уборка',
            {
                title = fcolor ..'Уборка и завтрак начало',
                onclick = function() ubornach(0) end
            },
            {
                title = fcolor ..'Уборка и завтрак конец',
                onclick = function () uborkon(0) end
            },
            {
                title = fcolor ..'Уборка всей тюрьмы начало',
                onclick = function() ubornach(1) end
            },
            {
                title = fcolor ..'Уборка всей тюрьмы конец',
                onclick = function () uborkon(1) end
            },
        }
    },
    {
        title = fcolor ..'3. Спортзал',
        submenu = {
            title = teg ..'Спортзал',
            {
                title = fcolor ..'Спорзал начало',
                onclick = function() sportnach() end
            },
            {
                title = fcolor ..'Спорзал конец',
                onclick = function() sportkon() end
            },
        }
    },
    {
        title = fcolor ..'4. Ужин',
        submenu = {
            title = teg ..'Ужин',
            {
                title = fcolor ..'Ужин начало',
                onclick = function() uzhinnach() end
            },
            {
                title = fcolor ..'Ужин конец',
                onclick = function() uzhinkon() end
            },
        }
    },
    {
        title = fcolor ..'5. Обед',
        submenu = {
            title = teg ..'Обед',
            {
                title = fcolor ..'Обед начало',
                onclick = function() obednach() end
            },
            {
                title = fcolor ..'Обед конец',
                onclick = function() obedkon() end
            },
        }
    },
}




function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    if aupd == true then apdeit() end
    -- register commands
    sampRegisterChatCommand("jd", jd)
    sampRegisterChatCommand("prisonreload", reloader)
    sampRegisterChatCommand("prisonupdate", updates)
    sampRegisterChatCommand("prisonver", apdeit)
    sampRegisterChatCommand("cam", cam)
    sampRegisterChatCommand("panel", panel)
    sampRegisterChatCommand("варн", warn)
    sampRegisterChatCommand("привет", privet)
    sampRegisterChatCommand("решётка", reshotka)
    sampRegisterChatCommand("куф", cuff)
    sampRegisterChatCommand("ункуф", uncuff)
    sampRegisterChatCommand("кпз", kpz)
    sampRegisterChatCommand("режим", function() if kpzblyat:status() == 'suspended' or kpzblyat:status() == 'dead' then kpzblyat:run() else sampAddChatMessage(teg..'Данная функция уже работает. Если произошла ошибка перезапустите скрипт', - 1) end end)
    sampRegisterChatCommand("кпз-врем", kpzvrem)
    sampRegisterChatCommand("кпз-кон", kpzkon)
    sampRegisterChatCommand("стол", stol)
    sampRegisterChatCommand("отмычка", otm)
    sampRegisterChatCommand("отмычка-варн", warnotm)
    sampRegisterChatCommand('prisonmenu', function() lua_thread.create(menu) end)
    sampRegisterChatCommand('fastmenu', function() if fastmenuthread:status() == 'suspended' or fastmenuthread:status() == 'dead' then fastmenuthread:run() else sampAddChatMessage(teg..'Данная функция уже работает. Если произошла ошибка перезапустите скрипт', - 1) end end)
    sampRegisterChatCommand("график", raspisanie)
    sampRegisterChatCommand("prisonhelp", prisonhelp)
    sampRegisterChatCommand("уведомления", function() sampAddChatMessage(fasttime and 'Уведомления выключены. Для включения введите {FF7000}/уведомления' or 'Уведомления включены. Для выключения введите {FF7000}/уведомления', 0x01A0E9) pris.fasttime = not pris.fasttime inicfg.save(default, 'PrisonHelper') end)
    sampRegisterChatCommand("prisonsetime", function() prisontime = true sampSendChat('/c 60') end)

    sampAddChatMessage(teg..'Успешно загружен. Версия: {ff7000}' ..thisScript().version, -1)

    if pris.fasttime == true then lua_thread.create(napominalka) sampAddChatMessage(teg ..'Уведомления графика тюрьмы {00FF00}включены', - 1) end
    if pris.grafiktime == true then sampAddChatMessage(teg ..'Уведомления графика тюрьмы в /c 60 {00FF00}включены', - 1) end
    if fastmenu == true and fastmenuthread:status() == 'suspended' or fastmenuthread:status() == 'dead' then fastmenuthread:run() end
    if pris.paydayhelp == true and paydayinformer:status() == 'suspended' or paydayinformer:status() == 'dead' then paydayinformer:run() end

    while true do
        wait(0)
        local ini = inicfg.load(default, 'PrisonHelper.ini')
        pris = ini.prison
        fasttime = pris.fasttime

        if kpzblyat:status() == 'running' or kpzblyat:status() == nil then if isKeyDown(VK_MENU) and isKeyJustPressed(VK_OEM_5) then kpzblyat:terminate() sampAddChatMessage(teg ..'Зачитывание лекции остановлено', - 1) end end
        if fastmenuthread:status() == 'running' or fastmenuthread:status() == nil then if isKeyDown(VK_MENU) and isKeyJustPressed(VK_OEM_5) then fastmenuthread:terminate() sampAddChatMessage(teg ..'Быстрое меню выключено/перезагружено.', - 1) if fastmenu == true then fastmenuthread:run() end end end


        -- Загрузка времени
        local dt = os.date("*t"); systime = dt.hour dt.hour = dt.hour - pris.hour
        local dt = os.date("*t", os.time(dt))
    end
end

function raspisanie()
    sampShowDialog(31232, '{F70000}График работы тюрьмы и заключённых:', rasp, 'Ok!', _, 0)
end

function prisonhelp()
    sampShowDialog(12312, 'Prison Helper', ph, 'Ok!', _, 0)
end

function warnotm(id)
    if id ~= '' then
        lua_thread.create(function()
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
            sampSendChat('/me убрал отмычку в карман пиджака')
            wait(1000)
            sampSendChat('/do Отмычка в кармане пиджака.')
            wait(1000)
            sampSendChat('Зключённый №' ..id ..' , Вам вынесено камерное предупреждение за попытку взлома замка.')
            wait(2000)
            sampSendChat('При последующих попытках я буду вынужден надеть на Вас наручники.')
        end)
    else
        sampAddChatMessage('Введите {FF7000}/отмычка-варн ID', 0x01A0E9)
    end
end

function otm()
    lua_thread.create(function()
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
        sampSendChat('/me убрал отмычку в карман пиджака')
        wait(1000)
        sampSendChat('/do Отмычка в кармане пиджака.')
        wait(2000)
        sampSendChat('/n /key в наручниках - Non RP.')
    end)
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
        script.this:reload()
    end)
end

function reshotka(id)
    if id ~= '' then
        lua_thread.create(function()
            sampSendChat('Заключённый №'..id ..'.')
            wait(1000)
            sampSendChat('Вам вынесено камерное предупреждение за то, что вы гремите решёткой камеры.')
            wait(1000)
            sampSendChat('При последующем выносе предупреждения я буду вынужден надеть на Вас наручники.')
            wait(1000)
            sampSendChat('/n По РП с наручниками за спиной ты не можешь бить по решётке. Если замечу - залью ЖБ за NonRP.')
        end)
    else
        sampAddChatMessage('Введите {FF7000}/решётка ID', 0x01A0E9)
    end
end

function uncuff(id)
    if id ~= '' then
        lua_thread.create(function()
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
        end)
    else
        sampAddChatMessage('Введите {FF7000}/ункуф ID', 0x01A0E9)
    end
end

function cuff(id)
    if id ~= '' then
        lua_thread.create(function()
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
        end)
    else
        sampAddChatMessage('Введите {FF7000}/куф ID', 0x01A0E9)
    end
end

function warn(id)
    if id ~= '' then
        lua_thread.create(function()
            sampSendChat('Здравствуйте, заключённый №' ..id..'.')
            wait(1000)
            sampSendChat('Вам вынесено предупреждение за нарушение внутреннего порядка.')
            wait(1000)
            sampSendChat('При повтороном нарушении я буду вынужден посадить Вас в одиночную камеру.')
        end)
    else
        sampAddChatMessage('Введите {FF7000}/варн ID', 0x01A0E9)
    end
end

function privet(id)
    if id ~= '' then
        lua_thread.create(function()
            sampSendChat('Здравствуйте, заключённый №' ..id..'.')
            wait(2000)
            sampSendChat('Чем я могу Вам помочь?')
        end)
    else
        sampAddChatMessage('Введите {FF7000}/привет ID', 0x01A0E9)
    end
end

function stol(id)
    if id ~= '' then
        lua_thread.create(function()
            sampSendChat('Заключённый №' ..id ..', немедленно слезьте со стола!')
            wait(1000)
            sampSendChat('В противном случае я буду вынужден применить резиновую дубинку или резиновые пули!')
        end)
    else
        sampAddChatMessage('Введите {FF7000}/стол ID', 0x01A0E9)
    end
end

function stoladv()
    sampSendChat('Товарищ адвокат. Прошу Вас слезть со стола.')
    wait(1000)
    sampSendChat('В противном случае я буду вынужден заставить Вас сделать это.')
end

function kpz(id)
    if id ~= '' then
        lua_thread.create(function()
            sampSendChat('Заключённый №' ..id ..', Вы посажены в одиночную камеру без шанса на выход.')
            wait(1000)
            sampSendChat('Если же Вы попытаетесь взломать замок, я надену на Вас наручники.')
        end)
    else
        sampAddChatMessage('Введите {FF7000}/кпз ID', 0x01A0E9)
    end
end

function kpzvrem(id)
    if id ~= '' then
        lua_thread.create(function()
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
        end)
    else
        sampAddChatMessage('Введите {FF7000}/кпз-врем ID', 0x01A0E9)
    end
end

function kpzkon(id)
    if id ~= '' then
        lua_thread.create(function()
            sampSendChat('Заключённый №' ..id ..', время Вашего нахождения в одиночной камере подошло к концу.')
            wait(1000)
            sampSendChat('/me протянулся к поясному держателю, затем достал ключ от камеры')
            wait(250)
            sampSendChat('/me открыл/закрыл камеру, затем повесил ключ назад')
            sampSendChat('/jaildoor')
            wait(1000)
            sampSendChat('Можете выходить из камеры, но больше не нарушайте.')
        end)
    else
        sampAddChatMessage('Введите {FF7000}/кпз-кон ID', 0x01A0E9)
    end
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


function SE.onShowDialog(dialogId, style, title, button1, button2, text)
    if prisontime == true then
        if text:find('.+Текущее время:.+%{3399FF}%d+:%d+.+') then dtime = text:match('.+Текущее время.+%{3399FF}(%d+):%d+.+') pris.hour = systime - dtime inicfg.save(default, 'PrisonHelper')
            sampAddChatMessage('Время сохранено. Время от МСК: {FF7000}' ..pris.hour, 0x01A0E9)
        end
    end
	if title:find('.+Точное время') and pris.grafiktime then graf = grafiktimes() sampAddChatMessage(graf, 0x01A0E9) end
end




function apdeit()
    async_http_request('GET', 'https://raw.githubusercontent.com/SaburoShimizu/PrisonHelper/master/PrisonHelperVer', nil --[[параметры запроса]],
        function(resp) -- вызовется при успешном выполнении и получении ответа
            ver = resp.text:match('Version = (.+), URL.+')
            if ver ~= nil then obrupd(ver) end
        end,
        function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
            print(err)
            sampAddChatMessage(teg ..'Ошибка поиска версии. Попробуйте позже.', - 1)
    end)
end

function obrupd(ver)
    if thisScript().version < ver then if adownload then sampAddChatMessage(teg ..'Доступно новое обновление. {FF7000}Началась автоустановка', -1) updates() else sampAddChatMessage(teg..'Доступно новое обновление до версии {FF7000}' ..ver ..'{01A0E9}. Используйте {FF7000}/prisonupdate', - 1) end
    elseif thisScript().version == ver then sampAddChatMessage(teg..'У вас актуальная версия скрипта', - 1)
    elseif thisScript().version > ver then sampAddChatMessage(teg ..'У вас тестовая версия скрипта', - 1)
    end
end


function updates()
    async_http_request('GET', 'https://raw.githubusercontent.com/SaburoShimizu/PrisonHelper/master/PrisonHelper.lua', nil --[[параметры запроса]],
        function(respe) -- вызовется при успешном выполнении и получении ответа
            f = io.open(getWorkingDirectory() ..'/PrisonHelper.lua', 'wb')
            f:write(u8:decode(respe.text))
            f:close()
			sampAddChatMessage(teg ..'Обновление успешно скачалось. Скрипт перезапуститься автоматически', -1)
			thisScript():reload()
        end,
        function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
            print(err)
            sampAddChatMessage(teg ..'Ошибка обновления. Попробуйте позже.', - 1)
    end)
end


function checkmenu()
    my_dialog = {
        {
            title = string.format('%s Расписание в чате: %s', fcolor, pris.fasttime and '{00FF00}Вкл' or '{FF0000}Выкл'),
            onclick = function() sampAddChatMessage(fasttime and 'Уведомления выключены. Для включения введите {FF7000}/уведомления' or 'Уведомления включены. Для выключения введите {FF7000}/уведомления', 0x01A0E9) pris.fasttime = not pris.fasttime inicfg.save(default, 'PrisonHelper') end
        },
        {
            title = string.format('%s Автонастройка времени. Время от МСК: {FF7000}%s', fcolor, pris.hour),
            onclick = function() prisontime = true sampSendChat('/c 60') end
        },
        {
            title = string.format('%s Уведомомления о графике в /c 60: %s', fcolor, grafiktime and '{00FF00}Вкл' or '{FF0000}Выкл'),
            onclick = function() pris.grafiktime = not pris.grafiktime grafiktime = pris.grafiktime inicfg.save(default, 'PrisonHelper') end
        },
        {
            title = string.format('%s Напоминание о PayDay: %s', fcolor, pris.paydayhelp and '{00FF00}Вкл' or '{FF0000}Выкл'),
            onclick = function() pris.paydayhelp = not pris.paydayhelp inicfg.save(default, 'PrisonHelper') end
        },
        {
            title = string.format('%s Быстрое меню: %s', fcolor, fastmenu and '{00FF00}Вкл' or '{FF0000}Выкл'),
            submenu = {
                title = string.format('%s Быстрое меню: %s', teg, fastmenu and '{00FF00}Вкл' or '{FF0000}Выкл'),
                {
                    title = string.format('%s Быстрое меню (без сохранения в INI): %s', fcolor, fastmenu and '{00FF00}Вкл' or '{FF0000}Выкл'),
                    onclick = function() fastmenu = not fastmenu end
                },
                {
                    title = string.format('%s Быстрое меню (С сохранением в INI): %s', fcolor, fastmenu and '{00FF00}Вкл' or '{FF0000}Выкл'),
                    onclick = function() pris.fastmenu = not pris.fastmenu fastmenu = pris.fastmenu inicfg.save(default, 'PrisonHelper') end
                },
            },
        },
				{
					title = ' ',
				},
        {
            title = string.format('%s Информация о скрипте', fcolor),
            onclick = prisonhelp
        },
        {
            title = string.format('%s Перезапустить скрипт', fcolor),
            onclick = reloader
        },
        {
            title = string.format('%s Обновление скрипта', fcolor),
            submenu = {
                title = string.format('%s Текущая версия скрипта: {FF0000}%s', teg, thisScript().version),
                {
                    title = string.format('%s Автообновление скрипта: %s', fcolor, pris.aupd and '{00FF00}Вкп' or '{FF0000}Выкл'),
                    onclick = function() pris.aupd = not pris.aupd inicfg.save(default, 'PrisonHelper') sampAddChatMessage(string.format('%s Автообновление %s', teg, pris.aupd and '{00FF00}включено' or '{FF0000}выключено'), - 1) end
                },
                {
                    title = string.format('%s Автоустановка обновления скрипта: %s', fcolor, pris.adownload and '{00FF00}Вкп' or '{FF0000}Выкл'),
                    onclick = function() pris.adownload = not pris.adownload adownload = pris.adownload inicfg.save(default, 'PrisonHelper') sampAddChatMessage(string.format('%s Автоустановка %s', teg, pris.adownload and '{00FF00}включена' or '{FF0000}выключена'), - 1) end
                },
                {
                    title = string.format('%s Проверить наличие обновления', fcolor),
                    onclick = function() aupd = true apdeit() aupd = pris.aupd end
                },
                {
                    title = string.format('%s Принудительное обновление', fcolor),
                    onclick = function() updates() end
                }
            },
        }
    }
end

function menu()
    checkmenu()
    submenus_show(my_dialog, teg..'Настройки', 'Выбрать', 'Отменить', 'Назад')
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

function pdinf()
	sampAddChatMessage(teg..'Напоминание о PayDay: {00FF00}включено', -1)
  while true do wait(0)
    dt = os.date('*t'); dt.min = dt.min; dt.sec = dt.sec
    if data == true and dt.min == 55 and dt.sec == 10 then sampAddChatMessage('[TimeInChat] {D5DEDD}До PayDay осталось 5 минут. Не выходите в АФК', 0x01A0E9) wait(1000) end
    if data == true and dt.min == 59 and dt.sec == 10 then sampAddChatMessage('[TimeInChat] {D5DEDD}До PayDay осталась 1 минута. Не выходите в АФК', 0x01A0E9) wait(1000) end
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


function checkfunctionsmenu(pedid)
    functionsmenu = {
        {
            title = string.format('%s Привет', fcolor),
            onclick = function() privet(pedid) end
        },
        {
            title = string.format('%s Варн', fcolor),
            onclick = function() warn(pedid) end
        },
        {
            title = string.format('%s Решётка', fcolor),
            onclick = function() reshotka(pedid) end
        },
        {
            title = string.format('%s /cuff', fcolor),
            onclick = function() cuff(pedid) end
        },
        {
            title = string.format('%s /uncuff', fcolor),
            onclick = function() uncuff(pedid) end
        },
        {
            title = string.format('%s Отмычка', fcolor),
            onclick = function() otm() end
        },
        {
            title = string.format('%s Отмычка-варн', fcolor),
            onclick = function() warnotm(pedid) end
        },
        {
            title = string.format('%s КПЗ', fcolor),
            submenu = {
                title = string.format('%s КПЗ', fcolor),
                {
                    title = string.format('%s КПЗ', fcolor),
                    onclick = function() kpz(pedid) end
                },
                {
                    title = string.format('%s КПЗ-врем', fcolor),
                    onclick = function() kpzvrem(pedid) end
                },
                {
                    title = string.format('%s КПЗ-кон', fcolor),
                    onclick = function() kpzkon(pedid) end
                },
            },
        },
        {
            title = string.format('%s Стол', fcolor),
            onclick = function() stol(pedid) end
        },
        {
            title = string.format('%s Стол (Адвокат)', fcolor),
            onclick = function() stoladv() end
        },
    }
end


function fastmenufunc()
    sampAddChatMessage(teg ..'Быстрое меню {00FF00}включено', - 1)
    while true do wait(0)
        local rese, ped = getCharPlayerIsTargeting(playerHandle)
        if rese then
            if isKeyJustPressed(VK_G) then
                local _, pedid = sampGetPlayerIdByCharHandle(ped)
                local name = sampGetPlayerNickname(pedid)
                checkfunctionsmenu(pedid)
                submenus_show(functionsmenu, string.format('%s %s[%d]', teg, name, pedid), 'Выбрать', 'Отменить', 'Назад')
            end
        end
    end
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

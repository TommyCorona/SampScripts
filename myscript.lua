-- users = getTableUsersByUrl(url) - �������� ������� ������������� �� ������ �� .txt ���� ������.
-- * url - ������ �� .txt ���� ������.
-- * users - ������� �������������.
-- * users[����� ������������].name - ��� ������������; users[����� ������������].date - ������������� ���� ������ ������� (����� ������, ����� �������� �������������..
-- ..����, ����� ������� isAvailableUser).
-- availabled = isAvailableUser(users, name)
-- * users - ������� �������������.
-- * name - ��� ������������.
-- * availabled - ����������� (true/false).

function getTableUsersByUrl(url)
    local n_file, bool, users = os.getenv('TEMP')..os.time(), false, {}
    downloadUrlToFile(url, n_file, function(id, status)
        if status == 6 then bool = true end
    end)
    while not doesFileExist(n_file) do wait(0) end
    if bool then
        local file = io.open(n_file, 'r')
        for w in file:lines() do
            local n, d = w:match('(.*): (.*)')
            users[#users+1] = { name = n, date = d }
        end
        file:close()
        os.remove(n_file)
    end
    return users
end

function isAvailableUser(users, name)
    for i, k in pairs(users) do
        if k.name == name then
            local d, m, y = k.date:match('(%d+)%.(%d+)%.(%d+)')
            local time = {
                day = tonumber(d),
                isdst = true,
                wday = 0,
                yday = 0,
                year = tonumber(y),
                month = tonumber(m),
                hour = 0
            }
            if os.time(time) >= os.time() then return true end
        end
    end
    return false
end


-- ������ �� ������ ������� � ������.
site = 'https://pastebin.com/raw/mX6daJb8'

function main()
	autoupdate("��� ������ �� ��� json", '['..string.upper(thisScript().name)..']: ', "��� ������ �� ��� ����/url ������ ������� �� ������ (���� ���, �������� ��� � json)")
    while not isSampAvailable() do wait(0) end
    while sampGetCurrentServerName() == 'SA-MP' do wait(0) end
    local users = getTableUsersByUrl(site) -- ����� ������� ������.
    local _, myid = sampGetPlayerIdByCharHandle(playerPed) -- ����� ���� ��.
    if not isAvailableUser(users, sampGetPlayerNickname(myid)) then -- ���� ���� ��� ������ ��� � ������ ���� ����� ����, ��..
        sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ������.", 0xFFFF0000)
        thisScript():unload() -- ��������� ������.
    end
    wait(-1)
end

function autoupdate(json_url, prefix, url)
	local dlstatus = require('moonloader').download_status
	local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
	if doesFileExist(json) then os.remove(json) end
	downloadUrlToFile(json_url, json,
	  function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
		  if doesFileExist(json) then
			local f = io.open(json, 'r')
			if f then
			  local info = decodeJson(f:read('*a'))
			  updatelink = info.updateurl
			  updateversion = info.latest
			  f:close()
			  os.remove(json)
			  if updateversion ~= thisScript().version then
				lua_thread.create(function(prefix)
				  local dlstatus = require('moonloader').download_status
				  local color = -1
				  sampAddChatMessage((prefix..'���������� ����������. ������� ���������� c '..thisScript().version..' �� '..updateversion), color)
				  wait(250)
				  downloadUrlToFile(updatelink, thisScript().path,
					function(id3, status1, p13, p23)
					  if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
						print(string.format('��������� %d �� %d.', p13, p23))
					  elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
						print('�������� ���������� ���������.')
						sampAddChatMessage((prefix..'���������� ���������!'), color)
						goupdatestatus = true
						lua_thread.create(function() wait(500) thisScript():reload() end)
					  end
					  if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
						if goupdatestatus == nil then
						  sampAddChatMessage((prefix..'���������� ������ ��������. �������� ���������� ������..'), color)
						  update = false
						end
					  end
					end
				  )
				  end, prefix
				)
			  else
				update = false
				print('v'..thisScript().version..': ���������� �� ���������.')
			  end
			end
		  else
			print('v'..thisScript().version..': �� ���� ��������� ����������. ��������� ��� ��������� �������������� �� '..url)
			update = false
		  end
		end
	  end
	)
	while update ~= false do wait(100) end
  end
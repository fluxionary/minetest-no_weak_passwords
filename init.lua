local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local auth_handler = minetest.get_auth_handler()

local function log(level, message, ...)
    minetest.log(level, ('[%s] %s'):format(modname, message:format(...)))
end

local function load_passwords()
    local filename = modpath .. '/weak_passwords.txt'
    local bad_passwords = {}
    for line in io.lines(filename) do
        table.insert(bad_passwords, line)
    end
    log('action', '%s bad passwords loaded', #bad_passwords)
    return bad_passwords
end

local passwords = load_passwords()

local function has_weak_password(name)
    local auth = auth_handler.get_auth(name)
    if not auth then
        log('error', 'Auth for %s is not initialized', name)
        return false
    end

    for _, password in ipairs(passwords) do
        if minetest.check_password_entry(name, auth.password, password) then
            return true
        end
    end

    if minetest.check_password_entry(name, auth.password, name) then
        return true
    end

    return false
end

local function kick(player)
    local player_name = player:get_player_name()
    local reason = 'Your account has been reset due to a weak password. Please choose a stronger one.'
    if not minetest.kick_player(player_name, reason) then
        player:set_detach()
        if not minetest.kick_player(player_name, reason) then
            log('warning', 'Failed to kick player %s after detaching!', player_name)
            return false
        end
    end
    return true
end

local function remove_player(name)
    local rc = minetest.remove_player(name)

    if rc == 0 then
        log('action', 'Removed player %s due to weak password', name)
        return minetest.remove_player_auth(name)
    elseif rc == 1 then
        log('action', 'No such player %s', name)
        return false
    elseif rc == 2 then
        log('warning', 'Player %s is connected, cannot remove', name)
        return false
    else
        log('error', 'Unhandled remove_player return code %s', rc)
        return false
    end
end

minetest.register_on_prejoinplayer(function(name, ipstr)
    -- return a string w/ the reason for refusal; otherwise return nothing
    local start = os.time()
    local r
    if has_weak_password(name) and remove_player(name) then
        r = 'Your account has been reset due to a weak password. Please choose a stronger one.'
    end
    log('action', 'checks took %s', os.time() - start)
    return r
end)

minetest.register_on_newplayer(function(player)
    local name = player:get_player_name()

    if has_weak_password(name) then
        if kick(player) then
            minetest.after(1, remove_player, name)
        end
    end
end)

--[[
    ShadeInstaller v1.0.0
    Universal Linux Setup Wizard (Arch, Debian/Ubuntu, Fedora)
    Author: ShadowDevForge
    
    Usage: 
      lua shade_install.lua             # Normal Mode
      lua shade_install.lua --dry-run   # Preview Mode
]]

--------------------------------------------------------------------------------
-- 0. GLOBAL CONFIG & ARGS
--------------------------------------------------------------------------------

local DRY_RUN = false
for _, v in ipairs(arg or {}) do
    if v == "--dry-run" then DRY_RUN = true end
end

--------------------------------------------------------------------------------
-- 1. SYSTEM & DISTRO DETECTION
--------------------------------------------------------------------------------

local System = {}

function System:get_distro()
    local handle = io.popen("cat /etc/os-release 2>/dev/null")
    if not handle then return "unknown" end
    local content = handle:read("*a"):lower()
    handle:close()

    if content:find("id=arch") or content:find("id_like=arch") then return "arch"
    elseif content:find("id=debian") or content:find("id=ubuntu") or content:find("id_like=debian") then return "deb"
    elseif content:find("id=fedora") then return "fedora"
    end
    return "unknown"
end

local CURRENT_DISTRO = System:get_distro()

--------------------------------------------------------------------------------
-- 2. PACKAGE MANAGER STRATEGIES
--------------------------------------------------------------------------------

local PM = {
    arch = {
        name = "Pacman",
        install = "sudo pacman -S --noconfirm",
        update  = "sudo pacman -Syu --noconfirm",
        shell_cmd = "sudo chsh -s"
    },
    deb = {
        name = "APT",
        install = "sudo apt install -y",
        update  = "sudo apt update && sudo apt upgrade -y",
        shell_cmd = "sudo chsh -s"
    },
    fedora = {
        name = "DNF",
        install = "sudo dnf install -y",
        update  = "sudo dnf upgrade -y",
        shell_cmd = "sudo chsh -s"
    },
    unknown = {
        name = "Unknown",
        install = "echo 'Unsupported OS' #",
        update = "echo 'Unsupported OS' #",
        shell_cmd = "echo"
    }
}

local Manager = PM[CURRENT_DISTRO]

--------------------------------------------------------------------------------
-- 3. UI UTILITIES
--------------------------------------------------------------------------------

local UI = {}

UI.colors = {
    rosewater = "\27[38;5;223m", flamingo = "\27[38;5;217m", mauve = "\27[38;5;183m",
    red = "\27[38;5;203m", peach = "\27[38;5;215m", green = "\27[38;5;120m",
    teal = "\27[38;5;159m", sapphire = "\27[38;5;75m", lavender = "\27[38;5;189m",
    text = "\27[38;5;253m", subtext = "\27[38;5;248m", surface = "\27[38;5;237m",
    reset = "\27[0m", bold = "\27[1m", yellow = "\27[38;5;228m", 
    blue = "\27[38;5;81m" -- Fixed: Added missing blue color
}

function UI:clear() os.execute("clear") end

function UI:banner()
    self:clear()
    local c = self.colors
    print(c.mauve .. [[

        ▄█████ ▄▄ ▄▄  ▄▄▄  ▄▄▄▄  ▄▄▄▄▄    
        ▀▀▀▄▄▄ ██▄██ ██▀██ ██▀██ ██▄▄     
        █████▀ ██ ██ ██▀██ ████▀ ██▄▄▄    
                                                                                             
██ ▄▄  ▄▄  ▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄  ▄▄    ▄▄    ▄▄▄▄▄ ▄▄▄▄ 
██ ███▄██ ███▄▄   ██  ██▀██ ██    ██    ██▄▄  ██▄█▄
██ ██ ▀██ ▄▄██▀   ██  ██▀██ ██▄▄▄ ██▄▄▄ ██▄▄▄ ██ ██

             | By ShadowDevForge | 

]] .. c.reset)
    
    local mode_str = DRY_RUN and (c.yellow .. " [DRY-RUN MODE]" .. c.reset) or ""
    print(string.format("%s%s   :: OS: %s%s%s | Manager: %s%s%s%s ::%s\n", 
        c.bold, c.subtext, 
        c.sapphire, CURRENT_DISTRO:upper(), c.subtext,
        c.sapphire, Manager.name, c.subtext, mode_str,
        c.reset))
    print(c.surface .. string.rep("─", 55) .. c.reset .. "\n")
end

function UI:section(title)
    print("\n" .. self.colors.lavender .. ":: " .. self.colors.bold .. title .. self.colors.reset)
    print(self.colors.surface .. string.rep("-", 40) .. self.colors.reset)
end

function UI:ask(question, default, validation_fn)
    local def_str = default and string.format(" [%s]", default) or ""
    while true do
        io.write(string.format("%s%s?%s%s %s: ", 
            self.colors.teal, question, self.colors.subtext, def_str, self.colors.reset))
        local answer = io.read()
        if answer == "" and default then answer = default end
        
        if not validation_fn or validation_fn(answer) then
            return answer
        else
            print(self.colors.red .. "Invalid input. Please try again." .. self.colors.reset)
        end
    end
end

function UI:checkbox(index, name, is_selected)
    local check = is_selected and (self.colors.green .. "x") or " "
    print(string.format(" %s%2d.%s [%s%s%s] %s%s", 
        self.colors.peach, index, self.colors.reset, 
        self.colors.bold, check, self.colors.reset, 
        self.colors.text, name))
end

function UI:ask_error_action(cmd)
    print(self.colors.red .. "\n[!] Command failed: " .. self.colors.reset .. cmd)
    print(self.colors.subtext .. "Select action:" .. self.colors.reset)
    print(" (r) Retry")
    print(" (s) Skip this step")
    print(" (a) Abort installation")
    local ans = self:ask("Action", "r", function(x) return x:match("^[rsa]$") end)
    return ans
end

--------------------------------------------------------------------------------
-- 4. DATA (8 Domains x 8 Items + Resolvers)
--------------------------------------------------------------------------------

local Data = {}

-- Resolver: Converts abstract package name to distro-specific name
function Data.resolve(pkg_map)
    if type(pkg_map) == "string" then return pkg_map end
    local val = pkg_map[CURRENT_DISTRO] or pkg_map["default"] or pkg_map["deb"]
    return val
end

Data.shells = {
    { name = "Zsh (Recommended)", pkg = "zsh", bin = "/usr/bin/zsh" },
    { name = "Fish", pkg = "fish", bin = "/usr/bin/fish" },
    { name = "Bash (Default)", pkg = "bash", bin = "/usr/bin/bash" }
}

Data.nvim_distros = {
    { name = "NvShade", url = "https://github.com/shadowdevforge/nvshade" },
    { name = "LazyVim", url = "https://github.com/LazyVim/starter" },
    { name = "NvChad", url = "https://github.com/NvChad/NvChad" },
    { name = "AstroNvim", url = "https://github.com/AstroNvim/Template" },
    { name = "Kickstart", url = "https://github.com/nvim-lua/kickstart.nvim" }
}

Data.domains = {
    { 
        name = "Browsers", 
        items = {
            { n="Firefox", p={ default="firefox", deb="firefox-esr" } },
            { n="Chromium", p="chromium" },
            { n="Brave", p={ arch="brave-bin", default="brave-browser" } },
            { n="LibreWolf", p={ arch="librewolf-bin", default="librewolf" } },
            { n="Tor Browser", p="tor-browser" },
            { n="Qutebrowser", p="qutebrowser" },
            { n="Lynx", p="lynx" },
            { n="Vivaldi", p="vivaldi" }
        }
    },
    { 
        name = "Multimedia", 
        items = {
            { n="VLC Player", p="vlc" },
            { n="MPV", p="mpv" },
            { n="OBS Studio", p="obs-studio" },
            { n="Kdenlive", p="kdenlive" },
            { n="GIMP", p="gimp" },
            { n="Inkscape", p="inkscape" },
            { n="Audacity", p="audacity" },
            { n="Blender", p="blender" }
        }
    },
    { 
        name = "Dev Tools", 
        items = {
            { n="Base Tools", p={ arch="base-devel", deb="build-essential", fedora="@development-tools" } },
            { n="Git", p="git" },
            { n="Docker", p="docker" },
            { n="VS Code", p={ arch="visual-studio-code-bin", default="code" } },
            { n="LazyGit", p="lazygit" },
            { n="Postman", p={ arch="postman-bin", default="postman" } },
            { n="CMake", p="cmake" },
            { n="Ninja", p="ninja" }
        }
    },
    { 
        name = "System Utils", 
        items = {
            { n="Htop", p="htop" },
            { n="Btop", p="btop" },
            { n="Neofetch", p="neofetch" },
            { n="Unzip", p="unzip" },
            { n="Curl", p="curl" },
            { n="Wget", p="wget" },
            { n="BleachBit", p="bleachbit" },
            { n="GParted", p="gparted" }
        }
    },
    { 
        name = "Social", 
        items = {
            { n="Discord", p="discord" },
            { n="Telegram", p="telegram-desktop" },
            { n="Slack", p="slack-desktop" },
            { n="Signal", p="signal-desktop" },
            { n="Zoom", p="zoom" },
            { n="Teams", p="teams" },
            { n="Element", p="element-desktop" },
            { n="Thunderbird", p="thunderbird" }
        }
    },
    { 
        name = "Gaming", 
        items = {
            { n="Steam", p={ default="steam", deb="steam-installer" } },
            { n="Lutris", p="lutris" },
            { n="Wine", p="wine" },
            { n="Winetricks", p="winetricks" },
            { n="GameMode", p="gamemode" },
            { n="MangoHud", p="mangohud" },
            { n="RetroArch", p="retroarch" },
            { n="Heroic", p="heroic-games-launcher-bin" }
        }
    },
    { 
        name = "Terminal", 
        items = {
            { n="FZF", p="fzf" },
            { n="RipGrep", p="ripgrep" },
            { n="Bat", p="bat" },
            { n="Tmux", p="tmux" },
            { n="Zoxide", p="zoxide" },
            { n="Eza (ls)", p="eza" },
            { n="Yazi", p="yazi" },
            { n="Fd", p="fd" }
        }
    },
    { 
        name = "Languages", 
        items = {
            { n="Python", p={ default="python", deb="python3" } },
            { n="NodeJS", p="nodejs" },
            { n="Go", p="go" },
            { n="Rust", p="rustup" },
            { n="GCC", p="gcc" },
            { n="Lua", p="lua" },
            { n="Ruby", p="ruby" },
            { n="PHP", p="php" }
        }
    }
}

--------------------------------------------------------------------------------
-- 5. LOGIC & STATE
--------------------------------------------------------------------------------

local Installer = {
    user_conf = {
        shell = nil,
        selected_pkgs = {}, -- Map: pkg_ref -> bool
        nvim = { install = false, url = nil, name = nil },
        git = { setup = false, name = "", email = "" }
    },
    log_file = os.getenv("HOME") .. "/ShadeInstaller.log"
}

function Installer:init_log()
    local f = io.open(self.log_file, "w")
    if f then
        f:write("--- ShadeInstaller Log ---\n")
        f:write("Distro: " .. CURRENT_DISTRO .. "\n")
        f:write("Mode: " .. (DRY_RUN and "Dry Run" or "Live") .. "\n")
        f:write("Date: " .. os.date() .. "\n\n")
        f:close()
    end
end

function Installer:append_log(msg)
    local f = io.open(self.log_file, "a")
    if f then f:write(msg .. "\n"); f:close() end
end

-- 5.1 Step: Shell
function Installer:step_shell()
    UI:section("Select Shell")
    for i, shell in ipairs(Data.shells) do
        print(string.format(" %s%d.%s %s", UI.colors.peach, i, UI.colors.reset, shell.name))
    end
    
    local choice = tonumber(UI:ask("Choice", "1", function(x) 
        local n = tonumber(x)
        return n and n >= 1 and n <= #Data.shells
    end))
    
    self.user_conf.shell = Data.shells[choice]
end

-- 5.2 Step: Packages
function Installer:step_packages()
    local done = false
    while not done do
        UI:clear()
        UI:banner()
        UI:section("Package Domains")
        
        for i, domain in ipairs(Data.domains) do
            local count = 0
            for _, item in ipairs(domain.items) do
                if self.user_conf.selected_pkgs[item.p] then count = count + 1 end
            end
            local count_str = (count > 0) and (UI.colors.green .. " ["..count.." selected]" .. UI.colors.reset) or ""
            print(string.format(" %s%2d.%s %-20s%s", UI.colors.peach, i, UI.colors.reset, domain.name, count_str))
        end

        print("\n" .. UI.colors.subtext .. " Enter ID to open domain, (d)one to proceed." .. UI.colors.reset)
        local input = UI:ask("Selection", "d")

        if input == "d" then
            done = true
        else
            local idx = tonumber(input)
            if idx and Data.domains[idx] then
                self:domain_menu(Data.domains[idx])
            end
        end
    end
end

function Installer:domain_menu(domain)
    local back = false
    while not back do
        UI:clear()
        UI:banner()
        UI:section("Domain: " .. domain.name)
        
        for i, item in ipairs(domain.items) do
            local is_selected = self.user_conf.selected_pkgs[item.p]
            UI:checkbox(i, item.n, is_selected)
        end

        print("\n" .. UI.colors.subtext .. " (ID) Toggle, (a) All, (n) None, (b) Back" .. UI.colors.reset)
        local input = UI:ask("Option", "b")

        if input == "b" then back = true
        elseif input == "a" then
            for _, item in ipairs(domain.items) do self.user_conf.selected_pkgs[item.p] = true end
        elseif input == "n" then
            for _, item in ipairs(domain.items) do self.user_conf.selected_pkgs[item.p] = nil end
        else
            local idx = tonumber(input)
            if idx and domain.items[idx] then
                local key = domain.items[idx].p
                self.user_conf.selected_pkgs[key] = not self.user_conf.selected_pkgs[key]
            end
        end
    end
end

-- 5.3 Step: Neovim
function Installer:step_nvim()
    UI:section("Neovim Setup")
    if UI:ask("Install Neovim & Config?", "y"):lower() ~= "y" then 
        self.user_conf.nvim.install = false
        return 
    end

    self.user_conf.nvim.install = true
    print("\n" .. UI.colors.sapphire .. " Choose Distribution:" .. UI.colors.reset)
    for i, dist in ipairs(Data.nvim_distros) do
        local prefix = (i == 1) and (UI.colors.yellow .. "★ ") or "  "
        print(string.format(" %s%s%d.%s %s", prefix, UI.colors.peach, i, UI.colors.reset, dist.name))
    end
    
    local choice = tonumber(UI:ask("Choice", "1", function(x) 
        local n = tonumber(x)
        return n and n >= 1 and n <= #Data.nvim_distros
    end))
    
    self.user_conf.nvim.name = Data.nvim_distros[choice].name
    self.user_conf.nvim.url = Data.nvim_distros[choice].url
end

-- 5.4 Step: Git
function Installer:step_git()
    UI:section("Git Configuration")
    if UI:ask("Configure Git globals?", "y"):lower() == "y" then
        self.user_conf.git.setup = true
        self.user_conf.git.name = UI:ask("Git User Name")
        self.user_conf.git.email = UI:ask("Git Email", nil, function(e)
            return e:find("@") -- Simple validation
        end)
    else
        self.user_conf.git.setup = false
    end
end

-- 5.5 Step: Summary & Confirmation
function Installer:step_summary()
    while true do
        UI:clear()
        UI:banner()
        UI:section("Manifest Summary")

        -- Calculate resolved packages for transparency
        local resolved_list = {}
        for map_ref, _ in pairs(self.user_conf.selected_pkgs) do
            local r = Data.resolve(map_ref)
            if r then table.insert(resolved_list, r) end
        end

        print(string.format(" %sDistro:%s     %s", UI.colors.pink, UI.colors.reset, CURRENT_DISTRO:upper()))
        print(string.format(" %sShell:%s      %s", UI.colors.pink, UI.colors.reset, self.user_conf.shell.name))
        print(string.format(" %sNeovim:%s     %s", UI.colors.pink, UI.colors.reset, self.user_conf.nvim.install and self.user_conf.nvim.name or "No"))
        print(string.format(" %sGit:%s        %s", UI.colors.pink, UI.colors.reset, self.user_conf.git.setup and self.user_conf.git.email or "No"))
        print(string.format(" %sPackages:%s   %d queued", UI.colors.pink, UI.colors.reset, #resolved_list))
        
        -- Preview first few packages
        if #resolved_list > 0 then
            print(UI.colors.subtext .. " Preview: " .. table.concat(resolved_list, ", ", 1, math.min(5, #resolved_list)) .. (#resolved_list > 5 and "..." or "") .. UI.colors.reset)
        end

        print("\n" .. UI.colors.sapphire .. " Options:" .. UI.colors.reset)
        print(" (p) Proceed with Install")
        print(" (e) Edit Selections")
        print(" (q) Quit")
        
        local choice = UI:ask("Action", "p")
        if choice == "p" then return true
        elseif choice == "e" then return false -- Go back to main loop
        elseif choice == "q" then os.exit()
        end
    end
end

-- 5.6 Step: Execution Engine
function Installer:execute()
    self:init_log()
    UI:section("Installation Progress")

    local tasks = {}

    -- 1. Update
    table.insert(tasks, { name = "Update System Repos", cmd = Manager.update })

    -- 2. Shell
    if self.user_conf.shell.pkg ~= "bash" then
        table.insert(tasks, { name = "Install Shell: " .. self.user_conf.shell.name, cmd = Manager.install .. " " .. self.user_conf.shell.pkg })
    end

    -- 3. Packages
    local pkg_list = {}
    for map_ref, _ in pairs(self.user_conf.selected_pkgs) do
        local real_name = Data.resolve(map_ref)
        if real_name then table.insert(pkg_list, real_name) end
    end
    if #pkg_list > 0 then
        table.insert(tasks, { name = "Install User Packages", cmd = Manager.install .. " " .. table.concat(pkg_list, " ") })
    end

    -- 4. Neovim
    if self.user_conf.nvim.install then
        table.insert(tasks, { name = "Install Neovim", cmd = Manager.install .. " neovim" })
        table.insert(tasks, { name = "Backup Old Config", cmd = "mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true" })
        table.insert(tasks, { name = "Clone Config ("..self.user_conf.nvim.name..")", cmd = string.format("git clone %s ~/.config/nvim", self.user_conf.nvim.url) })
    end

    -- 5. Git
    if self.user_conf.git.setup then
        table.insert(tasks, { name = "Git Config: Name", cmd = string.format('git config --global user.name "%s"', self.user_conf.git.name) })
        table.insert(tasks, { name = "Git Config: Email", cmd = string.format('git config --global user.email "%s"', self.user_conf.git.email) })
    end

    -- 6. Shell Change (Last)
    if self.user_conf.shell.bin ~= "/usr/bin/bash" then
        table.insert(tasks, { 
            name = "Set Default Shell", 
            cmd = string.format("%s %s %s", Manager.shell_cmd, self.user_conf.shell.bin, os.getenv("USER"))
        })
    end

    -- Execution Loop
    local total = #tasks
    for i, task in ipairs(tasks) do
        local prefix = string.format("[%d/%d] ", i, total)
        
        -- Print visible progress
        print(UI.colors.blue .. prefix .. UI.colors.reset .. task.name)
        
        self:append_log("\n[TASK] " .. task.name)
        self:append_log("[CMD]  " .. task.cmd)

        if DRY_RUN then
            print(UI.colors.subtext .. "  [DRY] " .. task.cmd .. UI.colors.reset)
            os.execute("sleep 0.1")
        else
            -- Run Command with Error Handling
            local success = false
            while not success do
                local code = os.execute(task.cmd .. " >> " .. self.log_file .. " 2>&1")
                
                -- Check exit code (Lua 5.1 compat: returns status code directly or true/false)
                local is_ok = (code == 0 or code == true)
                
                if is_ok then
                    success = true
                else
                    self:append_log("[ERROR] Failed with code " .. tostring(code))
                    local action = UI:ask_error_action(task.cmd)
                    if action == "r" then
                        -- Retry loop
                    elseif action == "s" then
                        success = true -- Pretend success to skip
                        self:append_log("[SKIP] User skipped task")
                    elseif action == "a" then
                        print(UI.colors.red .. "\nInstallation Aborted by User." .. UI.colors.reset)
                        os.exit(1)
                    end
                end
            end
        end
    end

    print("\n" .. UI.colors.green .. "✔ Installation Complete!" .. UI.colors.reset)
    print(UI.colors.subtext .. "  Log: " .. self.log_file .. UI.colors.reset)
    
    if self.user_conf.shell.pkg ~= "bash" then
        print("\n" .. UI.colors.yellow .. "NOTE: You changed your shell to " .. self.user_conf.shell.name)
        print("      Please log out and log back in for changes to apply." .. UI.colors.reset)
    end
end

--------------------------------------------------------------------------------
-- 6. MAIN CONTROLLER
--------------------------------------------------------------------------------

local function main()
    if CURRENT_DISTRO == "unknown" and not DRY_RUN then
        print(UI.colors.red .. "CRITICAL: Unsupported Distribution." .. UI.colors.reset)
        print("This script supports Arch, Debian/Ubuntu, and Fedora.")
        os.exit(1)
    end

    UI:banner()

    -- Configuration Phase
    local ready = false
    while not ready do
        Installer:step_shell()
        Installer:step_packages()
        
        UI:clear()
        UI:banner()
        Installer:step_nvim()
        
        UI:clear()
        UI:banner()
        Installer:step_git()
        
        -- Summary returns true to proceed, false to edit
        ready = Installer:step_summary()
        
        if not ready then
            -- Reset sensitive UIs or just loop back
            print(UI.colors.yellow .. "\nReloading configuration..." .. UI.colors.reset)
            os.execute("sleep 0.5")
            UI:clear()
        end
    end
    
    -- Execution Phase
    Installer:execute()
end

main()

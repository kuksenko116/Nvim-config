-- Omarchy (Arch Linux) integration. Everything here is a no-op on other systems.
--
-- Every Omarchy theme ships a neovim.lua written for LazyVim:
--   { { "<theme plugin>", ... }, { "LazyVim/LazyVim", opts = { colorscheme = "<name>" } } }
-- We use the plugin specs as-is and read the colorscheme name out of the LazyVim entry,
-- so `omarchy theme set ...` drives Neovim the same way it drives Omarchy's own setup.
-- Set vim.g.omarchy_follow_theme = false (before lazy.setup) to opt out.
local M = {}

local state_dir = vim.fn.expand("~/.local/state/omarchy/current")
local theme_file = state_dir .. "/theme/neovim.lua"

local function enabled()
	return vim.g.omarchy_follow_theme ~= false and vim.fn.filereadable(theme_file) == 1
end

local function is_lazyvim(plugin)
	return type(plugin) == "table" and plugin[1] == "LazyVim/LazyVim"
end

local function theme_spec()
	if not enabled() then
		return {}
	end
	local ok, spec = pcall(dofile, theme_file)
	return ok and type(spec) == "table" and spec or {}
end

-- lazy.nvim specs for the active theme's plugins (see plugins/ui/omarchy-theme.lua)
M.plugins = function()
	return vim.tbl_filter(function(plugin)
		return not is_lazyvim(plugin)
	end, theme_spec())
end

-- Colorscheme name chosen by the active theme, or nil
M.colorscheme = function()
	for _, plugin in ipairs(theme_spec()) do
		if is_lazyvim(plugin) and type(plugin.opts) == "table" then
			return plugin.opts.colorscheme
		end
	end
end

-- Apply the theme's colorscheme. False when there is none or its plugin isn't installed.
M.apply = function()
	local name = M.colorscheme()
	return name ~= nil and pcall(vim.cmd.colorscheme, name)
end

-- Follow theme changes while Neovim is running. omarchy-theme-set replaces
-- current/theme in one move, so watching current/ is enough.
M.watch = function()
	if not enabled() then
		return
	end
	local event, timer = vim.uv.new_fs_event(), vim.uv.new_timer()
	local current = M.colorscheme()
	event:start(state_dir, {}, function()
		-- several entries change per switch; react once they settle
		timer:start(
			200,
			0,
			vim.schedule_wrap(function()
				local name = M.colorscheme()
				if name == nil or name == current then
					return
				end
				current = name
				if not M.apply() then
					vim.notify(
						"Omarchy theme wants colorscheme '"
							.. name
							.. "'. Restart Neovim to install its plugin, or run :Lazy update if it is installed.",
						vim.log.levels.WARN
					)
				end
			end)
		)
	end)
end

return M

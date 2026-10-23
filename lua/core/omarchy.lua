-- Omarchy (Arch Linux) integration. Everything here is a no-op on other systems.
local M = {}

local theme_file = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")

-- Colorscheme name from the active Omarchy theme, or nil.
-- Omarchy themes ship a LazyVim spec ({ "LazyVim/LazyVim", opts = { colorscheme = ... } });
-- we only read the name out of it. Set vim.g.omarchy_follow_theme = false to opt out.
M.colorscheme = function()
	if vim.g.omarchy_follow_theme == false or vim.fn.filereadable(theme_file) == 0 then
		return nil
	end

	local ok, spec = pcall(dofile, theme_file)
	if not ok or type(spec) ~= "table" then
		return nil
	end

	for _, plugin in ipairs(spec) do
		if type(plugin) == "table" and plugin[1] == "LazyVim/LazyVim" and type(plugin.opts) == "table" then
			return plugin.opts.colorscheme
		end
	end
end

return M

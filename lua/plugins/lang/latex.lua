return {
	"lervag/vimtex",
	lazy = false,
	ft = { "tex", "latex" },
	init = function()
		-- zathura (Arch) gives forward/inverse search; "general" uses open/xdg-open
		vim.g.vimtex_view_method = vim.fn.executable("zathura") == 1 and "zathura" or "general"
		vim.g.vimtex_compiler_method = "latexmk"
		vim.cmd([[
            let g:vimtex_compiler_latexmk = {
              \ 'build_dir' : 'build',
              \ 'options' : [
              \   '-pdf',
              \   '-interaction=nonstopmode',
              \   '-synctex=1',
              \ ],
            \ }
        ]])
	end,
}

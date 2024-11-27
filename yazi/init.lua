require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

local home = os.getenv("HOME")
require("bunny"):setup({
	hops = {
		{ tag = "Home", path = home, key = "h" },
		{ tag = "Config", path = home .. "/.config", key = "c" },
		{ tag = "Local", path = home .. "/.local", key = "l" },
	},
	notify = false,
})

require("copy-file-contents"):setup({
	clipboard_cmd = "default",
	append_char = "\n",
	notification = true,
})

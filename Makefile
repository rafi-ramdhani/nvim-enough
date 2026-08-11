.PHONY: check smoke budget treesitter lint fmt fmt-check

# Everything CI runs, locally.
check: smoke budget lint fmt-check

smoke:
	nvim --headless -c "luafile scripts/smoke.lua" -c "qa!"

# NVIM_ENOUGH_NO_USER keeps your own lua/user/ plugins out of the count.
budget:
	NVIM_ENOUGH_NO_USER=1 nvim --headless -c "luafile scripts/budget.lua" -c "qa!"

treesitter:
	nvim --headless -c "luafile scripts/treesitter.lua" -c "qa!"

lint:
	shellcheck install.sh

fmt:
	stylua init.lua lua scripts

fmt-check:
	stylua --check init.lua lua scripts

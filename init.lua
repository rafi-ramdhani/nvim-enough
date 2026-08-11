-- nvim-enough: a Neovim configuration that is just enough.
--
-- Everything lives under lua/enough/. To change something, do not edit these
-- files: create lua/user/init.lua instead. It is gitignored, it is merged over
-- the defaults, and it survives `git pull`. See user.example/ for a template.

require("enough").setup()

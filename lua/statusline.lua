--------------------------------------------------------------------------------
---- lua/statusline.lua --------------------------------------------------------
--------------------------------------------------------------------------------

--[[
local function setInterval(interval, callback)
    local timer = uv.new_timer()
    timer:start(interval, interval, function ()
        callback()
    end)
    return timer
end
]]

local function lsp_status()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        -- todo: fish swimming
        return " no lsp "
    end
    local names = vim.iter(attached_clients)
        :map(function(client)
            local name = client.name:gsub("language.server", "ls")
            return name
        end)
        :totable()
    return " <" .. table.concat(names, ", ") .. "> "
end

-- middle will be bg/fg swap of the rest of the normal statusline
-- statusline remains theme agnostic
function apply_statusline_center_hl()
    local statusline_hl = vim.api.nvim_get_hl(0, { name = 'StatusLine' })
    vim.api.nvim_set_hl(0, 'StatusLineCenter', { fg = statusline_hl.bg, bg = statusline_hl.fg })
end
apply_statusline_center_hl()
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = apply_statusline_center_hl,
})

function get_statusline()
    return table.concat({
      ' %f',                    -- filepath relative to current dir
      ' (%LL)',                 -- line count
      '%r',                     -- is readonly
      '%m',                     -- is modified
      '%w',                     -- is preview
      '%=%#StatusLineCenter#',  -- (seperator)
      lsp_status(),             -- names of attached lsp clients
      '%#StatusLine#%=',        -- (seperator)
      '%y',                     -- filetype
      ' %2p%%',                 -- % scrolled through file
      ' %3l:%-2c '              -- row:col cursor coords
    }, "")
end

-- vim.o.statusline = "%{%v:lua.get_statusline()%}"
--hl-StatusLine

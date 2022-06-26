local Job = require("plenary.job")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local debug = function(str)
	print(vim.inspect(str))
end

local get_picker = function(opts, stuff)
	pickers.new(opts, {
		prompt_title = "Choose a recipe to run",
		finder = finders.new_table({
			results = stuff,
		}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				print(vim.inspect(selection))
				vim.api.nvim_put({ selection[1] }, "", false, true)
			end)
			return true
		end,
	}):find()
end

local get_available_recipes = function()
	local data, code = Job --TODO error check if not lazy
		:new({
			command = "just",
			args = { "--list" },
		})
		:sync()
	return data
end

local format_output = function(output)
	table.remove(output, 1)

	for _, value in pairs(output) do
		value:match("^%s*(.-)%s*$") --FIX shit dont work we need to remove whitespace
	end

	return output
end

local output = get_available_recipes()
local recipes = format_output(output)
get_picker({}, recipes)

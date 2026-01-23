local M = {}

local comment_map = {
	c = "// ",
	cpp = "// ",
	javascript = "// ",
	typescript = "// ",
	lua = "-- ",
	java = "# ",
	sh = "# "
}

local comment_editor = function(ft, current_line)
	local indent_length = 1
	-- count indent length
	while true 
	do
		if string.sub(current_line, indent_length, indent_length) ~= '\9' 
		then
			break
		end

		indent_length = indent_length + 1
	end

	-- If it not have file type not thing to do
	local prefix = comment_map[ft]
	if prefix == nil
	then
		return current_line
	end

	-- remove space
	local trim_current_line = (current_line:gsub("^%s*(.-)%s*$", "%1"))

	-- get comment_flag
	local prefix_length = #prefix
	local comment_flag = string.sub(trim_current_line, 1, prefix_length)

	-- remove comment flag
	if comment_flag == prefix
	then
		prefix = ""
		trim_current_line = string.sub(trim_current_line, prefix_length + 1, -1)
	end

	-- is this line have indent? if it have adding the indent
	local fill_indent = ""
	while indent_length > 1
	do
		fill_indent = fill_indent .. '\9'
		indent_length = indent_length - 1
	end

	local new_current_line = fill_indent .. prefix .. trim_current_line
	return new_current_line
end

local selection = function()
	local start_pos = vim.fn.getpos('v')
	local end_pos = vim.fn.getpos('.')

	local start_line = start_pos[2] - 1
	local end_line = end_pos[2]
	if end_line < start_line
	then
		return end_line - 1, start_line + 1
	end
	return start_line, end_line
end

local move_to_right = function(ft)
	vim.api.nvim_win_set_cursor(0, {vim.fn.getpos('.')[2], #comment_map[ft]})
end

M.toggle_signle_comment = function()
	local ft = vim.api.nvim_get_option_value("filetype", {buf = 0})
	local current_line = vim.api.nvim_get_current_line()

	local new_current_line = comment_editor(ft, current_line)
	vim.api.nvim_set_current_line(new_current_line)
	move_to_right(ft)
end

M.toggle_multiple_comment = function()
	local ft = vim.api.nvim_get_option_value("filetype", {buf = 0})
	local start_line, end_line = selection()
	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
	local buffer = {}

	-- loop each lines
	for i=1, #lines
	do
		local new_current_line = comment_editor(ft, lines[i])
		table.insert(buffer, new_current_line)
	end
	vim.api.nvim_buf_set_lines(0, start_line, end_line, false, buffer)
	
	-- change to normal mode after comment
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys(esc, "n", false)
	move_to_right(ft)
end

return M

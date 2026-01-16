local M = {}

local comment_map = {
	c = "// ",
	cpp = "// ",
	javascript = "// ",
	typescript = "// ",
	lua = "-- ",
	java = "# "
}

M.toggle_signle_comment = function()
	local ft = vim.api.nvim_get_option_value("filetype", {buf = 0})
	local current_line = vim.api.nvim_get_current_line()

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
		return nil
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
		print(trim_current_line)
	end

	-- is this line have indent? if it have adding the indent
	local fill_indent = ""
	while indent_length > 1
	do
		fill_indent = fill_indent .. '\9'
		indent_length = indent_length - 1
	end

	local new_current_line = fill_indent .. prefix .. trim_current_line
	vim.api.nvim_set_current_line(new_current_line)
end

M.toggle_multiple_comment = function()
	local win_id = vim.api.nvim_win_get_buf(0)
	local buf = vim.api.nvim_win_get_buf(0)
	-- print("buf_line_count: ", vim.api.nvim_buf_line_count(buf))
	local start_line = vim.fn.getpos('v')[2]
	local end_line = vim.fn.getpos('.')[2]
	local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
	print("===")
	for i=start_line, end_line
	do
		print(lines[i])
	end
end

return M

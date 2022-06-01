-- LUA HTML parser
-- Original: https://gist.github.com/exebetche/6126573
-- Adapted by Andrey Gavrilov

local parser = {}

local empty_tags = {
	br = true,
	hr = true,
	img = true,
	embed = true,
	param = true,
	area = true,
	col = true,
	input = true,
	meta = true,
	link = true,
	base = true,
	basefont = true,
	frame = true,
	isindex = true
}

-- omittable tags siblings
-- if an open tag from the primary entry  follow
-- an unclosed tag of the secondary,
-- the secondary is automatically closed
-- See http://www.w3.org/TR/html5/syntax.html#optional-tags
local omittable_tags = {
	tbody = {
		thead = true,
		tbody = true,
		tfoot = true
	},
	thead = {
		thead = true,
		tbody = true,
		tfoot = true
	},
	tfoot = {
		thead = true,
		tbody = true,
		tfoot = true
	},
	td = {
		td = true,
		th = true
	},
	th = {
		td = true,
		th = true
	},
	tr = {
		tr = true
	},
	dd = {
		dd = true,
		dt = true
	},
	dt = {
		dd = true,
		dt = true
	},
	optgroup = {
		optgroup = true,
		option = true
	},
	optgroup = {
		optgroup = true,
		option = true
	},
	address = { p = true},
	article = { p = true},
	aside = { p = true},
	blockquote = { p = true},
	dir = { p = true},
	div = { p = true},
	dl = { p = true},
	fieldset = { p = true},
	footer = { p = true},
	form = { p = true},
	h1 = { p = true},
	h2 = { p = true},
	h3 = { p = true},
	h4 = { p = true},
	h5 = { p = true},
	h6 = { p = true},
	header = { p = true},
	hgroup = { p = true},
	hr = { p = true},
	menu = { p = true},
	nav = { p = true},
	ol = { p = true},
	p = { p = true},
	pre = { p = true},
	section = { p = true},
	table = { p = true},
	ul= { p = true}
}

-- omittable tags children
local omittable_tags2 = {
	table = {
		tr = true,
		td = true,
		p = true,
	},
	tr = {
		td = true,
		p = true
	},
	td = {
		p = true
	}
}

function parser.parse(data, lazy)
	local tree = {}
	local stack = {}
	local level = 0
	local new_level = 0
	table.insert(stack, tree)
	local node
	local lower_tag
	local script_open = false
	local script_val = ""
	local script_node = nil
	local tag_match = ""
	lazy = lazy or false

	for b, op, tag, attr, op2, bl1, val, bl2 in string.gmatch(
		data,
		"(<)(%/?!?)([%w:_-'\\\"%[]+)(.-)(%/?%-?)>"..
		"([%s\r\n\t]*)([^<]*)([%s\r\n\t]*)"
	) do
		lower_tag = string.lower(tag)

		if script_open then
			if lower_tag == "script" and op == "/" then
				node.childNodes[1].value = 	string.gsub(script_val, "^<!%[CDATA%[", "<!--//%1")
				if val ~= "" then
					table.insert(stack[level], {
						tagName = "textNode",
						value = val
					})
				end
				level = level - 1
				script_open = false
			else
				script_val = script_val..b..op..tag..attr..op2..bl1..val..bl2
			end
		elseif op == "!" then
		elseif op == "/" then
			-- Check if the previous children elements end tag have been omitted
			-- and should be close automatically

			while not lazy
			and omittable_tags2[lower_tag]
			and #stack[level] > 0
			and omittable_tags2[lower_tag][stack[level][#stack[level]].tagName]
			do
				print("Auto closing "..
				stack[level][#stack[level]].tagName..
				" followed by ending "..lower_tag)

				level = level - 1
				table.remove(stack)
			end
			if level==0 then return tree end

			if lower_tag ~= stack[level][#stack[level]].tagName
			then
				print("Mismatch: "..lower_tag..
				", (has "..stack[level][#stack[level]].tagName..")")
			end

			level = level - 1
			table.remove(stack)
		else

			level = level + 1
			node = nil
			node = {}
			node.tagName = lower_tag
			node.childNodes = {}

			if attr ~= "" then
				node.attr = {}

				for n, v in string.gmatch(
					attr,
					"%s([^%s=]+)=\"([^\"]+)\""
				) do
					node.attr[n] = string.gsub(v, '"', '[^\\]\\"')
				end

				for n, v in string.gmatch(
					attr,
					"%s([^%s=]+)='([^']+)'"
				) do
					node.attr[n] = string.gsub(v, '"', '[^\\]\\"')
				end
			end

			if lower_tag == "script"
			and node.attr
			and not node.attr["src"]
			then
				script_val = bl1..val..bl2
				table.insert(node.childNodes, {
					tagName = "textNode",
					value = ""
				})

				table.insert(stack[level], node)
				script_open = true
			else
				-- Check if the previous sibling element end tag has been omitted
				-- and should be close automatically

				if not lazy
				and omittable_tags[lower_tag]
				and level > 1
				and stack[level-1]
				and #stack[level-1] > 0
				and omittable_tags[lower_tag][stack[level-1][#stack[level-1]].tagName] == true
				then
					print("Auto closing "..
					stack[level-1][#stack[level-1]].tagName..
					" followed by "..lower_tag)

					level = level - 1
					table.remove(stack)
					if level==0 then return tree end
				end

				table.insert(stack[level], node)

				if empty_tags[lower_tag] then
					if val ~= "" then
						table.insert(stack[level], {
							tagName = "textNode",
							value = val
						})
					end
					node.childNodes = nil
					level = level - 1
				else
					if val ~= "" then
						table.insert(node.childNodes, {
							tagName = "textNode",
							value = val
						})
					end
					table.insert(stack, node.childNodes)
				end

			end
		end
	end
	return tree
end

return parser

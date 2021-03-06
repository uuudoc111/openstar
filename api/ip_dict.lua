


local function get_argByName(name)
	local x = 'arg_'..name
    local _name = ngx.unescape_uri(ngx.var[x])
    return _name
end

local _action = get_argByName("action")
local _dict = get_argByName("dict")
local _key = get_argByName("key")



local tmpdict = ngx.shared[_dict]
if tmpdict == nil then sayHtml_ext("dict is nil") end

--- add 仅对ip_dict操作
if _action == "add" then

	if _key == "" then
		sayHtml_ext({})
	else
		local _value = get_argByName("value")
		if _value ~= "allow" then _value = "deny" end
		local _time = tonumber( get_argByName("time")) or 0
		local re = tmpdict:safe_add(_key,_value,_time)
		sayHtml_ext({add=re,key=_key,value=_value})
	end
--- del 对所有ngx.shared可以删除		
elseif _action == "del" then

	if _key == "" then
		sayHtml_ext({})
	elseif _key == "all_key" then
	    local re = tmpdict:flush_all()
		local re1 = tmpdict:flush_expired(0)
		sayHtml_ext({flush_all=re,flush_expired=re1})
	else
		local re = tmpdict:delete(_key)
		local re1 = tmpdict:flush_expired(0)
		sayHtml_ext({delete=re,flush_expired=re1})
	end
--- set 仅对ip_dict操作
elseif _action == "set" then
	if _key == "" then
		sayHtml_ext({})
	else
		local _value = get_argByName("value")
		if _value ~= "allow" then _value = "deny" end
		local re = tmpdict:replace(_key,_value)
		sayHtml_ext({replace=re})
	end
--- get 对所有ngx.shared可查询
elseif _action == "get" then

	if _key == "count_key" then
		local _tb = tmpdict:get_keys(0)
		sayHtml_ext(table.getn(_tb))
	elseif _key == "all_key" then
		local _tb,tb_all = tmpdict:get_keys(0),{}
		for i,v in ipairs(_tb) do
			tb_all[v] = tmpdict:get(v)
		end
		sayHtml_ext(tb_all)
	elseif _key == "" then
		local _tb = tmpdict:get_keys(1024)
		sayHtml_ext(_tb)
	else
		sayHtml_ext(tmpdict:get(_key))
	end

else
	sayHtml_ext({code="action_error"})
end


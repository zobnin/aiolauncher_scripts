-- type = "module"
-- CSV Module
-- http://help.interfaceware.com/kb/parsing-csv-files

local function parse_line(line,sep) 
   local res = {}
   local pos = 1
   sep = sep or ','
   while true do 
      local c = string.sub(line,pos,pos)
      if (c == "") then break end
      local posn = pos 
      local ctest = string.sub(line,pos,pos)

      while ctest == ' ' do
         -- handle space(s) at the start of the line (with quoted values)
         posn = posn + 1
         ctest = string.sub(line,posn,posn) 
         if ctest == '"' then
            pos = posn
            c = ctest
         end
      end
      if (c == '"') then
         -- quoted value (ignore separator within)
         local txt = ""
         repeat
            local startp,endp = string.find(line,'^%b""',pos)
            txt = txt..string.sub(line,startp+1,endp-1)
            pos = endp + 1
            c = string.sub(line,pos,pos) 
            if (c == '"') then 
               txt = txt..'"' 
               -- check first char AFTER quoted string, if it is another
               -- quoted string without separator, then append it
               -- this is the way to "escape" the quote char in a quote. example:
               --   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
            elseif c == ' ' then
               -- handle space(s) before the delimiter (with quoted values)
               while c == ' ' do
                  pos = pos + 1
                  c = string.sub(line,pos,pos) 
               end
            end
         until (c ~= '"')
         table.insert(res,txt)

         if not (c == sep or c == "") then 
            error("ERROR: Invalid CSV field - near character "..pos.." in this line of the CSV file: \n"..line, 3)
         end
         pos = pos + 1
         posn = pos 
         ctest = string.sub(line,pos,pos)

         while ctest == ' ' do
            -- handle space(s) after the delimiter (with quoted values)
            posn = posn + 1
            ctest = string.sub(line,posn,posn) 
            if ctest == '"' then
               pos = posn
               c = ctest
            end
         end
      else	
         -- no quotes used, just look for the first separator
         local startp,endp = string.find(line,sep,pos)
         if (startp) then 
            table.insert(res,string.sub(line,pos,startp-1))
            pos = endp + 1
         else
            -- no separator found -> use rest of string and terminate
            table.insert(res,string.sub(line,pos))
            break
         end 
      end
   end
   return res
end
 
------------------------------------
---- Module Interface functions ----
------------------------------------
local csv = {}
 
function csv.parse(data, separator)
   -- handle '\r\n\' as line separator
   data = data:gsub('\r\n','\n')
   -- handle '\r' (bad form) as line separator  
   data = data:gsub('\r','\n')
   local result={}
   
   for line in data:gmatch("([^\n]+)") do
      local parsed_line = parse_line(line, separator)
      table.insert(result, parsed_line)
   end

   return result
end
 
return csv
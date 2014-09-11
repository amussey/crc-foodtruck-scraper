local lom = require 'lxp.lom'
local xpath = require 'xpath'

function print_r ( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t,"  ")
end

function string:split( inSplitPattern, outResults )

   if not outResults then
      outResults = { }
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( self, theStart ) )
   return outResults
end

function trimString( s )
   return string.match( s,"^()%s*$") and "" or string.match(s,"^%s*(.*%S)" )
end


local response = http.request {
    url = 'http://www.vtcrc.com/resources/food-truck-thursday/',
    params = {}
}


-- tab = lxp.lom.parse (response.content)
-- local condition = lxp.lom.parse(response.content)

-- print_r(response.content:split("\n"))

local page = response.content:split("\n")
table.remove(page, 1)
table.remove(page, 2)
table.remove(page, 3)
table.remove(page, 4)

-- print_r(page)

while string.find(page[1], "<p><strong>Thursday") == nil
do
    table.remove(page, 1)
end

local i = 1
while string.find(page[i], "</div>") == nil
do
      i = i + 1
end

while page[i] ~= nil
do
      table.remove(page, i)
end

----- Alright, so now we've cleaned out all of the excess junk.

-- print_r(page)
-- print("-------")

local trucks = {}
local current_date = ""
while page[1] ~= nil
do
      if string.find(page[1], "<p><strong>Thursday") ~= nil then
              current_date = page[1]
                current_date = string.gsub(current_date, "<p><strong>", "")
            current_date = string.gsub(current_date, "</strong></p>", "")
              trucks[current_date] = {}
        end
        if string.find(page[1], "<li>") ~= nil then
                current_truck = string.gsub(page[1], "<li>", "")
            current_truck = string.gsub(current_truck, "</li>", "")
            current_truck = trimString(string.gsub(current_truck, "&nbsp;", ""))
              table.insert(trucks[current_date], current_truck)
      end
        table.remove(page, 1)
end

-- print_r(json.stringify(trucks))


-- <p><strong>Thursday table.concat(page, "\n")


return json.stringify(trucks), {["Content-Type"]="application/json"}

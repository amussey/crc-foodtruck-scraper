local lom = require 'lxp.lom'
local xpath = require 'xpath'

local print_r = require "amussey/lib/lua/print_r"
require "amussey/lib/lua/stringOps"

local response = http.request {
    url = 'http://www.vtcrc.com/resources/food-truck-thursday/',
    params = {}
}


local page = response.content:split("\n")
table.remove(page, 1)
table.remove(page, 2)
table.remove(page, 3)
table.remove(page, 4)


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
        current_truck = string.gsub(current_truck, "&nbsp;", ""):trim()
        table.insert(trucks[current_date], current_truck)
    end
    table.remove(page, 1)
end


return json.stringify(trucks), {["Content-Type"]="application/json"}

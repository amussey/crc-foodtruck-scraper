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


local trucks = {}
local currentTruckNumber = -1
local currentDate = ""
while page[1] ~= nil and string.find(page[1], "</div>") == nil
do
    if string.find(page[1], "<p><strong>Thursday") ~= nil then
        currentTruckNumber = currentTruckNumber + 1
        currentDate = page[1]
        currentDate = string.gsub(currentDate, "<p><strong>", "")
        currentDate = string.gsub(currentDate, "</strong></p>", "")
        trucks["" .. currentTruckNumber] = {["date"]=currentDate, ["trucks"]={}}
    end
    if string.find(page[1], "<li>") ~= nil then
        currentTruck = string.gsub(page[1], "<li>", "")
        currentTruck = string.gsub(currentTruck, "</li>", "")
        currentTruck = string.gsub(currentTruck, "&nbsp;", ""):trim()
        table.insert(trucks["" .. currentTruckNumber]["trucks"], currentTruck)
    end
    table.remove(page, 1)
end


return json.stringify(trucks), {["Content-Type"]="application/json"}

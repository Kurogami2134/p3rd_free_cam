function PackIEEE754(number)
    if number == 0 then
        return string.char(0x00, 0x00, 0x00, 0x00)
    elseif number ~= number then
        return string.char(0xFF, 0xFF, 0xFF, 0xFF)
    else
        local sign = 0x00
        if number < 0 then
            sign = 0x80
            number = -number
        end
        local mantissa, exponent = math.frexp(number)
        exponent = exponent + 0x7F
        if exponent <= 0 then
            mantissa = math.ldexp(mantissa, exponent - 1)
            exponent = 0
        elseif exponent > 0 then
            if exponent >= 0xFF then
                return string.char(sign + 0x7F, 0x80, 0x00, 0x00)
            elseif exponent == 1 then
                exponent = 0
            else
                mantissa = mantissa * 2 - 1
                exponent = exponent - 1
            end
        end
        mantissa = math.floor(math.ldexp(mantissa, 23) + 0.5)
        return string.char(
                sign + math.floor(exponent / 2),
                (exponent % 2) * 0x80 + math.floor(mantissa / 0x10000),
                math.floor(mantissa / 0x100) % 0x100,
                mantissa % 0x100)
    end
end

function short_to_bytes(int) --> bytes
    local bin = string.char(int & 0xFF)..string.char((int >> 8) & 0xFF)
    return bin
end

function int_to_bytes(int) --> bytes
    local bin = string.char(int & 0xFF)..string.char((int >> 8) & 0xFF)
    bin = bin..string.char((int >> 16) & 0xFF)..string.char((int >> 24) & 0xFF)
    return bin
end

function save_settings(path, values) --> None
    local file = io.open("MODS/free_cam/"..path, "r")
    data_1 = file:read(0x140)
    file:read(0x1C)
    data_2 = file:read("*all")
    file:close()

    local file = io.open("MODS/free_cam/"..path, "w")
    file:write(data_1)
    
    file:write(string.reverse(PackIEEE754(values[3])))
    file:write(string.reverse(PackIEEE754(values[4])))
    file:write(string.reverse(PackIEEE754(values[5])))
    file:write(string.reverse(PackIEEE754(values[2])))
    file:write(string.reverse(PackIEEE754(-160)))
    file:write(string.reverse(PackIEEE754(560)))
    file:write(int_to_bytes(values[1]))
    
    file:write(data_2)
    file:close()
end

function main() --> nil
    local selected_element = 1
    local elements = {"Horizontal Speed", "Vertical Speed", "Default Position", 'Camera Distance', "Distance Scale"}
    local values = {8, .3, 185, 520, 3}
    local mins = {1, .05, -160, 0, .5}
    local maxs = {16, .8, 560, 2000, 6}
    local steps = {1, .05, 15, 20, .5}

    while true do
        buttons.read()

        for i=1, #elements do
            screen.print(20, 40 + 16 * i, elements[i], .6, selected_element == i and color.green or color.white)
            screen.print(300, 40 + 16 * i, values[i], .6, selected_element == i and color.green or color.white)
        end

        if buttons.down then
            selected_element = selected_element + 1
        elseif buttons.up then
            selected_element = selected_element - 1
        end
        if selected_element == 0 then
            selected_element = #elements
        elseif selected_element > #elements then
            selected_element = 1
        end

        if buttons.left then
            values[selected_element] = math.minmax(
                values[selected_element] - steps[selected_element],
                mins[selected_element],
                maxs[selected_element]
            )
        elseif buttons.right then
            values[selected_element] = math.minmax(
                values[selected_element] + steps[selected_element],
                mins[selected_element],
                maxs[selected_element]
            )
        end

        if buttons.circle or buttons.cross then
            save_settings("hd.bin", values)
            save_settings("psp.bin", values)
            break
        end
        screen.flip()
    end
end

main()

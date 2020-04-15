local proto = Proto('sproto', 'Sproto Protocol')

function proto.dissector(buffer, pinfo, tree)
    pinfo.cols.protocol = 'Sproto'

    local function recurse(parent, buffer, offset)
        if buffer():len() < offset + 2 then
            return -1
        end
        local length = buffer(offset, 2):uint()
        if buffer():len() < offset + 2 + length then
            return -1
        end
        local subtree = tree:add(proto, buffer(), "Sproto Protocol Data")
        subtree:add(buffer(offset, 2), "Data Length :" .. length)
        --todo解包 用了sproto自带的rpc response的包没法解 
        return offset + 2 + length
    end

    local offset = 0
    while offset < buffer():len() do
        offset = recurse(tree, buffer, offset)
        if offset < 0 then
            pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
            return
        end
    end
end

local dissectors = DissectorTable.get('tcp.port')
for _, port in ipairs { 15601 } do
    dissectors:add(port, proto)
end

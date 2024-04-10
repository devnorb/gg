-- skid this all you want idc anymore
-- THIS HAS ONLY BEEN TESTED WITH MACSPLOIT!!!
-- ig you can modify it for hydrogen
repeat task.wait() until game:IsLoaded();
local macsploitVersion = "0.9c"
local oldsti = setthreadidentity;
local oldgti = getthreadidentity();
local oldie = identifyexecutor();
local Environment = getgenv();
Environment.cache = nil;
local currentThreadIdentity;
local lastClonedInstance;
local cachedParts = {};
local allDrawingObjects = {};
local allDrawingObjectsCached = {};
--[[ sha384 hashing for getscripthash - credits to Egor-Skriptunoff ]]--
-- yes skidded this part and its very messy 
local unpack, byte, char, sub, floor, ceil, type = table.unpack or unpack, string.byte, string.char, string.sub,
    math.floor, math.ceil, type;
local sha512_feed_128
local sha2_K_lo, sha2_K_hi, sha2_H_lo, sha2_H_hi = {}, {}, {}, {}
local sha2_H_ext256                              = { [224] = {}, [256] = sha2_H_hi }
local sha2_H_ext512_lo, sha2_H_ext512_hi         = { [384] = {}, [512] = sha2_H_lo }, { [384] = {}, [512] = sha2_H_hi }
local HEX64
local common_W                                   = {}
local K_lo_modulo, hi_factor                     = 4294967296, 0
local sigma                                      = {
    { 1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15, 16 },
    { 15, 11, 5,  9,  10, 16, 14, 7,  2,  13, 1,  3,  12, 8,  6,  4 },
    { 12, 9,  13, 1,  6,  3,  16, 14, 11, 15, 4,  7,  8,  2,  10, 5 },
    { 8,  10, 4,  2,  14, 13, 12, 15, 3,  7,  6,  11, 5,  1,  16, 9 },
    { 10, 1,  6,  8,  3,  5,  11, 16, 15, 2,  12, 13, 7,  9,  4,  14 },
    { 3,  13, 7,  11, 1,  12, 9,  4,  5,  14, 8,  6,  16, 15, 2,  10 },
    { 13, 6,  2,  16, 15, 14, 5,  11, 1,  8,  7,  4,  10, 3,  9,  12 },
    { 14, 12, 8,  15, 13, 2,  4,  10, 6,  1,  16, 5,  9,  7,  3,  11 },
    { 7,  16, 15, 10, 12, 4,  1,  9,  13, 3,  14, 8,  2,  5,  11, 6 },
    { 11, 3,  9,  5,  8,  7,  2,  6,  16, 12, 10, 15, 4,  13, 14, 1 },
}; sigma[11], sigma[12]                          = sigma[1], sigma[2]
for _, libname in ipairs(_VERSION == "Lua 5.2" and { "bit32", "bit" } or { "bit", "bit32" }) do
    if type(_G[libname]) == "table" and _G[libname].bxor then
        b = _G[libname]
        library_name = libname
        break
    end
end

local AND, XOR, HEX
do
    local AND_of_two_bytes = { [0] = 0 }
    local idx = 0
    for y = 0, 127 * 256, 256 do
        for x = y, y + 127 do
            x = AND_of_two_bytes[x] * 2
            AND_of_two_bytes[idx] = x
            AND_of_two_bytes[idx + 1] = x
            AND_of_two_bytes[idx + 256] = x
            AND_of_two_bytes[idx + 257] = x + 1
            idx = idx + 2
        end
        idx = idx + 256
    end

    local function and_or_xor(x, y, operation)
        local x0 = x % 2 ^ 32
        local y0 = y % 2 ^ 32
        local rx = x0 % 256
        local ry = y0 % 256
        local res = AND_of_two_bytes[rx + ry * 256]
        x = x0 - rx
        y = (y0 - ry) / 256
        rx = x % 65536
        ry = y % 256
        res = res + AND_of_two_bytes[rx + ry] * 256
        x = (x - rx) / 256
        y = (y - ry) / 256
        rx = x % 65536 + y % 256
        res = res + AND_of_two_bytes[rx] * 65536
        res = res + AND_of_two_bytes[(x + y - rx) / 256] * 16777216
        if operation then
            res = x0 + y0 - operation * res
        end
        return res
    end

    function AND(x, y)
        return and_or_xor(x, y)
    end

    function OR(x, y)
        return and_or_xor(x, y, 1)
    end

    function XOR(x, y, z, t, u)
        if z then
            if t then
                if u then
                    t = and_or_xor(t, u, 2)
                end
                z = and_or_xor(z, t, 2)
            end
            y = and_or_xor(y, z, 2)
        end
        return and_or_xor(x, y, 2)
    end

    function XOR_BYTE(x, y)
        return x + y - 2 * AND_of_two_bytes[x + y * 256]
    end
end

HEX = HEX or
    pcall(string.format, "%x", 2 ^ 31) and
    function(x)
        return string.format("%08x", x % 4294967296)
    end
    or
    function(x)
        return string.format("%08x", (x + 2 ^ 31) % 2 ^ 32 - 2 ^ 31)
    end

local function XORA5(x, y)
    return XOR(x, y or 0xA5A5A5A5) % 4294967296
end

XOR = XOR or XORA5

function sha512_feed_128(H_lo, H_hi, str, offs, size)
    -- offs >= 0, size >= 0, size is multiple of 128
    -- W1_hi, W1_lo, W2_hi, W2_lo, ...   Wk_hi = W[2*k-1], Wk_lo = W[2*k]
    local W, K_lo, K_hi = common_W, sha2_K_lo, sha2_K_hi
    local h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo = H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5],
        H_lo[6], H_lo[7], H_lo[8]
    local h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi = H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5],
        H_hi[6], H_hi[7], H_hi[8]
    for pos = offs, offs + size - 1, 128 do
        for j = 1, 16 * 2 do
            pos = pos + 4
            local a, b, c, d = byte(str, pos - 3, pos)
            W[j] = ((a * 256 + b) * 256 + c) * 256 + d
        end
        for jj = 17 * 2, 80 * 2, 2 do
            local a_hi, a_lo, b_hi, b_lo = W[jj - 31], W[jj - 30], W[jj - 5], W[jj - 4]
            local b_hi_6, b_hi_19, b_hi_29, b_lo_19, b_lo_29, a_hi_1, a_hi_7, a_hi_8, a_lo_1, a_lo_8 =
                b_hi % 2 ^ 6, b_hi % 2 ^ 19, b_hi % 2 ^ 29, b_lo % 2 ^ 19, b_lo % 2 ^ 29, a_hi % 2 ^ 1,
                a_hi % 2 ^ 7,
                a_hi % 2 ^ 8, a_lo % 2 ^ 1, a_lo % 2 ^ 8
            local tmp1 = XOR((a_lo - a_lo_1) / 2 ^ 1 + a_hi_1 * 2 ^ 31, (a_lo - a_lo_8) / 2 ^ 8 + a_hi_8 * 2 ^ 24,
                    (a_lo - a_lo % 2 ^ 7) / 2 ^ 7 + a_hi_7 * 2 ^ 25) % 2 ^ 32
                +
                XOR((b_lo - b_lo_19) / 2 ^ 19 + b_hi_19 * 2 ^ 13, b_lo_29 * 2 ^ 3 + (b_hi - b_hi_29) / 2 ^ 29,
                    (b_lo - b_lo % 2 ^ 6) / 2 ^ 6 + b_hi_6 * 2 ^ 26) % 2 ^ 32
                + W[jj - 14] + W[jj - 32]
            local tmp2 = tmp1 % 2 ^ 32
            W[jj - 1] = (XOR((a_hi - a_hi_1) / 2 ^ 1 + a_lo_1 * 2 ^ 31, (a_hi - a_hi_8) / 2 ^ 8 + a_lo_8 * 2 ^ 24, (a_hi - a_hi_7) / 2 ^ 7)
                + XOR((b_hi - b_hi_19) / 2 ^ 19 + b_lo_19 * 2 ^ 13, b_hi_29 * 2 ^ 3 + (b_lo - b_lo_29) / 2 ^ 29, (b_hi - b_hi_6) / 2 ^ 6)
                + W[jj - 15] + W[jj - 33] + (tmp1 - tmp2) / 2 ^ 32) % 2 ^ 32
            W[jj] = tmp2
        end
        local a_lo, b_lo, c_lo, d_lo, e_lo, f_lo, g_lo, h_lo = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo,
            h8_lo
        local a_hi, b_hi, c_hi, d_hi, e_hi, f_hi, g_hi, h_hi = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi,
            h8_hi
        for j = 1, 80 do
            local jj = 2 * j
            local e_lo_9, e_lo_14, e_lo_18, e_hi_9, e_hi_14, e_hi_18 = e_lo % 2 ^ 9, e_lo % 2 ^ 14, e_lo % 2 ^ 18,
                e_hi % 2 ^ 9, e_hi % 2 ^ 14, e_hi % 2 ^ 18
            local tmp1 = (AND(e_lo, f_lo) + AND(-1 - e_lo, g_lo)) % 2 ^ 32 + h_lo + K_lo[j] + W[jj]
                +
                XOR((e_lo - e_lo_14) / 2 ^ 14 + e_hi_14 * 2 ^ 18, (e_lo - e_lo_18) / 2 ^ 18 + e_hi_18 * 2 ^ 14,
                    e_lo_9 * 2 ^ 23 + (e_hi - e_hi_9) / 2 ^ 9) % 2 ^ 32
            local z_lo = tmp1 % 2 ^ 32
            local z_hi = AND(e_hi, f_hi) + AND(-1 - e_hi, g_hi) + h_hi + K_hi[j] + W[jj - 1] +
                (tmp1 - z_lo) / 2 ^ 32
                +
                XOR((e_hi - e_hi_14) / 2 ^ 14 + e_lo_14 * 2 ^ 18, (e_hi - e_hi_18) / 2 ^ 18 + e_lo_18 * 2 ^ 14,
                    e_hi_9 * 2 ^ 23 + (e_lo - e_lo_9) / 2 ^ 9)
            h_lo = g_lo; h_hi = g_hi
            g_lo = f_lo; g_hi = f_hi
            f_lo = e_lo; f_hi = e_hi
            tmp1 = z_lo + d_lo
            e_lo = tmp1 % 2 ^ 32
            e_hi = (z_hi + d_hi + (tmp1 - e_lo) / 2 ^ 32) % 2 ^ 32
            d_lo = c_lo; d_hi = c_hi
            c_lo = b_lo; c_hi = b_hi
            b_lo = a_lo; b_hi = a_hi
            local b_lo_2, b_lo_7, b_lo_28, b_hi_2, b_hi_7, b_hi_28 = b_lo % 2 ^ 2, b_lo % 2 ^ 7, b_lo % 2 ^ 28,
                b_hi % 2 ^ 2, b_hi % 2 ^ 7, b_hi % 2 ^ 28
            tmp1 = z_lo + (AND(d_lo, c_lo) + AND(b_lo, XOR(d_lo, c_lo))) % 2 ^ 32
                +
                XOR((b_lo - b_lo_28) / 2 ^ 28 + b_hi_28 * 2 ^ 4, b_lo_2 * 2 ^ 30 + (b_hi - b_hi_2) / 2 ^ 2,
                    b_lo_7 * 2 ^ 25 + (b_hi - b_hi_7) / 2 ^ 7) % 2 ^ 32
            a_lo = tmp1 % 2 ^ 32
            a_hi = (z_hi + AND(d_hi, c_hi) + AND(b_hi, XOR(d_hi, c_hi)) + (tmp1 - a_lo) / 2 ^ 32
                    + XOR((b_hi - b_hi_28) / 2 ^ 28 + b_lo_28 * 2 ^ 4, b_hi_2 * 2 ^ 30 + (b_lo - b_lo_2) / 2 ^ 2, b_hi_7 * 2 ^ 25 + (b_lo - b_lo_7) / 2 ^ 7)) %
                2 ^ 32
        end
        a_lo = h1_lo + a_lo
        h1_lo = a_lo % 2 ^ 32
        h1_hi = (h1_hi + a_hi + (a_lo - h1_lo) / 2 ^ 32) % 2 ^ 32
        a_lo = h2_lo + b_lo
        h2_lo = a_lo % 2 ^ 32
        h2_hi = (h2_hi + b_hi + (a_lo - h2_lo) / 2 ^ 32) % 2 ^ 32
        a_lo = h3_lo + c_lo
        h3_lo = a_lo % 2 ^ 32
        h3_hi = (h3_hi + c_hi + (a_lo - h3_lo) / 2 ^ 32) % 2 ^ 32
        a_lo = h4_lo + d_lo
        h4_lo = a_lo % 2 ^ 32
        h4_hi = (h4_hi + d_hi + (a_lo - h4_lo) / 2 ^ 32) % 2 ^ 32
        a_lo = h5_lo + e_lo
        h5_lo = a_lo % 2 ^ 32
        h5_hi = (h5_hi + e_hi + (a_lo - h5_lo) / 2 ^ 32) % 2 ^ 32
        a_lo = h6_lo + f_lo
        h6_lo = a_lo % 2 ^ 32
        h6_hi = (h6_hi + f_hi + (a_lo - h6_lo) / 2 ^ 32) % 2 ^ 32
        a_lo = h7_lo + g_lo
        h7_lo = a_lo % 2 ^ 32
        h7_hi = (h7_hi + g_hi + (a_lo - h7_lo) / 2 ^ 32) % 2 ^ 32
        a_lo = h8_lo + h_lo
        h8_lo = a_lo % 2 ^ 32
        h8_hi = (h8_hi + h_hi + (a_lo - h8_lo) / 2 ^ 32) % 2 ^ 32
    end
    H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8] = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo,
        h6_lo,
        h7_lo, h8_lo
    H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8] = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi,
        h6_hi,
        h7_hi, h8_hi
end

do
    local function mul(src1, src2, factor, result_length)
        local result, carry, value, weight = {}, 0.0, 0.0, 1.0
        for j = 1, result_length do
            for k = math.max(1, j + 1 - #src2), math.min(j, #src1) do
                carry = carry +
                    factor * src1[k] *
                    src2
                    [j + 1 - k] -- "int32" is not enough for multiplication result, that's why "factor" must be of type "double"
            end
            local digit = carry % 2 ^ 24
            result[j] = floor(digit)
            carry = (carry - digit) / 2 ^ 24
            value = value + digit * weight
            weight = weight * 2 ^ 24
        end
        return result, value
    end

    local idx, step, p, one, sqrt_hi, sqrt_lo = 0, { 4, 1, 2, -2, 2 }, 4, { 1 }, sha2_H_hi, sha2_H_lo
    repeat
        p = p + step[p % 6]
        local d = 1
        repeat
            d = d + step[d % 6]
            if d * d > p then -- next prime number is found
                local root = p ^ (1 / 3)
                local R = root * 2 ^ 40
                R = mul({ R - R % 1 }, one, 1.0, 2)
                local _, delta = mul(R, mul(R, R, 1.0, 4), -1.0, 4)
                local hi = R[2] % 65536 * 65536 + floor(R[1] / 256)
                local lo = R[1] % 256 * 16777216 + floor(delta * (2 ^ -56 / 3) * root / p)
                if idx < 16 then
                    root = p ^ (1 / 2)
                    R = root * 2 ^ 40
                    R = mul({ R - R % 1 }, one, 1.0, 2)
                    _, delta = mul(R, R, -1.0, 2)
                    local hi = R[2] % 65536 * 65536 + floor(R[1] / 256)
                    local lo = R[1] % 256 * 16777216 + floor(delta * 2 ^ -17 / root)
                    local idx = idx % 8 + 1
                    sha2_H_ext256[224][idx] = lo
                    sqrt_hi[idx], sqrt_lo[idx] = hi, lo + hi * hi_factor
                    if idx > 7 then
                        sqrt_hi, sqrt_lo = sha2_H_ext512_hi[384], sha2_H_ext512_lo[384]
                    end
                end
                idx = idx + 1
                sha2_K_hi[idx], sha2_K_lo[idx] = hi, lo % K_lo_modulo + hi * hi_factor
                break
            end
        until p % d == 0
    until idx > 79
end

local function hash(width, message)
    local length, tail, H_lo, H_hi = 0.0, "", { unpack(sha2_H_ext512_lo[width]) },
        not HEX64 and { unpack(sha2_H_ext512_hi[width]) }

    local function partial(message_part)
        if message_part then
            if tail then
                length = length + #message_part
                local offs = 0
                if tail ~= "" and #tail + #message_part >= 128 then
                    offs = 128 - #tail
                    sha512_feed_128(H_lo, H_hi, tail .. sub(message_part, 1, offs), 0, 128)
                    tail = ""
                end
                local size = #message_part - offs
                local size_tail = size % 128
                sha512_feed_128(H_lo, H_hi, message_part, offs, size - size_tail)
                tail = tail .. sub(message_part, #message_part + 1 - size_tail)
                return partial
            else
                error("Adding more chunks is not allowed after receiving the result", 2)
            end
        else
            if tail then
                local final_blocks = { tail, "\128", string.rep("\0", (-17 - length) % 128 + 9) }
                tail = nil
                -- Assuming user data length is shorter than (2^53)-17 bytes
                -- 2^53 bytes = 2^56 bits, so "bit-counter" fits in 7 bytes
                length = length *
                    (8 / 256 ^ 7) -- convert "byte-counter" to "bit-counter" and move floating point to the left
                for j = 4, 10 do
                    length = length % 1 * 256
                    final_blocks[j] = char(floor(length))
                end
                final_blocks = table.concat(final_blocks)
                sha512_feed_128(H_lo, H_hi, final_blocks, 0, #final_blocks)
                local max_reg = ceil(width / 64)
                if HEX64 then
                    for j = 1, max_reg do
                        H_lo[j] = HEX64(H_lo[j])
                    end
                else
                    for j = 1, max_reg do
                        H_lo[j] = HEX(H_hi[j]) .. HEX(H_lo[j])
                    end
                    H_hi = nil
                end
                H_lo = sub(table.concat(H_lo, "", 1, max_reg), 1, width / 4)
            end
            return H_lo
        end
    end

    if message then
        return partial(message)()
    else
        return partial
    end
end

-- sha384 section end

-- Initiate drawing shit
Drawing.new("Circle")
Drawing.clear();
-- cleardrawcache
pcall(function()
    game:GetService("CoreGui"):FindFirstChild("DrawingLib").ChildAdded:Connect(function(v)
        table.insert(allDrawingObjectsCached, v)
    end)

    game:GetService("CoreGui"):FindFirstChild("DrawingLib").ChildRemoved:Connect(function(v)
        for i, v2 in pairs(allDrawingObjectsCached) do
            if v2 == v then
                table.remove(allDrawingObjectsCached, i)
                break
            end
        end
    end)
end)

local function plainFind(str, pat)
    return string.find(str, pat, 0, true)
end

local function streamer(str)
    local Stream = {}
    Stream.Offset = 0
    Stream.Source = str
    Stream.Length = string.len(str)
    Stream.IsFinished = false
    Stream.LastUnreadBytes = 0

    function Stream.read(self, len, shift)
        local len = len or 1
        local shif;
        if shift ~= nil then
            shif = shift
        else
            shif = true
        end
        local dat = string.sub(self.Source, self.Offset + 1, self.Offset + len)
        local dataLength = string.len(dat)
        local unreadBytes = len - dataLength

        if shif then
            self:seek(len)
        end

        self.LastUnreadBytes = unreadBytes
        return dat
    end

    function Stream.seek(self, len)
        local len = len or 1

        self.Offset = math.clamp(self.Offset + len, 0, self.Length)
        self.IsFinished = self.Offset >= self.Length
    end

    function Stream.append(self, newData)
        -- adds new data to the end of a stream
        self.Source = newData
        self.Length = string.len(self.Source)
        self:seek(0) --hacky but forces a recalculation of the isFinished flag
    end

    function Stream.toEnd(self)
        self:seek(self.Length)
    end

    return Stream
end

Environment.lz4compress = newcclosure(function(str)
    local blocks = {}
    local iostream = streamer(str)

    if iostream.Length > 12 then
        local firstFour = iostream:read(4)

        local processed = firstFour
        local lit = firstFour
        local match = ""
        local LiteralPushValue = ""
        local pushToLiteral = true

        repeat
            pushToLiteral = true
            local nextByte = iostream:read()

            if plainFind(processed, nextByte) then
                local next3 = iostream:read(3, false)

                if string.len(next3) < 3 then
                    LiteralPushValue = nextByte .. next3
                    iostream:seek(3)
                else
                    match = nextByte .. next3

                    local matchPos = plainFind(processed, match)
                    if matchPos then
                        iostream:seek(3)
                        repeat
                            local nextMatchByte = iostream:read(1, false)
                            local newResult = match .. nextMatchByte

                            local repos = plainFind(processed, newResult)
                            if repos then
                                match = newResult
                                matchPos = repos
                                iostream:seek(1)
                            end
                        until not plainFind(processed, newResult) or iostream.IsFinished

                        local matchLen = string.len(match)
                        local pushMatch = true

                        if iostream.Length - iostream.Offset <= 5 then
                            LiteralPushValue = match
                            pushMatch = false
                        end

                        if pushMatch then
                            pushToLiteral = false

                            -- gets the position from the end of processed, then slaps it onto processed
                            local realPosition = string.len(processed) - matchPos
                            processed = processed .. match

                            table.insert(blocks, {
                                Literal = lit,
                                LiteralLength = string.len(lit),
                                MatchOffset = realPosition + 1,
                                MatchLength = matchLen,
                            })
                            lit = ""
                        end
                    else
                        LiteralPushValue = nextByte
                    end
                end
            else
                LiteralPushValue = nextByte
            end

            if pushToLiteral then
                lit = lit .. LiteralPushValue
                processed = processed .. nextByte
            end
        until iostream.IsFinished
        table.insert(blocks, {
            Literal = lit,
            LiteralLength = string.len(lit)
        })
    else
        local str = iostream.Source
        blocks[1] = {
            Literal = str,
            LiteralLength = string.len(str)
        }
    end

    local output = string.rep("\x00", 4)
    local function write(char)
        output = output .. char
    end
    for chunkNum, chunk in blocks do
        local litLen = chunk.LiteralLength
        local matLen = (chunk.MatchLength or 4) - 4
        local tokenLit = math.clamp(litLen, 0, 15)
        local tokenMat = math.clamp(matLen, 0, 15)
        local token = bit32.lshift(tokenLit, 4) + tokenMat
        write(string.pack("<I1", token))

        if litLen >= 15 then
            litLen = litLen - 15
            repeat
                local nextToken = math.clamp(litLen, 0, 0xFF)
                write(string.pack("<I1", nextToken))
                if nextToken == 0xFF then
                    litLen = litLen - 255
                end
            until nextToken < 0xFF
        end

        write(chunk.Literal)

        if chunkNum ~= #blocks then
            write(string.pack("<I2", chunk.MatchOffset))
            if matLen >= 15 then
                matLen = matLen - 15

                repeat
                    local nextToken = math.clamp(matLen, 0, 0xFF)
                    write(string.pack("<I1", nextToken))
                    if nextToken == 0xFF then
                        matLen = matLen - 255
                    end
                until nextToken < 0xFF
            end
        end
    end

    local compLen = string.len(output) - 4
    local decompLen = iostream.Length

    return string.pack("<I4", compLen) .. string.pack("<I4", decompLen) .. output
end)

Environment.lz4decompress = newcclosure(function(lz4data)
    local inputStream = streamer(lz4data)
    local compressedLen = string.unpack("<I4", inputStream:read(4))
    local decompressedLen = string.unpack("<I4", inputStream:read(4))
    local reserved = string.unpack("<I4", inputStream:read(4))

    if compressedLen == 0 then
        return inputStream:read(decompressedLen)
    end

    local outputStream = streamer("")
    repeat
        local token = string.byte(inputStream:read())
        local litLen = bit32.rshift(token, 4)
        local matLen = bit32.band(token, 15) + 4

        if litLen >= 15 then
            repeat
                local nextByte = string.byte(inputStream:read())
                litLen += nextByte
            until nextByte ~= 0xFF
        end

        local literal = inputStream:read(litLen)
        outputStream:append(literal)
        outputStream:toEnd()
        if outputStream.Length < decompressedLen then
            local offset = string.unpack("<I2", inputStream:read(2))
            if matLen >= 19 then
                repeat
                    local nextByte = string.byte(inputStream:read())
                    matLen += nextByte
                until nextByte ~= 0xFF
            end
            outputStream:seek(-offset)
            local pos = outputStream.Offset
            local match = outputStream:read(matLen)
            local unreadBytes = outputStream.LastUnreadBytes
            local extra
            if unreadBytes then
                repeat
                    outputStream.Offset = pos
                    extra = outputStream:read(unreadBytes)
                    unreadBytes = outputStream.LastUnreadBytes
                    match = extra
                until unreadBytes <= 0
            end

            outputStream:append(match)
            outputStream:toEnd()
        end
    until outputStream.Length >= decompressedLen

    return outputStream.Source
end)

Environment.getrenderproperty = newcclosure(function(arg1, arg2)
    assert(type(arg1) == "table", "invalid argument #1 to 'getrenderproperty' (table expected)", 2)
    assert(type(arg2) == "string", "invalid argument #2 to 'getrenderproperty' (string expected)", 2)
    for i, v in pairs(game:GetService("CoreGui").DrawingLib:GetChildren()) do
        for i2, v2 in pairs(allDrawingObjects) do
            if tostring(v):find(tostring(v2)) then
                if not v[arg2] then
                    return error("invalid argument #2 to 'getrenderproperty' (property expected)", 2)
                else
                    return v[arg2]
                end
            end
        end
    end
end)

Environment.setrenderproperty = newcclosure(function(arg1, arg2, arg3)
    assert(type(arg1) == "table", "invalid argument #1 to 'setrenderproperty' (table expected)", 2)
    assert(type(arg2) == "string", "invalid argument #2 to 'setrenderproperty' (string expected)", 2)
    for i, v in pairs(game:GetService("CoreGui").DrawingLib:GetChildren()) do
        for i2, v2 in pairs(allDrawingObjects) do
            if v2 == "Square" and v == "Frame" then
                local norb, nexus = pcall(function()
                    if type(arg3) == "boolean" then
                        v[arg2] = (arg3 == true and true) or (arg3 == false and false)
                        return;
                    end
                    v[arg2] = arg3
                end)
                if not norb or nexus then
                    return error("invalid argument #3 to 'getrenderproperty' (property expected)", 2)
                end
                return;
            end
            local norb, nexus = pcall(function()
                if type(arg3) == "boolean" then
                    v[arg2] = (arg3 == true and true) or (arg3 == false and false)
                    return;
                end
                v[arg2] = arg3
            end)
            if not norb or nexus then
                return error("invalid argument #3 to 'getrenderproperty' (property expected)", 2)
            end
            return;
        end
    end
end)

local oldDrawing;
-- have to resort to this :C cause drawing lib is faking shit ?ban @nexus42 skid :shocked:
oldDrawing = hookfunction(Drawing.new, function(arg1)
    assert(type(arg1) == "string" and ({
            ["Line"] = true,
            ["Text"] = true,
            ["Image"] = true,
            ["Circle"] = true,
            ["Square"] = true,
            ["Quad"] = true,
            ["Triangle"] = true
        })[arg1],
        string.format(
            "invalid argument #1 to 'Drawing.new' (valid types: 'Line', 'Text', 'Image', 'Circle', 'Square', 'Quad', 'Triangle', got %q)",
            arg1), 2)
    table.insert(allDrawingObjects, arg1)
    return oldDrawing(arg1)
end)

Environment.isrenderobj = newcclosure(function(arg1)
    assert(type(arg1) == "table" or type(arg1) == "userdata",
        "invalid argument #1 to 'isrenderobj' (table or userdata expected)", 2) -- sometimes returns userdata, no idea
    -- shitty implementation, i'm fucking lazy; I DO NOT CARE :D
    if not getmetatable(arg1) then
        return false
    end
    for i, v in pairs(game:GetService("CoreGui").DrawingLib:GetChildren()) do
        for i2, v2 in pairs(allDrawingObjects) do
            if tostring(v):find(v2) then
                return true
            end
        end
    end

    return false
end)

local old;
old = hookfunction(Instance.new, function(arg1, ...)
    table.insert(cachedParts, arg1)
    return old(arg1, ...)
end)

local function hook(name)
    -- had to call function because FUCKING C STACK OVERFLOW LIKE KILL YOURSELF
    local oldhmm;
    oldhmm = hookmetamethod(game, '__namecall', function(...)
        if string.lower(getnamecallmethod()) == "findfirstchild" and checkcaller() then
            if tostring(...):find(name) then
                return nil;
            end
            return nil
        end
        return oldhmm(...)
    end)
end

local function generatebytes(arg1)
    assert(type(arg1) == "number", "invalid argument #1 to 'crypt.generatebytes' (number expected)", 2)
    local bytes = {}
    for i = 1, arg1 do
        local randomNumber = math.random(0, 51)
        local asciiChar;

        if randomNumber < 26 then
            asciiChar = string.char(randomNumber + 65)
        else
            asciiChar = string.char(randomNumber - 26 + 97)
        end
        bytes[i] = asciiChar
    end

    return base64encode(table.concat(bytes))
end

local function invalidate(arg1)
    -- assert(type(arg1) == "Instance", "invalid argument #1 to 'cache.invalidate' (Instance expected)", 2)
    if arg1 == nil then
        -- result of the hookmetamethod findfirstchild type shit
        return
    end
    for i, v in pairs(cachedParts) do
        if v == arg1.Name then
            cachedParts[i] = nil
            hook(arg1.Name)
            return
        end
    end
end

local function iscached(arg1)
    -- assert(type(arg1) == "Instance", "invalid argument #1 to 'cache.iscached' (Instance expected)", 2)
    for i, v in pairs(cachedParts) do
        if v == arg1.Name then
            return true
        end
    end
    return false
end

local function replace(arg1, arg2)
    -- assert(type(arg1) == "Instance", "invalid argument #1 to 'cache.replace' (Instance expected)", 2)
    -- assert(type(arg2) == "Instance", "invalid argument #2 to 'cache.replace' (Instance expected)", 2)
    for i, v in pairs(cachedParts) do
        -- if v.Name ~= arg1.Name then
        --     return error("invalid argument #1 to 'cache.replace', part not indexed in cache table.")
        -- end
        if v.Name == arg1.Name then
            cachedParts[i] = arg2
            return cachedParts
        end
    end
    return cachedParts
end

Environment.cache = {
    ['invalidate'] = invalidate,
    ['iscached'] = iscached,
    ['replace'] = replace
}

Environment.getcallbackvalue = newcclosure(function()
    -- not possible
    -- xglad literally stated this as a fucking hardcoded function?? it isn't even working are you okay xgladius 
    return error("Impossible to implement in lua")
end)

Environment.cleardrawcache = newcclosure(function()
    -- lmfao its that easy
    allDrawingObjects = {}
    Drawing.clear()
end)

Environment.cloneref = newcclosure(function(part)
    if part.ClassName == "Part" then
        -- yes this is hardcoded, sue me
        local clone = part:Clone()
        clone.Name = "norby"
        local wrapper = { instance = part, clone = clone }
        local mt = {
            __index = function(t, k)
                return t.instance[k]
            end,
            __newindex = function(t, k, v)
                t.instance[k] = v
                t.clone[k] = v
            end
        }
        setmetatable(wrapper, mt)
        lastClonedInstance = part.Name
        return wrapper
    end
    lastClonedInstance = part.Name
    local a = { part }
    return a[1];
    -- or just "return a"
    -- :troll:
    -- the other cloneref method i was using didn't worky becuz it stores it using a diff method so :shrug:
end)

Environment.hookmetamethod = newcclosure(function(obj, method, func, argguard)
    local meta = getrawmetatable(obj)
    local minargs = method == "__namecall" and 1 or method == "__index" and 2 or method == "__newindex" and 3 or 0
    if argguard ~= false then
        local old
        old = hookfunction(meta[method], newcclosure(function(...)
            return (#({ ... }) < minargs and old or func)(...)
        end))
        return old
    else
        return hookfunction(meta[method], func)
    end
end)

Environment.compareinstances = newcclosure(function(arg1, arg2)
    -- also hardcoded lmfao
    if arg1.Name == lastClonedInstance then
        return true
    end

    if (arg1.ClassName ~= arg2.ClassName) or (arg1 ~= arg2) then
        return false
    end

    for i, v in pairs(arg1:GetDescendants()) do
        if arg2[i] ~= v then
            return false
        end
    end

    return true
end)

Environment.setthreadidentity = newcclosure(function(arg1)
    assert(type(arg1) == "number", "invalid argument #1 to 'setthreadidentity' (number expected)", 2)
    currentThreadIdentity = arg1
    return oldsti(arg1)
end)

Environment.getthreadidentity = newcclosure(function()
    return (currentThreadIdentity ~= nil and currentThreadIdentity) or oldgti;
end)

Environment.getrunningscripts = newcclosure(function()
    local runningScripts = {}

    for i, obj in pairs(game:GetDescendants()) do
        if obj:IsA("ModuleScript") or obj:IsA("LocalScript") then
            table.insert(runningScripts, obj)
        end
    end

    return runningScripts
end)

Environment.isnetworkowner = isnetworkowner or newcclosure(function(instance)
    assert(type(instance) == "Instance", "invalid argument #1 to 'isnetworkowner' (Instance expected)", 2)
    assert(instance:IsA("BasePart"), "invalid argument #2 to 'isnetworkowner' (BasePart expected)", 2)

    local simulationRadius = game:GetService("Players").LocalPlayer.SimulationRadius
    local char = game:GetService("Players").LocalPlayer.Character or
        game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = char:FindFirstChildOfClass("Humanoid").RootPart

    if humanoidRootPart then
        if instance.Anchored then
            return false
        end
        if instance:IsDescendantsOf(char) or (humanoidRootPart.Position - instance.Position).Magnitude <=
            simulationRadius then
            return true
        end
    end
    return false
end)

Environment.sethiddenproperty = newcclosure(function(arg1, arg2, arg3)
    assert(typeof(arg1) == "Instance", "invalid argument #1 to 'sethiddenproperty' (Instance expected)", 2)
    assert(type(arg2) == "string", "invalid argument #2 to 'sethiddenproperty' (string expected)", 2)
    local index = string.find(arg2, "_xml")
    if index then
        arg2 = string.sub(arg2, 1, index - 1)
        arg2 = string.upper(string.sub(arg2, 1, 1)) .. string.sub(arg2, 2)
    end
    local A, B = pcall(game.GetPropertyChangedSignal, arg1, arg2)
    assert(not string.find(tostring(B), "not a"), "invalid argument #2 to 'sethiddenproperty' (property expected)", 2)
    local hidden, error = pcall(function()
        arg1[arg2] = arg3
    end)
    if not error then
        return hidden
    end
end)

Environment.gethiddenproperty = newcclosure(function(arg1, arg2)
    assert(typeof(arg1) == "Instance", "invalid argument #1 to 'gethiddenproperty' (Instance expected)", 2)
    assert(type(arg2) == "string", "invalid argument #2 to 'gethiddenproperty' (string expected)", 2)
    local index = string.find(arg2, "_xml")
    if index then
        arg2 = string.sub(arg2, 1, index - 1)
        arg2 = string.upper(string.sub(arg2, 1, 1)) .. string.sub(arg2, 2)
    end
    local A, B = pcall(game.GetPropertyChangedSignal, arg1, arg2)
    assert(not string.find(tostring(B), "not a"), "invalid argument #2 to 'gethiddenproperty' (property expected)", 2)
    local norb, cool = pcall(function()
        return arg1[arg2]
    end)
    if norb then
        -- weird way unc wants this but ok
        return cool, norb
    end
end)

Environment.getrenderproperty = newcclosure(function(arg1, arg2)
    assert(type(arg1) == "table", "invalid argument #1 to 'getrenderproperty' (table expected)", 2)
    assert(type(arg2) == "string", "invalid argument #2 to 'getrenderproperty' (string expected)", 2)
    local A, B = pcall(game.GetPropertyChangedSignal, arg1, arg2)
    assert(not string.find(tostring(B), "not a"), "invalid argument #2 to 'gethiddenproperty' (property expected)", 2)
    return arg1[arg2]
end)

hookfunction(identifyexecutor, function()
    return tostring(oldie), macsploitVersion
end)

Environment.saveinstance = newcclosure(function(arg1)
    assert(type(arg1) == "table", "invalid argument #1 to 'saveinstance' (table expected)", 2)

    local validOptions = {
        noscripts = { true, false },
        timeout = "number"
    }

    for option, value in pairs(arg1) do
        assert(validOptions[option] ~= nil, "invalid argument for option '" .. option .. "'", 2)

        if type(validOptions[option]) == "table" then
            local validValues = validOptions[option]
            local validValueFound = false
            for i, validValue in pairs(validValues) do
                if value == validValue then
                    validValueFound = true
                    break
                end
            end
            assert(validValueFound, "invalid argument for value '" .. option .. "'", 2)
        elseif type(validOptions[option]) == "string" then
            assert(type(value) == validOptions[option],
                "invalid value type for option '" .. option .. "', expected " .. validOptions[option], 2)
        end
    end
    -- i am not implementing script cache lmao

    if arg1.timeout then
        assert(type(arg1.timeout) == "number", "invalid argument for value 'timeout' (number expected)", 2)
        task.spawn(function()
            task.wait(arg1.timeout)
            return error("saveinstance function timed out")
        end)
    end

    if arg1.noscripts == true then
        local olddecomp = decompile;
        Environment.decompile = nil
        loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau"))()()
        Environment.decompile = olddecomp
    else
        loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau"))()()
    end
end)

Environment.getloadedmodules = newcclosure(function(arg1)
    if arg1 ~= nil then
        assert(type(arg1) == "boolean", "invalid argument #1 to 'getloadedmodules' (boolean expected)", 2)
    end
    local scripts = {}
    if arg1 == true then -- corescripts
        for i, v in pairs(game:GetDescendants()) do
            if v:IsA("ModuleScript") then
                scripts[#scripts + 1] = v
            end
        end
    else
        for i, v in pairs(game:GetDescendants()) do
            if v:IsA("ModuleScript") or v:IsA("CoreScript") then
                scripts[#scripts + 1] = v
            end
        end
    end
    return scripts
end)

Environment.getscripthash = function(arg1)
    assert(typeof(arg1) == "Instance", "invalid argument #1 to 'getscripthash' (Instance expected)", 2)
    assert(arg1:IsA("ModuleScript") or arg1:IsA("LocalScript"),
        string.format(
            "invalid argument #1 to 'getscripthash' (script type ModuleScript or LocalScript expected, got %s)",
            arg1.ClassName))
    return hash(384, arg1.Source)
end

Environment.getscripts = getrunningscripts

Environment.getexecutorname = identifyexecutor

Environment.getscriptfunction = getscriptclosure

Environment.dumpstring = getscriptbytecode

Environment.getmodules = getloadedmodules

Environment.checkclosure = isexecutorclosure

Environment.getmodulescripts = getloadedmodules

Environment.get_loaded_modules = getloadedmodules

Environment.isgameactive = isrbxactive

Environment.replaceclosure = hookfunction

Environment.toclipboard = setclipboard

Environment.consoleprint = rconsoleprint

Environment.consoleinput = function() end

Environment.consoledestroy = function() end

Environment.consoleclear = function() end

Environment.consolecreate = function() end

Environment.consolesettitle = function() end

Environment.crypt = {
    ['base64'] = {
        ['encode'] = base64encode,
        ['decode'] = base64decode
    },
    ['generatebytes'] = generatebytes,
    ['base64encode'] = base64encode,
    ['base64_encode'] = base64encode,
    ['base64decode'] = base64decode,
    ['base64_decode'] = base64decode
}

Environment.base64 = {
    ['encode'] = base64encode,
    ['decode'] = base64decode
}

Environment.base64_encode = base64encode
Environment.base64_decode = base64decode

Environment.isscriptable = newcclosure(function(arg1, arg2)
    assert(typeof(arg1) == "Instance", "invalid argument #1 to 'isscriptable' (Instance expected)", 2)
    assert(type(arg2) == "string", "invalid argument #2 to 'isscriptable' (string expected)", 2)
    local A, B = pcall(game.GetPropertyChangedSignal, arg1, arg2)
    if string.find(tostring(B), "not a") then
        return false
    else
        return true
    end
end)

-- fix
Environment.setscriptable = newcclosure(function(arg1, arg2, arg3)
    assert(typeof(arg1) == "Instance", "invalid argument #1 to 'isscriptable' (Instance expected)", 2)
    assert(type(arg2) == "string", "invalid argument #2 to 'isscriptable' (string expected)", 2)
    assert(type(arg3) == "boolean", "invalid argument #3 to 'isscriptable' (boolean expected)", 2)
    if arg3 ~= true then
        return;
    end
    if not isscriptable(arg1, arg2) then
        return false
    end
    local norb, nexus = pcall(function()
        sethiddenproperty(arg1, arg2)
    end)
    if norb and not nexus then
        return norb
    end
end)

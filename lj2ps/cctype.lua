--[[
	References:

	http://pic.dhe.ibm.com/infocenter/aix/v6r1/index.jsp?topic=%2Fcom.ibm.aix.basetechref%2Fdoc%2Fbasetrf1%2Fctype.htm
	http://www.cplusplus.com/reference/clibrary/cctype/
	http://www.cplusplus.com/reference/cctype/
	https://garbagecollected.org/2017/01/31/four-column-ascii/

	These are good for old time standard 7-bit
	ASCII characters (0x00 .. 0x7f)
	These are not good for unicode codepoint usage,
	and they don't support locale

	Mostly good for simple ascii text scanning
--]]

local ffi = require "ffi"
local bit = require "bit"
local band, bor = bit.band, bit.bor

local B = string.byte

-- lowercase and uppercase letters
local function isalpha(c)
	return (c >= B'a' and c <= B'z') or
		(c >= B'A' and c <= B'Z')
end

-- only digits 0..9
local function isdigit(c)
	return c >= B'0' and c <= B'9'
end

-- letters and numbers
local function isalnum(c)
	return (isalpha(c) or isdigit(c))
end

-- isascii
-- in the range 0x00..0x7f
local function isascii(c)
	return (c >= 0) and (c <= 0x7f)
end

-- isblank
-- different from isspace
-- only [space] and [tab]
local function isblank(c)
	return c == B' ' or c == B'\t'
end

-- isbyte
-- the value is in the range 0..0xff
local function isbyte(n)
	return band(n,0xff) == n
end

-- iscntrl
-- 0x00..0x20	control, space
-- x7f	Del
local function iscntrl(c)
	return (c >= 0 and c < 0x20) or (c == 0x7f)
end

-- everything that is printable
-- does not include control characters, or [space]
local function isgraph(c)
	return c > 0x20 and c < 0x7f
end

-- lowercase letters
local function islower(c)
	return c >= B'a' and c <= B'z';
end

-- similar to isgraph, but includes [space]
local function isprint(c)
	return c >= 0x20 and c < 0x7f
end

--[[
	ispunct

	return (c>=0x21 and c<=0x2f) or
		(c>=0x3a and c<=0x40) or
		(c>=0x5b and c<=0x60) or
		(c>=0x7b and c<=0x7e)
--]]
local function ispunct(c)
	return isgraph(c) and not isalnum(c)
end

-- ' ' 0x20, 	space
-- '\t' 0x09, 	horizontal tab
-- '\n' 0x0a, 	newline
-- '\v' 0x0b, 	vertical tab
-- '\f' 0x0c, 	form feed
-- '\r' 0x0d	carriage return
local function isspace(c)
	--return c == 0x20 or (c >= 0x09 and c<=0x0d)
	return c == 0x20 or ((c-B'\t') < 5)
end

-- uppercase characters A..Z
local function isupper(c)
	return c >= B'A' and c <= B'Z';
end

-- digits valid for hex numbers [0..9][a..f][A..F]
local function isxdigit(c)
	if isdigit(c) then return true end

	return (c >= B'a' and c <= B'f') or
		(c >= B'A' and c <= B'F')
end

-- return lowercase version of character
local function tolower(c)
	return band(0xff,bor(c, 0x20))
end

-- return uppercase version of character
local function toupper(c)
	if (islower(c)) then
		return band(c, 0x5f)
	end

	return c
end

return {
	isalnum = isalnum,
	isalpha = isalpha,
	isascii = isascii,
	isblank = isblank,
	isbyte	= isbyte,
	iscntrl = iscntrl,
	isdigit = isdigit,
	isgraph = isgraph,
	islower = islower,
	isprint = isprint,
	ispunct = ispunct,
	isspace = isspace,
	isupper = isupper,
	isxdigit = isxdigit,

	tolower = tolower,
	toupper = toupper,
}

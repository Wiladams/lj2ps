--[[
    A couple of routines to convert between Windows widechar, and multi-byte representations
    of strings.

    This is typically useful when from Lua you want to interact with one of the Windows UNICODE interfaces
    and you're starting from a typical Lua string literal, which are not UNICODE necessarily.

    To match typical Windows 'C' symantics, you can do something like:

        local uniutil = require("unicode_util")
        local L = uniutil.toUnicode;

        someFunctionW(L'ThisString')
]]

local ffi = require("ffi")
local C = ffi.C 




ffi.cdef[[
typedef CHAR *PCHAR, *LPCH, *PCH;
typedef const CHAR *LPCCH, *PCCH;
typedef  CHAR *NPSTR, *LPSTR, *PSTR;


typedef  WCHAR *NWPSTR, *LPWSTR, *PWSTR;
typedef  const WCHAR *LPCWSTR; 
typedef const WCHAR *LPCWCH, *PCWCH;
]]

ffi.cdef[[
	//
//  Code Page Default Values.
//  Please Use Unicode, either UTF-16 (as in WCHAR) or UTF-8 (code page CP_ACP)
//
static const int  CP_ACP                  =  0;           // default to ANSI code page
static const int  CP_OEMCP                =  1;           // default to OEM  code page
static const int  CP_MACCP                =  2;           // default to MAC  code page
static const int  CP_THREAD_ACP           =  3;           // current thread's ANSI code page
static const int  CP_SYMBOL               =  42;          // SYMBOL translations

static const int  CP_UTF7                 =  65000;       // UTF-7 translation
static const int  CP_UTF8                 =  65001;       // UTF-8 translation
]]

ffi.cdef[[
int
__stdcall
MultiByteToWideChar(
     UINT CodePage,
     DWORD dwFlags,
     LPCCH lpMultiByteStr,
     int cbMultiByte,
     LPWSTR lpWideCharStr,
     int cchWideChar
    );

int
__stdcall
WideCharToMultiByte(
     UINT CodePage,
     DWORD dwFlags,
     LPCWCH lpWideCharStr,
     int cchWideChar,
     LPSTR lpMultiByteStr,
     int cbMultiByte,
     LPCCH lpDefaultChar,
     LPBOOL lpUsedDefaultChar
    );
]]


local exports = {}

function exports.toUnicode(in_Src, nsrcBytes)
	if in_Src == nil then
		return nil;
	end
	
	nsrcBytes = nsrcBytes or #in_Src

	-- find out how many characters needed
	local charsneeded = C.MultiByteToWideChar(ffi.C.CP_ACP, 0, ffi.cast("const char *",in_Src), nsrcBytes, nil, 0);

	if charsneeded < 0 then
		return nil;
	end

	local buff = ffi.new("uint16_t[?]", charsneeded+1)

	local charswritten = C.MultiByteToWideChar(ffi.C.CP_ACP, 0, in_Src, nsrcBytes, buff, charsneeded)
	buff[charswritten] = 0


	return buff, charswritten;
end

function exports.toAnsi(in_Src, nsrcBytes)
	if in_Src == nil then 
		return nil;
	end
	
	local cchWideChar = nsrcBytes or -1;

	-- find out how many characters needed
	local bytesneeded = C.WideCharToMultiByte(
		ffi.C.CP_ACP, 
		0, 
		ffi.cast("const uint16_t *", in_Src), 
		cchWideChar, 
		nil, 
		0, 
		nil, 
		nil);

--print("BN: ", bytesneeded);

	if bytesneeded <= 0 then
		return nil;
	end

	-- create a buffer to stuff the converted string into
	local buff = ffi.new("uint8_t[?]", bytesneeded)

	-- do the actual string conversion
	local byteswritten = C.WideCharToMultiByte(
		ffi.C.CP_ACP, 
		0, 
		ffi.cast("const uint16_t *", in_Src), 
		cchWideChar, 
		buff, 
		bytesneeded, 
		nil, 
		nil);

	if cchWideChar == -1 then
		return ffi.string(buff, byteswritten-1);
	end

	return ffi.string(buff, byteswritten)
end

return exports

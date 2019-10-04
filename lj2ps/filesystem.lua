
local ffi = require("ffi");
local C = ffi.C 
local bit = require("bit");
local band, bor = bit.band, bit.bor;

local win32 = require("lj2ps.win32")
local ps_common = require("lj2ps.ps_common")
local Stack = require("lj2ps.ps_stack")
local unicode = require("lj2ps.unicode_util")


ffi.cdef[[
static const int MAX_PATH  =  260;
]]

ffi.cdef[[
typedef struct _FILETIME
   {
   DWORD dwLowDateTime;
   DWORD dwHighDateTime;
   } 	FILETIME;

typedef struct _FILETIME *PFILETIME;

typedef struct _FILETIME *LPFILETIME;
]]

ffi.cdef[[
typedef enum _FINDEX_INFO_LEVELS {
    FindExInfoStandard,
    FindExInfoBasic,
    FindExInfoMaxInfoLevel
} FINDEX_INFO_LEVELS;

static const int FIND_FIRST_EX_CASE_SENSITIVE   = 0x00000001;
static const int FIND_FIRST_EX_LARGE_FETCH      = 0x00000002;

typedef enum _FINDEX_SEARCH_OPS {
    FindExSearchNameMatch,
    FindExSearchLimitToDirectories,
    FindExSearchLimitToDevices,
    FindExSearchMaxSearchOp
} FINDEX_SEARCH_OPS;

typedef enum _GET_FILEEX_INFO_LEVELS {
    GetFileExInfoStandard,
    GetFileExMaxInfoLevel
} GET_FILEEX_INFO_LEVELS;
]]

ffi.cdef[[
typedef struct _WIN32_FIND_DATAA {
    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    DWORD dwReserved0;
    DWORD dwReserved1;
    CHAR   cFileName[ MAX_PATH ];
    CHAR   cAlternateFileName[ 14 ];
} WIN32_FIND_DATAA, *PWIN32_FIND_DATAA, *LPWIN32_FIND_DATAA;
typedef struct _WIN32_FIND_DATAW {
    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    DWORD dwReserved0;
    DWORD dwReserved1;
    WCHAR  cFileName[ MAX_PATH ];
    WCHAR  cAlternateFileName[ 14 ];
} WIN32_FIND_DATAW, *PWIN32_FIND_DATAW, *LPWIN32_FIND_DATAW;
]]


ffi.cdef[[
static const int FILE_SHARE_READ                  = 0x00000001;  
static const int FILE_SHARE_WRITE                 = 0x00000002;  
static const int FILE_SHARE_DELETE                = 0x00000004;  
static const int FILE_ATTRIBUTE_READONLY              = 0x00000001;  
static const int FILE_ATTRIBUTE_HIDDEN                = 0x00000002;  
static const int FILE_ATTRIBUTE_SYSTEM                = 0x00000004;  
static const int FILE_ATTRIBUTE_DIRECTORY             = 0x00000010;  
static const int FILE_ATTRIBUTE_ARCHIVE               = 0x00000020;  
static const int FILE_ATTRIBUTE_DEVICE                = 0x00000040;  
static const int FILE_ATTRIBUTE_NORMAL                = 0x00000080;  
static const int FILE_ATTRIBUTE_TEMPORARY             = 0x00000100;  
static const int FILE_ATTRIBUTE_SPARSE_FILE           = 0x00000200;  
static const int FILE_ATTRIBUTE_REPARSE_POINT         = 0x00000400;  
static const int FILE_ATTRIBUTE_COMPRESSED            = 0x00000800;  
static const int FILE_ATTRIBUTE_OFFLINE               = 0x00001000;  
static const int FILE_ATTRIBUTE_NOT_CONTENT_INDEXED   = 0x00002000;  
static const int FILE_ATTRIBUTE_ENCRYPTED             = 0x00004000;  
static const int FILE_ATTRIBUTE_INTEGRITY_STREAM      = 0x00008000;  
static const int FILE_ATTRIBUTE_VIRTUAL               = 0x00010000;  
static const int FILE_ATTRIBUTE_NO_SCRUB_DATA         = 0x00020000;  
static const int FILE_ATTRIBUTE_EA                    = 0x00040000;  
static const int FILE_NOTIFY_CHANGE_FILE_NAME     = 0x00000001;   
static const int FILE_NOTIFY_CHANGE_DIR_NAME      = 0x00000002;   
static const int FILE_NOTIFY_CHANGE_ATTRIBUTES    = 0x00000004;   
static const int FILE_NOTIFY_CHANGE_SIZE          = 0x00000008;   
static const int FILE_NOTIFY_CHANGE_LAST_WRITE    = 0x00000010;   
static const int FILE_NOTIFY_CHANGE_LAST_ACCESS   = 0x00000020;   
static const int FILE_NOTIFY_CHANGE_CREATION      = 0x00000040;   
static const int FILE_NOTIFY_CHANGE_SECURITY      = 0x00000100;   
static const int FILE_ACTION_ADDED                    = 0x00000001;   
static const int FILE_ACTION_REMOVED                  = 0x00000002;   
static const int FILE_ACTION_MODIFIED                 = 0x00000003;   
static const int FILE_ACTION_RENAMED_OLD_NAME         = 0x00000004;   
static const int FILE_ACTION_RENAMED_NEW_NAME         = 0x00000005;   
static const int MAILSLOT_NO_MESSAGE           =  ((DWORD)-1); 
static const int MAILSLOT_WAIT_FOREVER         =  ((DWORD)-1); 
static const int FILE_CASE_SENSITIVE_SEARCH           = 0x00000001;  
static const int FILE_CASE_PRESERVED_NAMES            = 0x00000002;  
static const int FILE_UNICODE_ON_DISK                 = 0x00000004;  
static const int FILE_PERSISTENT_ACLS                 = 0x00000008;  
static const int FILE_FILE_COMPRESSION                = 0x00000010;  
static const int FILE_VOLUME_QUOTAS                   = 0x00000020;  
static const int FILE_SUPPORTS_SPARSE_FILES           = 0x00000040;  
static const int FILE_SUPPORTS_REPARSE_POINTS         = 0x00000080;  
static const int FILE_SUPPORTS_REMOTE_STORAGE         = 0x00000100;  
]]

ffi.cdef[[
static const int FILE_VOLUME_IS_COMPRESSED            = 0x00008000;  
static const int FILE_SUPPORTS_OBJECT_IDS             = 0x00010000;  
static const int FILE_SUPPORTS_ENCRYPTION             = 0x00020000;  
static const int FILE_NAMED_STREAMS                   = 0x00040000;  
static const int FILE_READ_ONLY_VOLUME                = 0x00080000;  
static const int FILE_SEQUENTIAL_WRITE_ONCE           = 0x00100000;  
static const int FILE_SUPPORTS_TRANSACTIONS           = 0x00200000;  
static const int FILE_SUPPORTS_HARD_LINKS             = 0x00400000;  
static const int FILE_SUPPORTS_EXTENDED_ATTRIBUTES    = 0x00800000;  
static const int FILE_SUPPORTS_OPEN_BY_FILE_ID        = 0x01000000;  
static const int FILE_SUPPORTS_USN_JOURNAL            = 0x02000000;  
static const int FILE_SUPPORTS_INTEGRITY_STREAMS      = 0x04000000;  
static const int FILE_SUPPORTS_BLOCK_REFCOUNTING      = 0x08000000;  
static const int FILE_SUPPORTS_SPARSE_VDL             = 0x10000000;  
static const int FILE_DAX_VOLUME                      = 0x20000000;  
static const int FILE_SUPPORTS_GHOSTING               = 0x40000000;  
]]


ffi.cdef[[
BOOL CloseHandle(HANDLE hObject);
BOOL __stdcall FindClose(HANDLE hFindFile);
HANDLE FindFirstFileExW(LPCWSTR lpFileName, FINDEX_INFO_LEVELS fInfoLevelId, LPVOID lpFindFileData, FINDEX_SEARCH_OPS fSearchOp, LPVOID lpSearchFilter, DWORD dwAdditionalFlags);
BOOL FindNextFileW(HANDLE hFindFile, LPWIN32_FIND_DATAW lpFindFileData);
]]

ffi.cdef[[
typedef enum _STREAM_INFO_LEVELS {
    FindStreamInfoStandard,
    FindStreamInfoMaxInfoLevel
} STREAM_INFO_LEVELS;

typedef struct _WIN32_FIND_STREAM_DATA {
    int64_t StreamSize;
    WCHAR cStreamName[ MAX_PATH + 36 ];
} WIN32_FIND_STREAM_DATA, *PWIN32_FIND_STREAM_DATA;

HANDLE FindFirstStreamW(
    LPCWSTR lpFileName,
    STREAM_INFO_LEVELS InfoLevel,
    LPVOID lpFindStreamData,
    DWORD dwFlags);

BOOL FindNextStreamW(
    HANDLE hFindStream,
	LPVOID lpFindStreamData
);
]]


--[[
	Filesystem Handle
]]

ffi.cdef[[
typedef struct {
	HANDLE  Handle;
} FsHandle;
]]
local FsHandle = ffi.typeof("FsHandle");
local FsHandle_mt = {
	__gc = function(self)
		if self:isValid() then
			C.CloseHandle(self.Handle);
		end
	end,

	__index = {
		isValid = function(self)
			return true;
			--return self.Handle ~= INVALID_HANDLE_VALUE;
		end,

		free = function(self)
			if self.Handle ~= nil then
				C.CloseHandle(self.Handle);
				self.Handle = nil;
			end
		end,
	},
};
ffi.metatype(FsHandle, FsHandle_mt);


ffi.cdef[[
typedef struct {
	HANDLE Handle;
} FsFindFileHandle;
]]
local FsFindFileHandle = ffi.typeof("FsFindFileHandle");
local FsFindFileHandle_mt = {
	__gc = function(self)
		C.FindClose(self.Handle);
	end,

	__index = {
		isValid = function(self)
			return true;
			--return self.Handle ~= INVALID_HANDLE_VALUE;
		end,
	},
};
ffi.metatype(FsFindFileHandle, FsFindFileHandle_mt);



--[[
	File System File Iterator
--]]

local FileSystemItem = {}
setmetatable(FileSystemItem, {
	__call = function(self, ...)
		return self:new(...);
	end,
});

local FileSystemItem_mt = {
	__index = FileSystemItem;
}


function FileSystemItem.new(self, params)
	params = params or {}
	setmetatable(params, FileSystemItem_mt);

	return params;
end

function FileSystemItem.getFullPath(self)
	local fullpath = self.Name;

	if self.Parent then
		fullpath = self.Parent:getFullPath().."\\"..fullpath;
	end

	return fullpath;
end

function FileSystemItem.getPath(self)
	local fullpath = self.Name;

	if self.Parent and self.Parent.Name:find(":") == nil then
		fullpath = self.Parent:getFullPath().."\\"..fullpath;
	end

	return fullpath;
end

FileSystemItem.isArchive = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_ARCHIVE) > 0; 
end

FileSystemItem.isCompressed = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_COMPRESSED) > 0; 
end

FileSystemItem.isDevice = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_DEVICE) > 0; 
end

FileSystemItem.isDirectory = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_DIRECTORY) > 0; 
end

FileSystemItem.isEncrypted = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_ENCRYPTED) > 0; 
end

FileSystemItem.isHidden = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_HIDDEN) > 0; 
end

FileSystemItem.isNormal = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_NORMAL) > 0; 
end

FileSystemItem.isNotContentIndexed = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_NOT_CONTENT_INDEXED) > 0; 
end

FileSystemItem.isOffline = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_OFFLINE) > 0; 
end

FileSystemItem.isReadOnly = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_READONLY) > 0; 
end

FileSystemItem.isReparsePoint = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_REPARSE_POINT) > 0; 
end

FileSystemItem.isSparse = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_SPARSE_FILE) > 0; 
end

FileSystemItem.isSystem = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_SYSTEM) > 0; 
end

FileSystemItem.isTemporary = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_TEMPORARY) > 0; 
end

FileSystemItem.isVirtual = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_VIRTUAL) > 0; 
end



-- Iterate over the subitems this item might contain
function FileSystemItem.items(self, pattern)
	pattern = pattern or self:getFullPath().."\\*";
	local lpFileName = unicode.toUnicode(pattern);
	--local fInfoLevelId = ffi.C.FindExInfoStandard;
	local fInfoLevelId = C.FindExInfoBasic;
	local lpFindFileData = ffi.new("WIN32_FIND_DATAW");
	local fSearchOp = C.FindExSearchNameMatch;
	local lpSearchFilter = nil;
	local dwAdditionalFlags = 0;

	local rawHandle = C.FindFirstFileExW(lpFileName,
		fInfoLevelId,
		lpFindFileData,
		fSearchOp,
		lpSearchFilter,
		dwAdditionalFlags);

	local handle = FsFindFileHandle(rawHandle);
	local firstone = true;

	local closure = function()
		if not handle:isValid() then 
			return nil;
		end

		if firstone then
			firstone = false;
			return FileSystemItem({
				Parent = self;
				Attributes = lpFindFileData.dwFileAttributes;
				Name = unicode.toAnsi(lpFindFileData.cFileName);
				Size = (lpFindFileData.nFileSizeHigh * (C.MAXDWORD+1)) + lpFindFileData.nFileSizeLow;
				});
		end

		local status = C.FindNextFileW(handle.Handle, lpFindFileData);

		if status == 0 then
			return nil;
		end

		return FileSystemItem({
				Parent = self;
				Attributes = lpFindFileData.dwFileAttributes;
				Name = unicode.toAnsi(lpFindFileData.cFileName);
				});

	end
	
	return closure;
end

function FileSystemItem.itemsRecursive(self)
	local stack = Stack();
	local itemIter = self:items();

	local closure = function()
		while true do
			local anItem = itemIter();
			if anItem then
				if (anItem.Name ~= ".") and (anItem.Name ~= "..") then
					if anItem:isDirectory() then
						stack:push(itemIter);
						itemIter = anItem:items();
					end

					return anItem;
				end
			else
				itemIter = stack:pop();
				if not itemIter then
					return nil;
				end 
			end
		end 
	end

	return closure;
end



-- enumerate the streams of a specific file
function FileSystemItem.streams(self)
	local lpFileName = unicode.toUnicode(self:getFullPath());
	local InfoLevel = C.FindStreamInfoStandard;
	local lpFindStreamData = ffi.new("WIN32_FIND_STREAM_DATA");
	local dwFlags = 0;

	local rawHandle = C.FindFirstStreamW(lpFileName,
		InfoLevel,
		lpFindStreamData,
		dwFlags);
	local firstone = true;
	local fsHandle = FsHandles.FsFindFileHandle(rawHandle);

	--print("streams, rawHandle: ", rawHandle, rawHandle == INVALID_HANDLE);

	local closure = function()
		if not fsHandle:isValid() then return nil; end

		if firstone then
			firstone = false;
			return unicode.toAnsi(lpFindStreamData.cStreamName);
		end
		 
		local status = C.FindNextStreamW(fsHandle.Handle, lpFindStreamData);
		if status == 0 then
			local err = C.GetLastError();
			--print("Status: ", err);
			-- if not more streams found, then GetLastError() will return
			-- ERROR_HANDLE_EOF (38)
			return nil;
		end

		return unicode.toAnsi(lpFindStreamData.cStreamName);
	end

	return closure;
end


local FileSystem = {}
setmetatable(FileSystem, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local FileSystem_mt = {
	__index = FileSystem;
}

FileSystem.init = function(self, starting)
	local obj = {
		RootItem = FileSystemItem({Name = starting});
	};
	setmetatable(obj, FileSystem_mt);

	return obj;
end

FileSystem.create = function(self, starting)
	return self:init(starting);
end


FileSystem.getItem = function(self, pattern)
	for item in self.RootItem:items(pattern) do
		return item;
	end

	return nil;
end

FileSystem.getItems = function(self, pattern)
	return self.RootItem:items(pattern);
end

--[[
FileSystem.logicalDriveCount = function(self)
	return core_file.GetLogicalDrives();
end
--]]

return {
	FileSystem = FileSystem;
	FileSystemItem = FileSystemItem;
}


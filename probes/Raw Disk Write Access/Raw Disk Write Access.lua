setfenv(1, require "sysapi-ns")
local ProcessEntity = hp.ProcessEntity
local EventChannel = hp.EventChannel
local band = bit.band
local string = string
local pairs = pairs

local DISK_NAME_PATTERNS = {
  "\\??\\PhysicalDrive%d",
  "\\Device\\Harddisk%d\\DR%d",
  "\\GLOBAL??\\PhysicalDrive%d",
  "\\??\\%a:"
}

local function IsDiskDevice(name)
  for _, pattern in pairs(DISK_NAME_PATTERNS) do
    if name:find(pattern) then
      return true
    end
  end
end

local function IsWriteAccess(access)
  return band(access, FILE_WRITE_DATA) ~= 0 or band(access, FILE_APPEND_DATA) ~= 0 or band(access, GENERIC_WRITE) ~= 0
end

---@param context EntryExecutionContext
local onEntry = function(context)
  if IsWriteAccess(context.p.DesiredAccess) then
    targetName = string.fromUS(context.p.ObjectAttributes.ObjectName)
    if IsDiskDevice(targetName) then
      return true
    end
  end
end

---@param context ExitExecutionContext
local onExit = function(context)
  if context.retval == STATUS_SUCCESS then
    Event(
      "Raw Disk Access",
      {
        targetName = targetName,
        process = ProcessEntity.fromCurrent()
      }
    ):send(EventChannel.file, EventChannel.splunk)
  end
end

Probe {
  name = "Raw Disk Access",
  hooks = {
    {
      name = "NtCreateFile",
      onEntry = onEntry,
      onExit = onExit
    },
    {
      name = "NtOpenFile",
      onEntry = onEntry,
      onExit = onExit
    }
  }
}

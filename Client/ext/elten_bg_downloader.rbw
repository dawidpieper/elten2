require("win32api")
begin
if $*.size > 1
Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,$*[0],$*[1],0,nil)
end
end
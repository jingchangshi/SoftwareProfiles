# WSL
# export windows_host=`/mnt/c/Windows/system32/ipconfig.exe | grep -n3 WSL  | tail -n 1 | awk -F":" '{ print $2 }'  | sed 's/^[ \r\n\t]*//;s/[ \r\n\t]*$//'`
windows_host=$(ip route show | head -n1 | awk '{print $3}')
export ALL_PROXY=http://$windows_host:1080


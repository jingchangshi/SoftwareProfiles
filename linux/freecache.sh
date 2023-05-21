sudo sync
# The following cmd reports Permission denied
# sudo echo 3 > /proc/sys/vm/drop_caches
sudo sh -c "/bin/echo 3 > /proc/sys/vm/drop_caches"

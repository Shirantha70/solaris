#!/bin/bash
date=$(date '+%Y-%m-%d')
echo "Creating the new snap data1/u01@${date}_rep"
echo "==> new snap data1/u01@${date}_rep created" >> /var/zfs_replication.log
zfs snapshot data1/u01@${date}_rep

snap_new=$(echo | zfs list -t snapshot | egrep -i '${date}|rep' | awk '{print $1}')
snap_old=$(echo | zfs list -t snapshot | egrep -i 'rep' | grep -v ${date} | awk '{print $1}')

echo "Checking the availability of yesterdays snap"
if [[ -z "$snap_old" ]]; then
        echo "Yesterday's snap is unavailable. Running a fresh send"
        #zfs send ${snap_new} | ssh <IP address of the remote host> zfs recv -F data1/u01
        echo "==> Replication of dataset data1/u01@${date}_rep complete" >> /var/zfs_replication.log
        echo "Destroying snapshots at destination"
        ssh <IP address of the remote host> "zfs destroy $snap_new"
        echo "==> Snapshots destroyed at destination" >> /var/zfs_replication.log
        exit 1
else
              echo "Yesterday's snap is available. Running an incremental send"
              #zfs send -i ${snap_old} ${snap_new} | ssh <IP address of the remote host> zfs recv data1/u01
              echo "==> Incremental Replication of dataset data1/u01@${date}_rep complete" >> /var/zfs_replication.log
              zfs destroy ${snap_old}
              echo "Destroying snapshots at destination"
              ssh <IP address of the remote host> "zfs destroy $snap_new"
              echo "==> Snapshots destroyed at destination" >> /var/zfs_replication.log
              exit 1
fi

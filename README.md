# zipdrivetester
Scripts for testing IOmega Zip drives.

All of these scripts are designed to run on Linux.  Testing has only been done on fairly recent versions of Fedora.

To test a Zip drive,

```
sudo ./check-zip-drive.sh /dev/sdX
```

Where `/dev/sdX` is the block device for the Zip drive.  **The test will destroy any data on the disk in the drive.**  Some checks are in place to prevent running the test on non-Zip disks, but be careful!

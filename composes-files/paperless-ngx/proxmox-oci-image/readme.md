1. Celery will have issues launching, you can check that inside the Paperless-ngx container using the following commands:
```
ls -la /dev/shm
mount | grep shm
```
2. You can fix it by adding this to your container config (e.g. `/etc/pve/lxc/<LXCID>.conf`):
```
lxc.mount.entry = tmpfs dev/shm tmpfs rw,nosuid,nodev,create=dir 0 0
```
3. Finally, restart the container. Celery should start up fine after that.

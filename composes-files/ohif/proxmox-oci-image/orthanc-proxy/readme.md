# Setting up NGINX container
1. To get the NGINX container to run, make sure you have a mount point set to:
   ```
   /etc/nginx/conf.d/
   ```
2. Start the container once (does not matter if it crashes or not)
   - Reason: We want `/etc/nginx/conf.d/default.conf` in the container to generate with the correct owner and permissions.
3. Run the following command on the host:
   ```
   cat > /rpool/data/subvol-10162-disk-1/default.conf <<'EOF'
   server {
       listen 80 default_server;
       location /orthanc/ {
           proxy_pass http://YourOrthancIP:8042;
           proxy_set_header HOST $host;
           proxy_set_header X-Real-IP $remote_addr;
           rewrite /orthanc(.*) $1 break;
           add_header Access-Control-Allow-Credentials true always;
           add_header Access-Control-Allow-Headers DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type always;
           add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
           add_header Access-Control-Allow-Origin * always;
       }
   }
   EOF
   ```
   - Replace `subvol-10162-disk-1` with the subvolume and disk corresponding to your container pointing to `/etc/nginx/conf.d/`
   - Replace `http://YourOrthancIP:8042` with the IP address of the orthanc container
     - In my case, I would write `http://10.0.1.162:8042`
4. Start the container now, and it should work.

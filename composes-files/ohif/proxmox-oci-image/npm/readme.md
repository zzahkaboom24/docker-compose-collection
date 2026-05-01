Setting up the reverse proxy [NPM] correctly for OHIF + Orthanc + oauth2-proxy + Pocket ID
1. Go in NGINX Proxy Manager -> Create a `Proxy Host`:
   - `Domain Names`: ohif.zzahkaboom24.de
     - Replace with whatever you want your domain name to be for OHIF
   - `Scheme`: http
   - `Forward Hostname / IP`: 10.0.1.163
     - Replace with whatever the IP of the OHIF container is
   - `Forward Port`: 80
     - Replace with whatever port you set in the OHIF container
       - Environment variable `PORT` is set to 80 by default and can be changed accordingly
2. In the `Custom Locations` tab, add the following:
   - `Location`: /oauth2/
   - `Scheme`: http
   - `Forward Hostname / IP`: 10.0.1.164
     - Replace with whatever the IP of the oauth2-proxy container is
   - `Forward Port`: 4180
3. In the `Advanced` tab, add the following:
   ```
   location = /oauth2/auth {
       internal;
       proxy_pass http://10.0.1.164:4180;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Scheme $scheme;
       proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
       proxy_set_header Content-Length "";
       proxy_pass_request_body off;
   }
   
   location = /manifest.json {
       proxy_pass http://10.0.1.163:80;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
   }
   
   location / {
       auth_request /oauth2/auth;
       error_page 401 = /oauth2/sign_in?rd=$scheme://$host$request_uri;
   
       auth_request_set $auth_cookie $upstream_http_set_cookie;
       add_header Set-Cookie $auth_cookie;
   
       proxy_pass http://10.0.1.163:80;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
   }
   ```
   - Replace `http://10.0.1.164` with whatever the IP of the oauth2-proxy container is
   - Replace `http://10.0.1.163:80` with whatever the IP and port of the OHIF container is
4. Hit `Save`
5. Create another `Proxy Host`:
   - `Domain Names`: orthanc.zzahkaboom24.de
     - Replace with whatever you want your domain name to be for OHIF
   - `Scheme`: http
   - `Forward Hostname / IP`: 10.0.1.161
     - Replace with whatever the IP of the OHIF container is
   - `Forward Port`: 8042
6. In the `Custom Locations` tab, add the following 2 locations:
   First:
   - `Location`: /orthanc/
   - `Scheme`: http
   - `Forward Hostname / IP`: 10.0.1.162
     - Replace with whatever the IP of the nginx container is
   - `Forward Port`: 80
   Second:
   - `Location`: /oauth2/
   - `Scheme`: http
   - `Forward Hostname / IP`: 10.0.1.164
     - Replace with whatever the IP of the oauth2-proxy container is
   - `Forward Port`: 4180
7. In the `Advanced` tab, add the following:
   ```
   location = /oauth2/auth {
       internal;
       proxy_pass http://10.0.1.164:4180;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Scheme $scheme;
       proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
       proxy_set_header Content-Length "";
       proxy_pass_request_body off;
   }
   
   location / {
       auth_request /oauth2/auth;
       error_page 401 = /oauth2/sign_in?rd=$scheme://$host$request_uri;
       auth_request_set $auth_cookie $upstream_http_set_cookie;
       add_header Set-Cookie $auth_cookie;
   
       proxy_pass http://10.0.1.161:8042;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
   }
   ```
   - Replace `http://10.0.1.164` with whatever the IP of the oauth2-proxy container is
   - Replace `http://10.0.1.161` with whatever the IP of the Orthanc container is
8. Hit `Save`

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
2. In the `Custom Locations` tab, add the following locations:
   - First:
     - `Location`: /oauth2/
     - `Scheme`: http
     - `Forward Hostname / IP`: 10.0.1.164
       - Replace with whatever the IP of the oauth2-proxy container is
     - `Forward Port`: 4180
   - Second:
     - `Location`: /orthanc/
     - `Scheme`: http
     - `Forward Hostname / IP`: 10.0.1.161
       - Replace with whatever the IP of the oauth2-proxy container is
     - `Forward Port`: 8042
     - Click on the `Advanced` button for this specific custom location, and add the following:
       ```
       default_type text/html;
       return 403 '
       <!DOCTYPE html>
       <html>
       <head>
       <title>403 Forbidden</title>
       <style>
           body { background-color: #121212; color: #e0e0e0; font-family: sans-serif; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; margin: 0; }
           h1 { border-bottom: 1px solid #333; padding-bottom: 10px; width: 80%; text-align: center; font-weight: normal; }
           .footer { font-size: 0.9em; color: #666; margin-top: 10px; }
           a { color: #bb86fc; text-decoration: none; }
           a:hover { text-decoration: underline; }
       </style>
       </head>
       <body>
           <h1>403 Forbidden</h1>
           <p>Direct access to Orthanc UI is disabled on this domain.</p>
           <p>Use the Orthanc domain instead.</p>
           <p>Return to <a href="/">OHIF Viewer</a></p>
       </body>
       </html>
       ';
       ```
       - This ensures that https://ohif.yourdomain.tld/orthanc/ stays blocked
         - That's because it brings us to the Orthanc WebUI anyways, so is not of any use to us
   - Third:
     - `Location`: /orthanc/dicom-web/
     - `Scheme`: http
     - `Forward Hostname / IP`: 10.0.1.161
       - Replace with whatever the IP of the oauth2-proxy container is
     - `Forward Port`: 8042
     - Click on the `Advanced` button for this specific custom location, and add the following:
       ```
       auth_request /oauth2/auth;
       error_page 401 = /oauth2/sign_in?rd=$scheme://$host$request_uri;
       auth_request_set $auth_cookie $upstream_http_set_cookie;
       add_header Set-Cookie $auth_cookie;
       
       rewrite ^/orthanc/(.*)$ /$1 break;
       
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       
       proxy_redirect off;
       ```
4. In the `Advanced` tab, add the following:
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
5. Hit `Save`
6. Create another `Proxy Host`:
   - `Domain Names`: orthanc.zzahkaboom24.de
     - Replace with whatever you want your domain name to be for OHIF
   - `Scheme`: http
   - `Forward Hostname / IP`: 10.0.1.161
     - Replace with whatever the IP of the OHIF container is
   - `Forward Port`: 8042
7. In the `Custom Locations` tab, add the following location:
   - `Location`: /oauth2/
   - `Scheme`: http
   - `Forward Hostname / IP`: 10.0.1.164
     - Replace with whatever the IP of the oauth2-proxy container is
   - `Forward Port`: 4180
8. In the `Advanced` tab, add the following:
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
9. Hit `Save`

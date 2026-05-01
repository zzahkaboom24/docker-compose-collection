# Setting up OHIF container
1. Make a directory which we'll save our hookscript in:
   ```
   mkdir -p /var/lib/vz/snippets
   ```
2. Run the following command on the host:
   ```
   cat > /var/lib/vz/snippets/setcap-ohif.sh <<'EOF'
   #!/bin/sh
   CTID="$1"
   PHASE="$2"
   
   if [ "$PHASE" = "pre-start" ]; then
       setcap 'cap_net_bind_service=+ep' "/rpool/data/subvol-${CTID}-disk-0/usr/sbin/nginx" || true
   fi
   EOF
   ```
3. Make it executable:
   ```
   chmod +x /var/lib/vz/snippets/setcap-ohif.sh
   ```
4. Wire it into the container:
   ```
   pct set 10163 -hookscript local:snippets/setcap-ohif.sh
   ```
   - Replace `10163` with whatever your LXC container's id is
---
## Additional note
If any changes are made to the `APP_CONFIG` variable of the OHIF container, and you have OHIF behind Cloudflare, follow these steps to properly apply changes despite Cloudflare caching:
1. Access the OHIF container:
   ```
   pct enter 10163
   ```
2. Delete `app-config.js` and `app-config.js.gz`:
   ```
   rm -rf /usr/share/nginx/html/app-config.js /usr/share/nginx/html/app-config.js.gz
   ```
3. Do your changes to the `APP_CONFIG` variable if not already done
4. Restart the OHIF container:
   ```
   pct stop 10163
   ```
   ```
   pct start 10163
   ```
5. Go to the Cloudflare Dashboard -> Your domain -> Caching -> Configuration -> Custom Purge -> URL -> Enter `https://ohif.yourdomain.tld/app-config.js` -> Click `Purge`
   - Now `https://ohif.yourdomain.tld/app-config.js` should finally show the changes to the `APP_CONFIG` correctly

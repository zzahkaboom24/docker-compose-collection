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

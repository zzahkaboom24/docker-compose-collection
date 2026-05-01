# Setting up oauth2-proxy container
1. To get the NGINX container to run, make sure you have a mount point set to:
   ```
   /etc/oauth2-proxy/
   ```
2. Run the following command on the host:
   ```
   cat > /rpool/data/subvol-10164-disk-1/oauth2-proxy.cfg <<'EOF'
   http_address = "0.0.0.0:4180"
   reverse_proxy = true
   
   # Replace YOUR-POCKET-ID-DOMAIN with your actual Pocket ID URL
   provider = "oidc"
   oidc_issuer_url = "https://YOUR-POCKET-ID-DOMAIN"
   client_id = "PASTE-FROM-POCKET-ID"
   client_secret = "PASTE-FROM-POCKET-ID"

   # Use `openssl rand -base64 32 | tr -- '+/' '-_' | head -c 32` in terminal to generate the 32 character random secret
   cookie_domains = [".zzahkaboom24.de"]
   cookie_secure = true
   cookie_secret = "GENERATE-A-32-BYTE-RANDOM-STRING"
   cookie_expire = "168h"

   # Replace https://ohif.yourdomain.tld/oauth2/callback with your actual OHIF URL
   whitelist_domains = [".zzahkaboom24.de"]
   redirect_url = "https://ohif.yourdomain.tld/oauth2/callback"

   # Don't require email-domain whitelisting (Pocket ID handles user allow-listing)
   email_domains = ["*"]
   skip_provider_button = true
   code_challenge_method = "S256"

   # Restricts which IPs oauth2-proxy trusts.
   # Change depending on the subnet all your CTs live on.
   trusted_proxy_ips = ["10.0.1.0/24"]
   ```
3. Fix ownership:
   ```
   chown 100000:100000 /rpool/data/subvol-10164-disk-1/oauth2-proxy.cfg
   ```
4. Inside Pocket ID, register an OIDC client with two redirect URIs:
   ```
   https://ohif.zzahkaboom24.de/oauth2/callback
   ```
   ```
   https://orthanc.zzahkaboom24.de/oauth2/callback
   ```
   - Now you can get the `client_id` and `client_secret` for your oauth2-proxy configuration
5. Start the container now, and it should work.

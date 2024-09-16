To install **Nginx** and set up a **custom domain** to point to `localhost` on Ubuntu 20.04, follow these steps. We'll use Nginx as a reverse proxy to route requests from a custom domain (like `myapp.local`) to a local service running on `localhost:3000`.

### Steps:
1. **Install Nginx**.
2. **Set up a custom domain** in your `/etc/hosts` file.
3. **Configure Nginx for your custom domain**.
4. **Test your configuration**.

### 1. Install Nginx

First, install Nginx on your **Ubuntu** machine. For [MacOS](nginx-macos.md)

```bash
sudo apt update
sudo apt install nginx
```




After installation, Nginx should automatically start. You can check its status with:

```bash
sudo systemctl status nginx
```

If it's not running, start Nginx manually:

```bash
sudo systemctl start nginx
```

Ensure Nginx starts on boot:

```bash
sudo systemctl enable nginx
```

### 2. Set Up a Custom Domain in `/etc/hosts`

To point a custom domain (like `myapp.local`) to `localhost`, modify your `/etc/hosts` file.

Open the file for editing:

```bash
sudo nano /etc/hosts
```

Add a new line for your custom domain:

```
127.0.0.1    myapp.local
```

Save the file (`Ctrl + O`, then `Enter`) and exit (`Ctrl + X`).

Now, when you type `myapp.local` in your browser, it will point to `localhost`.

### 3. Configure Nginx for Your Custom Domain

Next, configure Nginx to handle requests to `myapp.local` and route them to your local service (e.g., a Next.js app running on `localhost:3000`).

#### Create a new Nginx configuration file for your domain:

```bash
sudo nano /etc/nginx/sites-available/myapp.local
```

Add the following configuration to route traffic from `myapp.local` to a service running on `localhost:3000`:

```nginx
server {
    listen 80;
    server_name myapp.local;

    location / {
        proxy_pass http://localhost:3000;  # Route to local service on port 3000
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### Enable the new site configuration:

1. Create a symbolic link to the `sites-enabled` directory to activate the configuration.

   ```bash
   sudo ln -s /etc/nginx/sites-available/myapp.local /etc/nginx/sites-enabled/
   ```

2. Test the Nginx configuration to ensure there are no syntax errors:

   ```bash
   sudo nginx -t
   ```

   If the configuration is valid, you’ll see a message like: `nginx: configuration file /etc/nginx/nginx.conf test is successful`.

3. Reload Nginx to apply the changes:

   ```bash
   sudo systemctl reload nginx
   ```

### 4. Test Your Configuration

At this point, you should be able to access your local service using your custom domain.

1. Ensure your local service (e.g., a Next.js app or any web server) is running on `localhost:3000`.

   ```bash
   npm run dev  # If it's a Next.js app
   ```

2. Open a browser and navigate to `http://myapp.local`. You should see your local service being served by Nginx.

## Optional: Set Up HTTPS with a Self-Signed Certificate

If you want to configure HTTPS, you can generate a self-signed certificate and set up Nginx to serve your app over HTTPS.

#### Step 1: Generate SSL Certificates

Make dir `ssl`
```
sudo mkdir -p /etc/nginx/ssl
```

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/myapp.local.key -out /etc/nginx/ssl/myapp.local.crt -subj "/CN=myapp.local"
```

This will generate the following files:
- `/etc/nginx/ssl/myapp.local.key`: The private key.
- `/etc/nginx/ssl/myapp.local.crt`: The certificate.

#### Trust the Self-Signed Certificate (Optional)
Since this is a self-signed certificate, your browser will not automatically trust it, and you’ll see a security warning. To avoid this, you can manually trust the certificate by adding it to your trusted root certificates.

- For Chrome (MacOS/Linux):
Go to `chrome://settings/security`
Scroll down to "Manage certificates."
In the "Authorities" tab, import the localhost.crt file you generated.

- For Chrome (Windows):
Open Chrome settings.
Search for "Security" and click "Manage Certificates."
Under the "Trusted Root Certification Authorities" tab, import the localhost.crt.

#### Step 2: Configure Nginx to Use HTTPS

Edit the Nginx configuration for `myapp.local`:

```bash
sudo nano /etc/nginx/sites-available/myapp.local
```

Update the configuration to listen on port `443` for HTTPS and point to your SSL certificates:

```nginx
server {
    listen 80;
    server_name myapp.local;
    return 301 https://$host$request_uri;  # Redirect HTTP to HTTPS
}

server {
    listen 443 ssl;
    server_name myapp.local;

    ssl_certificate /etc/nginx/ssl/myapp.local.crt;
    ssl_certificate_key /etc/nginx/ssl/myapp.local.key;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### Step 3: Reload Nginx

```bash
sudo systemctl reload nginx
```

Now you should be able to access your app securely using `https://myapp.local`. Note that since this is a self-signed certificate, your browser will likely show a security warning.

### Summary

1. **Install Nginx** and set up a local domain in `/etc/hosts`.
2. **Configure Nginx** to route the custom domain (e.g., `myapp.local`) to `localhost`.
3. **Test the setup** by running your local service and visiting the custom domain.
4. Optionally, **set up HTTPS** with a self-signed certificate.

By following these steps, you can easily access your local development environment using a custom domain name like `myapp.local`.

## Troubles:

`nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)`

To check what is running on port 80 and kill the process in Ubuntu, follow these steps:

### 1. Check What Is Running on Port 80

You can use the `lsof` (list open files) or `netstat` commands to check which process is using port 80.

#### Using `lsof`:
```bash
sudo lsof -i :80
```

This will display a list of processes using port 80. You should see output like this:

```
COMMAND   PID   USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
nginx    12345  root   6u  IPv4 1234567      0t0  TCP *:http (LISTEN)
```

In this example, `nginx` is running on port 80, and the process ID (PID) is `12345`.

#### Using `netstat`:
```bash
sudo netstat -tuln | grep :80
```

This will show something like:

```
tcp        0      0 0.0.0.0:80          0.0.0.0:*               LISTEN
```

If you want more detailed information about the process, use the `ps` command with the PID obtained from the `lsof` or `netstat` output.

### 2. Kill the Process Running on Port 80

Once you have the PID of the process using port 80, you can kill it using the `kill` command:

```bash
sudo kill -9 <PID>
```

For example, if the PID of the process is `12345`:

```bash
sudo kill -9 12345
```

Alternatively, you can use the process name (for example, `nginx`) to stop the service:

#### If Nginx or Apache is Running:
If the service running on port 80 is `nginx` or `apache2`, you can stop it directly using the following commands:

```bash
# For Nginx
sudo systemctl stop nginx

# For Apache
sudo systemctl stop apache2
```

### 3. Verify Port 80 is Free

After killing the process or stopping the service, verify that nothing is running on port 80:

```bash
sudo lsof -i :80
```

If the command returns no output, then port 80 is now free.

### Summary

1. **Find the process** using port 80:
   - `sudo lsof -i :80`
2. **Kill the process**:
   - `sudo kill -9 <PID>`
3. **Verify that port 80 is free**:
   - `sudo lsof -i :80`

**This will help you free up port 80 for other services.**

## How to Fix HSTS Issue
- Option 1: Clear the HSTS Settings in Your Browser
You need to clear the HSTS policy for myapp.local from your browser. Here’s how to do it for different browsers:

- For Chrome:
Open Chrome and go to the URL `chrome://net-internals/#hsts`
In the Delete domain security policies section, enter "myapp.local" into the Domain: field.
Click Delete.

## Site is opening in google search
- Use incognito tab in your browser.

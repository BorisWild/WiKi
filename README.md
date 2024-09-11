To install **Nginx** and set up a **custom domain** to point to `localhost` on Ubuntu 20.04, follow these steps. We'll use Nginx as a reverse proxy to route requests from a custom domain (like `myapp.local`) to a local service running on `localhost`.

### Steps:
1. **Install Nginx**.
2. **Set up a custom domain** in your `/etc/hosts` file.
3. **Configure Nginx for your custom domain**.
4. **Test your configuration**.

### 1. Install Nginx

First, install Nginx on your Ubuntu machine.

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

### Optional: Set Up HTTPS with a Self-Signed Certificate

If you want to configure HTTPS, you can generate a self-signed certificate and set up Nginx to serve your app over HTTPS.

#### Step 1: Generate SSL Certificates

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/myapp.local.key -out /etc/nginx/ssl/myapp.local.crt -subj "/CN=myapp.local"
```

This will generate the following files:
- `/etc/nginx/ssl/myapp.local.key`: The private key.
- `/etc/nginx/ssl/myapp.local.crt`: The certificate.

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

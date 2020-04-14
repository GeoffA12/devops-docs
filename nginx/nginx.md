# Nginx Configuration
[Back to Server Config](readme.md)

Nginx is a relatively lightweight and powerful webserver for Linux that we will be using in order to redirect requests coming in to our server and to serve static resources (such as HTML pages) back to a client. Nginx has some powerful tools at its disposal, one of the most important (for this guide and project) being the `proxy-pass` functionality. As you know from Software Engineering 1, we had to write request handlers and APIs that listened on specific ports in the system for requests, and would respond to those requests. However, those request handlers were listening on `localhost` only, meaning they wouldn't be accessible from outside of the server. For problems like this, Nginx acts as a "reverse proxy", listening for normal HTTP/HTTPS requests on ports 80 and 443 (respectively), and then can either reroute the traffic to another webserver (either within the system, that would be listening on a `localhost:[port]`, or to a seperate physical server entirely), serve static web files, invoke PHP or other server-side languages, and a myriad of other functionality not mentioned here. 

For configuring Nginx, there are two directories that should be called out on the system as important before heading any further:

 * `/etc/nginx/sites-available/`
 * `/etc/nginx/sites-enabled/`

These two directories serve to hold the Nginx configurations for sites and services that the server should be able to serve back to those who initiate requests to the services. The `sites-available` directory is the hub of all configurations for each service/site/domain that you are going to be hosting on that server, or be proxy-passing to another server using Nginx as a middleman. However, nginx will only use configurations in `sites-enabled` in order to process requests, and we are going to ue this to our advantage. By putting configurations into `sites-available` instead of `sites-enabled`, we can easily take a certain ruleset offline, without having to worry about removing or moving files, since we can make a link from a configuration file in `sites-available` to `sites-enabled`, and that will allow Nginx to find and enable that configuration. This method ensures that there is only 1 version of the configuration on the server at any one time, configurations can be disabled if we so choose, and configurations can exist in `sites-available` that aren't ready to be enabled (such as editing/creating them, and coming back to them).

To start, we will make sure the Nginx service is started and runs before working. Then, download the sample configuration provided [here](sample.nginx.conf) on the server to `/etc/nginx/sites-available/`, and we will and dive into editing the sample configuration so that it will be usable on your server.

To check the status of Nginx on Ubuntu, we are going to use the native Linux process manager `system-d`, and its command line utility `systemctl` to interact with the Nginx process. System-d will manage the launch and running of our Nginx process, and will also autostart it when the server reboots. (This will look similar to using `sudo ./backend.sh [api] start|stop|status` from SWE1, which is because the `backend.sh` script provided by the TAs used system-d behind the scenes).

```
sudo systemctl start nginx
sudo systemctl enable nginx
systemctl status nginx
```

To download the sample configuration into `/etc/ngnix/sites-available`:

```
cd /etc/nginx/sites-available
wget https://bitbucket.org/2019swe2documentation/server-setup/raw/17fc04e21a2b8f64292374196c6127b558423206/sample.nginx.conf
```

Go ahead and open up the file with `nano` (a command line text editor), and we are going to change a couple of lines in order to have Nginx redirect to our Node instance that we set up earlier. For this we will need the Port number from the node instance we configured earlier, as well as the subdomain we configured in the Digital Ocean web portal. 

When using the sample configuration included, replace the `XX01` with the port number for our Node instance, and anywhere it says `DOMAIN_HERE` with our domain that we set up in Digital Ocean. Finally, replace `/SOME/PATH` with the path that you want to have after the domain (i.e. after .com/). `/` is a valid value, however since it is already used earlier in the configuration, use `/node` for now. Exit nano with `Ctrl + X` and save, then we will make a link to `/etc/nginx/sites-enabled/` to enable our config. Following this, we will generate our HTTPS certificates, then restart Nginx. **IF YOU RECEIVE AN ERROR AT THIS STAGE, DO NOT RESTART NGINX UNTIL THE TEST COMMAND (`nginx -t`) PASSES!**

```
sudo ln -s /etc/nginx/sites-available/sample.nginx.conf /etc/nginx/sites-enabled/
nginx -t
sudo systemctl restart nginx
```

### SSL/HTTPS Configuration with Certbot

Finally, we are going to setup HTTPS certificates for our domain. We won't be able to access our site without it, because our Nginx configuration is set to redirect traffic to HTTPS, however without a certificate browsers won't load the site. Luckily, Certbot makes it really simple to generate HTTPS certificates and keys with Lets Encrypt. The certs will also be added automatically to our site's Nginx config after they are generated.

To use Certbot, call the certbot command, and walk through the prompts to setup certbot. Certbot will ask you for your email address as a verification step, and will ask for you to accept the terms and conditions (Yes), and if you'd like to be on the mailing list (you can say no to this), then attempt the challenges to verify the server is setup for https.

Certbot will present you two options for setting up Nginx redirection to HTTPS if the challenges succeed. We want to choose option `1 - No Redirection`, since we already have redirection in our Nginx config. This option will still automatically add the certificate lines to our Nginx config.

```
sudo certbot --nginx -d [domain]
```

Now that we have configred HTTPS, we can restart Nginx and our server is set up! we can now navigate to our domain and our Node site should appear, and values should write to mongoDB.

```
sudo nginx -t
sudo systemctl restart nginx
```

From here you can load your site!

[Back to main docs](readme.md)
server {
        listen [::]:443 ssl;
        listen 443 ssl;
	root /var/www/demand.team22.softwareengineeringii.com/html;
        server_name demand.team22.softwareengineeringii.com;

        underscores_in_headers on;
	
	location /orderHandler {
		proxy_pass http://localhost:4004;
		proxy_http_version 1.1;
		proxy_set_header Host $host;
	}
	
        location /cs {
                proxy_pass http://localhost:4023;
		proxy_http_version 1.1;
		proxy_set_header Host $host;
        }

        location / {
                index common-services/index.html common-services/index.htm;
        }


    ssl_certificate /etc/letsencrypt/live/demand.team22.softwareengineeringii.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/demand.team22.softwareengineeringii.com/privkey.pem; # managed by Certbot
}

server {
        listen 80 ;
        listen [::]:80 ;
        server_name demand.team22.softwareengineeringii.com;

        return 301 https://$host$request_uri;
}

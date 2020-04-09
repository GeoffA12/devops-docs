server {
        listen [::]:443 ssl;
        listen 443 ssl;

        server_name demand.team12.softwareengineeringii.com;

        underscores_in_headers on;

        location /api/backend {
                proxy_set_header        Host $host;
                proxy_set_header        X-Real-IP $remote_addr;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header        X-Forwarded-Proto $scheme;

                proxy_pass http://localhost:4012;
        }

        location /api/cs {
                proxy_set_header        Host $host;
                proxy_set_header        X-Real-IP $remote_addr;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header        X-Forwarded-Proto $scheme;

                proxy_pass http://localhost:4112;
        }

        location /apps {
                root /home/team12;
                index index.html index.htm;
        }

	location /cs/ {
		root /home/team12;
	}

        location / {
                root /home/team12/demand-frontend;
                index index.html index.htm;
        }


    ssl_certificate /etc/letsencrypt/live/demand.team12.softwareengineeringii.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/demand.team12.softwareengineeringii.com/privkey.pem; # managed by Certbot
}

server {
        listen 80 ;
        listen [::]:80 ;
        server_name demand.team12.softwareengineeringii.com;

        return 301 https://$host$request_uri;
}

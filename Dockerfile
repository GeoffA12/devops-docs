FROM nginx

RUN rm /etc/nginx/conf.d/default.conf

RUN mkdir /etc/letsencrypt
RUN mkdir /etc/letsencrypt/live
RUN mkdir /etc/letsencrypt/live/demand.team22.softwareengineeringii.com

RUN mkdir /var/www
RUN mkdir /var/www/demand.team22.softwareengineeringii.com
RUN mkdir /var/www/demand.team22.softwareengineeringii.com/html

COPY nginx/sites-available/demand.team22.softwareengineeringii.com /etc/nginx/conf.d
COPY demand.team22.softwareengineeringii.com /etc/letsencrypt/live/demand.team22.softwareengineeringii.com
COPY demand-cloud /var/www/demand.team22.softwareengineeringii.com/html
WORKDIR /var/www/demand.team22.softwareengineeringii.com/html
EXPOSE 80
EXPOSE 443
#ADD ./ /var/www/demand.team22.softwareengineeringii.com/html 
#COPY /etc/letsencrypt/live/demand.team22.softwareengineeringii.com /etc/letsencrypt/live/demand.team22.softwareengineeringii.com


# Nginx ReverseProxy Creator
![NginxLogo](https://www.nginx.com/resources/wiki/_static/img/logo.png)

Just a little script to create Nginx reverse proxy with SSL support.

## Installation
To start, just clone this repo to your **/opt** folder :
```
git clone https://github.com/bilyboy785/nginx-reverseproxy-creator.git /opt/nginxreverse && cd /opt/nginxreverse
```

## Defaut Usage
By default, you can launch the script without parameters :
```
./nginx-reverse.sh
```

It will ask you some informations about domain and application port :

![NginxReverse](https://goo.gl/W3NNUf)

## Advanced Usage
So, you can use parameters when launching the script. Two options are available :
 * classic : create a classic reverse proxy with HTTP support (80)
 * ssl : create an SSL reverse proxy with HTTPS and auto redirection from 80 to 443


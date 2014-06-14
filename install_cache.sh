#!/usr/bin/env bash

wget http://repo.varnish-cache.org/debian/GPG-key.txt -O- -o /dev/null | sudo apt-key add -
echo "deb http://repo.varnish-cache.org/ubuntu/ precise varnish-4.0" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install -y varnish


sudo tee /etc/varnish/default.vcl <<EOF
backend default {
  .host = "192.168.2.101";
  .port = "80";
}

sub vcl_recv {
  # unless sessionid is in the request, don't pass ANY cookies (referral_source, utm, etc)
  if (req.request == "GET" && (req.url ~ "^/static" || req.url ~ "^/media" || req.http.cookie !~ "sessionid")) {
    remove req.http.Cookie;
  }

  # normalize accept-encoding to account for different browsers
  # see: https://www.varnish-cache.org/trac/wiki/VCLExampleNormalizeAcceptEncoding
  if (req.http.Accept-Encoding) {
    if (req.http.Accept-Encoding ~ "gzip") {
      set req.http.Accept-Encoding = "gzip";
    } elsif (req.http.Accept-Encoding ~ "deflate") {
      set req.http.Accept-Encoding = "deflate";
    } else {
    # unkown algorithm
      remove req.http.Accept-Encoding;
    }
  }
}

sub vcl_fetch {
  # static/media files always cached
  if (req.url ~ "^/static" || req.url ~ "^/media") {
    unset beresp.http.set-cookie;
    return (deliver);
  }

  # pass through for anything with a session/csrftoken set
  if (beresp.http.set-cookie ~ "sessionid" || beresp.http.set-cookie ~ "csrftoken") {
    return (hit_for_pass);
  } else {
    return (deliver);
  }
}
EOF

sudo sed -i /etc/default/varnish -e 's/-a :6081/-a :80/'

sudo service varnish restart
vcl 4.1;

backend default {
    .host = "127.0.0.1";
    .port = "8443";
}

sub vcl_recv {
    if (req.http.Authorization || req.http.Cookie) {
        return (pass);
    }

    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    set req.url = regsub(req.url, "\?.*$", "");

    return (hash);
}

sub vcl_hash {
    hash_data(req.url);
    if (req.http.Host) {
        hash_data(req.http.Host);
    }
    return (lookup);
}

sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
}

sub vcl_backend_response {
    if (beresp.status == 200) {
        set beresp.ttl = 120s;
    } else {
        set beresp.ttl = 0s;
    }
    unset beresp.http.Set-Cookie;

    return (deliver);
}
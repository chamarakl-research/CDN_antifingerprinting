#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide for a comprehensive documentation
# at https://www.varnish-cache.org/docs/.

# Marker to tell the VCL compiler that this VCL has been written with the
# 4.0 or 4.1 syntax.
vcl 4.1;
import proxy;
# Default backend definition. Set this to point to your content server.
backend default {
    .host = "10.42.0.1";
    .port = "8080";
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.
    if(!req.http.X-Forwarded-Proto)
    {
        if (proxy.is_ssl())
        {
            set req.http.X-Forwarded-Proto = "https";
        }
        else
        {
            set req.http.X-Forwarded-Proto = "http";
        }
    }

    if(req.url ~"\.(png|gif|jpg|swf|css|js)$")
    {
        return (hash);
    }
}

sub vcl_hash
{
    hash_data(req.url);
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.
    if(beresp.ttl <= 0s || beresp.http.Set-Cookie || beresp.http.Vary=="*")
    {
        set beresp.ttl = 120 s;
        return (deliver);
    }
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.
    if(obj.hits > 0)
    {
        set resp.http.X-Cache = "HIT";
    }
    else
    {
        set resp.http.X-Cache = "MISS";
    }
}

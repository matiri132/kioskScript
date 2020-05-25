# By default, uWSGI will look for a callable called application, #which is why we called our function application
# environ: ENV_VAR  ---- start_resoibse: the name the app will use internally to reffer the webserver (uWSGI)
def application(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/html')])
    return b"<h1 style='color:blue'>Hello There!</h1>"

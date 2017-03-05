import std.functional;
import std.exception;

import vibe.http.router;
import vibe.http.server;
import vibe.http.fileserver;

private void main()
{
	auto router = new URLRouter;
	router.get("/", &showHome);
	router.get("*", serveStaticFiles("public"));

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.errorPageHandler = toDelegate(&showError);
	settings.accessLogToConsole = true;

	listenHTTP (settings, router);

	import vibe.core.core;

	runTask(
		{
			import std.process:browse;
			browse ("http://127.0.0.1:8080/");
		}
	);

	runApplication();
}

private void showError (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
	res.render!("error.dt", req, error);
}

private void showHome (HTTPServerRequest req, HTTPServerResponse res)
{
	res.render!("home.dt", req);
}

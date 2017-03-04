import vibe.http.server;

private void main()
{
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP (settings, &hello);

	import vibe.core.core;

	runTask(
		{
			import std.process:browse;
			browse ("http://127.0.0.1:8080/");
		}
	);

	runApplication();
}

private void hello (HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody ("Hello, World!");
}

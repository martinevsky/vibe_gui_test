import std.functional;
import std.exception;

import vibe.core.core;
import vibe.web.web;

struct ReviewInfo
{
	string url;
	string title;
	string autor;
	string state;
}

private void main()
{
	ReviewInfo[] reviews;

	{
		ReviewInfo info = {"http://yandex.ru", "Test review title", "Somebody", "Somestate"};
		reviews ~= info;
	}

	{
		ReviewInfo info = {"http://google.ru", "Test TestTestTestTestTest review title", "Тщищвнbody", "Somestate"};
		reviews ~= info;
	}

	{
		ReviewInfo info = {"http://mail.ru", "Тестовое тесто", "Somebody", "Otherstate"};
		reviews ~= info;
	}

	{
		ReviewInfo info = {"http://yandex.ru", "Test review title", "Somebody", "Otherstate"};
		reviews ~= info;
	}

	import std.stdio;
	SelectReviewAndUpload (reviews, delegate (in ReviewInfo info){writeln ("Attach to:", info);}, {writeln ("Make new");});
	SelectReviewAndUpload (reviews, delegate (in ReviewInfo info){writeln ("Attach to:", info);}, {writeln ("Make new");});
}

class WebView
{
	interface Controller
	{
		const (ReviewInfo[]) GetReviewList() const;
		const void OnAttach (in uint index);
		const void OnMakeNew ();
	}

	this(Controller controller)
	{
		m_controller = controller;
	}

	public void index()
	{
		auto reviews = m_controller.GetReviewList(); 
		render!("home.dt", reviews)();
	}

	public void postAttach (uint reviewId)
	{
		m_controller.OnAttach (reviewId);

		redirect ("http://ya.ru/");

		exitEventLoop();
	}

	private Controller m_controller;
}

void SelectReviewAndUpload (in ReviewInfo[] reviews, in void delegate(in ReviewInfo) uploadToExisting, in void delegate() uploadToNew)
{
	class Controller : WebView.Controller
	{
		const (ReviewInfo[]) GetReviewList() const
		{
			return reviews;
		}

		const void OnAttach (in uint index)
		{
			uploadToExisting (reviews[index]);
		}

		const void OnMakeNew ()
		{
			uploadToNew();
		}
	}

	auto view = new WebView (new Controller);
	ShowWebView (view);
}

void ShowWebView (T)(T view)
{
	import vibe.http.router;
	import vibe.http.fileserver;
	
	static void showError (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
	{
		res.render!("error.dt", req, error);
	}

	auto router = new URLRouter;
	router.get ("*", serveStaticFiles ("public"));
	router.registerWebInterface (view);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.errorPageHandler = toDelegate (&showError);
	settings.accessLogToConsole = true;

	listenHTTP (settings, router);

	runTask(
		{
			import std.process:browse;
			browse ("http://127.0.0.1:8080/");
		}
	);

	runEventLoop();
}

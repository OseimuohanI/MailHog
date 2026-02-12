package web

import (
	"bytes"
	"html/template"
	"log"
	"mime"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/gorilla/pat"
	"github.com/mailhog/MailHog-UI/config"
)

var APIHost string
var WebPath string

const customCSS = "" +
"body.mh-dark { background: #0f1115; color: #e6e6e6; }\n" +
"body.mh-dark .navbar-default { background: #141821; border-color: #242a36; }\n" +
"body.mh-dark .navbar-default .navbar-brand,\n" +
"body.mh-dark .navbar-default .navbar-nav > li > a { color: #e6e6e6; }\n" +
"body.mh-dark .navbar-default .navbar-nav > li > a:hover,\n" +
"body.mh-dark .navbar-default .navbar-brand:hover { color: #ffffff; }\n" +
"body.mh-dark .nav > li > a { color: #d7dbe6; }\n" +
"body.mh-dark .nav > li > a:hover,\n" +
"body.mh-dark .nav > li > a:focus { background: #1b2130; color: #ffffff; }\n" +
"body.mh-dark .well { background: #161b22; border-color: #2a2f3a; color: #e6e6e6; }\n" +
"body.mh-dark .messages .msglist-message { border-bottom: 1px solid #2a2f3a; }\n" +
"body.mh-dark .messages .msglist-message:hover { background: #1b2130; }\n" +
"body.mh-dark .subject.unread { color: #e6e6e6; }\n" +
"body.mh-dark .toolbar { background: #0f1115; border-color: #2a2f3a; }\n" +
"body.mh-dark .btn-default { background: #1b2130; border-color: #2a2f3a; color: #e6e6e6; }\n" +
"body.mh-dark .btn-default:hover,\n" +
"body.mh-dark .btn-default:focus { background: #242b3d; color: #ffffff; }\n" +
"body.mh-dark input.form-control,\n" +
"body.mh-dark select.form-control { background: #0f1115; color: #e6e6e6; border-color: #2a2f3a; }\n" +
"body.mh-dark .list-group-item { background: #141821; border-color: #2a2f3a; color: #e6e6e6; }\n" +
"body.mh-dark .list-group-item:hover { background: #1b2130; }\n" +
"body.mh-dark .table > thead > tr > th,\n" +
"body.mh-dark .table > tbody > tr > th,\n" +
"body.mh-dark .table > tfoot > tr > th,\n" +
"body.mh-dark .table > thead > tr > td,\n" +
"body.mh-dark .table > tbody > tr > td,\n" +
"body.mh-dark .table > tfoot > tr > td { border-color: #2a2f3a; }\n" +
"body.mh-dark .nav-tabs > li > a { color: #d7dbe6; }\n" +
"body.mh-dark .nav-tabs > li.active > a,\n" +
"body.mh-dark .nav-tabs > li.active > a:hover,\n" +
"body.mh-dark .nav-tabs > li.active > a:focus { background: #141821; border-color: #2a2f3a; color: #ffffff; }\n" +
"body.mh-dark .tab-content { background: #0f1115; }\n" +
".mh-theme-fab { position: fixed; right: 16px; bottom: 16px; z-index: 9999; padding: 6px 10px; border-radius: 4px; border: 1px solid #2a2f3a; background: #1b2130; color: #e6e6e6; font-size: 12px; }\n" +
"body.mh-light .mh-theme-fab { background: #f7f7f7; color: #333333; border-color: #cccccc; }\n" +
"body.mh-dark .mh-theme-toggle { cursor: pointer; }\n"

const customJS = "" +
"(function(){\n" +
"  function ready(fn){\n" +
"    if(document.readyState !== 'loading'){ fn(); } else { document.addEventListener('DOMContentLoaded', fn); }\n" +
"  }\n" +
"\n" +
"  function setTheme(theme){\n" +
"    var body = document.body;\n" +
"    if(!body){ return; }\n" +
"    body.classList.toggle('mh-dark', theme === 'dark');\n" +
"    body.classList.toggle('mh-light', theme === 'light');\n" +
"  }\n" +
"\n" +
"  function getStoredTheme(){\n" +
"    try { return localStorage.getItem('mhTheme'); } catch(e) { return null; }\n" +
"  }\n" +
"\n" +
"  function storeTheme(theme){\n" +
"    try { localStorage.setItem('mhTheme', theme); } catch(e) {}\n" +
"  }\n" +
"\n" +
"  function resolveTheme(){\n" +
"    var stored = getStoredTheme();\n" +
"    if(stored){ return stored; }\n" +
"    if(window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches){\n" +
"      return 'dark';\n" +
"    }\n" +
"    return 'light';\n" +
"  }\n" +
"\n" +
"  function addToggle(){\n" +
"    var nav = document.querySelector('.navbar-nav.navbar-right');\n" +
"    var li;\n" +
"    var a = document.createElement('a');\n" +
"    a.href = '#';\n" +
"    a.className = 'mh-theme-toggle';\n" +
"    a.addEventListener('click', function(ev){\n" +
"      ev.preventDefault();\n" +
"      var next = document.body.classList.contains('mh-dark') ? 'light' : 'dark';\n" +
"      setTheme(next);\n" +
"      storeTheme(next);\n" +
"      updateLabel();\n" +
"    });\n" +
"    if(nav){\n" +
"      li = document.createElement('li');\n" +
"      li.appendChild(a);\n" +
"      nav.insertBefore(li, nav.firstChild);\n" +
"    } else {\n" +
"      a.className = 'mh-theme-fab';\n" +
"      document.body.appendChild(a);\n" +
"    }\n" +
"\n" +
"    function updateLabel(){\n" +
"      var isDark = document.body.classList.contains('mh-dark');\n" +
"      a.textContent = isDark ? 'Light mode' : 'Dark mode';\n" +
"    }\n" +
"    updateLabel();\n" +
"  }\n" +
"\n" +
"  function updateGithubLink(){\n" +
"    var link = document.querySelector('a[href*=\"github.com/mailhog/MailHog\"]');\n" +
"    if(!link){ return; }\n" +
"    link.href = 'https://github.com/OseimuohanI/MailHog';\n" +
"  }\n" +
"\n" +
"  ready(function(){\n" +
"    setTheme(resolveTheme());\n" +
"    updateGithubLink();\n" +
"    addToggle();\n" +
"  });\n" +
"\n" +
"  if(window.matchMedia){\n" +
"    var media = window.matchMedia('(prefers-color-scheme: dark)');\n" +
"    if(media && typeof media.addEventListener === 'function'){\n" +
"      media.addEventListener('change', function(e){\n" +
"        if(getStoredTheme()){ return; }\n" +
"        setTheme(e.matches ? 'dark' : 'light');\n" +
"      });\n" +
"    } else if(media && typeof media.addListener === 'function'){\n" +
"      media.addListener(function(e){\n" +
"        if(getStoredTheme()){ return; }\n" +
"        setTheme(e.matches ? 'dark' : 'light');\n" +
"      });\n" +
"    }\n" +
"  }\n" +
"})();\n"

type Web struct {
	config *config.Config
	asset  func(string) ([]byte, error)
}

func CreateWeb(cfg *config.Config, r http.Handler, asset func(string) ([]byte, error)) *Web {
	web := &Web{
		config: cfg,
		asset:  asset,
	}

	pat := r.(*pat.Router)

	WebPath = cfg.WebPath

	log.Printf("Serving under http://%s%s/", cfg.UIBindAddr, WebPath)

	pat.Path(WebPath + "/css/custom.css").Methods("GET").HandlerFunc(web.StaticBytes("text/css; charset=utf-8", []byte(customCSS)))
	pat.Path(WebPath + "/js/custom.js").Methods("GET").HandlerFunc(web.StaticBytes("application/javascript; charset=utf-8", []byte(customJS)))
	pat.Path(WebPath + "/images/{file:.*}").Methods("GET").HandlerFunc(web.Static("assets/images/{{file}}"))
	pat.Path(WebPath + "/css/{file:.*}").Methods("GET").HandlerFunc(web.Static("assets/css/{{file}}"))
	pat.Path(WebPath + "/js/{file:.*}").Methods("GET").HandlerFunc(web.Static("assets/js/{{file}}"))
	pat.Path(WebPath + "/fonts/{file:.*}").Methods("GET").HandlerFunc(web.Static("assets/fonts/{{file}}"))
	pat.StrictSlash(true).Path(WebPath + "/").Methods("GET").HandlerFunc(web.Index())

	return web
}

func (web Web) Static(pattern string) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, req *http.Request) {
		fp := strings.TrimSuffix(pattern, "{{file}}") + req.URL.Query().Get(":file")
		if b, err := web.asset(fp); err == nil {
			ext := filepath.Ext(fp)

			w.Header().Set("Content-Type", mime.TypeByExtension(ext))
			w.WriteHeader(200)
			w.Write(b)
			return
		}
		log.Printf("[UI] File not found: %s", fp)
		w.WriteHeader(404)
	}
}

func (web Web) StaticBytes(contentType string, data []byte) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, req *http.Request) {
		w.Header().Set("Content-Type", contentType)
		w.WriteHeader(200)
		w.Write(data)
	}
}

func (web Web) Index() func(http.ResponseWriter, *http.Request) {
	tmpl := template.New("index.html")
	tmpl.Delims("[:", ":]")

	asset, err := web.asset("assets/templates/index.html")
	if err != nil {
		log.Fatalf("[UI] Error loading index.html: %s", err)
	}

	tmpl, err = tmpl.Parse(string(asset))
	if err != nil {
		log.Fatalf("[UI] Error parsing index.html: %s", err)
	}

	layout := template.New("layout.html")
	layout.Delims("[:", ":]")

	asset, err = web.asset("assets/templates/layout.html")
	if err != nil {
		log.Fatalf("[UI] Error loading layout.html: %s", err)
	}

	layout, err = layout.Parse(string(asset))
	if err != nil {
		log.Fatalf("[UI] Error parsing layout.html: %s", err)
	}

	return func(w http.ResponseWriter, req *http.Request) {
		data := map[string]interface{}{
			"config":  web.config,
			"Page":    "Browse",
			"APIHost": APIHost,
		}

		b := new(bytes.Buffer)
		err := tmpl.Execute(b, data)

		if err != nil {
			log.Printf("[UI] Error executing template: %s", err)
			w.WriteHeader(500)
			return
		}

		data["Content"] = template.HTML(b.String())

		b = new(bytes.Buffer)
		err = layout.Execute(b, data)

		if err != nil {
			log.Printf("[UI] Error executing template: %s", err)
			w.WriteHeader(500)
			return
		}

		page := b.String()
		page = injectBefore(page, "</head>", "    <link rel=\"stylesheet\" href=\"css/custom.css\">\n")
		page = injectBefore(page, "</body>", "    <script src=\"js/custom.js\"></script>\n")

		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.WriteHeader(200)
		w.Write([]byte(page))
	}
}

func injectBefore(input string, marker string, insertion string) string {
	if strings.Contains(input, insertion) {
		return input
	}
	idx := strings.LastIndex(strings.ToLower(input), strings.ToLower(marker))
	if idx == -1 {
		return input
	}
	return input[:idx] + insertion + input[idx:]
}

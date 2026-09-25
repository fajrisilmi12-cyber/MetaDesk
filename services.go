package main

// Service is a Meta web service hosted inside the single MetaDesk window.
type Service struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	URL  string `json:"url"`
}

// services is the fixed dock list: one window, one session, no multi-account.
var services = []Service{
	{ID: "whatsapp", Name: "WhatsApp", URL: "https://web.whatsapp.com"},
	{ID: "instagram", Name: "Instagram", URL: "https://www.instagram.com"},
	{ID: "facebook", Name: "Facebook", URL: "https://www.facebook.com"},
}

// defaultServiceID is the service opened on startup.
const defaultServiceID = "whatsapp"

// serviceURL returns the URL for id, falling back to the default service.
func serviceURL(id string) string {
	for _, s := range services {
		if s.ID == id {
			return s.URL
		}
	}
	for _, s := range services {
		if s.ID == defaultServiceID {
			return s.URL
		}
	}
	return services[0].URL
}

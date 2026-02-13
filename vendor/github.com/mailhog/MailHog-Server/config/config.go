package config

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"github.com/ian-kent/envconf"
	"github.com/mailhog/MailHog-Server/monkey"
	"github.com/mailhog/data"
	"github.com/mailhog/storage"
)

// DefaultConfig is the default config
func DefaultConfig() *Config {
	return &Config{
		SMTPBindAddr: "0.0.0.0:1025",
		APIBindAddr:  "0.0.0.0:8025",
		Hostname:     "mailhog.example",
		MongoURI:     "127.0.0.1:27017",
		MongoDb:      "mailhog",
		MongoColl:    "messages",
		MaildirPath:  "./mailhog-data",
		JimStateFile: defaultJimStateFile,
		StorageType:  "maildir",
		CORSOrigin:   "",
		WebPath:      "",
		MessageChan:  make(chan *data.Message),
		OutgoingSMTP: make(map[string]*OutgoingSMTP),
	}
}

// Config is the config, kind of
type Config struct {
	SMTPBindAddr     string
	APIBindAddr      string
	Hostname         string
	MongoURI         string
	MongoDb          string
	MongoColl        string
	StorageType      string
	CORSOrigin       string
	MaildirPath      string
	InviteJim        bool
	JimStateFile     string
	Storage          storage.Storage
	MessageChan      chan *data.Message
	Assets           func(asset string) ([]byte, error)
	Monkey           monkey.ChaosMonkey
	OutgoingSMTPFile string
	OutgoingSMTP     map[string]*OutgoingSMTP
	WebPath          string
}

// OutgoingSMTP is an outgoing SMTP server config
type OutgoingSMTP struct {
	Name      string
	Save      bool
	Email     string
	Host      string
	Port      string
	Username  string
	Password  string
	Mechanism string
}

var cfg = DefaultConfig()

const defaultJimStateFile = "./mailhog-data/jim.json"

// Jim is a monkey
var Jim = &monkey.Jim{}

// Configure configures stuff
func Configure() *Config {
	switch cfg.StorageType {
	case "memory":
		log.Println("Using in-memory storage")
		cfg.Storage = storage.CreateInMemory()
	case "mongodb":
		log.Println("Using MongoDB message storage")
		s := storage.CreateMongoDB(cfg.MongoURI, cfg.MongoDb, cfg.MongoColl)
		if s == nil {
			log.Println("MongoDB storage unavailable, reverting to in-memory storage")
			cfg.Storage = storage.CreateInMemory()
		} else {
			log.Println("Connected to MongoDB")
			cfg.Storage = s
		}
	case "maildir":
		log.Println("Using maildir message storage")
		s := storage.CreateMaildir(cfg.MaildirPath)
		cfg.Storage = s
	default:
		log.Fatalf("Invalid storage type %s", cfg.StorageType)
	}

	if cfg.JimStateFile == defaultJimStateFile && cfg.MaildirPath != "./mailhog-data" {
		cfg.JimStateFile = filepath.Join(cfg.MaildirPath, "jim.json")
	}

	Jim.Configure(func(message string, args ...interface{}) {
		log.Printf(message, args...)
	})

	if err := LoadJimState(cfg); err != nil {
		log.Printf("Error loading Jim state: %s", err)
	}
	if cfg.InviteJim {
		cfg.Monkey = Jim
	} else {
		cfg.Monkey = nil
	}

	if len(cfg.OutgoingSMTPFile) > 0 {
		b, err := ioutil.ReadFile(cfg.OutgoingSMTPFile)
		if err != nil {
			log.Fatal(err)
		}
		var o map[string]*OutgoingSMTP
		err = json.Unmarshal(b, &o)
		if err != nil {
			log.Fatal(err)
		}
		cfg.OutgoingSMTP = o
	}

	return cfg
}

// RegisterFlags registers flags
func RegisterFlags() {
	flag.StringVar(&cfg.SMTPBindAddr, "smtp-bind-addr", envconf.FromEnvP("MH_SMTP_BIND_ADDR", "0.0.0.0:1025").(string), "SMTP bind interface and port, e.g. 0.0.0.0:1025 or just :1025")
	flag.StringVar(&cfg.APIBindAddr, "api-bind-addr", envconf.FromEnvP("MH_API_BIND_ADDR", "0.0.0.0:8025").(string), "HTTP bind interface and port for API, e.g. 0.0.0.0:8025 or just :8025")
	flag.StringVar(&cfg.Hostname, "hostname", envconf.FromEnvP("MH_HOSTNAME", "mailhog.example").(string), "Hostname for EHLO/HELO response, e.g. mailhog.example")
	flag.StringVar(&cfg.StorageType, "storage", envconf.FromEnvP("MH_STORAGE", "maildir").(string), "Message storage: 'maildir' (default), 'memory', or 'mongodb'")
	flag.StringVar(&cfg.MongoURI, "mongo-uri", envconf.FromEnvP("MH_MONGO_URI", "127.0.0.1:27017").(string), "MongoDB URI, e.g. 127.0.0.1:27017")
	flag.StringVar(&cfg.MongoDb, "mongo-db", envconf.FromEnvP("MH_MONGO_DB", "mailhog").(string), "MongoDB database, e.g. mailhog")
	flag.StringVar(&cfg.MongoColl, "mongo-coll", envconf.FromEnvP("MH_MONGO_COLLECTION", "messages").(string), "MongoDB collection, e.g. messages")
	flag.StringVar(&cfg.CORSOrigin, "cors-origin", envconf.FromEnvP("MH_CORS_ORIGIN", "").(string), "CORS Access-Control-Allow-Origin header for API endpoints")
	flag.StringVar(&cfg.MaildirPath, "maildir-path", envconf.FromEnvP("MH_MAILDIR_PATH", "./mailhog-data").(string), "Maildir path (defaults to './mailhog-data')")
	flag.BoolVar(&cfg.InviteJim, "invite-jim", envconf.FromEnvP("MH_INVITE_JIM", false).(bool), "Decide whether to invite Jim (beware, he causes trouble)")
	flag.StringVar(&cfg.JimStateFile, "jim-state-file", envconf.FromEnvP("MH_JIM_STATE_FILE", defaultJimStateFile).(string), "File for persisting Jim state (defaults to maildir-path/jim.json)")
	flag.StringVar(&cfg.OutgoingSMTPFile, "outgoing-smtp", envconf.FromEnvP("MH_OUTGOING_SMTP", "").(string), "JSON file containing outgoing SMTP servers")
	Jim.RegisterFlags()
}

// JimState is persisted to disk to preserve the chaos monkey config across restarts.
type JimState struct {
	Enabled bool        `json:"enabled"`
	Jim     *monkey.Jim `json:"jim,omitempty"`
}

// LoadJimState restores Jim state from disk if configured.
func LoadJimState(cfg *Config) error {
	if cfg.JimStateFile == "" {
		return nil
	}

	b, err := os.ReadFile(cfg.JimStateFile)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}

	var state JimState
	if err := json.Unmarshal(b, &state); err != nil {
		return err
	}

	cfg.InviteJim = state.Enabled
	if state.Jim != nil {
		state.Jim.ConfigureFrom(Jim)
		Jim = state.Jim
	}

	return nil
}

// SaveJimState writes the current Jim state to disk if configured.
func SaveJimState(cfg *Config) error {
	if cfg.JimStateFile == "" {
		return nil
	}

	state := JimState{
		Enabled: cfg.Monkey != nil,
	}
	if state.Enabled {
		state.Jim = Jim
	}

	b, err := json.Marshal(state)
	if err != nil {
		return err
	}

	if err := os.MkdirAll(filepath.Dir(cfg.JimStateFile), 0755); err != nil {
		return err
	}

	return os.WriteFile(cfg.JimStateFile, b, 0644)
}

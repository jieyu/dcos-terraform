package main

import (
	"flag"
	"log"

	"github.com/jieyu/dcos-terraform/cmd/module-source-converter/app"
)

func addFlags(flags *flag.FlagSet, config *app.Config) {
	flags.StringVar(&config.ModulesDir, "modules-dir", "", "The directory where all modules are located")
}

func main() {
	config := app.NewConfig()

	addFlags(flag.CommandLine, config)
	flag.Parse()

	err := app.Run(config)
	if err != nil {
		log.Fatal(err)
	}
}

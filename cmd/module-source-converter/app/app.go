package app

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/hashicorp/hcl/hcl/ast"
	"github.com/hashicorp/hcl/hcl/parser"
	"github.com/hashicorp/hcl/hcl/printer"
	"github.com/hashicorp/hcl/hcl/token"
)

type Config struct {
	ModulesDir string
}

func NewConfig() *Config {
	return &Config{}
}

func Run(config *Config) error {
	paths, err := getMainModuleFilePaths(config.ModulesDir)
	if err != nil {
		return fmt.Errorf("Failed to get main modules file paths: %v", err)
	}

	// Map from `path` to `ast.File`.
	convertedAstFiles := map[string]*ast.File{}

	for _, path := range paths {
		content, err := ioutil.ReadFile(path)
		if err != nil {
			return fmt.Errorf("Failed to read %q: %v", path, err)
		}

		astFile, err := parser.Parse(content)
		if err != nil {
			return fmt.Errorf("Failed to parse to HCL AST: %v", err)
		}

		log.Printf("Converting %q", path)

		convertedAstFile, err := convertAstFile(astFile, config)
		if err != nil {
			return fmt.Errorf("Failed to convert %q, %v", path, err)
		}

		convertedAstFiles[path] = convertedAstFile
	}

	for path, astFile := range convertedAstFiles {
		file, err := os.OpenFile(path, os.O_TRUNC|os.O_WRONLY, 0644)
		if err != nil {
			return fmt.Errorf("Failed to open %q: %v", path, err)
		}
		defer file.Close()

		err = printer.Fprint(file, astFile)
		if err != nil {
			return fmt.Errorf("Failed to print %q: %v", path, err)
		}
	}

	return nil
}

// Convert the source to be a relative path if it is absolute under
// dcos-terraform org. For instance:
//  - from: "dcos-terraform/infrastructure/aws"
//  - to:	"../../aws/infrastructure"
func getUpdatedSource(source string) string {
	strs := strings.Split(strings.Trim(source, "\""), "/")
	if len(strs) != 3 {
		return source
	}
	if strs[0] != "dcos-terraform" {
		return source
	}
	if strs[0] == "." || strs[0] == ".." {
		return source
	}
	return "\"" + strings.Join([]string{"..", "..", strs[2], strs[1]}, "/") + "\""
}

// Rewrite module source according to the specified "operation".
func convertAstFile(astFile *ast.File, config *Config) (*ast.File, error) {
	isModuleIdentifier := func(t token.Token) bool {
		return t.Type == token.IDENT && t.Text == "module"
	}

	isSourceIdentifier := func(t token.Token) bool {
		return t.Type == token.IDENT && t.Text == "source"
	}

	isModule := func(item *ast.ObjectItem) bool {
		return len(item.Keys) > 0 && isModuleIdentifier(item.Keys[0].Token)
	}

	isSource := func(item *ast.ObjectItem) bool {
		return len(item.Keys) > 0 && isSourceIdentifier(item.Keys[0].Token)
	}

	findSourceInModule := func(item *ast.ObjectItem) *ast.ObjectItem {
		objectList := item.Val.(*ast.ObjectType).List
		for _, item := range objectList.Items {
			if isSource(item) {
				return item
			}
		}
		return nil
	}

	walker := func(node ast.Node) (ast.Node, bool) {
		if node == nil {
			return node, false
		}

		switch n := node.(type) {
		case *ast.ObjectItem:
			if isModule(n) {
				source := findSourceInModule(n)
				if source != nil {
					literal := source.Val.(*ast.LiteralType)
					if literal.Token.Type != token.STRING {
						panic("Expect a string token")
					}

					original := literal.Token.Text
					converted := getUpdatedSource(original)
					literal.Token.Text = converted

					log.Printf("Updated source from %q to %q", original, converted)
				}

				// No need to walk down the AST tree as modules are
				// not nested.
				return node, false
			}
		}

		return node, true
	}

	return ast.Walk(astFile, walker).(*ast.File), nil
}

// Return a list of paths to the main module files (i.e. "main.tf").
func getMainModuleFilePaths(modulesDir string) ([]string, error) {
	results := []string{}

	walker := func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return fmt.Errorf("Failed to visit %q: %v", path, err)
		}

		if !info.IsDir() && info.Name() == "main.tf" {
			results = append(results, path)
		}

		return nil
	}

	err := filepath.Walk(modulesDir, walker)
	if err != nil {
		return nil, err
	}

	return results, nil
}

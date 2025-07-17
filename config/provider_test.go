package config

import (
	"testing"

	"github.com/crossplane/upjet/pkg/config"
)

func TestGetProvider(t *testing.T) {
	provider := GetProvider()
	
	if provider == nil {
		t.Fatal("GetProvider() returned nil")
	}
	
	// Test that the provider has the correct configuration
	if provider.RootGroup != "backblaze.upbound.io" {
		t.Errorf("Expected RootGroup to be 'backblaze.upbound.io', got '%s'", provider.RootGroup)
	}
	
	if provider.ModulePath != "github.com/markopolo123/provider-backblaze" {
		t.Errorf("Expected ModulePath to be 'github.com/markopolo123/provider-backblaze', got '%s'", provider.ModulePath)
	}
	
	if provider.ShortName != "backblaze" {
		t.Errorf("Expected ShortName to be 'backblaze', got '%s'", provider.ShortName)
	}
}

func TestExternalNameConfigurations(t *testing.T) {
	testCases := []struct {
		resourceName string
		expectedType config.ExternalNameType
	}{
		{"b2_bucket", config.NameAsIdentifier},
		{"b2_application_key", config.NameAsIdentifier},
		{"b2_bucket_file", config.NameAsIdentifier},
	}
	
	for _, tc := range testCases {
		t.Run(tc.resourceName, func(t *testing.T) {
			externalName, exists := ExternalNameConfigs[tc.resourceName]
			if !exists {
				t.Errorf("ExternalNameConfig not found for resource: %s", tc.resourceName)
				return
			}
			
			if externalName.Type != tc.expectedType {
				t.Errorf("Expected external name type %v for %s, got %v", tc.expectedType, tc.resourceName, externalName.Type)
			}
		})
	}
}

func TestExternalNameConfigured(t *testing.T) {
	configured := ExternalNameConfigured()
	
	expectedResources := []string{
		"b2_bucket$",
		"b2_application_key$",
		"b2_bucket_file$",
	}
	
	if len(configured) != len(expectedResources) {
		t.Errorf("Expected %d configured resources, got %d", len(expectedResources), len(configured))
	}
	
	for _, expected := range expectedResources {
		found := false
		for _, actual := range configured {
			if actual == expected {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("Expected resource %s not found in configured list", expected)
		}
	}
}
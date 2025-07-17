package clients

import (
	"testing"
)

func TestTerraformSetupBuilder(t *testing.T) {
	version := "1.5.7"
	providerSource := "Backblaze/b2"
	providerVersion := "0.10.0"
	
	setupFn := TerraformSetupBuilder(version, providerSource, providerVersion)
	
	if setupFn == nil {
		t.Fatal("TerraformSetupBuilder returned nil")
	}
}

func TestTerraformSetupBuilderWithoutProviderConfig(t *testing.T) {
	setupFn := TerraformSetupBuilder("1.5.7", "Backblaze/b2", "0.10.0")
	
	if setupFn == nil {
		t.Fatal("TerraformSetupBuilder returned nil")
	}
}
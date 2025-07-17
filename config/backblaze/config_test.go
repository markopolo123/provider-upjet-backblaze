package backblaze

import (
	"testing"

	"github.com/crossplane/upjet/pkg/config"
)

func TestConfigure(t *testing.T) {
	provider := config.NewProvider([]byte("{}"), "backblaze", "github.com/markopolo123/provider-backblaze", []byte("{}"))
	
	// Apply the configuration
	Configure(provider)
	
	testCases := []struct {
		resourceName string
		expectedKind string
		expectedGroup string
		expectedVersion string
	}{
		{"b2_bucket", "Bucket", "b2", "v1alpha1"},
		{"b2_application_key", "ApplicationKey", "b2", "v1alpha1"},
		{"b2_bucket_file", "BucketFile", "b2", "v1alpha1"},
	}
	
	for _, tc := range testCases {
		t.Run(tc.resourceName, func(t *testing.T) {
			resource := provider.Resources[tc.resourceName]
			if resource == nil {
				t.Errorf("Resource %s not found in provider configuration", tc.resourceName)
				return
			}
			
			if resource.Kind != tc.expectedKind {
				t.Errorf("Expected Kind %s for %s, got %s", tc.expectedKind, tc.resourceName, resource.Kind)
			}
			
			if resource.ShortGroup != tc.expectedGroup {
				t.Errorf("Expected ShortGroup %s for %s, got %s", tc.expectedGroup, tc.resourceName, resource.ShortGroup)
			}
			
			if resource.Version != tc.expectedVersion {
				t.Errorf("Expected Version %s for %s, got %s", tc.expectedVersion, tc.resourceName, resource.Version)
			}
		})
	}
}
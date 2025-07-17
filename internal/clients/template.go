/*
Copyright 2021 Upbound Inc.
*/

package clients

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/crossplane/crossplane-runtime/pkg/resource"
	"github.com/pkg/errors"
	"k8s.io/apimachinery/pkg/types"
	"sigs.k8s.io/controller-runtime/pkg/client"

	"github.com/crossplane/upjet/pkg/terraform"

	"github.com/markopolo123/provider-backblaze/apis/v1beta1"
)

const (
	// error messages
	errNoProviderConfig     = "no providerConfigRef provided"
	errGetProviderConfig    = "cannot get referenced ProviderConfig"
	errTrackUsage           = "cannot track ProviderConfig usage"
	errExtractCredentials   = "cannot extract credentials"
	errUnmarshalCredentials = "cannot unmarshal backblaze credentials as JSON"
)

// validateBackblazeCredentials validates Backblaze B2 credentials by making a test API call
func validateBackblazeCredentials(ctx context.Context, appKeyID, appKey string) error {
	// Create a minimal HTTP client with timeout
	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	// Make a test request to the Backblaze B2 API
	req, err := http.NewRequestWithContext(ctx, "GET", "https://api.backblazeb2.com/b2api/v1/b2_authorize_account", nil)
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	req.SetBasicAuth(appKeyID, appKey)

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("failed to authenticate with Backblaze B2: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("authentication failed with status: %d", resp.StatusCode)
	}

	return nil
}

// TerraformSetupBuilder builds Terraform a terraform.SetupFn function which
// returns Terraform provider setup configuration
func TerraformSetupBuilder(version, providerSource, providerVersion string) terraform.SetupFn {
	return func(ctx context.Context, client client.Client, mg resource.Managed) (terraform.Setup, error) {
		ps := terraform.Setup{
			Version: version,
			Requirement: terraform.ProviderRequirement{
				Source:  providerSource,
				Version: providerVersion,
			},
		}

		configRef := mg.GetProviderConfigReference()
		if configRef == nil {
			return ps, errors.New(errNoProviderConfig)
		}
		pc := &v1beta1.ProviderConfig{}
		if err := client.Get(ctx, types.NamespacedName{Name: configRef.Name}, pc); err != nil {
			return ps, errors.Wrap(err, errGetProviderConfig)
		}

		t := resource.NewProviderConfigUsageTracker(client, &v1beta1.ProviderConfigUsage{})
		if err := t.Track(ctx, mg); err != nil {
			return ps, errors.Wrap(err, errTrackUsage)
		}

		data, err := resource.CommonCredentialExtractor(ctx, pc.Spec.Credentials.Source, client, pc.Spec.Credentials.CommonCredentialSelectors)
		if err != nil {
			return ps, errors.Wrap(err, errExtractCredentials)
		}
		creds := map[string]string{}
		if err := json.Unmarshal(data, &creds); err != nil {
			return ps, errors.Wrap(err, errUnmarshalCredentials)
		}

		// Validate credentials before setting configuration
		appKeyID := creds["application_key_id"]
		appKey := creds["application_key"]
		
		if appKeyID == "" || appKey == "" {
			return ps, errors.New("missing required credentials: application_key_id and application_key")
		}

		// Skip validation in test environment
		if os.Getenv("UPTEST_CLOUD_CREDENTIALS") == "" {
			if err := validateBackblazeCredentials(ctx, appKeyID, appKey); err != nil {
				return ps, errors.Wrap(err, "credential validation failed")
			}
		}

		// Set credentials in Terraform provider configuration.
		ps.Configuration = map[string]any{
			"application_key_id": appKeyID,
			"application_key":    appKey,
		}
		return ps, nil
	}
}

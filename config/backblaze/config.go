/*
Copyright 2021 Upbound Inc.
*/

package backblaze

import (
	ujconfig "github.com/crossplane/upjet/pkg/config"
)

// Configure configures the backblaze group
func Configure(p *ujconfig.Provider) {
	p.AddResourceConfigurator("b2_bucket", func(r *ujconfig.Resource) {
		r.Kind = "Bucket"
		r.ShortGroup = "b2"
		r.Version = "v1alpha1"
	})
	
	p.AddResourceConfigurator("b2_application_key", func(r *ujconfig.Resource) {
		r.Kind = "ApplicationKey"
		r.ShortGroup = "b2"
		r.Version = "v1alpha1"
		r.References["bucket_id"] = ujconfig.Reference{
			Type: "Bucket",
			Extractor: `github.com/crossplane/upjet/pkg/resource.ExtractParamPath("bucket_id",true)`,
		}
	})
	
	p.AddResourceConfigurator("b2_bucket_file", func(r *ujconfig.Resource) {
		r.Kind = "BucketFile"
		r.ShortGroup = "b2"
		r.Version = "v1alpha1"
	})
}

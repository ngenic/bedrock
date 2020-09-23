output "chart"          { value = length(helm_release.flux_helm) > 0 ? helm_release.flux_helm[0].metadata[0].chart : null }
output "name"           { value = length(helm_release.flux_helm) > 0 ? helm_release.flux_helm[0].metadata[0].name : null }
output "namespace"      { value = length(helm_release.flux_helm) > 0 ? helm_release.flux_helm[0].metadata[0].namespace : null }
output "revision"       { value = length(helm_release.flux_helm) > 0 ? helm_release.flux_helm[0].metadata[0].revision : null }
output "status"         { value = length(helm_release.flux_helm) > 0 ? helm_release.flux_helm[0].status : null }
output "version"        { value = length(helm_release.flux_helm) > 0 ? helm_release.flux_helm[0].metadata[0].version : null }
output "app_version"    { value = length(helm_release.flux_helm) > 0 ? helm_release.flux_helm[0].metadata[0].app_version : null }
output "values"         { value = length(helm_release.flux_helm) > 0 ? helm_release.flux_helm[0].metadata[0].values : null }
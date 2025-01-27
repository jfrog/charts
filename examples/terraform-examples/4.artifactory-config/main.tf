# This file contains the terraform configuration to create the following resources in Artifactory

# Create a local generic repository
resource "artifactory_local_generic_repository" "generic-local" {
    key             = "generic-local"
    repo_layout_ref = "simple-default"
}

# Create a remote generic repository
resource "artifactory_local_maven_repository" "maven-local" {
    key                             = "maven-local"
    checksum_policy_type            = "client-checksums"
    snapshot_version_behavior       = "unique"
    max_unique_snapshots            = 10
    handle_releases                 = true
    handle_snapshots                = true
    suppress_pom_consistency_checks = false
}

# Create a remote Maven repository
resource "artifactory_remote_maven_repository" "maven-remote" {
    key                             = "maven-remote"
    url                             = "https://repo1.maven.org/maven2/"
    fetch_jars_eagerly              = true
    fetch_sources_eagerly           = false
    suppress_pom_consistency_checks = false
    reject_invalid_jars             = true
    metadata_retrieval_timeout_secs = 120
}

# Create a virtual Maven repository that includes the local and remote Maven repositories created above
resource "artifactory_virtual_maven_repository" "maven-virtual" {
    key             = "maven-virtual"
    repo_layout_ref = "maven-2-default"
    repositories    = [
        artifactory_local_maven_repository.maven-local.key,
        artifactory_remote_maven_repository.maven-remote.key
    ]
    description                              = "A test virtual repo"
    notes                                    = "Internal description"
    # includes_pattern                         = "**"
    # excludes_pattern                         = "com/google/**"
    force_maven_authentication               = true
    pom_repository_references_cleanup_policy = "discard_active_reference"
}

# Create the devs group
resource "artifactory_group" "devs" {
    name              = "devs"
    description       = "Developers group"
    auto_join         = true
    realm             = "artifactory"
    realm_attributes  = ""
    admin_privileges  = false
}

# Create the ops group
resource "artifactory_group" "ops" {
    name              = "ops"
    description       = "Operations group"
    auto_join         = true
    realm             = "artifactory"
    realm_attributes  = ""
    admin_privileges  = false
}

# Create the user developer1 and add them to the devs group
resource "artifactory_user" "developer1" {
    name     = "developer1"
    email    = "developer1@example.com"
    password = "Password1"
    admin    = false
    groups   = [artifactory_group.devs.name]
}

# Create the user developer2 and add them to the devs and ops group
resource "artifactory_user" "developer2" {
    name     = "developer2"
    email    = "developer2@example.com"
    password = "Password2"
    admin    = false
    groups   = [artifactory_group.devs.name, artifactory_group.ops.name]
}

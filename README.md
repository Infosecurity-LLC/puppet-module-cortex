### Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options and additional functionality](#usage)

## Overview

Cortex is part of [TheHive](https://thehive-project.org) platform and allows observables such as IP and email addresses, URLs, domain names, files or hashes to be analyzed through a web interface. Analysts can also automate these operations and submit large sets of observables from TheHive or through the Cortex REST API from alternative SIRP platforms, custom scripts or MISP.

## Module description

This module is responsible for the installation, configuration, and deployment of Cortex application.

For storing data, Cortex uses ElasticSearch (version 5.x), which needs to be configured independently (e.g. using our TheHive module).

## Usage

### Configuring the Cortex instance

The Puppet `cortex` class provides a default installation of Cortex. Before importing the `cortex` class, you should set up the secret key `play_secret_key`, which is used by the Play framework. Its value can either be specified using Heira (recommended), or using a class parameter.

> Note: This module does not handle a reverse proxy. An example for creating a reverse proxy using Apache is provided [below](#creating-a-reverse-proxy).

#### Using Hiera

The default parameters are present in the [manifests/init.pp](manifests/init.pp) file, which one can override, if required. Since `play_secret_key` is a required parameter, its value must be specified. To change the port on which the Cortex instance should be listening, update the `port` variable in the Hiera configuration:

```yaml
cortex::play_secret_key: '<secret key>'
cortex::port: 9999
```

Then include the class in your manifest file.

```ruby
include ::cortex
```

#### Using a class declaration

The secret key and port can also be provided as a parameter to the class declaration.

```ruby
class cortex {
  play_secret_key => '<secret key>',
  port            => 9999
}
```

> Note: A random key of the required length can be generated with: `$ cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1`

#### Creating a reverse proxy

To serve the web interface on a custom server, create a reverse proxy for Apache. A skeleton for setting up the reverse proxy is shown below:

```ruby
  # Setup reverse proxy.
  apache::vhost { $cortex_server_name:
    port              => $apache_https_port,
    docroot           => $apache_document_root,
    serveradmin       => $cortex_server_admin,
    servername        => $cortex_server_name,
    ssl               => true,
    ssl_cert          => $tls_cert,
    ssl_key           => $tls_key,
    log_level         => 'info',
    access_log_format => 'combined',
    ssl_proxyengine   => true,
    proxy_pass        => [
      {
        'path'         => '/',
        'url'          => "http://127.0.0.1:${port}/",
        'reverse_urls' => ["http://127.0.0.1:${port}/"],
      },
    ],
    directories       => [
      {
        provider       => 'location',
        path           => '/',
        options        => '-Indexes',
        allow_override => 'None',
        auth_type      => 'None',
      },
    ],
    rewrites          => [
          {
            rewrite_rule => ['^/oauth/redirect$ /index.html [R,NE]']
          }
        ],
  }
```

For passing additional parameters, consult the documentation in: [https://forge.puppet.com/puppetlabs/apache](https://forge.puppet.com/puppetlabs/apache)

### Cortex configuration file

The template for Cortex configuration file is present in [templates/application.erb](templates/application.erb), you can change it own template. The configurable parameters are listed below:

* `play_secret_key`:  Play framework secret key [required]
* `port`: Port where Cortex instance should be started (default: `9001`)
* `user`: User who owns the Cortex repository and configuration directory (default: `cortex`)
* `group`: Group who owns the Cortex repository and configuration directory (default: `cortex`)
* `install_from_source`: Whether to install the RPM from source (default: `false`)
* `source_url`: Source URL for Cortex RPM (default: `''`)
* `config_dir`: Cortex configuration directory (default: `'/etc/cortex'`)
* `config_file`: Cortex configuration file (default: `'application.conf'`)
* `config_template`: Template for config file (default: `cortex/application.erb`)
* `analyzers_path`: Path where to store Cortex-Analyzers (default: `'/opt/cortex/analyzers'`)
* `analyzers_git_repo`: GitHub repository for Cortex-Analyzers (default: `'https://github.com/TheHive-Project/Cortex-Analyzers.git'`)
* `analyzers_git_repo_tag`: GitHub repository tag for Cortex-Analyzers (default: `'1.14.4'`)
* `analyzers_min_parallelism`: Minimum number of threads available for analyzers (default: `2`)
* `analyzers_factor_parallelism`: Parallelism factor for analyzers (default: `2`)
* `analyzers_max_parallelism`: Maximum number of threads available for analyzers (default: `4`)
* `elasticsearch_index`: ElasticSearch index name (default: `'the_hive'`)
* `elasticsearch_cluster_name`: ElasticSearch cluster name (default: `'hive'`)
* `elasticsearch_uri`: URL for connect to ElasticSearch (default: `"http://127.0.0.1:9200/"`). If multiple Elasticsearch nodes are used as a cluster, you should add addresses of the master nodes in the url like this: `http://node1:9200,node2:9200/`
* `elasticsearch_docker_image`: Docker image used for ElasticSearch (default: `'docker.elastic.co/elasticsearch/elasticsearch:5.6.14'`)
* `elasticsearch_scroll_keepalive`: Scroll keepalive time (default: `'1m'`)
* `elasticsearch_scroll_pagesize`: Scroll page size (default: `50`)
* `elasticsearch_shards_count`: Number of shards (default: `5`)
* `elasticsearch_replicas_count`: Number of replicas (default: `1`)
* `elasticsearch_max_nested_fields`: Maximum number of nested fields (default: `100`)
* `elasticsearch_xpack_enabled`: Specifiy whether XPack is enabled or not (default: `false`)
* `elasticsearch_xpack_username`: XPack username
* `elasticsearch_xpack_password`: XPack password
* `elasticsearch_ssl_enabled`: Enable SSL to connect to ElasticSearch (default: `false`)
* `elasticsearch_certificate_authority_path`: Path to certificate authority file
* `elasticsearch_certificate_path`: Path to certificate file
* `elasticsearch_ssl_key`: Path to SSL key file
* `elasticsearch_searchguard_keystore_path`: Path to JKS file containing client certificate
* `elasticsearch_searchguard_keystore_password`: Password of the keystore
* `elasticsearch_searchguard_truststore_path`: Path to JKS file containing certificate authorities
* `elasticsearch_searchguard_truststore_password`: Password of the truststore
* `elasticsearch_searchguard_host_verification`: Enforce hostname verification (default: `false`)
* `elasticsearch_searchguard_host_verification_resolve_hostname`: If hostname verification is enabled specify if hostname should be resolved
* `auth_providers`: List of authentication providers (default: `['local']`)
* `auth_basic_enabled`: Specify if basic authentication is enabled or not (default: `false`)
* `auth_active_directory_enabled`: Use ActiveDirectory to authenticate users (default: `false`)
* `auth_ad_domain_fqdn`: ActiveDirectory domain FQDN [required]
* `auth_ad_server_names`: The Windows domain name(s) in DNS format [required]
* `auth_ad_domain_name`: The Windows domain name using short format
* `auth_ad_use_ssl`: If `true`, use SSL to connect to the domain controller (default: `false`)
* `auth_ldap_enabled`: Specify if LDAP authentication is enabled or not (default: `false`)
* `auth_ldap_servernames`: LDAP server name(s)
* `auth_ldap_account_bind_dn`: Account to use to bind to the LDAP server [required]
* `auth_ldap_account_bind_pw`: Password of the binding account [required]
* `auth_ldap_account_base_dn`: Base DN to search users [required]
* `auth_ldap_filter`: Filter to search user in the directory server [required]
* `auth_ldap_use_ssl`: If 'true', use SSL to connect to the LDAP directory server
* `auth_oauth2_sso_enabled`: Specify if OAuth2 and SSO are enabled or not (default: `false`)
* `auth_oauth2_client_id`: The OAuth2 client ID is a public identifier for apps (default: `'cortex'`)
* `auth_oauth2_secret`: The OAuth2 key is a secret known only to the application and the authorization server. It must be sufficiently random to not be guessable
* `auth_oauth2_client_redirect_uri`: After a user successfully authorizes an application, the authorization server will redirect the user back to the application with either an authorization code or access token in the URL
* `auth_oauth2_response_type`: OAuth2 response type can be `'code'` for requesting an authorization code, or `'token'` for requesting an access token (implicit grant) (default: `'code'`)
* `auth_oauth2_grant_type`: OAuth2 grant types include Authorization Code, Implicit, Password, Client Credentials, Device Code, and Refresh Token (default: `'authorization_code'`)
* `auth_oauth2_auth_url`: URL of the authorization server
* `auth_oauth2_token_url`: URL from where to get the access token
* `auth_oauth2_user_url`: User URL used for creating the request header
* `auth_oauth2_scope`: OAuth2 scope provides a way to limit the amount of access that is granted to an access token (default: `'read:user'`)
* `auth_sso_mapper`: Name of mapping class from user resource to backend user (default: `'group'`)
* `auth_sso_login`: SSO username for login (default: `'username'`)
* `auth_sso_name`: SSO name (default: `'name'`)
* `auth_sso_groups`: SSO groups (default: `'groups'`)
* `auth_sso_organization`: SSO organization (default: `'cortex'`)
* `auth_sso_autocreate`: If `true`, the user will be auto created from SSO credentials (default: `true`)
* `auth_sso_default_roles`: List of default SSO roles, which can either be `'admin'`, `'limited_user'`, `'user'` or `'read_only_user'`
* `auth_sso_autologin`: If set to `false`, the user would have to manually login by pressing the "Sign in with SSO" button (default: `true`)
* `auth_sso_group_url`: SSO groups URL
* `auth_sso_mappings`: Mappings used for assigning permissions to groups. It contains an array of hashes with the following keys:
  - `auth_sso_mapping_key`: SSO mapping key (default: `['cert']`)
  - `auth_sso_mapping_permissions`: SSO mapping permissions (default: `['admin']`)
* `session_authentication_warning`: Maximum warning time between two requests without requesting authentication (default: `'5m'`)
* `session_authentication_inactivity`: Maximum inactivity time between two requests without requesting authentication (default: `'1h'`)
* `http_parser_maxmemorybuffer`: Maximum textual content length (default: `'1M'`)
* `http_parser_maxdiskbuffer`: Maximum file size (default: `'1G'`)

#### The variables below are required for setting up the corresponding Cortex analyzers

* `c1fapp_secret_key`
* `google_safe_browsing_secret_key`
* `dnsdb_secret_key`
* `joesandbox_secret_key`
* `misp_secret_key`
* `otxquery_secret_key`
* `passivetotal_secret_key`
* `phishtank_secret_key`
* `phishinginitiative_secret_key`
* `wot_secret_key`

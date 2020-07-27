# == Class: cortex
#
# Install, configure, and deploy Cortex.
class cortex (
  # Key for setting up cookies authentication for the Play Framework.
  # which can be generated with:
  # `cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1`
  String $play_secret_key,
  # The port where the Cortex server should be started.
  Integer $port = 9001,
  String $user = 'cortex',
  String $group = 'cortex',
  Boolean $install_from_source = false,
  String $source_url = '',
  String $config_dir = '/etc/cortex',
  String $config_file = 'application.conf',
  String $config_template = 'cortex/application.erb',
  # Cortex-Analyzers GitHub repository.
  String $analyzers_path = '/opt/cortex/analyzers',
  String $analyzers_git_repo = 'https://github.com/TheHive-Project/Cortex-Analyzers.git',
  String $analyzers_git_repo_tag = '1.14.4',
  Integer $analyzers_min_parallelism = 2,
  Integer $analyzers_factor_parallelism = 2,
  Integer $analyzers_max_parallelism = 4,
  # ElasticSearch configuration variables.
  String $elasticsearch_index = 'the_hive',
  String $elasticsearch_cluster_name = 'hive',
  String $elasticsearch_uri = 'http://127.0.0.1:9200/',
  String $elasticsearch_scroll_keepalive = '1m',
  Integer $elasticsearch_scroll_pagesize = 50,
  Integer $elasticsearch_shards_count = 5,
  Integer $elasticsearch_replicas_count = 1,
  Integer $elasticsearch_max_nested_fields = 100,
  Boolean $elasticsearch_xpack_enabled = false,
  String $elasticsearch_xpack_username = '',
  String $elasticsearch_xpack_password = '',
  String $elasticsearch_certificate_authority_path = '',
  String $elasticsearch_certificate_path = '',
  Boolean $elasticsearch_ssl_enabled = false,
  String $elasticsearch_ssl_key = '',
  Boolean $elasticsearch_searchguard_enabled = false,
  String $elasticsearch_searchguard_keystore_path = '',
  String $elasticsearch_searchguard_keystore_password = '',
  String $elasticsearch_searchguard_truststore_path = '',
  String $elasticsearch_searchguard_truststore_password = '',
  Boolean $elasticsearch_searchguard_host_verification = false,
  Boolean $elasticsearch_searchguard_host_verification_resolve_hostname = false,
  # Authorization configuration variables.
  Array $auth_providers = ['local'],
  Boolean $auth_basic_enabled = false,
  Boolean $auth_active_directory_enabled = false,
  # Configuration variables for setting up Active Directory authentication.
  String $auth_ad_domain_fqdn = '',
  String $auth_ad_server_names = '',
  String $auth_ad_domain_name = '',
  Boolean $auth_ad_use_ssl = true,
  # Configuration variables for setting up LDAP authentication.
  Boolean $auth_ldap_enabled = false,
  String $auth_ldap_servernames = '',
  String $auth_ldap_account_bind_dn = '',
  String $auth_ldap_account_bind_pw = '',
  String $auth_ldap_account_base_dn = '',
  String $auth_ldap_filter = '',
  String $auth_ldap_use_ssl = '',
  # Configuration variables for setting up OAuth2 and Single sign-on (SSO).
  Boolean $auth_oauth2_sso_enabled = false,
  String $auth_oauth2_client_id = 'cortex',
  String $auth_oauth2_secret = '',
  String $auth_oauth2_client_redirect_uri = '',
  String $auth_oauth2_response_type = 'code',
  String $auth_oauth2_grant_type = 'authorization_code',
  String $auth_oauth2_auth_url = '',
  String $auth_oauth2_token_url = '',
  String $auth_oauth2_user_url = '',
  # Standard for constructing an OAuth2 scope:
  # https://tools.ietf.org/html/rfc6749#section-3.3
  String $auth_oauth2_scope = 'read:user',
  String $auth_sso_mapper = 'group',
  String $auth_sso_login = 'username',
  String $auth_sso_name = 'name',
  String $auth_sso_groups = 'groups',
  String $auth_sso_organization = 'cortex',
  Boolean $auth_sso_autocreate = true,
  Array $auth_sso_default_roles = [],
  # If set to `false`, the user would have to manually login by pressing the "Sing in with SSO" button
  Boolean $auth_sso_autologin = true,
  String $auth_sso_group_url = '',
  Array[Hash] $auth_sso_mappings =
  [{'auth_sso_mapping_key' => 'cert',
    'auth_sso_mapping_permissions' => ['admin']}
  ],
  # Configuration variables for controlling session timeout.
  String $session_authentication_warning = '5m',
  String $session_authentication_inactivity = '1h',
  String $http_parser_maxmemorybuffer = '1M',
  String $http_parser_maxdiskbuffer = '1G',
  # Configuration variables required for setting up Cortex analyzers.
  String $c1fapp_secret_key = '',
  String $google_safe_browsing_secret_key = '',
  String $dnsdb_secret_key = '',
  String $joesandbox_secret_key = '',
  String $misp_secret_key = '',
  String $otxquery_secret_key = '',
  String $passivetotal_secret_key = '',
  String $phishtank_secret_key = '',
  String $phishinginitiative_secret_key = '',
  String $wot_secret_key = '',
  ) {
  contain '::cortex::install'

  contain '::cortex::config'

  contain '::cortex::service'
}

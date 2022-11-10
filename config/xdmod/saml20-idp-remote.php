<?php
/**
 * SAML 2.0 remote IdP metadata for SimpleSAMLphp.
 *
 * Remember to remove the IdPs you don't use from this file.
 *
 * See: https://simplesamlphp.org/docs/stable/simplesamlphp-reference-idp-remote
 */

$metadata['https://oidc.puc-rio.eu.org/realms/oondemand'] = array (
  'entityid' => 'https://oidc.puc-rio.eu.org/realms/oondemand',
  'contacts' =>
  array (
  ),
  'metadata-set' => 'saml20-idp-remote',
  'sign.authnrequest' => true,
  'SingleSignOnService' =>
  array (
    0 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
      'Location' => 'https://oidc.puc-rio.eu.org/realms/oondemand/protocol/saml',
    ),
    1 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://oidc.puc-rio.eu.org/realms/oondemand/protocol/saml',
    ),
    2 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP',
      'Location' => 'https://oidc.puc-rio.eu.org/realms/oondemand/protocol/saml',
    ),
    3 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact',
      'Location' => 'https://oidc.puc-rio.eu.org/realms/oondemand/protocol/saml',
    ),
  ),
  'SingleLogoutService' =>
  array (
    0 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
      'Location' => 'https://oidc.puc-rio.eu.org/realms/oondemand/protocol/saml',
    ),
    1 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://oidc.puc-rio.eu.org/realms/oondemand/protocol/saml',
    ),
    2 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact',
      'Location' => 'https://oidc.puc-rio.eu.org/realms/oondemand/protocol/saml',
    ),
  ),
  'ArtifactResolutionService' =>
  array (
    0 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP',
      'Location' => 'https://oidc.puc-rio.eu.org/realms/oondemand/protocol/saml/resolve',
      'index' => 0,
    ),
  ),
  'NameIDFormats' =>
  array (
    0 => 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
    1 => 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient',
    2 => 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified',
    3 => 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
  ),
  'keys' =>
  array (
    0 =>
    array (
      'encryption' => false,
      'signing' => true,
      'type' => 'X509Certificate',
      'X509Certificate' => 'MIICoTCCAYkCBgGD7QVwOjANBgkqhkiG9w0BAQsFADAUMRIwEAYDVQQDDAlvb25kZW1hbmQwHhcNMjIxMDE4MjEzMzIwWhcNMzIxMDE4MjEzNTAwWjAUMRIwEAYDVQQDDAlvb25kZW1hbmQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCvI+TxNLBTJiIBLERhPTMwUUhh4NguJItIw0Bq924kes7gs5J+r98p32U3kiBmGKmEOLoZ4rs+oEyaQ3oEfukozmW2SvHK6auZ375dlowJn5jZMa4pvlH+40yg6tWv24WN7NYI32Z101t4GTo/4pQLjXxnGDJQLxZv9wSYhtRG1N1JwoI/nco3iiJhcJBbDRGkQMoaZ9r7PjRlm7U0f+lfqdsKKw+YPQkZao9hdFKT2wq93Kyirw2r/BO6cBI7YP/ypgtlBHRUoByMfwJpVd2D9fPbrpfILGh6B799+jNcfjx14EKFpAPCtADqZpemOAG+lGETu6bWEJzSXn3UAB41AgMBAAEwDQYJKoZIhvcNAQELBQADggEBAHjtxUivTdlsIi2CwoA1aTHFDb8lISMobAQtiF+CF7geYxO02X4AYS5FSBA740DBASoNBWRN8wRrSYPE1/8OxnSmbQvBfgOsUNAgRj6Gb6sNZ+LsMBWUfUjaQv0CLoKPM9wKq8hXh2VYXVm9Tda2SNtkk2UTBMMGLwU9MgpnJYGU00qY3wxfWOC08lDtwdkrvQaKutv42p5aFRyfSQLs43GJbY8/WNZjcGdXCfByows46k/g5W4WnhCXpVEdUCOCHSSgEUJk+gdVR789YqEMnz1xTzx/Dz9yWtgbRv7J0SRd9C2AIKxzkSPrHJPUCE6i7KUauQ59Cg7RGnk57dlrx5U=',
    ),
  ),
);

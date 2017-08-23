# -*- coding: utf-8 -*-
# vim: ft=sls

{% if grains['os_family'] == 'RedHat' %}

{% set pkg = salt['grains.filter_by']({
  '6': {
    'key': 'https://www.elrepo.org/RPM-GPG-KEY-elrepo.org',
    'key_hash': 'md5=d7507f4b95dd2c0271de97afe1badc51',
    'rpm': 'http://www.elrepo.org/elrepo-release-6-6.el6.elrepo.noarch.rpm',
  },
  '7': {
    'key': 'https://www.elrepo.org/RPM-GPG-KEY-elrepo.org',
    'key_hash': 'md5=d7507f4b95dd2c0271de97afe1badc51',
    'rpm': 'http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm',
  },
}, 'osmajorrelease') %}


elrepo.pubkey:
  file.managed:
    - name: /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
    - source: {{ salt['pillar.get']('elrepo:pubkey', pkg.key) }}
    - source_hash:  {{ salt['pillar.get']('elrepo:pubkey_hash', pkg.key_hash) }}

elrepo.rpm:
  pkg.installed:
    - sources:
      - elrepo-release: {{ salt['pillar.get']('elrepo:rpm', pkg.rpm) }}
    - requires:
      - file: elrepo.pubkey

{% if salt['pillar.get']('elrepo:disabled', True) %}
elrepo.disable:
  file.replace:
    - name: /etc/yum.repos.d/elrepo.repo
    - pattern: '^enabled=\d'
    - repl: enabled=0
{% else %}
elrepo.enable:
  file.replace:
    - name: /etc/yum.repos.d/elrepo.repo
    - pattern: '^enabled=\d'
    - repl: enabled=1
{% endif %}

{% endif %}

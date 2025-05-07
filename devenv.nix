{ config, pkgs, ... }:

with pkgs; {
  env = {
    LD_LIBRARY_PATH = "${config.devenv.profile}/lib";
  };

  packages = [
    git
    libyaml
    sqlite-interactive
    sqlite
    openssl
    postgresql_17
    mariadb_114
    libmysqlclient

    cargo
    rustc
  ];

  languages.ruby.enable = true;
  languages.ruby.versionFile = ./.ruby-version;

  services.postgres = {
    enable = true;
    listen_addresses = "127.0.0.1";
    port = 5432;
    initialScript = ''
      CREATE ROLE postgres WITH SUPERUSER LOGIN;
    '';
  };
}

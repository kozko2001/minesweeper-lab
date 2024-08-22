{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.elixir
    pkgs.erlang
    pkgs.elixir-ls
    pkgs.inotify-tools
  ];

  shellHook = ''
    mix deps.get
  '';
}

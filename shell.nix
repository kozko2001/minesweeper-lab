{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.elixir
    pkgs.erlang
    pkgs.elixir-ls
    pkgs.inotify-tools
  ];

  shellHook = ''
    echo "Welcome to the Elixir Advent of Code environment!"
    mix deps.get
  '';
}

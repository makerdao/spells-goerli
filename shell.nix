{ url
  , dappPkgs ? (
    import (fetchTarball "https://github.com/makerdao/makerpkgs/tarball/master") {}
  ).dappPkgsVersions.master-20200217
}: with dappPkgs;

mkShell {
  DAPP_SOLC = solc-static-versions.solc_0_6_12 + "/bin/solc-0.6.12";
  DAPP_BUILD_OPTIMIZE = 0;
  DAPP_BUILD_OPTIMIZE_RUNS = 200;
  DAPP_LIBRARIES = " lib/dss-exec-lib/src/DssExecLib.sol:DssExecLib:0x4aad139a88d2dd5e7410b408593208523a3a891d";
  DAPP_LINK_TEST_LIBRARIES = 0;
  buildInputs = [
    dapp
    hevm
    seth
    jq
    curl
  ];

  shellHook = ''
    export NIX_SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    unset SSL_CERT_FILE

    export ETH_RPC_URL="''${ETH_RPC_URL:-${url}}"
  '';
}

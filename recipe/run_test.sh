#!/bin/bash
set -ex

if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then
  sed_inplace="sed -i ''"
else
  sed_inplace="sed -i"
fi

DENSITIES_DIRECTORY=${PREFIX}/share/chargemol/atomic_densities/

# Run Siesta example
cd examples_to_run/SIESTA_chabazite_zeolite_example/DDEC6
ln -s $DENSITIES_DIRECTORY .
ln -s ../chabazite.XSF chabazite.XSF

$sed_inplace "s#/home/tamanz/bin/atomic_densities/#atomic_densities/#g" job_control.txt

# Only run the binary when the build host can actually execute it. The
# osx-arm64 package is cross-compiled on conda-forge's x86_64 runners, where
# running the arm64 binary fails with "Bad CPU type in executable". Native
# builds (linux-64, osx-64, and arm64 hosts) still run the full example.
host_arch="$(uname -m)"
bin_arch="$(file -b "${PREFIX}/bin/chargemol" 2>/dev/null || true)"
if { [[ "${host_arch}" == "arm64" ]] && echo "${bin_arch}" | grep -q "arm64"; } || \
   { [[ "${host_arch}" == "x86_64" ]] && echo "${bin_arch}" | grep -Eq "x86[-_]64"; }; then
  chargemol
  ls -ltra
  grep "Finished chargemol" chabazite.output
else
  echo "Host arch '${host_arch}' cannot run cross-compiled binary ('${bin_arch}'); skipping run-test."
fi
cd -

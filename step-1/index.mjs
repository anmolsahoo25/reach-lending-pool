import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

/* log messages from the app */
const log = (msg) => console.log(`[APP]   : ${msg}`);

/* log messages from Reach */
const logReach = (addrs) => {
  const f = ([s,e]) => {
    const s1 = addrs[e[0]];
    const s2 = typeof(addrs[e[1]]) === 'undefined' ?
      (typeof(e[1]) === 'undefined' ? "" : e[1]) : addrs[e[1]];
    const s3 = typeof(e[2]) === 'undefined' ? "" : e[2];
    console.log(`[REACH] : ${s}${s1} ${s2}${s3}`);
  };

  return f;
};

(async () => {
  log("Starting application");

  /* starting balance for all test accounts */
  const startingBalance = stdlib.parseCurrency(100);

  /* object to store addresses of test accounts created */
  var addrs = {};

  /* accDeployer - the account which deploys the application */
  const accDeployer = await stdlib.newTestAccount(startingBalance);

  /* store each account address mapped to its name in the addrs object */
  addrs[accDeployer.getAddress()] = "accDeployer"

  log(`accDeployer (${accDeployer.getAddress().slice(0,4)}...) ${await stdlib.balanceOf(accDeployer)} microALGO`);

  /* contract info for deployer account */
  const ctcDeployer = accDeployer.contract(backend);

  await Promise.all([
    backend.Deployer(ctcDeployer, {
      log: logReach(addrs)
    })
  ]);
})();

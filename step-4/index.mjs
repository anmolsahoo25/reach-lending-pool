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

/* deposit behavior */
const deposit = () => {
  var x = 0;
  const f = () => {
    if(x === 0) {
      x = x + 1;
      return ['Deposit', 100];
    } else {
      return ['Deposit', 0];
    }
  };
   
  return f;
};

/* borrow behavior */
const borrowAndRepay = () => {
  var x = 0;
  const f = () => {
    if(x < 10) {
      x = x + 1;
      return ['Borrow', 50];
    } else {
      return ['Repay', 100];
    }
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

  /* accLender - account which lends funds to the pool */
  const accLender = await stdlib.newTestAccount(startingBalance);

  /* accBorrower - account which borrows funds from the pool */
  const accBorrower = await stdlib.newTestAccount(startingBalance);

  /* store each account address mapped to its name in the addrs object */
  addrs[accDeployer.getAddress()] = "accDeployer"
  addrs[accLender.getAddress()]   = "accLender  "
  addrs[accBorrower.getAddress()] = "accBorrower"

  log(`accDeployer (${accDeployer.getAddress().slice(0,4)}...) ${await stdlib.balanceOf(accDeployer)} microALGO`);
  log(`accLender   (${accLender.getAddress().slice(0,4)}...) ${await stdlib.balanceOf(accLender)} microALGO`);
  log(`accBorrower (${accBorrower.getAddress().slice(0,4)}...) ${await stdlib.balanceOf(accBorrower)} microALGO`);

  /* contract info for deployer account */
  const ctcDeployer = accDeployer.contract(backend);

  /* contract info for lender, created by receiving info from deployer */
  const ctcLender = accLender.contract(backend, ctcDeployer.getInfo());

  /* contract info for borrower, created by receiving info from deployer */
  const ctcBorrower = accBorrower.contract(backend, ctcDeployer.getInfo());

  await Promise.all([
    backend.Deployer(ctcDeployer, {
      log: logReach(addrs)
    }),
    backend.Lender(ctcLender, {
      getMsg: deposit()
    }),
    backend.Borrower(ctcBorrower, {
      getMsg: borrowAndRepay()
    })
  ]);
})();

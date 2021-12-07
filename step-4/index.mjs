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
const depositAndWithdraw = () => {
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

  const startingBalance = stdlib.parseCurrency(100);

  var addrs = {};

  const acc0 = await stdlib.newTestAccount(startingBalance);
  const accA = await stdlib.newTestAccount(startingBalance);
  const accB = await stdlib.newTestAccount(startingBalance);

  addrs[acc0.getAddress()] = "acc0"
  addrs[accA.getAddress()] = "accA"
  addrs[accB.getAddress()] = "accB"

  log(`acc0 (${acc0.getAddress().slice(0,4)}...) ${await stdlib.balanceOf(acc0)} microALGO`);
  log(`accA (${accA.getAddress().slice(0,4)}...) ${await stdlib.balanceOf(accA)} microALGO`);
  log(`accB (${accB.getAddress().slice(0,4)}...) ${await stdlib.balanceOf(accB)} microALGO`);

  const ctc0 = acc0.contract(backend);
  const ctcA = accA.contract(backend, ctc0.getInfo());
  const ctcB = accB.contract(backend, ctc0.getInfo());

  await Promise.all([
    backend.Deployer(ctc0, {
      log: logReach(addrs)
    }),
    backend.Lender(ctcA, {
      getMsg: depositAndWithdraw()
    }),
    backend.Borrower(ctcB, {
      getMsg: borrowAndRepay()
    })
  ]);
})();

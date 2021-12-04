import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const log = (msg) => console.log(`[APP]   : ${msg}`);

(async () => {
	log("Starting application");

	const startingBalance = stdlib.parseCurrency(1000);

	var addrs = {};

	const acc0 = await stdlib.newTestAccount(startingBalance);
	const accA = await stdlib.newTestAccount(startingBalance);
	const accB = await stdlib.newTestAccount(startingBalance);

	addrs[acc0.getAddress()] = "acc0"
	addrs[accA.getAddress()] = "accA"
	addrs[accB.getAddress()] = "accB"

	log(`acc0 (${acc0.getAddress()}) ${await stdlib.balanceOf(acc0)} microALGO`);
	log(`accA (${acc0.getAddress()}) ${await stdlib.balanceOf(acc0)} microALGO`);
	log(`accB (${acc0.getAddress()}) ${await stdlib.balanceOf(acc0)} microALGO`);

	const ctc0 = acc0.contract(backend);
	const ctcA = accA.contract(backend, ctc0.getInfo());
	const ctcB = accB.contract(backend, ctc0.getInfo());

	await Promise.all([
		backend.Deployer(ctc0, {
			log: ([s1,[s11,s12]]) => console.log(
				`[REACH] : ${s1}${addrs[s11]} ${typeof(s12) === 'undefined' ? "" : s12 }`)
		}),
		backend.Lender(ctcA, {
			getMsg: () => ['Deposit', 0]
		}),
		backend.Borrower(ctcB, {
			getMsg: () => ['Repay', 0]
		})
	]);
})();

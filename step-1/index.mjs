import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const log = (msg) => console.log(`[APP]   : ${msg}`);

(async () => {
	log("Starting application");

	const startingBalance = stdlib.parseCurrency(1000);

	var addrs = {};

	const acc0 = await stdlib.newTestAccount(startingBalance);

	addrs[acc0.getAddress()] = "acc0"

	log(`acc0 (${acc0.getAddress()}) ${await stdlib.balanceOf(acc0)} microALGO`);

	const ctc0 = acc0.contract(backend);

	await Promise.all([
		backend.Deployer(ctc0, {
			log: ([s1,[s11,s12]]) => console.log(
				`[REACH] : ${s1}${addrs[s11]} ${typeof(s12) === 'undefined' ? "" : s12 }`)
		}),
	]);
})();

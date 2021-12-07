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
		console.log(`[REACH] : ${s}${s1}${s2}${s3}`);
	};

	return f;
};

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
			log: logReach(addrs)
		})
	]);
})();

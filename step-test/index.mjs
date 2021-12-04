import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const logMsg = (msg) => console.log(`[APP]   : ${msg}`);

(async () => {
	logMsg("Starting application");

	const startingBalance = stdlib.parseCurrency(10000);

	const acc0 = await stdlib.newTestAccount(startingBalance);
	const accA = await stdlib.newTestAccount(startingBalance);
	const accB = await stdlib.newTestAccount(startingBalance);
	const accC = await stdlib.newTestAccount(startingBalance);
	const accD = await stdlib.newTestAccount(startingBalance);

	logMsg(`acc0 (${acc0.getAddress()}): ${await stdlib.balanceOf(acc0)} ALGO`);
	logMsg(`accA (${accA.getAddress()}): ${await stdlib.balanceOf(accA)} ALGO`);
	logMsg(`accB (${accB.getAddress()}): ${await stdlib.balanceOf(accB)} ALGO`);
	logMsg(`accC (${accC.getAddress()}): ${await stdlib.balanceOf(accC)} ALGO`);
	logMsg(`accD (${accD.getAddress()}): ${await stdlib.balanceOf(accD)} ALGO`);

	const ctc0 = acc0.contract(backend);
	const ctcA = accA.contract(backend, ctc0.getInfo());
	const ctcB = accB.contract(backend, ctc0.getInfo());
	const ctcC = accC.contract(backend, ctc0.getInfo());
	const ctcD = accD.contract(backend, ctc0.getInfo());

	await Promise.all([
		backend.Deployer(ctc0, {
			log: ([s1,s2]) => console.log(`[REACH] : ${s1}${s2}`)
		}),
		backend.Lender(ctcA, {
		}),
		backend.Lender(ctcB, {
		}),
		backend.Borrower(ctcC, {
		}),
		backend.Borrower(ctcD, {
		})
	]);

	logMsg(`acc0 (${acc0.getAddress()}): ${await stdlib.balanceOf(acc0)} ALGO`);
	logMsg(`accA (${accA.getAddress()}): ${await stdlib.balanceOf(accA)} ALGO`);
	logMsg(`accB (${accB.getAddress()}): ${await stdlib.balanceOf(accB)} ALGO`);
	logMsg(`accC (${accC.getAddress()}): ${await stdlib.balanceOf(accC)} ALGO`);
	logMsg(`accD (${accD.getAddress()}): ${await stdlib.balanceOf(accD)} ALGO`);
})();

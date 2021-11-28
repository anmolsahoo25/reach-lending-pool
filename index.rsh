'reach 0.1';

export const main = Reach.App(() => {

	// data definitions
	const LenderMsg   = Data({Deposit: UInt, Withdraw: UInt});
	const BorrowerMsg = Data({Borrow : UInt, Repay   : UInt});

	// participant interfaces
	const Deployer = Participant('Deployer', {
		log: Fun(true, Null)
	});

	const Lender = ParticipantClass('Lender', {
	});

	const Borrower = ParticipantClass('Borrower', {
	});

	// logging function
	const logMsg = (s, d) => {
		if (s == "LendingTransaction") {
			Deployer.interact.log(["Lending transaction  : ", d]);
		}

		if (s == "BorrowerTransaction") {
			Deployer.interact.log(["Borrower transaction : ", d]);
		}

		if (s == "LenderPaid") {
			Deployer.interact.log(["Lender paid          : ", d]);
		}

		if (s == "LenderWithdrew") {
			Deployer.interact.log(["Lender withdrew      : ", d]);
		}

		if (s == "BorrowerBorrowed") {
			Deployer.interact.log(["Borrower borrowed    : ", d]);
		}

		if (s == "BorrowerRepaid") {
			Deployer.interact.log(["Borrower repaid      : ", d]);
		}
	};

	// deploy app
	deploy();

	// initial consensus
	Deployer.publish().pay(1000);
	Deployer.interact.log(["App deployed by: ", this]);
	const deposits = new Map(UInt);
	const loans    = new Map(UInt);
	/*
	const cAlgo = new Token({
	  name: Bytes(32).pad("cAlgo"),
	  symbol: Bytes(8).pad("cAlgo"),
		supply: 1000});
	*/

	/*
	const lastLenderPayout = new Map(UInt);
	const lastBorrowerPayout = new Map(UInt);
	*/
	commit();


	// first publication
	Lender.only(() => {const msg = LenderMsg.Deposit(100)});
	Lender.publish(msg).pay(
		msg.match({
			Deposit: ((v) => v),
			Withdraw: ((v) => 0)
		}));;

	// transaction loop
	var [lastLender, lastLenderMsg] = [this, msg];
	invariant(true);
	while(true) {
		//logMsg("LendingTransaction", [lastLender, lastLenderMsg]);
		switch(lastLenderMsg) {
			case Deposit:
				//logMsg("LenderPaid", [lastLender, lastLenderMsg]);
				/*
				if(balance(cAlgo) >= lastLenderMsg) {
					transfer(lastLenderMsg, cAlgo).to(lastLender);
				}
				*/
				deposits[lastLender] = fromSome(deposits[lastLender],0) + lastLenderMsg;
			case Withdraw:
				if(balance() - lastLenderMsg > 0 &&
					 lastLenderMsg <= fromSome(deposits[lastLender],0))
			  {
					transfer(lastLenderMsg).to(lastLender);
					deposits[lastLender] = fromSome(deposits[lastLender],0)-lastLenderMsg;
					//logMsg("LenderWithdrew", [lastLender, lastLenderMsg]);
				}
		}
		commit();

		Borrower.only(() => {
			const borrowerMsg = BorrowerMsg.Borrow(10);
			const lastBorrower = this});
		Borrower.publish(borrowerMsg, lastBorrower).pay(
			borrowerMsg.match({
				Borrow: ((v) => 0),
				Repay: ((v) => v <= fromSome(loans[this], 0) ?  v : fromSome(loans[this], 0))
			}));;

		/*
		// update the interest payment
		if(fromSome(lastLenderPayout[lastLender], 0) == 0) {
			// first transaction
			lastLenderPayout[lastLender] = lastConsensusSecs();
		} else {
			const lastLenderPayoutTime = fromSome(lastLenderPayout[lastLender], 0);
			Deployer.interact.log(["held for", ["", lastConsensusSecs() - lastLenderPayoutTime]]);
			lastLenderPayout[lastLender] = lastConsensusSecs();
		}
		*/

		// perform borrower transaction
		//logMsg("BorrowerTransaction", [this, borrowerMsg]);
		switch(borrowerMsg) {
			case Borrow:
				if (balance() - borrowerMsg >= 0) {
					transfer(borrowerMsg).to(this);
					//logMsg("BorrowerBorrowed", [this, borrowerMsg]);
					loans[this] = fromSome(loans[this], 0) + borrowerMsg;
				}
			case Repay:
				if(borrowerMsg <= fromSome(loans[this], 0)) {
					//logMsg("BorrowerRepaid", [this, borrowerMsg]);
					loans[this] = fromSome(loans[this],0) - borrowerMsg;
				}
		}
		commit();

		Lender.only(() => {const lenderMsg = LenderMsg.Withdraw(10)});
		Lender.publish(lenderMsg);
		// update borrower interest payment
		[lastLender, lastLenderMsg] = [this, lenderMsg];
		continue;
	}
	commit();
});

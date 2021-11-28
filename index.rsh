'reach 0.1';

export const main = Reach.App(() => {

	// data definitions
	const Msg = Data({
	  Deposit  : UInt,
	  Withdraw : UInt,
	  Borrow   : UInt,
	  Repay    : UInt,
	  Transfer : Object({amount: UInt , to: Address})
	});
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


	// util functions
	const min = (a,b) => a < b ? a : b;

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

		if (s == "TransferTransaction") {
			Deployer.interact.log(["Lender transferred   : ", d]);
		}
	};

	// deploy app
	deploy();

	// initial consensus
	Deployer.publish().pay(1000);
	Deployer.interact.log(["App deployed by: ", this]);
	const deposits = new Map(UInt);
	const loans    = new Map(UInt);

	const cAlgo = new Token({
	  name: Bytes(32).pad("cAlgo"),
	  symbol: Bytes(8).pad("cAlgo")});

	/*
	const lastLenderPayout = new Map(UInt);
	const lastBorrowerPayout = new Map(UInt);
	*/
	commit();

	// transaction loop
	Deployer.publish();
	var [] = [];
	invariant(true);
	while(true) {
		commit();

		Lender.only(() => {const msg = Msg.Deposit(10)});
		Borrower.only(() => {const msg = Msg.Borrow(10)});
		race(Lender, Borrower).publish(msg).pay(
			msg.match({
				Deposit  : ((v) => [0,  [0, cAlgo]]),
				Withdraw : ((v) => [0,  [0, cAlgo]]),
				Borrow   : ((_) => [0,  [0, cAlgo]]),
				Repay    : ((v) => [0,  [0, cAlgo]]),
				Transfer : ((_) => [0,  [0, cAlgo]])
			})
		);
		// Repay    : (v) => { return [ min(v, fromSome(loans[this], 0)) , [10,cAlgo]]; },

		switch(msg) {
			case Deposit:
			  logMsg("LendingTransaction", [this, msg]);
				logMsg("LenderPaid", [this, msg]);

				if(balance(cAlgo) >= msg) {
					transfer(msg, cAlgo).to(this);
				}

				deposits[this] = fromSome(deposits[this],0) + msg;
			case Withdraw:
				if(balance() - msg > 0 &&
					 msg <= fromSome(deposits[this],0))
			  {
					logMsg("LendingTransaction", [this, msg]);
					logMsg("LenderWithdrew", [this, msg]);
					transfer(msg).to(this);
					deposits[this] = fromSome(deposits[this],0) - msg;
				}
			case Borrow:
				if (msg <= balance())
				{
					logMsg("BorrowerTransaction", [this, msg]);
					logMsg("BorrowerBorrowed", [this, msg]);
					transfer(msg).to(this);
					loans[this] = fromSome(loans[this], 0) + msg;
				}
			case Repay:
				if(msg <= fromSome(loans[this], 0))
				{
					logMsg("BorrowerTransaction", [this, msg]);
					logMsg("BorrowerRepaid", [this, msg]);
					loans[this] = fromSome(loans[this],0) - msg;
				}
			case Transfer:
				logMsg("TransferTransaction", [this, msg]);
		}

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
		continue;
	}
	commit();
});

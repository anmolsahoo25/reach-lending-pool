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

	const MaybeAddr = Maybe(Address);
	const MaybeMsg  = Maybe(Msg);

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

		else if (s == "BorrowerTransaction") {
			Deployer.interact.log(["Borrower transaction : ", d]);
		}

		else if (s == "LenderPaid") {
			Deployer.interact.log(["Lender paid          : ", d]);
		}

		else if (s == "LenderWithdrew") {
			Deployer.interact.log(["Lender withdrew      : ", d]);
		}

		else if (s == "BorrowerBorrowed") {
			Deployer.interact.log(["Borrower borrowed    : ", d]);
		}

		else if (s == "BorrowerRepaid") {
			Deployer.interact.log(["Borrower repaid      : ", d]);
		}

		else if (s == "TransferTransaction") {
			Deployer.interact.log(["Lender transferred   : ", d]);
		}

		else {
			Deployer.interact.log([s, d]);
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
	  symbol: Bytes(8).pad("cAlgo")});
	*/

	const lastLenderPayout = new Map(UInt);
	const lastBorrowerPayout = new Map(UInt);
	commit();

	Lender.publish().pay(1000);
	deposits[this] = 1000;
	commit();

	// transaction loop
	Deployer.publish();
	var [lastAddr , lastMsg] = [this, MaybeMsg.None(null)];
	invariant(true);
	while(true) {
		commit();

		Lender.only(()   => {const msg = Msg.Withdraw(10); const part = this;});
		Borrower.only(() => {const msg = Msg.Borrow(10)  ; const part = this;});
		race(Lender, Borrower).publish(msg, part).pay(
			msg.match({
				Deposit  : ((v) => v),
				Withdraw : ((v) => 0),
				Borrow   : ((_) => 0),
			  Repay    : ((v) => min(v, fromSome(loans[this],0))),
				Transfer : ((_) => 0)
			})
		);

		switch(msg) {
			case Deposit:
			  //logMsg("LendingTransaction", [this, msg]);
				logMsg("LenderPaid", [this, msg]);

				/*
				if(balance(cAlgo) >= msg) {
					transfer(msg, cAlgo).to(this);
				}
				*/

				deposits[this] = fromSome(deposits[this],0) + msg;
			case Withdraw:
				const canWithdraw =
					(balance() - msg > 0) && (msg <= fromSome(deposits[this], 0));

				//logMsg("LendingTransaction", [this, msg]);
				logMsg("LenderWithdrew", [this, canWithdraw ? msg : 0]);
				if(canWithdraw)
			  {
					transfer(msg).to(this);
					deposits[this] = fromSome(deposits[this],0) - msg;

					/* calculate interest earned */
					if(isSome(lastLenderPayout[this])) {
						const timeHeld = lastConsensusSecs() - fromSome(lastLenderPayout[this], 0);
						const payout = fxrescale(fxmul(fxint(+timeHeld),fx(100)(Pos,1)), 1).i.i;
						if(balance() - payout > 0) {
							transfer(payout).to(this);
						}
					}
				}
			case Borrow:
				if (msg <= balance())
				{
					//logMsg("BorrowerTransaction", [this, msg]);
					logMsg("BorrowerBorrowed", [this, msg]);
					transfer(msg).to(this);
					loans[this] = fromSome(loans[this], 0) + msg;
				}
			case Repay:
				if(msg <= fromSome(loans[this], 0))
				{
					//logMsg("BorrowerTransaction", [this, msg]);
					logMsg("BorrowerRepaid", [this, msg]);

					/* calculate interest repay */
					if(isSome(lastBorrowerPayout[this])) {
						const timeHeld = lastConsensusSecs() - fromSome(lastBorrowerPayout[this], 0);
						const interest = fxrescale(fxmul(fxint(+timeHeld),fx(100)(Pos,2)), 1).i.i;
						loans[this] = fromSome(loans[this],0) - (msg - interest);
					} else {
						loans[this] = fromSome(loans[this],0) - msg;
					}
				}
			case Transfer:
				//logMsg("TransferTransaction", [this, msg]);
		}

		/* update last consensus stat */

		if(isSome(lastMsg)) {
			const lastMsgVal = fromSome(lastMsg, Msg.Deposit(0));
			switch(lastMsgVal) {
				case Withdraw:
					logMsg("update lender payout for: ", [lastAddr, lastConsensusSecs()]);
					lastLenderPayout[lastAddr] = lastConsensusSecs();
				case Repay:
					logMsg("update borrower payout for: ", [lastAddr, lastConsensusSecs()]);
					lastBorrowerPayout[lastAddr] = lastConsensusSecs();
				case Borrow:
				case Deposit:
				case Transfer:
			}
		}

		[lastAddr, lastMsg] = [part, MaybeMsg.Some(msg)];
		continue;
	}
	commit();
});

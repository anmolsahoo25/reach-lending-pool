'reach 0.1';

export const main = Reach.App(() => {

    /* data definitions */
    const Msg = Data({
        Deposit : UInt,
        Withdraw: UInt,
        Borrow  : UInt,
        Repay   : UInt,
        Transfer: Object({amount: UInt, to: Address})
    });

    const MaybeMsg = Maybe(Msg);

    /* participant interfaces */
    const Deployer = Participant('Deployer', {
        log: Fun(true, Null)
    });

    const Lender = ParticipantClass('Lender', {
        getMsg: Fun(true, Msg)
    });

    const Borrower = ParticipantClass('Borrower', {
        getMsg: Fun(true, Msg)
    });

		/* util functions */
		const log = (s, d) => {
			if (s == "FirstPub") {
				Deployer.interact.log(["First publication by : ", d]);
			}

			else if (s == "Transaction") {
				Deployer.interact.log(["Transaction by       : ", d]);
			}

			else if (s == "LendingTransaction") {
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

    /* deploy app */
    deploy();

    /* first consensus for setup */
    Deployer.publish()
		log("FirstPub", [this]);

    /* setup linear state */
    const deposits = new Map(UInt);
    const loans    = new Map(UInt);

    /* while loop for executing transactions */
    var [lastAddr, lastMsg] = [this, MaybeMsg.None(null)]
    invariant(true)
    while(true) {
				commit();

				/* local steps to retrieve transaction message */
				Lender.only(() => { 
					const msg = declassify(interact.getMsg());
				});
				Borrower.only(() => {
					const msg = declassify(interact.getMsg());
				});

				/* transaction race */
				race(Lender, Borrower).publish(msg).pay([
					msg.match({
						Deposit : (v) => v,
						Withdraw: (_) => 0,
						Borrow  : (_) => 0,
						Repay   : (_) => 0,
						Transfer: (_) => 0
					})
				]);

				log("Transaction", [this, msg]);

				/* take an action depending on the msg */
				switch(msg) {
					case Deposit:
						log("LenderPaid", [this, msg]);
						deposits[this] = fromSome(deposits[this], 0) + msg;

					case Withdraw:
						const canWithdraw = 
							(balance() - msg > 0) && (msg <= fromSome(deposits[this], 0));

						if(canWithdraw) {
							log("LenderWithdrew", [this, msg]);
							transfer(msg).to(this);
							deposits[this] = fromSome(deposits[this], 0) - msg;
						}

					case Borrow:
					case Repay:
					case Transfer:
				}

				/* continue loop while updating loop variables */
        [lastAddr, lastMsg] = [this, MaybeMsg.Some(msg)];
        continue;
    }

		commit();
});

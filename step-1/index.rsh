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
				const msg = d[1];
				switch(msg) {
					case Deposit:
						Deployer.interact.log(["Transaction by       : ", d]);
					case Withdraw:
						Deployer.interact.log(["Transaction by       : ", d]);
					case Borrow:
						Deployer.interact.log(["Transaction by       : ", d]);
					case Repay:
						Deployer.interact.log(["Transaction by       : ", d]);
					case Transfer:
						Deployer.interact.log(["Transaction by       : ",
						    [d[0], msg.to, ["Transfer", msg.amt]]]);
				}
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

			else if (s == "TokenBalance") {
				Deployer.interact.log(["Token balance        : ", d]);
			}

			else if (s == "InterestEarned") {
				Deployer.interact.log(["Interest earned      : ", d]);
			}

			else if (s == "TotalInterest") {
				Deployer.interact.log(["Total interest       : ", d]);
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

		commit();

    /* while loop for executing transactions */
		Deployer.publish();
    var [] = []
    invariant(true)
    while(true) {
				commit();

				race(Lender, Borrower).publish();

        [] = [];
        continue;
    }

		commit();
});

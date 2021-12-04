'reach 0.1';

export const main = Reach.App(() => {

    /* data definitions */
    const Msg = Data({
        Deposit: UInt,
        Withdraw: UInt,
        Borrow: UInt,
        Repay: UInt,
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
					const partAddr = this;
					const msg = declassify(interact.getMsg());
				});
				Borrower.only(() => {
					const partAddr = this;
					const msg = declassify(interact.getMsg());
				});

				/* transaction race */
				race(Lender, Borrower).publish(partAddr, msg).pay(0);
				log("Transaction", [partAddr, msg]);

				/* continue loop while updating loop variables */
        [lastAddr, lastMsg] = [partAddr, MaybeMsg.Some(msg)];
        continue;
    }

		commit();
});

'reach 0.1';

export const main = Reach.App(() => {

    /* data definitions */
    const Msg = Data({
      Deposit : UInt,
      Withdraw: UInt,
      Borrow  : UInt,
      Repay   : UInt,
      Transfer: Object({amt: UInt, to: Address})
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

    /* deploy app */
    deploy();

    /* first consensus for setup */
    Deployer.publish()

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

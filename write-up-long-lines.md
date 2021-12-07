# 1. Discuss the setup of the Reach program
We will first start by discussing the high-level structure of the Reach program. Don't worry, we will go into each block and complete it, this is just the incomplete code to give an initial idea. Let's take a look below -

```javascript
/* section1: datatype definitions */
const Msg = Data.({/* fill in datatype constructors */});

// other declarations

/* section2: utility functions */
const min = (x,y) => x < y ? x : y;

// other functions

/* section3: participant interfaces */
const Deployer = Participant('Deployer', {/* fill in interface */}));

// other interfaces

/* deploy app */
deploy();

/* section4: first consensus publication */
Deployer.publish();

/* setup linear state */
const loans = new Map(UInt);

// other linear state

/* setup non-network token */
const token = new Token({});

commit();

/* section5: core while loop */
Deployer.publish();
var [] = []
invariant(true);
while(true) {
    commit();

    /* perform transaction logic */

    continue();
}

commit();
```

Let's take a look at the various sections. Note that each section will have additional content, which we will discuss in the further sections.
1. In `section1`, we declare all the datatypes that we are using.
2. In `section2` we define some utility functions such as `min` to use in our code.
3. In `section3` we specify the participant interfaces.
4. In `section4` we perform the first consensus publication so we can create the necessary linear state and tokens needed for the transactions.
5. In `section5` we execute a while loop which will take care of the transactions and represents the core of the program.

Hopefully that gave you a broad idea of how the code is structured, so lets start coding now and take a look at each of the sections in details.

# 2. Initial scaffolding and participant interfaces
_Code can be found here - [step-0](https://github.com/anmolsahoo25/reach-lending-pool/tree/trunk/step-0)_

Let's start by setting up a minimal Reach file. Open up `index.rsh` and type the following -

```javascript
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
```

Whew, that's a lot of code. Let's see what we did here -
1. Let's discuss the datatype declarations first. We create a datatype `Msg` which we use to encode the various messages that the participants can send. As these are tagged unions, they also carry extra information, such as the amount deposited, which address to transfer etc. We also declare a `MaybeMsg` type to denote an optional message value.
2. Next, we create the participant interfaces. We have a participant called  `Depositor` who is in-charge of deploying the application and logging functions. Then we create two `ParticipantClasses` named as `Lender` and `Borrower`, who serve to function as agents who deposit and borrow money respectively with functions for retrieving their actions each consensus transfer. Note that being `ParticipantClasses` instead of `Participants` allows us to reference multiple agents in one transaction (not used in this tutorial, but might be useful for future applications). At the same, `ParticipantClasses` cannot deploy applications, hence we need a special `Deployer` class.
3. Then we deploy the application and create the first consensus transfer with an empty publication from the `Deployer`. In this consensus transfer, we create the linear state that we will be using to track the deposits and borrows named as `deposits` and `loans` and commit the transaction.
4. Finally, we start another consensus transfer so that we can start the core while loop of our program. As of now we put in an empty invariant and the `while` loop runs forever. We have also not declared any loop variables  as of yet.

Run `reach compile index.rsh` on this file and you should get a compiled version of this code, which passes the verifier. Let's discuss the structure of our application a bit. In this code, each iteration of the while loop corresponds to a race between the `Lenders` and `Borrowers`. Depending on the actions produced by the winning agent,  we update the necessary state variables for the agent and the contract. Thus, it makes it easy to write (and verify) each step of the contract.

# 3. Front-end setup in Javascript
_Code can be found here - [step-1](https://github.com/anmolsahoo25/reach-lending-pool/tree/trunk/step-1)_

In this section, we can run our code (finally) to check if we have setup everything correctly. We can write a minimal front-end in Javascript. Open up `index.mjs` and input the following code -

```javascript
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

	const startingBalance = stdlib.parseCurrency(100);
	
	var addrs = {};

	const acc0 = await stdlib.newTestAccount(startingBalance);

	addrs[acc0.getAddress()] = "acc0"

	log(`acc0 (${acc0.getAddress().slice(0,4)}...) ${await stdlib.balanceOf(acc0)} microALGO`);

	const ctc0 = acc0.contract(backend);

	await Promise.all([
		backend.Deployer(ctc0, {
			log: logReach(addrs)
		})
	]);
})();
```

We create some logging functions (the logging function is not the cleanest, sorry!), create an account and create a Deployer participant. Hopefully, there is nothing much to explain here, but if you feel like you are missing something you can refer to the Reach tutorial here - [Scaffolding and Setup](https://docs.reach.sh/tut-2.html).

We also add a logging function in `index.rsh` (the definition would waste space here, so feel free to copy it from the source) and a new log after the first publication -

```javascript
/* first consensus for setup */
Deployer.publish();
logMsg("FirstTransaction", [this]);
```

Run `reach run` and if everything was successful, you should see this output -

```bash
[APP]   : Starting application
[APP]   : acc0 (0x7b...) 1000000000 microALGO
[REACH] : First publication by : acc0
```

As we can, we first log from the frontend and the first publication from Reach. So far, so good!

# 4. Implementing the core transaction loop
_Code can be found here - [step-2](https://github.com/anmolsahoo25/reach-lending-pool/tree/trunk/step-2)_

N ow that we have the basic app in place, we can go about implementing the core logic for our application. Let's see what that looks like. We change our `while` loop to look like this -

```javascript
/* while loop for executing transactions */
    Deployer.publish();
    var [] = []
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
      race(Lender, Borrower).publish(msg).pay(0);
      log("Transaction", [this, msg]);

      /* continue loop */
      [] = [];
      continue;
    }
```

Let's go over it step-by-step -

1. First, both `Lender` and `Participant` classes perform a local step to retrieve their action for this round.
2. Then they `race` to publish their message.
3. We log the winner of the race and the `msg` value.
4. We go onto the next iteration.

In the front-end, we create a few new accounts and add them as participants -

```javascript
...
const ctc0 = acc0.contract(backend);
const ctcA = accA.contract(backend, ctc0.getInfo());
const ctcB = accB.contract(backend, ctc0.getInfo());

...

await Promise.all([
  backend.Deployer(ctc0, {
    log: logReach(addrs)
  }),
  backend.Lender(ctcA, {
    getMsg: () => ['Deposit', 0]
  }),
  backend.Borrower(ctcB, {
    getMsg: () => ['Repay', 0]
  })
]);
```

Note that we create two static clients, who always return a fixed message. Let's run our code. You would see a lot of output, but the important one should be (some lines truncated) -

```bash
...
[REACH] : Transaction by       : accB Repay,0
[REACH] : Transaction by       : accA Deposit,0
...
```

As we can see, each round we are taking a transaction action from one account. Now all we have to do is implement the logic for each participant class!

# 5. Implementing and testing the logic for lending users
_Code can be found here - [step-3](https://github.com/anmolsahoo25/reach-lending-pool/tree/trunk/step-3)_

In this section, we will modify our reach program and implement the logic for the `Lenders`. First, we modify our race statement -

```javascript
race(Lender, Borrower).publish(msg).pay([
  msg.match({
    Deposit : (v) => v,
    Withdraw: (_) => 0,
    Borrow  : (_) => 0,
    Repay   : (_) => 0,
    Transfer: (_) => 0
  })
]);
```
After a participant wins a race, we take their published amount and use it to determine how much they need to pay. In this case, since we are only implementing the lenders side, in the case of `Deposit`, the participant needs to pay the number of tokens they publish and for a `Withdraw`, they  don't need to pay anything. For now, we stub out the borrower values with a 0, for now.

Now let's look at the next part -

```javascript
/* take an action depending on the msg */
switch(msg) {
  case Deposit:
    log("LenderPaid", [this, msg]);
    deposits[this] = fromSome(deposits[this], 0) + msg;

  case Withdraw:
    const canWithdraw =
      (msg <= balance()) && (msg <= fromSome(deposits[this], 0));

    if(canWithdraw) {
      log("LenderWithdrew", [this, msg]);
      transfer(msg).to(this);
      deposits[this] = fromSome(deposits[this], 0) - msg;
    }

  case Borrow:
  case Repay:
  case Transfer:
}
```

In this case, we switch what action to take based on the message. For a deposit, we update the linear staet called `deposits` for the participant address with the value of the deposit. In the case of a withdraw, we first check if the pool has sufficient balance and then if the current user has deposited the money they are trying to withdraw. If both the checks go through, then we transfer the sum to the user and update the deposit.

Note that since we need slightly more complicated behavior from our participants, we will write closures in Javascript which return a different value based on every call we make. We create a participant who deposits a certain sum and withdraws it over multiple intervals. See below -

```javascript
...
/* deposit behavior */
const depositAndWithdraw = () => {
  var x = 0;
  const f = () => {
    if(x === 0) {
      x = x + 1;
      return ['Deposit', 100];
    } else {
      return ['Withdraw', 50];
    }
  };

  return f;

...

await Promise.all([
    backend.Deployer(ctc0, {
      log: logReach(addrs)
    }),
    backend.Lender(ctcA, {
      getMsg: depositAndWithdraw()
    })
  ]);
};
```

Now, if we do `reach run`, we should focus on this particular output -

```bash
[REACH] : Transaction by       : accA Deposit,100
[REACH] : Lender paid          : accA 100
[REACH] : Transaction by       : accA Withdraw,50
[REACH] : Lender withdrew      : accA 50
[REACH] : Transaction by       : accA Withdraw,50
[REACH] : Lender withdrew      : accA 50
[REACH] : Transaction by       : accA Withdraw,50
[REACH] : Transaction by       : accA Withdraw,50
[REACH] : Transaction by       : accA Withdraw,50
[REACH] : Transaction by       : accA Withdraw,50
```

So the lender deposits 100 tokens and withdraws them over, 2 transactions. Notice that after the second withdrawal, the withdraws stop executing. Thus it seems our logic is correct!

# 6. Implementing and testing the logic for borrowing users
_Code can be found here - [step-4](https://github.com/anmolsahoo25/reach-lending-pool/tree/trunk/step-4)_

Now onto implementing the logic for borrowing users. It is mostly similar to the previous step, with a few changes. Let's look at the pay statement -

```javascript
race(Lender, Borrower).publish(msg).pay([
  msg.match({
    Deposit : (v) => v,
    Withdraw: (_) => 0,
    Borrow  : (_) => 0,
    Repay   : (v) => min(v, fromSome(loans[this], 0)),
    Transfer: (_) => 0
  })
]);
```
In the pay statement, we first check the amount that the user owes. We then choose the minimum from the amount the user is trying to pay and the loan they owe. This helps ensure that the user does not send more than they have borrowed.
Let's look at the action taken -

```javascript
case Borrow:
  if(msg <= balance()) {
    log("BorrowerBorrowed", [this, msg]);
    transfer(msg).to(this);
    loans[this] = fromSome(loans[this], 0) + msg;
  }
case Repay:
  const currLoan = fromSome(loans[this], 0);
  const toPay    = min(msg, currLoan);
  if(currLoan > 0) {
    log("BorrowerRepaid", [this, toPay]);
    loans[this] = currLoan - toPay;
  }
```

In the case of a borrow, we first check if the pool has sufficient balance to make the transaction. In the case it does, we then transfer the necessary sum and then update the linear state for loans. In the case of a repayment, we check what is the amount that they owe and take the minimum of the amount the participant is trying to repay and the outstanding loan. The reasoning is similar as above in the pay statement.

In this case, we would need two actors, one to deposit and one to borrow. Let's create those behaviors -

```javascript
...
/* deposit behavior */
const depositAndWithdraw = () => {
  var x = 0;
  const f = () => {
    if(x === 0) {
      x = x + 1;
      return ['Deposit', 100];
    } else {
      return ['Deposit', 0];
    }
  };

  return f;
};

...

/* borrow behavior */
const borrowAndRepay = () => {
  var x = 0;
  const f = () => {
    if(x < 10) {
      x = x + 1;
      return ['Borrow', 50];
    } else {
      return ['Repay', 100];
    }
  };

  return f;
};

...

await Promise.all([
  backend.Deployer(ctc0, {
    log: logReach(addrs)
  }),
  backend.Lender(ctcA, {
    getMsg: depositAndWithdraw()
  }),
  backend.Borrower(ctcB, {
    getMsg: borrowAndRepay()
  })
]);
```

Running `reach run` will lead to different behaviors each time, depending on who wins the race, but one of the outputs would be this -

```bash
[REACH] : Transaction by       : accA Deposit,100
[REACH] : Lender paid          : accA 100
...
[REACH] : Transaction by       : accB Borrow,50
[REACH] : Borrower borrowed    : accB 50
...
[REACH] : Transaction by       : accB Borrow,50
[REACH] : Borrower borrowed    : accB 50
...
[REACH] : Transaction by       : accB Borrow,50
...
[REACH] : Transaction by       : accB Repay,100
[REACH] : Borrower repaid      : accB 100
...
[REACH] : Transaction by       : accB Repay,100
[REACH] : Transaction by       : accB Repay,100
```

First `accA` deposits 100 tokens. Then `accB` issues 2 borrow requests. Note that after the second request, it cannot borrow more since there is no balance. Finally, it repays 100 tokens after which no more repayments are allowed.

# 7. Implementing and testing the debt tokenization
_Code can be found here - [step-5](https://github.com/anmolsahoo25/reach-lending-pool/tree/trunk/step-5)_
After getting the basic functions out of the way, we can look at some of the more interesting features we can implement. One of them is the debt tokenization feature. Debt tokenization essentially means that we denote the amount someone has deposited using a non-network token such as ASA's on Algorand or ERC20 on Ethereum. Thus, users can freely transfer their these tokens to each other and the pool will track these transactions to update the deposits. In this way, depositors can easily change their holdings and exposure.

We implement a simple system where we denote a deposit of 1 network token by 1 non-network token `token`. Upon depositing a certain value of network tokens in the pool, the user will receive the same amount of non-network tokens. Users can transfer their non-network tokens to each other. Let's see how we can implement this.
First we need to add 2 additional functions to the lender interface.

```javascript
const Lender = ParticipantClass('Lender', {
    getMsg: Fun(true, Msg),
    printTokenBalance: Fun(true, Null),
    informTokenId: Fun(true, Null)
});
```
The function `printTokenBalance` is a logging function to print the token balance for a particular account. The `informTokenId` is used to inform the account to opt-in to send / receive the token (this is necessary for Algorand).

Once this is done, we create (mint) the non-network token in the first consensus transaction -

```javascript
...
/* setup non-network token */
const token = new Token({
  name: Bytes(32).pad("token"),
  symbol: Bytes(8).pad("token"),
  supply: 1000
});
log("TokenBalance", [this, balance(token)]);

commit();

/* inform all lenders of token ID for opt-in */
Lender.interact.informTokenId(token);
...
```

We provide some (uninspiring) names to the various tokens and create its supply to be 1000. We do this only because it makes the log easier to read. Finally, we inform all the `Lenders` of the token id. With this, now we can update the transaction logic to handle the tokens. We start with the pay statment -

```javascript
/* transaction race */
race(Lender, Borrower).publish(msg).pay([
  msg.match({
    Deposit : ((v) => v),
    Withdraw: ((_) => 0),
    Borrow  : ((_) => 0),
    Repay   : ((v) => v <= fromSome(loans[this], 0) ? v : 0),
    Transfer: ((_) => 0)
  }),
  [
    msg.match({
      Deposit  : (_) => 0,
      Withdraw : (v) => min(v fromSome(deposits[this], 0)),
      Repay    : (_) => 0,
      Borrow   : (_) => 0,
      Transfer : ({amt, to}) => v <= fromSome(deposits[this], 0) ? v : 0
    }),
    token
  ]
]);
```
Notice that the pay statement is of the form `[UInt, [UInt, Token]`. In Reach, this is how we specify that we want to transfer multiple tokens in one transaction. The second match statement has the necessary values that we pay in the case of each action. In the case of a deposit, the contract will transfers tokens to the participant, and in the case of a withdraw or a transfer, the candidate must pay an amount smaller than their deposits. In the case of the withdraw, the tokens are added back to the pool and for a transfer, they are sent to the target address.

Let's look at the logic for the token transfers -

```javascript
case Deposit:
  log("LenderPaid", [this, msg]);
  deposits[this] = fromSome(deposits[this], 0) + msg;

  if(msg <= balance(token))
  {
    transfer(msg, token).to(this);
    log("TokenBalance", [Deployer, balance(token)]);
  }

case Withdraw:
  const canWithdraw =
    (msg <= balance()) && (msg <= fromSome(deposits[this], 0));

  if(canWithdraw)
  {
    log("LenderWithdrew", [this, msg]);
    log("TokenBalance", [Deployer, balance(token)]);
    transfer(msg).to(this);
    deposits[this] = fromSome(deposits[this], 0) - msg;
  }

case Transfer:
  if(msg.amt <= fromSome(deposits[this], 0))
  {
    transfer(msg.amt, token).to(msg.to);
    deposits[this] = fromSome(deposits[this], 0) - msg.amt;
    deposits[msg.to] = fromSome(deposits[msg.to], 0) + msg.amt;
    Lender.interact.printTokenBalance(token);
  }
```
The case for the deposit and withdraw is straight-forward. We check the necessary conditions to perform the transactions, and transfer the tokens to the users. The transfer case is interesting. After checking the the initiating user has enough tokens, we transfer the tokens to the target address and update the deposits respectively.

Let's create the behaviors for this case -

```javascript
/* deposit behavior */
const depositAndTransfer = (addr) => {
  var x = 0;
  const f = () => {
    if(x % 2 === 0) {
      x = x + 1;
      return ['Deposit', 100];
    } else {
      x = x + 1;
      return ['Transfer', {amt: 10, to: addr}];
    }
  };

  return f;
};

await Promise.all([
  backend.Deployer(ctc0, {
    log: logReach(addrs)
  }),
  backend.Lender(ctcA, {
    getMsg: depositAndTransfer(accB.getAddress()),
    printTokenBalance: async (token) => log(`accA ${await stdlib.balanceOf(accA, token)} tokens`),
    informTokenId: async (token) => await accA.tokenAccept(token)
  }),
  backend.Lender(ctcB, {
    getMsg: depositAndTransfer(accA.getAddress()),
    printTokenBalance: async (token) => log(`accB ${await stdlib.balanceOf(accB, token)} tokens`),
    informTokenId: async (token) => await accB.tokenAccept(token)
  })
]);
```

Now we can observe the output -

```bash
...
[REACH] : Transaction by       : accA Deposit,100
[REACH] : Lender paid          : accA 100
[REACH] : Token balance        : acc0 900
...
[REACH] : Transaction by       : accA accB Transfer,10
...
[APP]   : accB 130 tokens
[APP]   : accB 240 tokens
[APP]   : accA 170 tokens
[APP]   : accA 160 tokens
...
```

Note how after the frist deposit by `accA`, the token balance for the pool went down by 100, the exact amount that `accA` deposited. Next, `accA` transfers 10 tokens to `accB` and we can see that `accB` goes up by 110 (10 from transfer and 100 from some deposit) and `accA` goes down by 10.

# 8. Implementing and testing the interest calculation logic
_Code can be found here - [step-6](https://github.com/anmolsahoo26/reach-lending-pool/tree/trunk/step-6)_

Finally, we implement the feature that lets us calculate how much interest a lender has earned on his deposits. Now since this involves time and Reach only gives us the `lastConsensusSecs`, we will have to play a small trick to work properly with this.

First we add some linear state to track the last deposit time and the interest earned for each participant -

```
/* additional linear state for interest calculation */
const lastDepositTime = new Map(UInt);
const lenderInterest = new Map(UInt);
```

Then we update the while loop -
```javascript
var [lastAddr, lastMsg] = [this, MaybeMsg.None(null)]
invariant(true)
while(true) {
  commit();
  ...
  [lastAddr, lastMsg] = [this, MaybeMsg.Some(msg)]
}
```

We create two loop variables called `lastAddr` and `lastMsg`. These let us track who the participant in the last consensus transfer was and what action they took. Note that in each iteration, we first commit the consensus transfer, thus `lastConsensusSecs` will exactly correspond to the `lastAddr` and `lastMsg` that were used in the last consensus transfer. Finally, everytime we continue the loop, we update the loop variables to the current participant and message, which once committed in the next iteration, can be used with the last consensus time.

Then we implement the calculation logic -

```javascript
/* interest calculation */
if(isSome(lastMsg)) {
  const lastMsgVal = fromSome(lastMsg, Msg.Deposit(0));
  switch(lastMsgVal) {
    case Deposit:
      const addrDeposit = deposits[lastAddr];
      const addrLastDepositTime = lastDepositTime[lastAddr];
      lastDepositTime[lastAddr] = lastConsensusSecs();

      if(isSome(addrLastDepositTime)) {
        const principal = fromSome(addrDeposit, 0) - lastMsgVal;
        const time = (lastConsensusSecs() - fromSome(addrLastDepositTime, 0))
        const rate = 1;
        const interest = principal * rate * time;
        lenderInterest[lastAddr] = fromSome(lenderInterest[lastAddr],0) + interest;
        log("InterestEarned", [lastAddr, interest]);
        log("TotalInterest",  [lastAddr, lenderInterest[lastAddr]]);
      }
  }
}
```

In this piece, we first extract the last time we updated the transaction for the participant. We can then use lastConsensusSecs to calculate how long the principal was held for. Finally, we subtract the last deposit from the total deposit, as that will be counted in the next interest calculation period. With this information, can calculate the interest earned and we update the  last updated time to the last consensus time.

Let's write a simple behavior for this -

```javascript
...
/* deposit behavior */
const depositAndHold = () => {
  var x = 0;
  const f = () => {
    if(x === 0) {
      x = x + 1;
      return ['Deposit', 100];
    } else {
      return ['Deposit', 0];
    }
  };

  return f;
};

...

await Promise.all([
  backend.Deployer(ctc0, {
    log: logReach(addrs)
  }),
  backend.Lender(ctcA, {
    getMsg: depositAndHold(),
    printTokenBalance: async (token) => log(`accA ${await stdlib.balanceOf(accA, token)} tokens`),
    informTokenId: async (token) => await accA.tokenAccept(token)
  })
]);
```

Let's take a look at the output -

```bash
[REACH] : Transaction by       : accA Deposit,100
[REACH] : Lender paid          : accA 100
[REACH] : Token balance        : acc0 900
...
[REACH] : Interest earned      : accA 2500
[REACH] : Total interest       : accA Some,2500
...
[REACH] : Interest earned      : accA 2500
[REACH] : Total interest       : accA Some,5000
...
```

We can see that every transaction cycle, the participant is earning a constant interest from their holdings.

# 9. Thanks!
If you stuck around till the end (and even if you didn't), I really appreciate
you taking the time out for reading this. Hope you learnt something new!

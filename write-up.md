# 1. Discuss the setup of the Reach program
We will first start by discussing the high-level structure of the Reach program.
Don't worry, we will go into each block and complete it, this is just the
incomplete code to give an initial idea. Let's take a look below -

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

Let's take a look at the various sections. Note that each section will have
additional content, which we will discuss in the further sections.

1. In `section1`, we declare all the datatypes that we are using.
2. In `section2` we define some utility functions such as `min` to use in our
	 code.
3. In `section3` we specify the participant interfaces.
4. In `section4` we perform the first consensus publication so we can create
	 the necessary linear state and tokens needed for the transactions.
5. In `section5` we execute a while loop which will take care of the
	 transactions and represents the core of the program.

Hopefully that gave you a broad idea of how the code is structured, so lets
start coding now and take a look at each of the sections in details.

# 2. Initial scaffolding and participant interfaces
_Code can be found here - [step-0](https://github.com/anmolsahoo25/reach-lending-pool/tree/trunk/step-0)_

Let's start by setting up a minimal Reach file. Open up `index.rsh` and type
the following -

```javascript
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
1. Let's discuss the datatype declarations first. We create a datatype `Msg`
which we use to encode the various messages that the participants can send.
As these are tagged unions, they also carry extra information, such as the
amount deposited, which address to transfer etc. We also declare a `MaybeMsg`
type to denote an optional message value.
2. Next, we create the participant interfaces. We have a participant called 
`Depositor` who is in-charge of deploying the application and logging functions.
Then we create two `ParticipantClasses` named as `Lender` and `Borrower`, who
serve to function as agents who deposit and borrow money respectively with
functions for retrieving their actions each consensus transfer. Note that
being `ParticipantClasses` instead of `Participants` allows us to reference
multiple agents in one transaction (not used in this tutorial, but might be
useful for future applications). At the same, `ParticipantClasses` cannot
deploy applications, hence we need a special `Deployer` class.
3. Then we deploy the application and create the first consensus transfer with
an empty publication from the `Deployer`. In this consensus transfer, we create
the linear state that we will be using to track the deposits and borrows named
as `deposits` and `loans` and commit the transaction.
4. Finally, we start another consensus transfer so that we can start the core
while loop of our program. As of now we put in an empty invariant and the
`while` loop runs forever. We have also not declared any loop variables 
as of yet.

Run `reach compile index.rsh` on this file and you should get a compiled version
of this code, which passes the verifier.

Let's discuss the structure of our application a bit. In this code, each
iteration of the while loop corresponds to a race between the `Lenders` and
`Borrowers`. Depending on the actions produced by the winning agent, 
we update the necessary state variables for the agent and the contract. Thus,
it makes it easy to write (and verify) each step of the contract.

# 3. Front-end setup in Javascript
_Code can be found here - [step-1](https://github.com/anmolsahoo25/reach-lending-pool/tree/trunk/step-1)_
In this section, we can run our code (finally) to check if we have setup
everything correctly. We can write a minimal front-end in Javascript. Open
up `index.mjs` and input the following code -

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
```

We create some logging functions (the logging function is not the cleanest, sorry!),
create an account and create a Deployer participant. Hopefully, there is nothing
much to explain here, but if you feel like you are missing something you can refer
to the Reach tutorial here - [Scaffolding and Setup](https://docs.reach.sh/tut-2.html).

We also add a logging function in `index.rsh` and this line of code - 

```javascript
/* first consensus for setup */
Deployer.publish();
logMsg("FirstTransaction", [this]);
```

Run `reach run` and if everything was successful, you should see this output -

`bash
[APP]   : Starting application
[APP]   : acc0 (0x52b6f077fa97bd4bf467ce46e2c693590f1ac72b2cc62403bd5fd2668a0cd7cf) 1000000000 microALGO
[REACH] : First publication by : acc0
`
As we can, we first log from the frontend and the first publication from Reach.
So far, so good!

# 4. Implementing the core transaction loop

# 5. Implementing and testing the logic for lending users

# 6. Implementing and testing the logic for borrowing users

# 7. Implementing and testing the debt tokenization

# 8. Implementing and testing the interest calculation logic

# 9. Thanks!

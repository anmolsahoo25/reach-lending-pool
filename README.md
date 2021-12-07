# Reach Lending Pool Tutorial

This is a tutorial on constructing a basic lending pool in Reach. A lending
pool is a smart contract that allows users to deposit and borrow money. It
keeps track of the amounts deposited and borrowed and the interest earned
on the same. As an added bonus, it is possible to completely tokenize this
debt by using non-network tokens (ASA's on Algorand or ERC-20 on Ethereum).

The agenda of the tutorial is as follows - 


1. Discuss the setup of the Reach program
2. Initial scaffolding and participant interfaces
3. Front-end setup in Javascript
4. Implementing the core transaction loop
5. Implementing and testing the logic for lending users
6. Implementing and testing the logic for borrowing users
7. Implementing and testing the debt tokenization
8. Implementing and testing the interest calculation logic
9. Thanks!

DISCLAIMER: Please note that is only a tutorial and not meant to be used
in the real-world. The code has not been tested or audited for vulnerabilities.

# To run the project
```shell
npm i
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost
```

## Then copy the contract address in the inteactWithContract.js (contractAddress)
After that, run
```shell
npx hardhat run scripts/interactWithContract.js --network localhost
```

# Sample Hardhat Project

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```

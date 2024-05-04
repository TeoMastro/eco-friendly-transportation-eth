async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await ethers.provider.getBalance(deployer.address)).toString());

    try {
        const Contract = await ethers.getContractFactory("EcoFriendlyRewards");
        const contract = await Contract.deploy();
        console.log("Contract address:", contract.target);
    } catch (error) {
        console.error("Deployment Error:", error.message);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("Unhandled Error:", error);
        process.exit(1);
    });

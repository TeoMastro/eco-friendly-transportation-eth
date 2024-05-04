async function main() {
    const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Address after deploying the contract.
    const [owner] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("EcoFriendlyRewards");
    const ecoFriendlyRewards = await Contract.attach(contractAddress);

    // Register businesses
    await ecoFriendlyRewards.registerBusiness("Store1", 101);
    await ecoFriendlyRewards.registerBusiness("Store2", 102);

    // Register users and vehicles
    await ecoFriendlyRewards.registerUser("Alice", 1);
    await ecoFriendlyRewards.registerVehicle(1, "Tesla", "Model 3", 0); // Electric
    await ecoFriendlyRewards.registerUser("Bob", 2);
    await ecoFriendlyRewards.registerVehicle(2, "Toyota", "Prius", 1); // Hybrid
    await ecoFriendlyRewards.registerUser("Charlie", 3);
    await ecoFriendlyRewards.registerVehicle(3, "Honda", "Civic", 2); // Low Emission
    await ecoFriendlyRewards.registerUser("Mary", 4);
    await ecoFriendlyRewards.registerUser("Nick", 5);
    await ecoFriendlyRewards.registerUser("Lisa", 6);
    await ecoFriendlyRewards.registerUser("Maria", 7);
    await ecoFriendlyRewards.registerUser("Chris", 8);
    await ecoFriendlyRewards.registerUser("Christina", 9);
    await ecoFriendlyRewards.registerUser("Teo", 10);


    // Report mileage
    await ecoFriendlyRewards.reportMileage(1, 14000); // Tesla Model 3
    await ecoFriendlyRewards.reportMileage(2, 15500); // Toyota Prius
    await ecoFriendlyRewards.reportMileage(3, 16000); // Honda Civic

    // Redeem points
    await ecoFriendlyRewards.redeemPoints(1, 101, 800);  // Alice tries to redeem at Store1
    await ecoFriendlyRewards.redeemPoints(2, 102, 600);  // Bob tries to redeem at Store2
    await ecoFriendlyRewards.redeemPoints(3, 101, 200);  // Charlie tries to redeem at Store1

    // Display top 10 users
    try {
        const topUsers = await ecoFriendlyRewards.getTop10Users();
        console.log(topUsers);
    } catch (error) {
        console.error("Error fetching top users:", error);
    }

    // Pause and unpause the system
    await ecoFriendlyRewards.pauseSystem();
    await ecoFriendlyRewards.unpauseSystem();
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

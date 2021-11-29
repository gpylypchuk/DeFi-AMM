const deploy = async () => {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contract with the account: ", deployer.address);

    const PlatziPunks = await ethers.getContractFactory("ScamCoin");
    const deployed = await PlatziPunks.deploy(10000);

    console.log("Deployed at: ", deployed.address);
}

deploy()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error);
        process.exit(1);
    });
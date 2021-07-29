const Web3 = require("web3")
const web3 = new Web3("https://cloudflare-eth.com");
const { EscrowArtifact } = require('./artifacts');

export const getWeb3 = () => {
    return new Promise((resolve, reject) => {
        window.addEventListener("load", async () => {
            if (window.ethereum) {
                const web3 = new Web3(window.ethereum);
                try {
                    // ask user permission to access his accounts
                    await window.ethereum.request({ method: "eth_requestAccounts" });
                    resolve(web3);
                } catch (error) {
                    reject(error);
                }
            } else {
                reject("Must install MetaMask");
            }
        });
    });
};

export const getContract = async (web3) => {
    const data = EscrowArtifact;

    const netId = await web3.eth.net.getId();
    const deployedNetwork = data.networks[netId];
    const contract = new web3.eth.Contract(
        data.abi,
        deployedNetwork && deployedNetwork.address
    );
    return contract;
};

export const getBlockNumber = async () => {
    const latestBlockNumber = await web3.eth.getBlockNumber();
    console.log(latestBlockNumber);
    return latestBlockNumber
}

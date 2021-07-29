import { getBlockNumber } from '../utils/web3';
import {
    getWeb3,
    getContract
} from '../utils/web3';

let web3, accounts, contract;

const getWeb3Context = async () => {
    web3 = await getWeb3();
    accounts = await web3.eth.getAccounts();
    contract = await getContract(web3);
}

function Landing() {
    getWeb3Context().then();

    return (
        <div>
            Block { }
        </div>
    );
}

export default Landing;

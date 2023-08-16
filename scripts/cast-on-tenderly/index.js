import 'dotenv/config';
import axios from 'axios';
import { Contract, ethers } from 'ethers';

const NETWORK_ID = 5;
const CHIEF_ADDRESS = '0x33Ed584fc655b08b2bca45E1C5b5f07c98053bC1';
const DEFAULT_TRANSACTION_PARAMETERS = { gasLimit: 1000000000 };

// check env vars
const REQUIRED_ENV_VARS = ['TENDERLY_USER', 'TENDERLY_PROJECT', 'TENDERLY_ACCESS_KEY'];
if (REQUIRED_ENV_VARS.some(varName => !process.env[varName])) {
    throw new Error(`Please provide all required env variables: ${REQUIRED_ENV_VARS.join(', ')}`);
}

// check process arguments
const SPELL_ADDRESS = process.argv[2];
if (!SPELL_ADDRESS) {
    throw new Error('Please provide address of the spell, e.g.: `node index.js 0x...`');
}

const createNewFork = async function () {
    const response = await axios.post(
        `https://api.tenderly.co/api/v1/account/${process.env.TENDERLY_USER}/project/${process.env.TENDERLY_PROJECT}/fork`,
        {
            network_id: NETWORK_ID,
        },
        {
            headers: {
                'X-Access-Key': process.env.TENDERLY_ACCESS_KEY,
            },
        }
    );
    const forkId = response.data.simulation_fork.id;
    const rpcUrl = `https://rpc.tenderly.co/fork/${forkId}`;
    const forkUrl = `https://dashboard.tenderly.co/${process.env.TENDERLY_USER}/${process.env.TENDERLY_PROJECT}/fork/${forkId}`;
    return { forkUrl, rpcUrl };
};

const runSpell = async function () {
    const { forkUrl, rpcUrl } = await createNewFork();
    console.info('tenderly fork is created', forkUrl);

    const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
    const signer = provider.getSigner();

    console.info('getting the hat...');
    await provider.send('tenderly_setStorageAt', [
        CHIEF_ADDRESS,
        ethers.utils.hexZeroPad(ethers.utils.hexValue(12), 32),
        ethers.utils.hexZeroPad(SPELL_ADDRESS, 32),
    ]);

    console.info('checking the hat...');
    const chief = new Contract(CHIEF_ADDRESS, ['function hat() external view returns (address)'], signer);
    const hat = await chief.hat();
    if (hat !== SPELL_ADDRESS) {
        throw new Error('spell does not have the hat');
    }

    console.info('scheduling spell on a fork...');
    const spell = new Contract(SPELL_ADDRESS, ['function schedule() external', 'function cast() external'], signer);
    const scheduleTx = await spell.schedule(DEFAULT_TRANSACTION_PARAMETERS);
    await scheduleTx.wait();

    console.info('warping the time...');
    await provider.send('evm_increaseTime', [ethers.utils.hexValue(60)]);

    console.info('casting spell on a fork...');
    const castTx = await spell.cast(DEFAULT_TRANSACTION_PARAMETERS);
    await castTx.wait();

    console.info('sucessfully casted');
};

runSpell();
